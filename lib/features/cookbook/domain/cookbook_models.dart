import 'package:uuid/uuid.dart';

enum CookbookMode { main, iron, hcim, uim, gim, custom }

enum StepCategory { quest, skilling, combat, prep, travel, banking, custom }

class CookbookTemplate {
  final String id;
  final String title;
  final String description;
  final CookbookMode mode;
  final List<String> tags;
  final String version;
  final String author;
  final List<CookbookSection> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  CookbookTemplate({
    String? id,
    required this.title,
    this.description = '',
    this.mode = CookbookMode.iron,
    this.tags = const [],
    this.version = '1.0',
    this.author = 'Local',
    this.sections = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get totalSteps => sections.fold(0, (sum, s) => sum + s.steps.length);

  CookbookTemplate copyWith({
    String? title, String? description, CookbookMode? mode,
    List<String>? tags, String? version, String? author,
    List<CookbookSection>? sections, DateTime? updatedAt,
  }) {
    return CookbookTemplate(
      id: id, title: title ?? this.title, description: description ?? this.description,
      mode: mode ?? this.mode, tags: tags ?? this.tags, version: version ?? this.version,
      author: author ?? this.author, sections: sections ?? this.sections,
      createdAt: createdAt, updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'description': description, 'mode': mode.name,
        'tags': tags, 'version': version, 'author': author,
        'sections': sections.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
      };

  factory CookbookTemplate.fromJson(Map<String, dynamic> json) => CookbookTemplate(
        id: json['id'] as String, title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        mode: CookbookMode.values.firstWhere((e) => e.name == json['mode'], orElse: () => CookbookMode.iron),
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        version: json['version'] as String? ?? '1.0', author: json['author'] as String? ?? '',
        sections: (json['sections'] as List<dynamic>?)?.map((s) => CookbookSection.fromJson(s as Map<String, dynamic>)).toList() ?? [],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );
}

class CookbookSection {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<CookbookStep> steps;

  CookbookSection({
    String? id, required this.title, this.description = '',
    this.order = 0, this.steps = const [],
  }) : id = id ?? const Uuid().v4();

  CookbookSection copyWith({String? title, String? description, int? order, List<CookbookStep>? steps}) {
    return CookbookSection(id: id, title: title ?? this.title, description: description ?? this.description,
      order: order ?? this.order, steps: steps ?? this.steps);
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'description': description, 'order': order,
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory CookbookSection.fromJson(Map<String, dynamic> json) => CookbookSection(
        id: json['id'] as String, title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '', order: json['order'] as int? ?? 0,
        steps: (json['steps'] as List<dynamic>?)?.map((s) => CookbookStep.fromJson(s as Map<String, dynamic>)).toList() ?? [],
      );
}

class CookbookStep {
  final String id;
  final int order;
  final String title;
  final String description;
  final String? location;
  final List<String> requirements;
  final int? estimatedMinutes;
  final StepCategory category;
  final String notes;
  final List<String> links;

  CookbookStep({
    String? id, this.order = 0, required this.title, this.description = '',
    this.location, this.requirements = const [], this.estimatedMinutes,
    this.category = StepCategory.custom, this.notes = '', this.links = const [],
  }) : id = id ?? const Uuid().v4();

  CookbookStep copyWith({
    int? order, String? title, String? description, String? location,
    List<String>? requirements, int? estimatedMinutes, StepCategory? category,
    String? notes, List<String>? links,
  }) {
    return CookbookStep(
      id: id, order: order ?? this.order, title: title ?? this.title,
      description: description ?? this.description, location: location ?? this.location,
      requirements: requirements ?? this.requirements, estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      category: category ?? this.category, notes: notes ?? this.notes, links: links ?? this.links,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'order': order, 'title': title, 'description': description,
        'location': location, 'requirements': requirements, 'estimatedMinutes': estimatedMinutes,
        'category': category.name, 'notes': notes, 'links': links,
      };

  factory CookbookStep.fromJson(Map<String, dynamic> json) => CookbookStep(
        id: json['id'] as String, order: json['order'] as int? ?? 0,
        title: json['title'] as String? ?? '', description: json['description'] as String? ?? '',
        location: json['location'] as String?, requirements: (json['requirements'] as List<dynamic>?)?.cast<String>() ?? [],
        estimatedMinutes: json['estimatedMinutes'] as int?,
        category: StepCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => StepCategory.custom),
        notes: json['notes'] as String? ?? '', links: (json['links'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

class CookbookProgress {
  final String templateId;
  final String characterId;
  final Set<String> completedStepIds;
  final String? lastViewedStepId;
  final DateTime startedAt;
  final DateTime updatedAt;

  CookbookProgress({
    required this.templateId, required this.characterId,
    this.completedStepIds = const {}, this.lastViewedStepId,
    DateTime? startedAt, DateTime? updatedAt,
  })  : startedAt = startedAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CookbookProgress copyWith({Set<String>? completedStepIds, String? lastViewedStepId, DateTime? updatedAt}) {
    return CookbookProgress(
      templateId: templateId, characterId: characterId,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      lastViewedStepId: lastViewedStepId ?? this.lastViewedStepId,
      startedAt: startedAt, updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'templateId': templateId, 'characterId': characterId,
        'completedStepIds': completedStepIds.toList(), 'lastViewedStepId': lastViewedStepId,
        'startedAt': startedAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
      };

  factory CookbookProgress.fromJson(Map<String, dynamic> json) => CookbookProgress(
        templateId: json['templateId'] as String, characterId: json['characterId'] as String,
        completedStepIds: (json['completedStepIds'] as List<dynamic>?)?.cast<String>().toSet() ?? {},
        lastViewedStepId: json['lastViewedStepId'] as String?,
        startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );
}
