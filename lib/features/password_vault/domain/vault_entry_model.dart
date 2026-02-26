import 'package:uuid/uuid.dart';

class VaultEntry {
  final String id;
  final String title;
  final String category;
  final String username;
  final String password;
  final String email;
  final String url;
  final String character;
  final String notes;
  final List<String> tags;
  final Map<String, String> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultEntry({
    String? id,
    this.title = '',
    this.category = '',
    this.username = '',
    this.password = '',
    this.email = '',
    this.url = '',
    this.character = '',
    this.notes = '',
    this.tags = const [],
    this.customFields = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  VaultEntry copyWith({
    String? title,
    String? category,
    String? username,
    String? password,
    String? email,
    String? url,
    String? character,
    String? notes,
    List<String>? tags,
    Map<String, String>? customFields,
    DateTime? updatedAt,
  }) {
    return VaultEntry(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      url: url ?? this.url,
      character: character ?? this.character,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'username': username,
        'password': password,
        'email': email,
        'url': url,
        'character': character,
        'notes': notes,
        'tags': tags,
        'customFields': customFields,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      email: json['email'] as String? ?? '',
      url: json['url'] as String? ?? '',
      character: json['character'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      customFields: (json['customFields'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}

enum VaultStatus { locked, unlocked, noVault }

class VaultState {
  final VaultStatus status;
  final List<VaultEntry> entries;
  final String? error;

  const VaultState({
    this.status = VaultStatus.noVault,
    this.entries = const [],
    this.error,
  });

  VaultState copyWith({
    VaultStatus? status,
    List<VaultEntry>? entries,
    String? error,
  }) {
    return VaultState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      error: error,
    );
  }
}
