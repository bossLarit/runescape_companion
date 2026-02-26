import 'package:uuid/uuid.dart';

enum GoalType { xp, item, gp, kc, quest, custom }

enum GoalStatus { active, completed, paused, abandoned }

enum GoalPriority { low, medium, high, critical }

class Goal {
  final String id;
  final String characterId;
  final String title;
  final String description;
  final GoalType type;
  final double targetValue;
  final double currentValue;
  final String unit;
  final GoalPriority priority;
  final DateTime? deadline;
  final GoalStatus status;
  final int estimatedMinutes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    String? id,
    required this.characterId,
    required this.title,
    this.description = '',
    this.type = GoalType.custom,
    this.targetValue = 0,
    this.currentValue = 0,
    this.unit = '',
    this.priority = GoalPriority.medium,
    this.deadline,
    this.status = GoalStatus.active,
    this.estimatedMinutes = 0,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progressPercent {
    if (targetValue <= 0) return status == GoalStatus.completed ? 100 : 0;
    return ((currentValue / targetValue) * 100).clamp(0, 100);
  }

  bool get isComplete => status == GoalStatus.completed || progressPercent >= 100;

  Goal copyWith({
    String? characterId,
    String? title,
    String? description,
    GoalType? type,
    double? targetValue,
    double? currentValue,
    String? unit,
    GoalPriority? priority,
    DateTime? deadline,
    GoalStatus? status,
    int? estimatedMinutes,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id,
      characterId: characterId ?? this.characterId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'title': title,
        'description': description,
        'type': type.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unit': unit,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'status': status.name,
        'estimatedMinutes': estimatedMinutes,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      characterId: json['characterId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.custom,
      ),
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => GoalPriority.medium,
      ),
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'] as String) : null,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}
