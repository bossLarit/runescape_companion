import 'package:uuid/uuid.dart';

enum SessionType { bossing, skilling, slayer, questing, custom }

class GameSession {
  final String id;
  final String characterId;
  final SessionType type;
  final String notes;
  final DateTime startTime;
  final DateTime? endTime;
  final double xpGained;
  final double lootValue;
  final int killCount;
  final int? durationOverrideMinutes;
  final List<String> tags;
  final DateTime createdAt;

  GameSession({
    String? id,
    required this.characterId,
    this.type = SessionType.custom,
    this.notes = '',
    DateTime? startTime,
    this.endTime,
    this.xpGained = 0,
    this.lootValue = 0,
    this.killCount = 0,
    this.durationOverrideMinutes,
    this.tags = const [],
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  bool get isActive => endTime == null;

  Duration get duration {
    if (durationOverrideMinutes != null) {
      return Duration(minutes: durationOverrideMinutes!);
    }
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get durationFormatted {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  GameSession copyWith({
    String? characterId,
    SessionType? type,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    double? xpGained,
    double? lootValue,
    int? killCount,
    int? durationOverrideMinutes,
    List<String>? tags,
  }) {
    return GameSession(
      id: id,
      characterId: characterId ?? this.characterId,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      xpGained: xpGained ?? this.xpGained,
      lootValue: lootValue ?? this.lootValue,
      killCount: killCount ?? this.killCount,
      durationOverrideMinutes: durationOverrideMinutes ?? this.durationOverrideMinutes,
      tags: tags ?? this.tags,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'type': type.name,
        'notes': notes,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'xpGained': xpGained,
        'lootValue': lootValue,
        'killCount': killCount,
        'durationOverrideMinutes': durationOverrideMinutes,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      characterId: json['characterId'] as String? ?? '',
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.custom,
      ),
      notes: json['notes'] as String? ?? '',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'] as String) : null,
      xpGained: (json['xpGained'] as num?)?.toDouble() ?? 0,
      lootValue: (json['lootValue'] as num?)?.toDouble() ?? 0,
      killCount: json['killCount'] as int? ?? 0,
      durationOverrideMinutes: json['durationOverrideMinutes'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }
}
