import 'dart:math';
import 'training_methods_data.dart';

// XP table for OSRS levels 1-99
const List<int> _xpTable = [
  0, 0, 83, 174, 276, 388, 512, 650, 801, 969, 1154, // 0-10
  1358, 1584, 1833, 2107, 2411, 2746, 3115, 3523, 3973, 4470, // 11-20
  5018, 5624, 6291, 7028, 7842, 8740, 9730, 10824, 12031, 13363, // 21-30
  14833, 16456, 18247, 20224, 22406, 24815, 27473, 30408, 33648, 37224, // 31-40
  41171, 45529, 50339, 55649, 61512, 67983, 75127, 83014, 91721,
  101333, // 41-50
  111945, 123660, 136594, 150872, 166636, 184040, 203254, 224466, 247886,
  273742, // 51-60
  302288, 333804, 368599, 407015, 449428, 496254, 547953, 605032, 668051,
  737627, // 61-70
  814445, 899257, 992895, 1096278, 1210421, 1336443, 1475581, 1629200, 1798808,
  1986068, // 71-80
  2192818, 2421087, 2673114, 2951373, 3258594, 3597792, 3972294, 4385776,
  4842295, 5346332, // 81-90
  5902831, 6517253, 7195629, 7944614, 8771558, 9684577, 10692629, 11805606,
  13034431, // 91-99
];

int xpForLevel(int level) {
  if (level < 1) return 0;
  if (level > 99) return _xpTable[99];
  return _xpTable[level];
}

int xpBetween(int fromLevel, int toLevel) {
  return xpForLevel(toLevel) - xpForLevel(fromLevel);
}

class MicroGoal {
  final String skill;
  final int currentLevel;
  final int targetLevel;
  final String milestone; // what unlocks at target level
  final TrainingMethod bestMethod;
  final int xpNeeded;
  final double estimatedHours;
  final int priority; // 1-5, higher = train first

  const MicroGoal({
    required this.skill,
    required this.currentLevel,
    required this.targetLevel,
    required this.milestone,
    required this.bestMethod,
    required this.xpNeeded,
    required this.estimatedHours,
    required this.priority,
  });

  String get id => '${skill}_${currentLevel}_$targetLevel';
}

/// A bite-sized session goal like "Do 100 Seers' Village laps"
class SessionGoal {
  final String skill;
  final int currentLevel;
  final TrainingMethod method;
  final String description; // e.g. "Do 100 Seers' Village laps"
  final int xpGained;
  final double estimatedHours;

  const SessionGoal({
    required this.skill,
    required this.currentLevel,
    required this.method,
    required this.description,
    required this.xpGained,
    required this.estimatedHours,
  });

  String get id => '${skill}_session_${method.method.hashCode}_$currentLevel';
}

class MicroGoalsEngine {
  /// Generate personalized micro goals for each skill based on current levels.
  /// Returns goals sorted by efficiency (best XP/hr methods first, then priority).
  static List<MicroGoal> generateGoals({
    required Map<String, int> playerLevels,
    bool isIronman = false,
    Intensity intensityPref = Intensity.either,
    Set<String>? focusSkills,
    int maxGoalsPerSkill = 2,
  }) {
    final goals = <MicroGoal>[];

    for (final entry in trainingData.entries) {
      final skillName = entry.key;
      final info = entry.value;

      if (focusSkills != null && !focusSkills.contains(skillName)) continue;

      final currentLevel = playerLevels[skillName] ?? 1;
      if (currentLevel >= 99) continue;

      final milestones =
          _getNextMilestones(info, currentLevel, maxGoalsPerSkill);

      for (final targetLevel in milestones) {
        final method = info.bestMethodAt(currentLevel,
            isIronman: isIronman, pref: intensityPref);
        if (method == null) continue;

        final xpNeeded = xpBetween(currentLevel, targetLevel);
        final hours = method.xpPerHour > 0 ? xpNeeded / method.xpPerHour : 0.0;

        final unlockText = info.milestoneUnlock(targetLevel) ??
            'Level $targetLevel $skillName';

        int priority = _calculatePriority(
          skillName,
          currentLevel,
          targetLevel,
          method.xpPerHour,
          hours,
        );

        goals.add(MicroGoal(
          skill: skillName,
          currentLevel: currentLevel,
          targetLevel: targetLevel,
          milestone: unlockText,
          bestMethod: method,
          xpNeeded: xpNeeded,
          estimatedHours: hours,
          priority: priority,
        ));
      }
    }

    goals.sort((a, b) {
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);
      return a.estimatedHours.compareTo(b.estimatedHours);
    });

    return goals;
  }

  /// Get the top N recommended goals across all skills — the "what to do next" list.
  static List<MicroGoal> getTopRecommendations({
    required Map<String, int> playerLevels,
    bool isIronman = false,
    Intensity intensityPref = Intensity.either,
    int limit = 15,
  }) {
    final all = generateGoals(
      playerLevels: playerLevels,
      isIronman: isIronman,
      intensityPref: intensityPref,
      maxGoalsPerSkill: 1,
    );
    return all.take(limit).toList();
  }

  /// Get quick wins: goals achievable in under N hours.
  static List<MicroGoal> getQuickWins({
    required Map<String, int> playerLevels,
    bool isIronman = false,
    Intensity intensityPref = Intensity.either,
    double maxHours = 5.0,
  }) {
    final all = generateGoals(
      playerLevels: playerLevels,
      isIronman: isIronman,
      intensityPref: intensityPref,
      maxGoalsPerSkill: 3,
    );
    return all
        .where((g) => g.estimatedHours <= maxHours && g.estimatedHours > 0)
        .toList();
  }

  /// Generate bite-sized session goals for a specific skill.
  /// e.g. "Do 100 Seers' Village laps", "Mine 20 inventories of iron"
  static List<SessionGoal> generateSessionGoals({
    required Map<String, int> playerLevels,
    bool isIronman = false,
    Intensity intensityPref = Intensity.either,
    String? forSkill,
  }) {
    final sessions = <SessionGoal>[];

    for (final entry in trainingData.entries) {
      final skillName = entry.key;
      final info = entry.value;

      if (forSkill != null && forSkill != skillName) continue;

      final currentLevel = playerLevels[skillName] ?? 1;
      if (currentLevel >= 99) continue;

      final methods = info.allMethodsAt(currentLevel,
          isIronman: isIronman, pref: intensityPref);

      for (final m in methods) {
        if (m.xpPerHour <= 0) continue;
        final unit = m.sessionUnit;
        final amount = m.sessionAmount;
        final xpPer = m.xpPerAction;

        if (unit != null && amount != null && xpPer != null) {
          final totalXp = amount * xpPer;
          final hours = totalXp / m.xpPerHour;
          sessions.add(SessionGoal(
            skill: skillName,
            currentLevel: currentLevel,
            method: m,
            description: 'Do $amount $unit — ${m.method}',
            xpGained: totalXp,
            estimatedHours: hours,
          ));
        } else {
          // Fallback: suggest a 1-hour session
          sessions.add(SessionGoal(
            skill: skillName,
            currentLevel: currentLevel,
            method: m,
            description: '1 hour of ${m.method}',
            xpGained: m.xpPerHour,
            estimatedHours: 1.0,
          ));
        }
      }
    }

    return sessions;
  }

  static List<int> _getNextMilestones(
      SkillTrainingInfo info, int currentLevel, int count) {
    final milestones = <int>[];

    // First: check skill-specific milestones
    for (final m in info.milestones) {
      if (m.level > currentLevel && m.level <= 99) {
        milestones.add(m.level);
        if (milestones.length >= count) break;
      }
    }

    // If no milestone found, add default intervals
    if (milestones.isEmpty) {
      final next = info.nextMilestoneAfter(currentLevel);
      if (next != null) milestones.add(next);
    }

    return milestones;
  }

  static int _calculatePriority(
    String skill,
    int currentLevel,
    int targetLevel,
    int xpPerHour,
    double hours,
  ) {
    int priority = 3; // default medium

    // Combat skills and essential skills get priority boost
    const highPrioritySkills = {
      'Slayer',
      'Prayer',
      'Herblore',
      'Construction',
      'Attack',
      'Strength',
      'Defence',
      'Ranged',
      'Magic',
    };
    if (highPrioritySkills.contains(skill)) priority++;

    // Quick wins (< 3 hours) get priority boost
    if (hours > 0 && hours < 3) priority++;

    // Very fast methods get priority boost (feels rewarding)
    if (xpPerHour >= 200000) priority++;

    // Close to milestone (within 5 levels) gets boost
    if (targetLevel - currentLevel <= 5) priority++;

    // Low level skills that are behind get boost
    if (currentLevel < 50) priority = max(priority, 3);

    return priority.clamp(1, 5);
  }

  /// Calculate total time to max from current levels.
  static double hoursToMax(Map<String, int> playerLevels,
      {bool isIronman = false}) {
    double total = 0;
    for (final entry in trainingData.entries) {
      final skill = entry.key;
      final info = entry.value;
      final current = playerLevels[skill] ?? 1;
      if (current >= 99) continue;

      final method = info.bestMethodAt(current, isIronman: isIronman);
      if (method == null || method.xpPerHour == 0) continue;

      final xpNeeded = xpBetween(current, 99);
      total += xpNeeded / method.xpPerHour;
    }
    return total;
  }

  /// Format hours nicely.
  static String formatHours(double hours) {
    if (hours < 0.01) return 'Quest/instant';
    if (hours < 1) return '${(hours * 60).round()} min';
    if (hours < 24) return '${hours.toStringAsFixed(1)} hrs';
    final days = hours / 24;
    return '${days.toStringAsFixed(1)} days';
  }
}
