import 'dart:convert';
import 'package:uuid/uuid.dart';

class BingoCell {
  final String text;
  final bool completed;
  final String? skillName;
  final int? targetLevel;

  const BingoCell({
    required this.text,
    this.completed = false,
    this.skillName,
    this.targetLevel,
  });

  BingoCell copyWith({
    String? text,
    bool? completed,
    String? skillName,
    int? targetLevel,
  }) {
    return BingoCell(
      text: text ?? this.text,
      completed: completed ?? this.completed,
      skillName: skillName ?? this.skillName,
      targetLevel: targetLevel ?? this.targetLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'completed': completed,
        if (skillName != null) 'skillName': skillName,
        if (targetLevel != null) 'targetLevel': targetLevel,
      };

  factory BingoCell.fromJson(Map<String, dynamic> json) {
    return BingoCell(
      text: json['text'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      skillName: json['skillName'] as String?,
      targetLevel: json['targetLevel'] as int?,
    );
  }

  static const BingoCell free = BingoCell(text: 'FREE', completed: true);
}

class BingoCard {
  final String id;
  final String characterId;
  final String title;
  final int size; // 3, 4, or 5
  final List<BingoCell> cells;
  final DateTime createdAt;
  final DateTime updatedAt;

  BingoCard({
    String? id,
    required this.characterId,
    required this.title,
    this.size = 5,
    required this.cells,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get totalCells => size * size;
  int get completedCount => cells.where((c) => c.completed).length;
  double get progressPercent =>
      totalCells > 0 ? completedCount / totalCells : 0;

  List<List<int>> get bingoLines {
    final lines = <List<int>>[];
    // Rows
    for (int r = 0; r < size; r++) {
      lines.add(List.generate(size, (c) => r * size + c));
    }
    // Columns
    for (int c = 0; c < size; c++) {
      lines.add(List.generate(size, (r) => r * size + c));
    }
    // Diagonals
    lines.add(List.generate(size, (i) => i * size + i));
    lines.add(List.generate(size, (i) => i * size + (size - 1 - i)));
    return lines;
  }

  List<List<int>> get completedLines {
    return bingoLines.where((line) {
      return line.every((i) => i < cells.length && cells[i].completed);
    }).toList();
  }

  int get bingoCount => completedLines.length;
  bool get isBlackout => completedCount == totalCells;

  BingoCard copyWith({
    String? title,
    int? size,
    List<BingoCell>? cells,
    DateTime? updatedAt,
  }) {
    return BingoCard(
      id: id,
      characterId: characterId,
      title: title ?? this.title,
      size: size ?? this.size,
      cells: cells ?? this.cells,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'title': title,
        'size': size,
        'cells': cells.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BingoCard.fromJson(Map<String, dynamic> json) {
    return BingoCard(
      id: json['id'] as String,
      characterId: json['characterId'] as String? ?? '',
      title: json['title'] as String? ?? 'Bingo Card',
      size: json['size'] as int? ?? 5,
      cells: (json['cells'] as List<dynamic>?)
              ?.map((c) => BingoCell.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // ── Sharing ────────────────────────────────────────

  /// Export only the card layout (no progress, no IDs).
  Map<String, dynamic> toShareJson() => {
        'v': 1,
        't': title,
        's': size,
        'c': cells.map((c) {
          final m = <String, dynamic>{'x': c.text};
          if (c.skillName != null) m['sk'] = c.skillName;
          if (c.targetLevel != null) m['lv'] = c.targetLevel;
          return m;
        }).toList(),
      };

  /// Encode to a shareable string.
  String toShareCode() {
    final json = jsonEncode(toShareJson());
    return base64Url.encode(utf8.encode(json));
  }

  /// Decode a share code into a fresh BingoCard (no progress).
  static BingoCard? fromShareCode(String code, {required String characterId}) {
    try {
      final json = jsonDecode(utf8.decode(base64Url.decode(code.trim())))
          as Map<String, dynamic>;
      final size = json['s'] as int? ?? 5;
      final title = json['t'] as String? ?? 'Shared Card';
      final rawCells = json['c'] as List<dynamic>? ?? [];
      final cells = rawCells.map((e) {
        final m = e as Map<String, dynamic>;
        final text = m['x'] as String? ?? '';
        return BingoCell(
          text: text,
          completed: text == 'FREE',
          skillName: m['sk'] as String?,
          targetLevel: m['lv'] as int?,
        );
      }).toList();
      return BingoCard(
        characterId: characterId,
        title: title,
        size: size,
        cells: cells,
      );
    } catch (_) {
      return null;
    }
  }

  static BingoCard createEmpty({
    required String characterId,
    String title = 'New Bingo Card',
    int size = 5,
  }) {
    final cells = List.generate(size * size, (i) {
      if (i == (size * size) ~/ 2) return BingoCell.free;
      return const BingoCell(text: '');
    });
    return BingoCard(
      characterId: characterId,
      title: title,
      size: size,
      cells: cells,
    );
  }
}
