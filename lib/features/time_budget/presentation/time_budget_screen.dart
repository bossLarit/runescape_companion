import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../../characters/domain/character_model.dart';
import '../../goal_planner/data/training_methods_data.dart';
import '../../goal_planner/data/micro_goals_engine.dart';

class TimeBudgetScreen extends HookConsumerWidget {
  const TimeBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final minutes = useState(60.0);
    final intensity = useState(Intensity.either);
    final focusArea = useState<_FocusArea>(_FocusArea.balanced);
    final generated = useState(false);

    final isIronman = activeChar != null &&
        {
          CharacterType.iron,
          CharacterType.hcim,
          CharacterType.uim,
          CharacterType.gim
        }.contains(activeChar.characterType);

    // Build player levels from hiscores
    final playerLevels = <String, int>{};
    hiscoreState.whenData((result) {
      if (result != null) {
        for (final entry in result.skills.entries) {
          playerLevels[entry.key] = entry.value.level;
        }
      }
    });

    // Generate plan
    List<_SessionItem> plan = [];
    int totalXp = 0;

    if (generated.value && playerLevels.isNotEmpty) {
      plan = _generateSessionPlan(
        playerLevels: playerLevels,
        isIronman: isIronman,
        totalMinutes: minutes.value.round(),
        intensity: intensity.value,
        focus: focusArea.value,
      );
      totalXp = plan.fold(0, (sum, item) => sum + item.xpGain);
    }

    final timeLabel = minutes.value < 60
        ? '${minutes.value.round()} min'
        : minutes.value == 60
            ? '1 hour'
            : '${(minutes.value / 60).toStringAsFixed(1)} hrs';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text('Time Budget Planner',
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
              ],
            ),
            const SizedBox(height: 20),

            // Input card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time slider
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 18, color: Color(0xFFD4A017)),
                        const SizedBox(width: 8),
                        const Text('How long do you want to play?',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFD4A017).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(timeLabel,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD4A017))),
                        ),
                      ],
                    ),
                    Slider(
                      value: minutes.value,
                      min: 15,
                      max: 240,
                      divisions: 15,
                      activeColor: const Color(0xFFD4A017),
                      onChanged: (v) {
                        minutes.value = v;
                        generated.value = false;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('15m',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white30)),
                        Text('1h',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white30)),
                        Text('2h',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white30)),
                        Text('4h',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white30)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Intensity + Focus row
                    Row(
                      children: [
                        // Intensity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.flash_on,
                                      size: 14, color: Colors.white54),
                                  SizedBox(width: 4),
                                  Text('Intensity',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white54)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SegmentedButton<Intensity>(
                                segments: const [
                                  ButtonSegment(
                                      value: Intensity.afk,
                                      label: Text('AFK',
                                          style: TextStyle(fontSize: 11)),
                                      icon: Icon(Icons.weekend, size: 14)),
                                  ButtonSegment(
                                      value: Intensity.either,
                                      label: Text('Mix',
                                          style: TextStyle(fontSize: 11)),
                                      icon: Icon(Icons.shuffle, size: 14)),
                                  ButtonSegment(
                                      value: Intensity.active,
                                      label: Text('Active',
                                          style: TextStyle(fontSize: 11)),
                                      icon:
                                          Icon(Icons.directions_run, size: 14)),
                                ],
                                selected: {intensity.value},
                                onSelectionChanged: (s) {
                                  intensity.value = s.first;
                                  generated.value = false;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Focus area
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.center_focus_strong,
                                      size: 14, color: Colors.white54),
                                  SizedBox(width: 4),
                                  Text('Focus',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white54)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SegmentedButton<_FocusArea>(
                                segments: const [
                                  ButtonSegment(
                                      value: _FocusArea.balanced,
                                      label: Text('Balanced',
                                          style: TextStyle(fontSize: 11))),
                                  ButtonSegment(
                                      value: _FocusArea.xpFocused,
                                      label: Text('Max XP',
                                          style: TextStyle(fontSize: 11))),
                                  ButtonSegment(
                                      value: _FocusArea.quickWins,
                                      label: Text('Quick Wins',
                                          style: TextStyle(fontSize: 11))),
                                ],
                                selected: {focusArea.value},
                                onSelectionChanged: (s) {
                                  focusArea.value = s.first;
                                  generated.value = false;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: playerLevels.isEmpty
                            ? null
                            : () => generated.value = true,
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Generate Session Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A017),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (playerLevels.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                            'Select an active character with stats to generate a plan',
                            style:
                                TextStyle(fontSize: 11, color: Colors.white38)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: !generated.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.schedule, size: 64, color: Colors.white12),
                          SizedBox(height: 12),
                          Text(
                              'Set your time and preferences, then generate a plan',
                              style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    )
                  : plan.isEmpty
                      ? const Center(
                          child: Text('No suggestions for current settings',
                              style: TextStyle(color: Colors.white38)),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Session plan list
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Summary bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4A017)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.auto_awesome,
                                            size: 16, color: Color(0xFFD4A017)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Session Plan — ${plan.length} activities',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFD4A017)),
                                        ),
                                        const Spacer(),
                                        _SmallStat(
                                            icon: Icons.schedule,
                                            label:
                                                '${plan.fold<int>(0, (s, i) => s + i.minutes)} min',
                                            color: const Color(0xFF42A5F5)),
                                        const SizedBox(width: 12),
                                        _SmallStat(
                                            icon: Icons.trending_up,
                                            label: _fmtXp(totalXp),
                                            color: const Color(0xFF43A047)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Plan items
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: plan.length,
                                      itemBuilder: (_, i) => _SessionItemCard(
                                        item: plan[i],
                                        index: i,
                                        totalItems: plan.length,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Right: summary panel
                            SizedBox(
                              width: 260,
                              child: _SummaryPanel(
                                plan: plan,
                                totalMinutes: minutes.value.round(),
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

// ─── Focus Area ──────────────────────────────────────

enum _FocusArea { balanced, xpFocused, quickWins }

// ─── Session Item ────────────────────────────────────

class _SessionItem {
  final String skill;
  final String method;
  final int minutes;
  final int xpGain;
  final int xpPerHour;
  final String milestone;
  final Intensity intensity;
  final String notes;

  const _SessionItem({
    required this.skill,
    required this.method,
    required this.minutes,
    required this.xpGain,
    required this.xpPerHour,
    this.milestone = '',
    required this.intensity,
    this.notes = '',
  });
}

// ─── Plan Generator ──────────────────────────────────

List<_SessionItem> _generateSessionPlan({
  required Map<String, int> playerLevels,
  required bool isIronman,
  required int totalMinutes,
  required Intensity intensity,
  required _FocusArea focus,
}) {
  final items = <_SessionItem>[];
  int remaining = totalMinutes;

  // Always add quick dailies first if time allows
  if (remaining >= 10) {
    items.add(const _SessionItem(
      skill: 'Farming',
      method: 'Herb + Birdhouse Run',
      minutes: 10,
      xpGain: 30000,
      xpPerHour: 0,
      milestone: 'Passive XP + GP',
      intensity: Intensity.active,
      notes: 'Start every session with runs',
    ));
    remaining -= 10;
  }

  // Get micro goals sorted by priority
  final goals = MicroGoalsEngine.generateGoals(
    playerLevels: playerLevels,
    isIronman: isIronman,
    intensityPref: intensity,
    maxGoalsPerSkill: 1,
  );

  if (goals.isEmpty) return items;

  switch (focus) {
    case _FocusArea.balanced:
      // Spread time across 2-4 different skills
      final skillSet = <String>{};
      for (final g in goals) {
        if (skillSet.length >= 4 || remaining <= 0) break;
        if (skillSet.contains(g.skill)) continue;
        skillSet.add(g.skill);

        final slotMinutes = min(remaining, max(15, totalMinutes ~/ 4));
        final xpGain = (g.bestMethod.xpPerHour * slotMinutes / 60).round();

        items.add(_SessionItem(
          skill: g.skill,
          method: g.bestMethod.method,
          minutes: slotMinutes,
          xpGain: xpGain,
          xpPerHour: g.bestMethod.xpPerHour,
          milestone: 'Lv${g.currentLevel} → ${g.targetLevel}: ${g.milestone}',
          intensity: g.bestMethod.intensity,
          notes: g.bestMethod.notes,
        ));
        remaining -= slotMinutes;
      }
      break;

    case _FocusArea.xpFocused:
      // Sort by XP/hr and fill with top methods
      final sorted = [...goals]..sort(
          (a, b) => b.bestMethod.xpPerHour.compareTo(a.bestMethod.xpPerHour));
      final skillSet = <String>{};
      for (final g in sorted) {
        if (skillSet.length >= 3 || remaining <= 0) break;
        if (skillSet.contains(g.skill)) continue;
        skillSet.add(g.skill);

        final slotMinutes = min(remaining, max(20, remaining ~/ 2));
        final xpGain = (g.bestMethod.xpPerHour * slotMinutes / 60).round();

        items.add(_SessionItem(
          skill: g.skill,
          method: g.bestMethod.method,
          minutes: slotMinutes,
          xpGain: xpGain,
          xpPerHour: g.bestMethod.xpPerHour,
          milestone: 'Lv${g.currentLevel} → ${g.targetLevel}: ${g.milestone}',
          intensity: g.bestMethod.intensity,
          notes: g.bestMethod.notes,
        ));
        remaining -= slotMinutes;
      }
      break;

    case _FocusArea.quickWins:
      // Prioritize goals closest to completion
      final sorted = [...goals]
        ..sort((a, b) => a.estimatedHours.compareTo(b.estimatedHours));
      final skillSet = <String>{};
      for (final g in sorted) {
        if (skillSet.length >= 5 || remaining <= 0) break;
        if (skillSet.contains(g.skill)) continue;
        if (g.estimatedHours <= 0) continue;
        skillSet.add(g.skill);

        final slotMinutes = min(remaining,
            min((g.estimatedHours * 60).ceil(), max(15, remaining ~/ 3)));
        final xpGain = (g.bestMethod.xpPerHour * slotMinutes / 60).round();

        items.add(_SessionItem(
          skill: g.skill,
          method: g.bestMethod.method,
          minutes: slotMinutes,
          xpGain: xpGain,
          xpPerHour: g.bestMethod.xpPerHour,
          milestone: 'Lv${g.currentLevel} → ${g.targetLevel}: ${g.milestone}',
          intensity: g.bestMethod.intensity,
          notes: g.bestMethod.notes,
        ));
        remaining -= slotMinutes;
      }
      break;
  }

  return items;
}

// ─── Widgets ─────────────────────────────────────────

class _SessionItemCard extends StatelessWidget {
  final _SessionItem item;
  final int index;
  final int totalItems;

  const _SessionItemCard({
    required this.item,
    required this.index,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Step number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('${index + 1}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4A017))),
              ),
            ),
            const SizedBox(width: 12),
            // Intensity icon
            Icon(
              item.intensity == Intensity.afk
                  ? Icons.weekend
                  : item.intensity == Intensity.active
                      ? Icons.directions_run
                      : Icons.shuffle,
              size: 16,
              color: item.intensity == Intensity.afk
                  ? const Color(0xFF42A5F5)
                  : const Color(0xFFFF9800),
            ),
            const SizedBox(width: 8),
            // Skill + method
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.skill,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Text('— ${item.method}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white60),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  if (item.milestone.isNotEmpty)
                    Text(item.milestone,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white38),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${item.minutes}m',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF42A5F5))),
            ),
            const SizedBox(width: 8),
            // XP
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmtXp(item.xpGain),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF43A047))),
                  if (item.xpPerHour > 0)
                    Text('${_fmtXp(item.xpPerHour)}/hr',
                        style: const TextStyle(
                            fontSize: 9, color: Colors.white30)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final List<_SessionItem> plan;
  final int totalMinutes;
  const _SummaryPanel({required this.plan, required this.totalMinutes});

  @override
  Widget build(BuildContext context) {
    final totalXp = plan.fold<int>(0, (s, i) => s + i.xpGain);
    final usedMinutes = plan.fold<int>(0, (s, i) => s + i.minutes);
    final skills = plan.map((p) => p.skill).toSet();
    final afkCount = plan.where((p) => p.intensity == Intensity.afk).length;
    final activeCount = plan.where((p) => p.intensity != Intensity.afk).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.summarize, size: 16, color: Color(0xFFD4A017)),
                  SizedBox(width: 6),
                  Text('Session Summary',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD4A017))),
                ],
              ),
              const Divider(height: 20),
              _SummaryRow(
                  icon: Icons.schedule,
                  label: 'Time Used',
                  value: '$usedMinutes / $totalMinutes min'),
              _SummaryRow(
                  icon: Icons.trending_up,
                  label: 'Total XP',
                  value: _fmtXp(totalXp),
                  valueColor: const Color(0xFF43A047)),
              _SummaryRow(
                  icon: Icons.grid_view,
                  label: 'Skills',
                  value: '${skills.length}'),
              _SummaryRow(
                  icon: Icons.weekend, label: 'AFK Steps', value: '$afkCount'),
              _SummaryRow(
                  icon: Icons.directions_run,
                  label: 'Active Steps',
                  value: '$activeCount'),
              const Divider(height: 20),

              // Time usage bar
              const Text('Time Allocation',
                  style: TextStyle(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      for (int i = 0; i < plan.length; i++)
                        Expanded(
                          flex: plan[i].minutes,
                          child: Container(
                            color: _skillColors[i % _skillColors.length],
                          ),
                        ),
                      if (usedMinutes < totalMinutes)
                        Expanded(
                          flex: totalMinutes - usedMinutes,
                          child: Container(color: Colors.white10),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Legend
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (int i = 0; i < plan.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _skillColors[i % _skillColors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('${plan[i].skill} (${plan[i].minutes}m)',
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white38)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Tips
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb,
                            size: 12, color: Color(0xFFD4A017)),
                        SizedBox(width: 4),
                        Text('Tip',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD4A017))),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Start with herb/birdhouse runs, then move to your main activities. Switch skills if you get bored!',
                      style: TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white54)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white70)),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SmallStat(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

const _skillColors = [
  Color(0xFF43A047),
  Color(0xFF42A5F5),
  Color(0xFFFF9800),
  Color(0xFF7E57C2),
  Color(0xFFE91E63),
  Color(0xFF00BCD4),
  Color(0xFFD4A017),
];

String _fmtXp(int xp) {
  if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
  if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}k';
  return '$xp';
}
