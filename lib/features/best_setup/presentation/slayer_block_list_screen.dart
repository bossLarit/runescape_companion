import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../data/slayer_block_list_data.dart';

class SlayerBlockListScreen extends HookWidget {
  const SlayerBlockListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMaster = useState(0);
    final master = slayerMasters[selectedMaster.value];
    final sortByWeight = useState(true);

    final tasks = sortByWeight.value
        ? (List<SlayerTaskWeight>.from(master.tasks)
          ..sort((a, b) => b.weight.compareTo(a.weight)))
        : List<SlayerTaskWeight>.from(master.tasks);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: Master selector ──
        SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Slayer Master',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4A017),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(slayerMasters.length, (i) {
                final m = slayerMasters[i];
                final isSelected = selectedMaster.value == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _MasterCard(
                    master: m,
                    isSelected: isSelected,
                    onTap: () => selectedMaster.value = i,
                  ),
                );
              }),
              const SizedBox(height: 16),

              // ── Recommended blocks ──
              const Text(
                'RECOMMENDED BLOCKS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE53935),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ...master.recommendedBlocks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.block, size: 12, color: Color(0xFFE53935)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF9A9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              if (master.recommendedSkips.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'RECOMMENDED SKIPS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF9800),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                ...master.recommendedSkips.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.skip_next,
                              size: 12, color: Color(0xFFFF9800)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFFCC80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 12),
              Card(
                color: const Color(0xFF1A2E14),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    master.blockNotes,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // ── Right: Task weights table ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    '${master.name} — Task Weights',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD4A017),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total weight: ${master.totalWeight}',
                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text('Sort by weight',
                        style: TextStyle(fontSize: 11)),
                    selected: sortByWeight.value,
                    onSelected: (v) => sortByWeight.value = v,
                    visualDensity: VisualDensity.compact,
                    selectedColor:
                        const Color(0xFFD4A017).withValues(alpha: 0.2),
                    showCheckmark: true,
                    checkmarkColor: const Color(0xFFD4A017),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Column headers
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                        width: 55,
                        child: Text('Rating',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38))),
                    Expanded(
                        child: Text('Task',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38))),
                    SizedBox(
                        width: 50,
                        child: Text('Weight',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38))),
                    SizedBox(
                        width: 55,
                        child: Text('Chance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38))),
                    SizedBox(
                        width: 45,
                        child: Text('Slayer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38))),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Task rows
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskRow(
                      task: task,
                      totalWeight: master.totalWeight,
                    );
                  },
                ),
              ),

              // ── Points info ──
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF2A1A08),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFD4A017)),
                      const SizedBox(width: 8),
                      Text(
                        'Points: ${master.pointsPer} per task  •  '
                        '${master.points10th} every 10th  •  '
                        '${master.points50th} every 50th',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD4A017),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${master.location}  •  '
                        '${master.combatReq} Combat'
                        '${master.slayerReq > 0 ? '  •  ${master.slayerReq} Slayer' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Master Card ─────────────────────────────────────────────────

class _MasterCard extends StatelessWidget {
  final SlayerMaster master;
  final bool isSelected;
  final VoidCallback onTap;

  const _MasterCard({
    required this.master,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? const Color(0xFFD4A017).withValues(alpha: 0.12)
          : null,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD4A017).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: isSelected
                      ? const Color(0xFFD4A017)
                      : Colors.white38,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFD4A017)
                            : Colors.white70,
                      ),
                    ),
                    Text(
                      '${master.location}  •  ${master.combatReq}+ CB',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${master.pointsPer} pts',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4A017),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Task Row ────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final SlayerTaskWeight task;
  final int totalWeight;

  const _TaskRow({required this.task, required this.totalWeight});

  @override
  Widget build(BuildContext context) {
    final chance = task.chancePercent(totalWeight);
    final ratingColor = _ratingColor(task.rating);

    return Tooltip(
      message: task.ratingNote ?? '',
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: ratingColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Rating badge
            SizedBox(
              width: 55,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  task.rating.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: ratingColor,
                  ),
                ),
              ),
            ),

            // Task name
            Expanded(
              child: Row(
                children: [
                  Text(
                    task.task,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: task.rating == 'block'
                          ? Colors.white38
                          : Colors.white70,
                      decoration: task.rating == 'block'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.unlockable) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_open,
                        size: 10, color: Color(0xFFFF9800)),
                  ],
                  if (task.quest != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.auto_stories,
                        size: 10, color: Color(0xFF64B5F6)),
                  ],
                ],
              ),
            ),

            // Weight
            SizedBox(
              width: 50,
              child: Text(
                '${task.weight}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: task.weight >= 9
                      ? const Color(0xFFE53935)
                      : task.weight >= 7
                          ? const Color(0xFFFF9800)
                          : Colors.white54,
                ),
              ),
            ),

            // Chance %
            SizedBox(
              width: 55,
              child: Text(
                '${chance.toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ),

            // Slayer level
            SizedBox(
              width: 45,
              child: Text(
                task.slayerReq > 1 ? '${task.slayerReq}' : '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: task.slayerReq > 1
                      ? const Color(0xFFD4A017)
                      : Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _ratingColor(String rating) {
    switch (rating) {
      case 'block':
        return const Color(0xFFE53935);
      case 'skip':
        return const Color(0xFFFF9800);
      case 'do':
        return const Color(0xFF64B5F6);
      case 'prefer':
        return const Color(0xFF43A047);
      case 'boss':
        return const Color(0xFFAB47BC);
      default:
        return Colors.white54;
    }
  }
}
