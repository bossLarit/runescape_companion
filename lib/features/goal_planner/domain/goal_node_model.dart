import 'package:uuid/uuid.dart';

enum GoalNodeType { quest, skill, item, gp, kc, unlock, custom }

enum GoalNodeStatus { locked, available, inProgress, completed, blocked }

enum DependencyRelation { requires, recommendedBefore, blockedBy }

class GoalNode {
  final String id;
  final String characterId;
  final String title;
  final String description;
  final GoalNodeType type;
  final GoalNodeStatus status;
  final double? targetValue;
  final double? currentValue;
  final String unit;
  final int? estimatedMinutes;
  final GoalPlannerPriority priority;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalNode({
    String? id,
    required this.characterId,
    required this.title,
    this.description = '',
    this.type = GoalNodeType.custom,
    this.status = GoalNodeStatus.available,
    this.targetValue,
    this.currentValue,
    this.unit = '',
    this.estimatedMinutes,
    this.priority = GoalPlannerPriority.medium,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progressPercent {
    if (targetValue == null || targetValue == 0) return status == GoalNodeStatus.completed ? 100 : 0;
    return (((currentValue ?? 0) / targetValue!) * 100).clamp(0, 100);
  }

  GoalNode copyWith({
    String? characterId,
    String? title,
    String? description,
    GoalNodeType? type,
    GoalNodeStatus? status,
    double? targetValue,
    double? currentValue,
    String? unit,
    int? estimatedMinutes,
    GoalPlannerPriority? priority,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return GoalNode(
      id: id,
      characterId: characterId ?? this.characterId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priority: priority ?? this.priority,
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
        'status': status.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unit': unit,
        'estimatedMinutes': estimatedMinutes,
        'priority': priority.name,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GoalNode.fromJson(Map<String, dynamic> json) => GoalNode(
        id: json['id'] as String,
        characterId: json['characterId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        type: GoalNodeType.values.firstWhere((e) => e.name == json['type'], orElse: () => GoalNodeType.custom),
        status: GoalNodeStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => GoalNodeStatus.available),
        targetValue: (json['targetValue'] as num?)?.toDouble(),
        currentValue: (json['currentValue'] as num?)?.toDouble(),
        unit: json['unit'] as String? ?? '',
        estimatedMinutes: json['estimatedMinutes'] as int?,
        priority: GoalPlannerPriority.values.firstWhere((e) => e.name == json['priority'], orElse: () => GoalPlannerPriority.medium),
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );
}

enum GoalPlannerPriority { low, medium, high, critical }

class GoalDependency {
  final String id;
  final String parentGoalId;
  final String dependencyGoalId;
  final DependencyRelation relationType;
  final String note;

  GoalDependency({
    String? id,
    required this.parentGoalId,
    required this.dependencyGoalId,
    this.relationType = DependencyRelation.requires,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentGoalId': parentGoalId,
        'dependencyGoalId': dependencyGoalId,
        'relationType': relationType.name,
        'note': note,
      };

  factory GoalDependency.fromJson(Map<String, dynamic> json) => GoalDependency(
        id: json['id'] as String,
        parentGoalId: json['parentGoalId'] as String? ?? '',
        dependencyGoalId: json['dependencyGoalId'] as String? ?? '',
        relationType: DependencyRelation.values.firstWhere((e) => e.name == json['relationType'], orElse: () => DependencyRelation.requires),
        note: json['note'] as String? ?? '',
      );
}
