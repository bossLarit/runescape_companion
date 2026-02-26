import 'dart:math';

import 'time_budget_models.dart';
import '../../goals/domain/goal_model.dart';

class SuggestionEngine {
  static const _defaultTemplates = <SuggestedTask>[
    SuggestedTask(id: 't1', title: 'Birdhouse runs', description: 'Quick passive hunter XP', sourceType: 'manualTemplate', estimatedMinutesMin: 5, estimatedMinutesMax: 10, intensity: EnergyLevel.low, tags: ['afk', 'skilling', 'hunter'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't2', title: 'Farm run', description: 'Herb + tree patches', sourceType: 'manualTemplate', estimatedMinutesMin: 10, estimatedMinutesMax: 20, intensity: EnergyLevel.low, tags: ['afk', 'skilling', 'farming'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't3', title: 'Slayer task', description: 'Work on current slayer assignment', sourceType: 'manualTemplate', estimatedMinutesMin: 30, estimatedMinutesMax: 90, intensity: EnergyLevel.medium, tags: ['active', 'slayer', 'combat'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't4', title: 'Vorkath', description: 'Money dragon farming', sourceType: 'manualTemplate', estimatedMinutesMin: 30, estimatedMinutesMax: 120, intensity: EnergyLevel.high, tags: ['active', 'bossing', 'profit'], expectedOutcome: 'gp'),
    SuggestedTask(id: 't5', title: 'Motherlode Mine', description: 'AFK mining XP', sourceType: 'manualTemplate', estimatedMinutesMin: 15, estimatedMinutesMax: 120, intensity: EnergyLevel.low, tags: ['afk', 'skilling', 'mining'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't6', title: 'Blast Furnace', description: 'Smithing XP and profit', sourceType: 'manualTemplate', estimatedMinutesMin: 30, estimatedMinutesMax: 60, intensity: EnergyLevel.medium, tags: ['active', 'skilling', 'profit'], expectedOutcome: 'gp'),
    SuggestedTask(id: 't7', title: 'Quest progression', description: 'Work on next quest in line', sourceType: 'manualTemplate', estimatedMinutesMin: 15, estimatedMinutesMax: 120, intensity: EnergyLevel.high, tags: ['active', 'questing', 'progression'], expectedOutcome: 'unlock'),
    SuggestedTask(id: 't8', title: 'NMZ training', description: 'AFK melee training', sourceType: 'manualTemplate', estimatedMinutesMin: 20, estimatedMinutesMax: 120, intensity: EnergyLevel.low, tags: ['afk', 'combat'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't9', title: 'Woodcutting', description: 'AFK woodcutting at best tree', sourceType: 'manualTemplate', estimatedMinutesMin: 15, estimatedMinutesMax: 120, intensity: EnergyLevel.low, tags: ['afk', 'skilling'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't10', title: 'Zulrah', description: 'Profit snake', sourceType: 'manualTemplate', estimatedMinutesMin: 30, estimatedMinutesMax: 120, intensity: EnergyLevel.high, tags: ['active', 'bossing', 'profit'], expectedOutcome: 'gp'),
    SuggestedTask(id: 't11', title: 'Bank standing skills', description: 'Fletching, herblore, crafting', sourceType: 'manualTemplate', estimatedMinutesMin: 10, estimatedMinutesMax: 60, intensity: EnergyLevel.low, tags: ['afk', 'skilling', 'chill'], expectedOutcome: 'xp'),
    SuggestedTask(id: 't12', title: 'Diary tasks', description: 'Work on achievement diary reqs', sourceType: 'manualTemplate', estimatedMinutesMin: 30, estimatedMinutesMax: 120, intensity: EnergyLevel.medium, tags: ['active', 'progression'], expectedOutcome: 'unlock'),
  ];

  List<SuggestedTask> generateSuggestions({
    required TimeBudgetRequest request,
    List<Goal> activeGoals = const [],
    int limit = 5,
  }) {
    final candidates = <_ScoredTask>[];

    // Score default templates
    for (final template in _defaultTemplates) {
      final score = _scoreTask(template, request);
      if (score > 0) {
        candidates.add(_ScoredTask(task: template, score: score));
      }
    }

    // Score tasks derived from active goals
    for (final goal in activeGoals) {
      if (goal.status != GoalStatus.active) continue;
      final task = SuggestedTask(
        id: 'goal_${goal.id}',
        title: 'Work on: ${goal.title}',
        description: goal.description,
        sourceType: 'goal',
        estimatedMinutesMin: goal.estimatedMinutes > 0 ? (goal.estimatedMinutes * 0.5).round() : 15,
        estimatedMinutesMax: goal.estimatedMinutes > 0 ? goal.estimatedMinutes : 60,
        intensity: _goalIntensity(goal),
        tags: goal.tags,
        expectedOutcome: goal.type.name,
        confidenceScore: 70,
        whySuggested: ['Active goal', 'Priority: ${goal.priority.name}'],
        characterId: goal.characterId,
      );
      final score = _scoreTask(task, request) + _goalPriorityBonus(goal);
      if (score > 0) {
        candidates.add(_ScoredTask(task: task, score: score));
      }
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));

    final results = candidates.take(limit).map((c) => c.task).toList();

    // Add fallback if not enough
    if (results.length < 2) {
      results.add(const SuggestedTask(
        id: 'fallback',
        title: 'Bank organization',
        description: 'Sort your bank, plan next steps',
        sourceType: 'manualTemplate',
        estimatedMinutesMin: 5,
        estimatedMinutesMax: 30,
        intensity: EnergyLevel.low,
        tags: ['chill', 'prep'],
        expectedOutcome: 'progress',
        confidenceScore: 30,
        whySuggested: ['Fallback suggestion', 'Always useful'],
      ));
    }

    return results;
  }

  double _scoreTask(SuggestedTask task, TimeBudgetRequest request) {
    double score = 50;

    // Time match
    if (task.estimatedMinutesMax <= request.availableMinutes) {
      score += 20;
    } else if (task.estimatedMinutesMin <= request.availableMinutes) {
      score += 10;
    } else {
      score -= 30; // Task takes longer than available
    }

    // Energy match
    if (task.intensity == request.energyLevel) {
      score += 15;
    } else if ((task.intensity.index - request.energyLevel.index).abs() == 1) {
      score += 5;
    } else {
      score -= 10;
    }

    // PlayStyle match
    final styleTag = request.playStyle.name.toLowerCase();
    if (task.tags.any((t) => t.toLowerCase() == styleTag)) {
      score += 20;
    }

    // Prep task bonus
    if (request.includePrepTasks && task.tags.contains('prep')) {
      score += 10;
    }

    // Recency penalty (simple random jitter to avoid repetition)
    score += Random().nextDouble() * 5;

    return max(0, score);
  }

  EnergyLevel _goalIntensity(Goal goal) {
    switch (goal.type) {
      case GoalType.quest:
        return EnergyLevel.high;
      case GoalType.kc:
        return EnergyLevel.high;
      case GoalType.xp:
        return EnergyLevel.medium;
      case GoalType.gp:
        return EnergyLevel.medium;
      case GoalType.item:
        return EnergyLevel.medium;
      case GoalType.custom:
        return EnergyLevel.medium;
    }
  }

  double _goalPriorityBonus(Goal goal) {
    switch (goal.priority) {
      case GoalPriority.critical:
        return 25;
      case GoalPriority.high:
        return 15;
      case GoalPriority.medium:
        return 5;
      case GoalPriority.low:
        return 0;
    }
  }
}

class _ScoredTask {
  final SuggestedTask task;
  final double score;
  const _ScoredTask({required this.task, required this.score});
}
