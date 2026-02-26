import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DryCalcScreen extends HookConsumerWidget {
  const DryCalcScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numeratorCtrl = useTextEditingController(text: '1');
    final denominatorCtrl = useTextEditingController(text: '128');
    final killsCtrl = useTextEditingController(text: '128');
    final dropsCtrl = useTextEditingController(text: '0');
    final result = useState<_DryResult?>(null);
    final selectedPreset = useState<_DropPreset?>(null);

    void calculate() {
      final num = int.tryParse(numeratorCtrl.text) ?? 1;
      final den = int.tryParse(denominatorCtrl.text) ?? 128;
      final kills = int.tryParse(killsCtrl.text) ?? 0;
      final drops = int.tryParse(dropsCtrl.text) ?? 0;

      if (den <= 0 || kills < 0 || num <= 0) {
        result.value = null;
        return;
      }

      final dropChance = num / den;
      result.value = _calculateDry(dropChance, kills, drops);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text('Drop Rate Calculator',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Dry Calc',
                      style: TextStyle(color: Color(0xFFD4A017), fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Input panel
                  SizedBox(
                    width: 340,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Drop Rate',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD4A017))),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: numeratorCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        labelText: 'Num',
                                        labelStyle: TextStyle(fontSize: 11),
                                      ),
                                      style: const TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('/',
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white54)),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: denominatorCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        labelText: 'Denominator',
                                        labelStyle: TextStyle(fontSize: 11),
                                      ),
                                      style: const TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: killsCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Kill Count / Attempts',
                                  prefixIcon: Icon(Icons.repeat, size: 18),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: dropsCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Drops Received (0 if dry)',
                                  prefixIcon: Icon(Icons.inventory_2, size: 18),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: calculate,
                                  icon: const Icon(Icons.calculate, size: 18),
                                  label: const Text('Calculate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A017),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text('Common Presets',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white54)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _presets.map((p) {
                                  final isActive = selectedPreset.value == p;
                                  return ActionChip(
                                    label: Text(p.label,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: isActive
                                                ? const Color(0xFFD4A017)
                                                : Colors.white60)),
                                    backgroundColor: isActive
                                        ? const Color(0xFFD4A017)
                                            .withValues(alpha: 0.15)
                                        : null,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      selectedPreset.value = p;
                                      numeratorCtrl.text =
                                          p.numerator.toString();
                                      denominatorCtrl.text =
                                          p.denominator.toString();
                                      calculate();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right: Results panel
                  Expanded(
                    child: result.value != null
                        ? _ResultPanel(result: result.value!)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.casino,
                                    size: 64, color: Colors.white12),
                                SizedBox(height: 12),
                                Text('Enter a drop rate and hit Calculate',
                                    style: TextStyle(color: Colors.white38)),
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
}

// ─── Data Model ──────────────────────────────────────

class _DryResult {
  final double dropChance;
  final int kills;
  final int drops;
  final double probZeroDrops;
  final double probAtLeastOne;
  final double expectedDrops;
  final int killsFor50;
  final int killsFor75;
  final int killsFor90;
  final int killsFor95;
  final int killsFor99;
  final double dryness;
  final String dryVerdict;
  final Color verdictColor;

  const _DryResult({
    required this.dropChance,
    required this.kills,
    required this.drops,
    required this.probZeroDrops,
    required this.probAtLeastOne,
    required this.expectedDrops,
    required this.killsFor50,
    required this.killsFor75,
    required this.killsFor90,
    required this.killsFor95,
    required this.killsFor99,
    required this.dryness,
    required this.dryVerdict,
    required this.verdictColor,
  });
}

_DryResult _calculateDry(double dropChance, int kills, int drops) {
  final probZero = pow(1 - dropChance, kills).toDouble();
  final probAtLeastOne = 1 - probZero;
  final expected = kills * dropChance;

  int killsForProb(double target) {
    if (dropChance <= 0) return 0;
    return (log(1 - target) / log(1 - dropChance)).ceil();
  }

  final k50 = killsForProb(0.50);
  final k75 = killsForProb(0.75);
  final k90 = killsForProb(0.90);
  final k95 = killsForProb(0.95);
  final k99 = killsForProb(0.99);

  // Dryness: how unlucky are you? (percentile of bad luck)
  double dryness = 0;
  String verdict = '';
  Color verdictColor = Colors.white54;

  if (kills > 0 && drops == 0) {
    dryness = probAtLeastOne * 100;
    if (dryness < 50) {
      verdict = 'Not dry yet';
      verdictColor = const Color(0xFF43A047);
    } else if (dryness < 75) {
      verdict = 'Getting unlucky';
      verdictColor = const Color(0xFFFF9800);
    } else if (dryness < 90) {
      verdict = 'Pretty dry';
      verdictColor = const Color(0xFFFF5722);
    } else if (dryness < 95) {
      verdict = 'Very dry!';
      verdictColor = const Color(0xFFD32F2F);
    } else if (dryness < 99) {
      verdict = 'Extremely dry!!';
      verdictColor = const Color(0xFFB71C1C);
    } else {
      verdict = 'Astronomically dry!!!';
      verdictColor = const Color(0xFF880E4F);
    }
  } else if (drops > 0) {
    final ratio = drops / expected;
    if (ratio >= 2.0) {
      verdict = 'Very lucky! ${ratio.toStringAsFixed(1)}x expected';
      verdictColor = const Color(0xFF43A047);
    } else if (ratio >= 1.2) {
      verdict = 'Lucky! ${ratio.toStringAsFixed(1)}x expected';
      verdictColor = const Color(0xFF43A047);
    } else if (ratio >= 0.8) {
      verdict = 'About average';
      verdictColor = const Color(0xFFD4A017);
    } else if (ratio >= 0.5) {
      verdict = 'Slightly dry (${ratio.toStringAsFixed(1)}x expected)';
      verdictColor = const Color(0xFFFF9800);
    } else {
      verdict = 'Very dry (${ratio.toStringAsFixed(1)}x expected)';
      verdictColor = const Color(0xFFD32F2F);
    }
    dryness = (1 - ratio).clamp(0, 1) * 100;
  }

  return _DryResult(
    dropChance: dropChance,
    kills: kills,
    drops: drops,
    probZeroDrops: probZero,
    probAtLeastOne: probAtLeastOne,
    expectedDrops: expected,
    killsFor50: k50,
    killsFor75: k75,
    killsFor90: k90,
    killsFor95: k95,
    killsFor99: k99,
    dryness: dryness,
    dryVerdict: verdict,
    verdictColor: verdictColor,
  );
}

// ─── Result Panel ────────────────────────────────────

class _ResultPanel extends StatelessWidget {
  final _DryResult result;
  const _ResultPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verdict card
          Card(
            color: result.verdictColor.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    result.drops == 0 && result.kills > 0
                        ? Icons.sentiment_very_dissatisfied
                        : result.verdictColor == const Color(0xFF43A047)
                            ? Icons.sentiment_very_satisfied
                            : Icons.sentiment_neutral,
                    size: 48,
                    color: result.verdictColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.dryVerdict,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: result.verdictColor)),
                        const SizedBox(height: 4),
                        Text(
                          'Drop rate: ${result.dropChance < 0.01 ? '1/${(1 / result.dropChance).round()}' : '${(result.dropChance * 100).toStringAsFixed(2)}%'}'
                          ' | ${result.kills} kills | ${result.drops} drops',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Chance of 0 drops',
                  value: '${(result.probZeroDrops * 100).toStringAsFixed(2)}%',
                  color: result.probZeroDrops > 0.5
                      ? const Color(0xFF43A047)
                      : const Color(0xFFFF5722),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'Chance of ≥1 drop',
                  value: '${(result.probAtLeastOne * 100).toStringAsFixed(2)}%',
                  color: result.probAtLeastOne > 0.5
                      ? const Color(0xFF43A047)
                      : const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'Expected drops',
                  value: result.expectedDrops.toStringAsFixed(2),
                  color: const Color(0xFFD4A017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kills needed table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.gps_fixed, size: 16, color: Color(0xFFD4A017)),
                      SizedBox(width: 6),
                      Text('Kills needed for probability',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4A017))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ProbRow(
                      label: '50%',
                      kills: result.killsFor50,
                      current: result.kills),
                  _ProbRow(
                      label: '75%',
                      kills: result.killsFor75,
                      current: result.kills),
                  _ProbRow(
                      label: '90%',
                      kills: result.killsFor90,
                      current: result.kills),
                  _ProbRow(
                      label: '95%',
                      kills: result.killsFor95,
                      current: result.kills),
                  _ProbRow(
                      label: '99%',
                      kills: result.killsFor99,
                      current: result.kills),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Visualization: Progress bar towards drop rate
          if (result.drops == 0 && result.kills > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, size: 16, color: Colors.white54),
                        SizedBox(width: 6),
                        Text('Your progress to drop rate',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ProgressBar(
                      label: 'vs Drop Rate',
                      value: result.kills / (1 / result.dropChance),
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 8),
                    _ProgressBar(
                      label: 'vs 2x Rate',
                      value: result.kills / (2 / result.dropChance),
                      color: const Color(0xFFFF5722),
                    ),
                    const SizedBox(height: 8),
                    _ProgressBar(
                      label: 'vs 3x Rate',
                      value: result.kills / (3 / result.dropChance),
                      color: const Color(0xFFD32F2F),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ProbRow extends StatelessWidget {
  final String label;
  final int kills;
  final int current;
  const _ProbRow(
      {required this.label, required this.kills, required this.current});

  @override
  Widget build(BuildContext context) {
    final reached = current >= kills;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (current / kills).clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(
                  reached ? const Color(0xFFD32F2F) : const Color(0xFF43A047),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              _formatKills(kills),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: reached ? const Color(0xFFD32F2F) : Colors.white54,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            reached ? Icons.warning : Icons.check_circle_outline,
            size: 14,
            color: reached ? const Color(0xFFD32F2F) : Colors.white24,
          ),
        ],
      ),
    );
  }

  String _formatKills(int k) {
    if (k >= 1000000) return '${(k / 1000000).toStringAsFixed(1)}M';
    if (k >= 1000) return '${(k / 1000).toStringAsFixed(1)}k';
    return '$k';
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ProgressBar(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(value * 100).toInt()}%',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

// ─── Presets ─────────────────────────────────────────

class _DropPreset {
  final String label;
  final int numerator;
  final int denominator;
  const _DropPreset(this.label, this.numerator, this.denominator);
}

const _presets = [
  _DropPreset('Pets (1/3k)', 1, 3000),
  _DropPreset('Pets (1/5k)', 1, 5000),
  _DropPreset('DWH (1/5k)', 1, 5000),
  _DropPreset('Zenyte (1/300)', 1, 300),
  _DropPreset('Whip (1/512)', 1, 512),
  _DropPreset('D Chainbody (1/32k)', 1, 32768),
  _DropPreset('Common (1/128)', 1, 128),
  _DropPreset('Barrows (1/16)', 1, 16),
  _DropPreset('CoX Purple (1/30)', 1, 30),
  _DropPreset('ToB Purple (1/9.1)', 10, 91),
  _DropPreset('ToA Purple (1/8)', 1, 8),
  _DropPreset('Zulrah unique (1/128)', 1, 128),
  _DropPreset('Vorkath unique (1/5k)', 1, 5000),
  _DropPreset('Corp Sigil (1/585)', 1, 585),
  _DropPreset('GWD Hilt (1/508)', 1, 508),
  _DropPreset('Crystal tool seed (1/400)', 1, 400),
];
