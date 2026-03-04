import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/dry_streak_data.dart';

Color _severityColor(int severity) {
  switch (severity) {
    case 0:
      return const Color(0xFF43A047);
    case 1:
      return const Color(0xFFD4A017);
    case 2:
      return const Color(0xFFFF9800);
    case 3:
      return const Color(0xFFFF5722);
    case 4:
      return const Color(0xFFD32F2F);
    case 5:
      return const Color(0xFFB71C1C);
    default:
      return const Color(0xFF9E9E9E);
  }
}

class DryStreakScreen extends HookConsumerWidget {
  const DryStreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBoss = useState<String?>(null);
    final bossDrop = useState<TrackedDrop?>(null);
    final kcCtrl = useTextEditingController(text: '0');
    final dropsCtrl = useTextEditingController(text: '0');
    final result = useState<DryStreakResult?>(null);
    final searchQuery = useState('');

    void calculate() {
      if (bossDrop.value == null) return;
      final kc = int.tryParse(kcCtrl.text) ?? 0;
      final drops = int.tryParse(dropsCtrl.text) ?? 0;
      result.value = DryStreakEngine.analyze(
        drop: bossDrop.value!,
        kc: kc,
        dropsReceived: drops,
      );
    }

    final bossNames = allBossNames;
    final filteredBosses = searchQuery.value.isEmpty
        ? bossNames
        : bossNames
            .where((b) =>
                b.toLowerCase().contains(searchQuery.value.toLowerCase()))
            .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text('Dry Streak Tracker',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('RNG',
                      style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: Boss & Drop Selector ──
                  SizedBox(
                    width: 280,
                    child: Column(
                      children: [
                        // Search
                        TextField(
                          onChanged: (v) => searchQuery.value = v,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Search boss...',
                            prefixIcon: Icon(Icons.search, size: 18),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        // Boss list
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredBosses.length,
                            itemBuilder: (_, i) {
                              final boss = filteredBosses[i];
                              final isActive = selectedBoss.value == boss;
                              final drops = dropsForBoss(boss);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Card(
                                  color: isActive
                                      ? const Color(0xFFD4A017)
                                          .withValues(alpha: 0.1)
                                      : null,
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    childrenPadding: const EdgeInsets.only(
                                        left: 12, right: 12, bottom: 8),
                                    title: Text(boss,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isActive
                                              ? const Color(0xFFD4A017)
                                              : Colors.white70,
                                        )),
                                    subtitle: Text(
                                        '${drops.length} tracked drops',
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white30)),
                                    onExpansionChanged: (expanded) {
                                      if (expanded) {
                                        selectedBoss.value = boss;
                                      }
                                    },
                                    children: drops.map((d) {
                                      final isSelected = bossDrop.value == d;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3),
                                        child: InkWell(
                                          onTap: () {
                                            bossDrop.value = d;
                                            selectedBoss.value = boss;
                                            kcCtrl.text = '0';
                                            dropsCtrl.text = '0';
                                            result.value = null;
                                          },
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF2196F3)
                                                      .withValues(alpha: 0.15)
                                                  : Colors.white
                                                      .withValues(alpha: 0.03),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF2196F3)
                                                        .withValues(alpha: 0.4)
                                                    : Colors.white.withValues(
                                                        alpha: 0.06),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: _categoryColor(
                                                        d.category),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(d.item,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w700
                                                            : FontWeight.w400,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF2196F3)
                                                            : Colors.white60,
                                                      )),
                                                ),
                                                Text(
                                                    '1/${DryStreakEngine.fmtKc(d.rateDenominator)}',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      color: isSelected
                                                          ? const Color(
                                                                  0xFF2196F3)
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : Colors.white30,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ── Right: Calculator + Results ──
                  Expanded(
                    child: bossDrop.value != null
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selected drop header
                                Card(
                                  color: const Color(0xFFD4A017)
                                      .withValues(alpha: 0.08),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _categoryColor(
                                                bossDrop.value!.category),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(bossDrop.value!.item,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Text(
                                                  '${bossDrop.value!.boss}  •  Drop rate: 1/${DryStreakEngine.fmtKc(bossDrop.value!.rateDenominator)}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white54)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Input
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Your Progress',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2196F3))),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: kcCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                  isDense: true,
                                                  labelText: 'Kill Count',
                                                  prefixIcon: Icon(Icons.repeat,
                                                      size: 18),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: dropsCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                  isDense: true,
                                                  labelText: 'Drops Received',
                                                  prefixIcon: Icon(
                                                      Icons.inventory_2,
                                                      size: 18),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: calculate,
                                            icon: const Icon(Icons.calculate,
                                                size: 18),
                                            label: const Text('How dry am I?'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFD4A017),
                                              foregroundColor: Colors.black,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Result
                                if (result.value != null) ...[
                                  _DryResultCard(result: result.value!),
                                  const SizedBox(height: 12),
                                  _MilestoneTable(
                                      drop: bossDrop.value!,
                                      currentKc: result.value!.kc),
                                ],
                              ],
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.casino,
                                    size: 64, color: Colors.white12),
                                SizedBox(height: 12),
                                Text('Select a boss and drop to track',
                                    style: TextStyle(color: Colors.white38)),
                                SizedBox(height: 4),
                                Text(
                                    'See how dry you really are with statistical context',
                                    style: TextStyle(
                                        color: Colors.white24, fontSize: 11)),
                              ],
                            ),
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

  Color _categoryColor(String category) {
    switch (category) {
      case 'pet':
        return const Color(0xFF9C27B0);
      case 'weapon':
        return const Color(0xFFE53935);
      case 'armour':
        return const Color(0xFF2196F3);
      case 'rare':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFD4A017);
    }
  }
}

// ─── Dry Result Card ─────────────────────────────────

class _DryResultCard extends StatelessWidget {
  final DryStreakResult result;
  const _DryResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(result.severity);

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _verdictIcon(result.dryPercentile),
                  size: 36,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.verdict,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color)),
                      const SizedBox(height: 4),
                      Text(
                        '${result.kc} KC  •  ${result.dropsReceived} drops  •  '
                        'Expected: ${result.expectedDrops.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('Dryness',
                      style: TextStyle(fontSize: 10, color: Colors.white38)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (result.dryPercentile / 100).clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${result.dryPercentile.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
            const SizedBox(height: 8),
            // Stats row
            Row(
              children: [
                _MiniStat(
                    'Drop Rate', result.drop.rateStr, const Color(0xFFD4A017)),
                const SizedBox(width: 12),
                _MiniStat(
                    'Probability',
                    '${(result.probAtLeastOne * 100).toStringAsFixed(1)}%',
                    result.probAtLeastOne > 0.5
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF43A047)),
                const SizedBox(width: 12),
                _MiniStat('Expected', result.expectedDrops.toStringAsFixed(2),
                    const Color(0xFF2196F3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _verdictIcon(double pct) {
    if (pct < 50) return Icons.sentiment_satisfied;
    if (pct < 75) return Icons.sentiment_neutral;
    if (pct < 90) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white30)),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

// ─── Milestone Table ─────────────────────────────────

class _MilestoneTable extends StatelessWidget {
  final TrackedDrop drop;
  final int currentKc;
  const _MilestoneTable({required this.drop, required this.currentKc});

  @override
  Widget build(BuildContext context) {
    final milestones = [0.50, 0.75, 0.90, 0.95, 0.99];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.gps_fixed, size: 14, color: Color(0xFFD4A017)),
                SizedBox(width: 6),
                Text('KC Milestones',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4A017))),
              ],
            ),
            const SizedBox(height: 10),
            ...milestones.map((prob) {
              final needed =
                  DryStreakEngine.killsForProb(drop.dropChance, prob);
              final reached = currentKc >= needed;
              final progress =
                  needed > 0 ? (currentKc / needed).clamp(0.0, 1.0) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text('${(prob * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(
                            reached
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF43A047),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(DryStreakEngine.fmtKc(needed),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: reached
                                ? const Color(0xFFD32F2F)
                                : Colors.white54,
                          )),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      reached ? Icons.warning : Icons.check_circle_outline,
                      size: 12,
                      color: reached ? const Color(0xFFD32F2F) : Colors.white24,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
