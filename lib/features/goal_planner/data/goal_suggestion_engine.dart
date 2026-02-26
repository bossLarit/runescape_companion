import 'osrs_goals_data.dart';

enum GoalReadiness { ready, almostReady, workTowards }

class ScoredGoal {
  final OsrsGoal goal;
  final GoalReadiness readiness;
  final double completionPercent; // 0-100 how close player is to meeting reqs
  final Map<String, SkillGap> skillGaps; // skills player still needs

  const ScoredGoal({
    required this.goal,
    required this.readiness,
    required this.completionPercent,
    required this.skillGaps,
  });

  List<SkillGap> get missingSkills =>
      skillGaps.values.where((g) => g.gap > 0).toList()
        ..sort((a, b) => b.gap.compareTo(a.gap));
}

class SkillGap {
  final String skill;
  final int required;
  final int current;

  const SkillGap({
    required this.skill,
    required this.required,
    required this.current,
  });

  int get gap => (required - current).clamp(0, 99);
  bool get met => current >= required;
}

class GoalSuggestionEngine {
  /// Analyze player stats and score all goals.
  static List<ScoredGoal> analyzeGoals({
    required Map<String, int> playerLevels,
    required Set<String> completedGoalIds,
  }) {
    final results = <ScoredGoal>[];

    for (final goal in osrsGoals) {
      if (completedGoalIds.contains(goal.id)) continue;

      final gaps = <String, SkillGap>{};
      int metCount = 0;
      int totalReqs = goal.skillRequirements.length;

      for (final entry in goal.skillRequirements.entries) {
        final skill = entry.key;
        final required = entry.value;
        final current = playerLevels[skill] ?? 1;

        gaps[skill] = SkillGap(
          skill: skill,
          required: required,
          current: current,
        );

        if (current >= required) metCount++;
      }

      double completionPct;
      GoalReadiness readiness;

      if (totalReqs == 0) {
        // No skill requirements — always available
        completionPct = 100;
        readiness = GoalReadiness.ready;
      } else {
        // Calculate weighted completion based on XP distance
        double totalWeight = 0;
        double metWeight = 0;
        for (final g in gaps.values) {
          final w = g.required.toDouble();
          totalWeight += w;
          metWeight += (g.current.clamp(1, g.required) / g.required) * w;
        }
        completionPct = totalWeight > 0 ? (metWeight / totalWeight) * 100 : 0;

        if (metCount == totalReqs) {
          readiness = GoalReadiness.ready;
        } else if (completionPct >= 80) {
          readiness = GoalReadiness.almostReady;
        } else {
          readiness = GoalReadiness.workTowards;
        }
      }

      results.add(ScoredGoal(
        goal: goal,
        readiness: readiness,
        completionPercent: completionPct,
        skillGaps: gaps,
      ));
    }

    return results;
  }

  /// Get suggested goals sorted by relevance.
  static List<ScoredGoal> getSuggestions({
    required Map<String, int> playerLevels,
    required Set<String> completedGoalIds,
    GoalCategory? category,
    GoalReadiness? readinessFilter,
    int limit = 50,
  }) {
    var scored = analyzeGoals(
      playerLevels: playerLevels,
      completedGoalIds: completedGoalIds,
    );

    if (category != null) {
      scored = scored.where((s) => s.goal.category == category).toList();
    }
    if (readinessFilter != null) {
      scored = scored.where((s) => s.readiness == readinessFilter).toList();
    }

    // Sort: ready first, then by priority (high first), then by completion %
    scored.sort((a, b) {
      final ra = a.readiness.index;
      final rb = b.readiness.index;
      if (ra != rb) return ra.compareTo(rb);

      final pa = a.goal.priority;
      final pb = b.goal.priority;
      if (pa != pb) return pb.compareTo(pa);

      return b.completionPercent.compareTo(a.completionPercent);
    });

    return scored.take(limit).toList();
  }

  /// Build a player level map from hiscores skill map.
  static Map<String, int> levelsFromHiscoreMap(Map<String, dynamic> skillMap) {
    final map = <String, int>{};
    for (final entry in skillMap.entries) {
      final val = entry.value;
      if (val is int) {
        map[entry.key] = val;
      } else if (val != null && val.level != null) {
        map[entry.key] = (val.level as int?) ?? 1;
      }
    }
    return map;
  }
}
