import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../../goal_planner/data/micro_goals_engine.dart';
import '../domain/bingo_model.dart';
import 'providers/bingo_provider.dart';

class BingoScreen extends HookConsumerWidget {
  const BingoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final cards = ref.watch(activeCharBingoProvider);
    final selectedCardId = useState<String?>(null);
    final hiscoreState = ref.watch(hiscoresProvider);

    // Build player levels
    final playerLevels = <String, int>{};
    hiscoreState.whenData((result) {
      if (result != null) {
        for (final entry in result.skills.entries) {
          if (entry.value.level > 0) {
            playerLevels[entry.key] = entry.value.level;
          }
        }
      }
    });

    // Auto-select first card
    if (selectedCardId.value == null && cards.isNotEmpty) {
      selectedCardId.value = cards.first.id;
    }
    // Clear selection if card was deleted
    if (selectedCardId.value != null &&
        !cards.any((c) => c.id == selectedCardId.value)) {
      selectedCardId.value = cards.isNotEmpty ? cards.first.id : null;
    }

    final selectedCard = selectedCardId.value != null
        ? cards.cast<BingoCard?>().firstWhere(
            (c) => c!.id == selectedCardId.value,
            orElse: () => null)
        : null;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text('Bingo',
                    style: Theme.of(context).textTheme.headlineMedium),
                if (activeChar != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(activeChar.displayName,
                        style: const TextStyle(
                            color: Color(0xFFD4A017), fontSize: 12)),
                  ),
                ],
                const Spacer(),
                if (selectedCard != null) ...[
                  // Auto-check from hiscores
                  if (playerLevels.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _autoCheck(ref, selectedCard, playerLevels),
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('Auto-Check'),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _shareCard(context, selectedCard),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  onPressed: activeChar == null
                      ? null
                      : () => _showImportDialog(
                          context, ref, activeChar.id, selectedCardId),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Import'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: activeChar == null
                      ? null
                      : () => _showNewCardDialog(context, ref, activeChar.id,
                          selectedCardId, playerLevels),
                  icon: const Icon(Icons.add),
                  label: const Text('New Card'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: activeChar == null
                  ? const Center(
                      child: Text('Create a character first',
                          style: TextStyle(color: Colors.white54)))
                  : cards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.grid_view_rounded,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 12),
                              const Text('No bingo cards yet',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 14)),
                              const SizedBox(height: 4),
                              const Text(
                                  'Create a card to start tracking goals!',
                                  style: TextStyle(
                                      color: Colors.white30, fontSize: 12)),
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card list sidebar
                            SizedBox(
                              width: 200,
                              child: Card(
                                child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  children: [
                                    for (final card in cards)
                                      _CardListTile(
                                        card: card,
                                        isSelected:
                                            card.id == selectedCardId.value,
                                        onTap: () =>
                                            selectedCardId.value = card.id,
                                        onDelete: () {
                                          ref
                                              .read(bingoProvider.notifier)
                                              .delete(card.id);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Bingo grid
                            if (selectedCard != null)
                              Expanded(
                                child: _BingoGrid(
                                  card: selectedCard,
                                  onToggleCell: (i) => ref
                                      .read(bingoProvider.notifier)
                                      .toggleCell(selectedCard.id, i),
                                  onEditCell: (i) => _showEditCellDialog(
                                      context, ref, selectedCard, i),
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoCheck(WidgetRef ref, BingoCard card, Map<String, int> levels) {
    final cells = List<BingoCell>.from(card.cells);
    bool changed = false;
    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i];
      if (cell.completed || cell.text == 'FREE') continue;
      if (cell.skillName != null && cell.targetLevel != null) {
        final playerLevel = levels[cell.skillName] ?? 1;
        if (playerLevel >= cell.targetLevel!) {
          cells[i] = cell.copyWith(completed: true);
          changed = true;
        }
      }
    }
    if (changed) {
      ref.read(bingoProvider.notifier).update(card.copyWith(cells: cells));
    }
  }

  void _showNewCardDialog(
      BuildContext context,
      WidgetRef ref,
      String characterId,
      ValueNotifier<String?> selectedCardId,
      Map<String, int> playerLevels) {
    showDialog(
      context: context,
      builder: (ctx) => _NewCardDialog(
        playerLevels: playerLevels,
        onCreated: (title, size, template) {
          final card = template ??
              BingoCard.createEmpty(
                characterId: characterId,
                title: title,
                size: size,
              );
          final finalCard = card.copyWith(title: title);
          ref.read(bingoProvider.notifier).add(
                BingoCard(
                  characterId: characterId,
                  title: finalCard.title,
                  size: finalCard.size,
                  cells: finalCard.cells,
                ),
              );
        },
      ),
    );
  }

  void _showEditCellDialog(
      BuildContext context, WidgetRef ref, BingoCard card, int cellIndex) {
    final cell = card.cells[cellIndex];
    if (cell.text == 'FREE') return;
    showDialog(
      context: context,
      builder: (ctx) => _EditCellDialog(
        cell: cell,
        onSave: (updated) {
          final cells = List<BingoCell>.from(card.cells);
          cells[cellIndex] = updated;
          ref.read(bingoProvider.notifier).update(card.copyWith(cells: cells));
        },
      ),
    );
  }

  void _shareCard(BuildContext context, BingoCard card) {
    final code = card.toShareCode();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share Bingo Card'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send this code to a friend so they can import your card layout.\nProgress is not included — they\'ll get a fresh card.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.white70),
                  maxLines: 6,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share code copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref,
      String characterId, ValueNotifier<String?> selectedCardId) {
    showDialog(
      context: context,
      builder: (ctx) => _ImportCardDialog(
        onImport: (card) {
          final imported = BingoCard(
            characterId: characterId,
            title: card.title,
            size: card.size,
            cells: card.cells,
          );
          ref.read(bingoProvider.notifier).add(imported);
          selectedCardId.value = imported.id;
        },
        characterId: characterId,
      ),
    );
  }
}

// ─── Card List Tile ──────────────────────────────────

class _CardListTile extends StatelessWidget {
  final BingoCard card;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardListTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? const Color(0xFFD4A017).withValues(alpha: 0.12)
          : Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFD4A017)
                                : Colors.white70),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('${card.size}×${card.size}',
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white30)),
                        const SizedBox(width: 6),
                        Text('${card.completedCount}/${card.totalCells} done',
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white30)),
                        if (card.bingoCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A017)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text('${card.bingoCount} BINGO',
                                style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD4A017))),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 14),
                color: Colors.white24,
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete card',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bingo Grid ──────────────────────────────────────

class _BingoGrid extends StatelessWidget {
  final BingoCard card;
  final void Function(int) onToggleCell;
  final void Function(int) onEditCell;

  const _BingoGrid({
    required this.card,
    required this.onToggleCell,
    required this.onEditCell,
  });

  @override
  Widget build(BuildContext context) {
    final completedLines = card.completedLines;
    final completedCellsInLines = <int>{};
    for (final line in completedLines) {
      completedCellsInLines.addAll(line);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats bar
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(card.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4A017))),
                const Spacer(),
                _StatBadge(
                    label: 'Completed',
                    value: '${card.completedCount}/${card.totalCells}'),
                const SizedBox(width: 8),
                _StatBadge(
                    label: 'Bingos',
                    value: '${card.bingoCount}',
                    color:
                        card.bingoCount > 0 ? const Color(0xFFD4A017) : null),
                if (card.isBlackout) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A017), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.black87),
                        SizedBox(width: 4),
                        Text('BLACKOUT!',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: card.progressPercent,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD4A017)),
            ),
          ),
          const SizedBox(height: 16),

          // The grid
          LayoutBuilder(builder: (context, constraints) {
            final maxGridSize = min(constraints.maxWidth, 600.0);
            final cellSize = (maxGridSize - (card.size - 1) * 4) / card.size;

            return Center(
              child: SizedBox(
                width: maxGridSize,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: card.size,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: card.totalCells,
                  itemBuilder: (context, i) {
                    if (i >= card.cells.length) {
                      return const SizedBox();
                    }
                    final cell = card.cells[i];
                    final isInBingoLine = completedCellsInLines.contains(i);
                    final isFree = cell.text == 'FREE';
                    final isEmpty = cell.text.isEmpty;

                    return _BingoCellWidget(
                      cell: cell,
                      cellSize: cellSize,
                      isInBingoLine: isInBingoLine,
                      isFree: isFree,
                      isEmpty: isEmpty,
                      onTap: () {
                        if (isEmpty) {
                          onEditCell(i);
                        } else {
                          onToggleCell(i);
                        }
                      },
                      onLongPress: () => onEditCell(i),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BingoCellWidget extends StatelessWidget {
  final BingoCell cell;
  final double cellSize;
  final bool isInBingoLine;
  final bool isFree;
  final bool isEmpty;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BingoCellWidget({
    required this.cell,
    required this.cellSize,
    required this.isInBingoLine,
    required this.isFree,
    required this.isEmpty,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isFree) {
      bgColor = const Color(0xFFD4A017).withValues(alpha: 0.2);
      borderColor = const Color(0xFFD4A017).withValues(alpha: 0.5);
      textColor = const Color(0xFFD4A017);
    } else if (cell.completed && isInBingoLine) {
      bgColor = const Color(0xFFD4A017).withValues(alpha: 0.25);
      borderColor = const Color(0xFFD4A017);
      textColor = const Color(0xFFD4A017);
    } else if (cell.completed) {
      bgColor = const Color(0xFF43A047).withValues(alpha: 0.2);
      borderColor = const Color(0xFF43A047).withValues(alpha: 0.6);
      textColor = const Color(0xFF43A047);
    } else if (isEmpty) {
      bgColor = Colors.white.withValues(alpha: 0.02);
      borderColor = Colors.white.withValues(alpha: 0.08);
      textColor = Colors.white24;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.04);
      borderColor = Colors.white.withValues(alpha: 0.12);
      textColor = Colors.white70;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isInBingoLine ? 2 : 1),
        ),
        child: Stack(
          children: [
            // Completed check
            if (cell.completed && !isFree)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle,
                    size: 14,
                    color: isInBingoLine
                        ? const Color(0xFFD4A017)
                        : const Color(0xFF43A047)),
              ),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: isEmpty
                    ? Icon(Icons.add,
                        size: 18, color: Colors.white.withValues(alpha: 0.15))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isFree)
                            const Icon(Icons.star,
                                size: 20, color: Color(0xFFD4A017)),
                          if (cell.skillName != null && !isFree) ...[
                            Icon(
                              Icons.trending_up,
                              size: 14,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            cell.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: cellSize > 100 ? 11 : 9,
                              fontWeight: isFree || cell.completed
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: textColor,
                              decoration: cell.completed && !isFree
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatBadge({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white38)),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color ?? Colors.white70)),
        ],
      ),
    );
  }
}

// ─── New Card Dialog ─────────────────────────────────

const _skillNames = [
  'Attack',
  'Defence',
  'Strength',
  'Hitpoints',
  'Ranged',
  'Prayer',
  'Magic',
  'Cooking',
  'Woodcutting',
  'Fletching',
  'Fishing',
  'Firemaking',
  'Crafting',
  'Smithing',
  'Mining',
  'Herblore',
  'Agility',
  'Thieving',
  'Slayer',
  'Farming',
  'Runecraft',
  'Hunter',
  'Construction',
];

class _NewCardDialog extends HookWidget {
  final void Function(String title, int size, BingoCard? template) onCreated;
  final Map<String, int> playerLevels;

  const _NewCardDialog({required this.onCreated, this.playerLevels = const {}});

  @override
  Widget build(BuildContext context) {
    final titleCtrl = useTextEditingController(text: 'My Bingo Card');
    final size = useState(5);
    final template = useState<String>('empty');

    return AlertDialog(
      title: const Text('New Bingo Card'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Card Title'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Grid Size: ', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 3, label: Text('3×3')),
                    ButtonSegment(value: 4, label: Text('4×4')),
                    ButtonSegment(value: 5, label: Text('5×5')),
                  ],
                  selected: {size.value},
                  onSelectionChanged: (s) => size.value = s.first,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: template.value,
              decoration: const InputDecoration(labelText: 'Template'),
              items: const [
                DropdownMenuItem(
                    value: 'empty',
                    child: Text('Empty — fill in your own goals')),
                DropdownMenuItem(
                    value: 'skills', child: Text('Random Skill Levels')),
                DropdownMenuItem(
                    value: 'mixed',
                    child: Text('Mixed Goals (skills + quests + items)')),
                DropdownMenuItem(
                    value: 'training', child: Text('From Training Plan')),
              ],
              onChanged: (v) => template.value = v ?? 'empty',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final title = titleCtrl.text.trim();
            if (title.isEmpty) return;

            BingoCard? tpl;
            if (template.value == 'skills') {
              tpl = _generateSkillTemplate(size.value);
            } else if (template.value == 'mixed') {
              tpl = _generateMixedTemplate(size.value);
            } else if (template.value == 'training') {
              tpl = _generateTrainingPlanTemplate(size.value);
            }

            onCreated(title, size.value, tpl);
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  BingoCard _generateSkillTemplate(int size) {
    final rng = Random();
    final totalCells = size * size;
    final center = totalCells ~/ 2;
    final levels = [50, 60, 70, 75, 80, 85, 90, 92, 95, 99];
    final shuffledSkills = List.of(_skillNames)..shuffle(rng);

    final cells = List.generate(totalCells, (i) {
      if (i == center) return BingoCell.free;
      final skill = shuffledSkills[i % shuffledSkills.length];
      final level = levels[rng.nextInt(levels.length)];
      return BingoCell(
        text: '$level $skill',
        skillName: skill,
        targetLevel: level,
      );
    });
    return BingoCard(
      characterId: '',
      title: '',
      size: size,
      cells: cells,
    );
  }

  BingoCard _generateTrainingPlanTemplate(int size) {
    final rng = Random();
    final totalCells = size * size;
    final center = totalCells ~/ 2;

    // Generate goals from the micro goals engine using player levels
    final effectiveLevels = playerLevels.isNotEmpty
        ? playerLevels
        : {for (final s in _skillNames) s: 1};

    final microGoals = MicroGoalsEngine.generateGoals(
      playerLevels: effectiveLevels,
      maxGoalsPerSkill: 3,
    );

    final quickWins = MicroGoalsEngine.getQuickWins(
      playerLevels: effectiveLevels,
      maxHours: 10,
    );

    final sessionGoals = MicroGoalsEngine.generateSessionGoals(
      playerLevels: effectiveLevels,
    );

    final cells = <BingoCell>[];

    // Mix: milestone goals + session goals
    final milestonePool = <BingoCell>[];
    for (final g in microGoals) {
      milestonePool.add(BingoCell(
        text: '${g.targetLevel} ${g.skill}',
        skillName: g.skill,
        targetLevel: g.targetLevel,
      ));
    }

    final sessionPool = <BingoCell>[];
    for (final s in sessionGoals) {
      sessionPool.add(BingoCell(
        text: s.description,
        skillName: s.skill,
      ));
    }

    final quickWinPool = <BingoCell>[];
    for (final g in quickWins) {
      final desc =
          '${g.milestone} (${MicroGoalsEngine.formatHours(g.estimatedHours)})';
      quickWinPool.add(BingoCell(
        text: desc,
        skillName: g.skill,
        targetLevel: g.targetLevel,
      ));
    }

    // Combine pools: prioritize milestone goals, mix in sessions
    milestonePool.shuffle(rng);
    sessionPool.shuffle(rng);
    quickWinPool.shuffle(rng);

    // Fill cells: ~60% milestones, ~25% sessions, ~15% quick wins
    final neededCells = totalCells - 1; // minus FREE space
    final milestoneCount =
        (neededCells * 0.6).ceil().clamp(0, milestonePool.length);
    final sessionCount =
        (neededCells * 0.25).ceil().clamp(0, sessionPool.length);
    final quickWinCount = (neededCells - milestoneCount - sessionCount)
        .clamp(0, quickWinPool.length);

    cells.addAll(milestonePool.take(milestoneCount));
    cells.addAll(sessionPool.take(sessionCount));
    cells.addAll(quickWinPool.take(quickWinCount));

    // If we still need more, pad with remaining from any pool
    final remaining = [
      ...milestonePool.skip(milestoneCount),
      ...sessionPool.skip(sessionCount),
      ...quickWinPool.skip(quickWinCount)
    ];
    remaining.shuffle(rng);
    while (cells.length < neededCells && remaining.isNotEmpty) {
      cells.add(remaining.removeAt(0));
    }
    // Pad with empty cells if all pools exhausted
    while (cells.length < neededCells) {
      cells.add(const BingoCell(text: ''));
    }

    cells.shuffle(rng);

    // Deduplicate skill names in adjacent cells by re-shuffling
    final usedSkills = <String>{};
    final deduped = <BingoCell>[];
    for (final c in cells) {
      if (c.skillName != null && usedSkills.contains(c.text)) continue;
      usedSkills.add(c.text);
      deduped.add(c);
    }
    while (deduped.length < neededCells) {
      deduped.add(const BingoCell(text: ''));
    }

    final finalCells = List.generate(totalCells, (i) {
      if (i == center) return BingoCell.free;
      final idx = i < center ? i : i - 1;
      return idx < deduped.length ? deduped[idx] : const BingoCell(text: '');
    });

    return BingoCard(
      characterId: '',
      title: '',
      size: size,
      cells: finalCells,
    );
  }

  BingoCard _generateMixedTemplate(int size) {
    final rng = Random();
    final totalCells = size * size;
    final center = totalCells ~/ 2;
    final goals = <BingoCell>[];

    final skillGoals = <BingoCell>[];
    final levels = [50, 60, 70, 75, 80, 85, 90, 99];
    final shuffledSkills = List.of(_skillNames)..shuffle(rng);
    for (int i = 0; i < 10; i++) {
      final skill = shuffledSkills[i % shuffledSkills.length];
      final level = levels[rng.nextInt(levels.length)];
      skillGoals.add(BingoCell(
        text: '$level $skill',
        skillName: skill,
        targetLevel: level,
      ));
    }

    final otherGoals = [
      const BingoCell(text: 'Fire Cape'),
      const BingoCell(text: 'Barrows Gloves'),
      const BingoCell(text: 'Quest Cape'),
      const BingoCell(text: 'Dragon Defender'),
      const BingoCell(text: 'Complete a Hard Diary'),
      const BingoCell(text: 'Fighter Torso'),
      const BingoCell(text: '1000 Total Level'),
      const BingoCell(text: '1500 Total Level'),
      const BingoCell(text: '2000 Total Level'),
      const BingoCell(text: 'Infernal Cape'),
      const BingoCell(text: '100 Combat Level'),
      const BingoCell(text: 'Void Knight Set'),
      const BingoCell(text: 'Full Graceful'),
      const BingoCell(text: 'Finish Recipe for Disaster'),
      const BingoCell(text: 'Complete a Medium Diary'),
    ];
    otherGoals.shuffle(rng);

    goals.addAll(skillGoals);
    goals.addAll(otherGoals);
    goals.shuffle(rng);

    final cells = List.generate(totalCells, (i) {
      if (i == center) return BingoCell.free;
      return i < goals.length ? goals[i] : const BingoCell(text: '');
    });
    return BingoCard(
      characterId: '',
      title: '',
      size: size,
      cells: cells,
    );
  }
}

// ─── Edit Cell Dialog ────────────────────────────────

class _ImportCardDialog extends HookWidget {
  final void Function(BingoCard) onImport;
  final String characterId;

  const _ImportCardDialog({
    required this.onImport,
    required this.characterId,
  });

  @override
  Widget build(BuildContext context) {
    final codeCtrl = useTextEditingController();
    final error = useState<String?>(null);
    final preview = useState<BingoCard?>(null);

    void tryParse() {
      final code = codeCtrl.text.trim();
      if (code.isEmpty) {
        error.value = null;
        preview.value = null;
        return;
      }
      final card = BingoCard.fromShareCode(code, characterId: characterId);
      if (card == null) {
        error.value = 'Invalid share code. Check that you pasted it correctly.';
        preview.value = null;
      } else {
        error.value = null;
        preview.value = card;
      }
    }

    return AlertDialog(
      title: const Text('Import Bingo Card'),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste a share code from a friend to import their bingo card layout.',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(
                labelText: 'Share code',
                hintText: 'Paste code here...',
                errorText: error.value,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, size: 18),
                  tooltip: 'Paste from clipboard',
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      codeCtrl.text = data!.text!;
                      tryParse();
                    }
                  },
                ),
              ),
              maxLines: 4,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              onChanged: (_) => tryParse(),
            ),
            if (preview.value != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF43A047).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 18, color: Color(0xFF43A047)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preview.value!.title,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${preview.value!.size}×${preview.value!.size} card · ${preview.value!.cells.where((c) => c.text.isNotEmpty).length} goals',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: preview.value == null
              ? null
              : () {
                  onImport(preview.value!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Imported "${preview.value!.title}" !'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Import'),
        ),
      ],
    );
  }
}

// ─── Edit Cell Dialog ────────────────────────────────

class _EditCellDialog extends HookWidget {
  final BingoCell cell;
  final void Function(BingoCell) onSave;

  const _EditCellDialog({required this.cell, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final textCtrl = useTextEditingController(text: cell.text);
    final isSkillGoal = useState(cell.skillName != null);
    final selectedSkill = useState(cell.skillName ?? _skillNames.first);
    final levelCtrl =
        useTextEditingController(text: cell.targetLevel?.toString() ?? '99');

    return AlertDialog(
      title: const Text('Edit Cell'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textCtrl,
              decoration: const InputDecoration(
                labelText: 'Goal text',
                hintText: 'e.g. 99 Cooking, Fire Cape, etc.',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Skill level goal',
                  style: TextStyle(fontSize: 13)),
              subtitle: const Text('Auto-check from hiscores',
                  style: TextStyle(fontSize: 10, color: Colors.white38)),
              value: isSkillGoal.value,
              onChanged: (v) {
                isSkillGoal.value = v;
                if (v) {
                  textCtrl.text = '${levelCtrl.text} ${selectedSkill.value}';
                }
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            if (isSkillGoal.value) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSkill.value,
                      decoration: const InputDecoration(
                          labelText: 'Skill', isDense: true),
                      items: _skillNames
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) {
                        selectedSkill.value = v ?? _skillNames.first;
                        textCtrl.text =
                            '${levelCtrl.text} ${selectedSkill.value}';
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: levelCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Level', isDense: true),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        textCtrl.text = '$v ${selectedSkill.value}';
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        if (cell.text.isNotEmpty)
          TextButton(
            onPressed: () {
              onSave(const BingoCell(text: ''));
              Navigator.of(context).pop();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(
          onPressed: () {
            final text = textCtrl.text.trim();
            if (text.isEmpty) return;
            onSave(BingoCell(
              text: text,
              completed: cell.completed,
              skillName: isSkillGoal.value ? selectedSkill.value : null,
              targetLevel:
                  isSkillGoal.value ? int.tryParse(levelCtrl.text) : null,
            ));
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
