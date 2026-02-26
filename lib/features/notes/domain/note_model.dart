import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String? characterId;
  final String title;
  final String content;
  final List<String> tags;
  final String category;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    String? id,
    this.characterId,
    required this.title,
    this.content = '',
    this.tags = const [],
    this.category = '',
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isGlobal => characterId == null || characterId!.isEmpty;

  Note copyWith({
    String? characterId,
    String? title,
    String? content,
    List<String>? tags,
    String? category,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      characterId: characterId ?? this.characterId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'title': title,
        'content': content,
        'tags': tags,
        'category': category,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      characterId: json['characterId'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String? ?? '',
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}
