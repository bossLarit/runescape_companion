enum EnergyLevel { low, medium, high }

enum PlayStyle { afk, active, profit, progression, chill, custom }

class TimeBudgetRequest {
  final String? characterId;
  final int availableMinutes;
  final EnergyLevel energyLevel;
  final PlayStyle playStyle;
  final bool includePrepTasks;

  const TimeBudgetRequest({
    this.characterId,
    this.availableMinutes = 60,
    this.energyLevel = EnergyLevel.medium,
    this.playStyle = PlayStyle.active,
    this.includePrepTasks = false,
  });

  TimeBudgetRequest copyWith({
    String? characterId,
    int? availableMinutes,
    EnergyLevel? energyLevel,
    PlayStyle? playStyle,
    bool? includePrepTasks,
  }) {
    return TimeBudgetRequest(
      characterId: characterId ?? this.characterId,
      availableMinutes: availableMinutes ?? this.availableMinutes,
      energyLevel: energyLevel ?? this.energyLevel,
      playStyle: playStyle ?? this.playStyle,
      includePrepTasks: includePrepTasks ?? this.includePrepTasks,
    );
  }
}

class SuggestedTask {
  final String id;
  final String title;
  final String description;
  final String sourceType;
  final int estimatedMinutesMin;
  final int estimatedMinutesMax;
  final EnergyLevel intensity;
  final List<String> tags;
  final String expectedOutcome;
  final int confidenceScore;
  final List<String> whySuggested;
  final String? characterId;

  const SuggestedTask({
    required this.id,
    required this.title,
    this.description = '',
    this.sourceType = 'manualTemplate',
    this.estimatedMinutesMin = 0,
    this.estimatedMinutesMax = 0,
    this.intensity = EnergyLevel.medium,
    this.tags = const [],
    this.expectedOutcome = '',
    this.confidenceScore = 50,
    this.whySuggested = const [],
    this.characterId,
  });
}
