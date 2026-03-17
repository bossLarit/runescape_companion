import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../../characters/domain/character_model.dart';
import '../../goal_planner/data/training_methods_data.dart';
import '../../goal_planner/data/micro_goals_engine.dart';
import '../../best_setup/data/bank_provider.dart';
import '../../../shared/widgets/bank_import_dialog.dart';

const _gold = kGold;
const _green = kAccentGreen;
const _blue = kAccentBlue;
const _orange = kAccentOrange;

// Preset time options — better UX than a slider
const _timePresets = [15, 30, 45, 60, 90, 120, 180, 240];

String _timeLabel(int mins) {
  if (mins < 60) return '${mins}m';
  if (mins == 60) return '1 hr';
  if (mins % 60 == 0) return '${mins ~/ 60} hrs';
  return '${mins ~/ 60}h ${mins % 60}m';
}

class TimeBudgetScreen extends HookConsumerWidget {
  const TimeBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final selectedMinutes = useState(60);
    final intensity = useState(Intensity.either);
    final focusArea = useState<_FocusArea>(_FocusArea.balanced);
    final generated = useState(false);

    final isIronman = activeChar != null &&
        {
          CharacterType.iron,
          CharacterType.hcim,
          CharacterType.uim,
          CharacterType.gim,
          CharacterType.hcgim
        }.contains(activeChar.characterType);

    final bankState = ref.watch(bankProvider);
    final bankItems = bankState.isLoaded && bankState.itemNames.isNotEmpty
        ? bankState.itemNames
        : null;

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
        totalMinutes: selectedMinutes.value,
        intensity: intensity.value,
        focus: focusArea.value,
        bankItems: bankItems,
      );
      totalXp = plan.fold(0, (sum, item) => sum + item.xpGain);
    }

    final hasStats = playerLevels.isNotEmpty;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Flexible(
                  child: Text('Time Budget Planner',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                if (activeChar != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(activeChar.displayName,
                        style: const TextStyle(color: _gold, fontSize: 12)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            const BankEmptyBanner(),

            // ── Configuration panel ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Time presets ──
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: _gold),
                        const SizedBox(width: 8),
                        const Text('Session length',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70)),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _timeLabel(selectedMinutes.value),
                            key: ValueKey(selectedMinutes.value),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _gold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timePresets.map((mins) {
                        final active = selectedMinutes.value == mins;
                        return _TimeChip(
                          label: _timeLabel(mins),
                          active: active,
                          onTap: () {
                            selectedMinutes.value = mins;
                            generated.value = false;
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Intensity + Focus ──
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
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white54)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _OptionPill(
                                    icon: Icons.weekend,
                                    label: 'AFK',
                                    active: intensity.value == Intensity.afk,
                                    color: _blue,
                                    onTap: () {
                                      intensity.value = Intensity.afk;
                                      generated.value = false;
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _OptionPill(
                                    icon: Icons.shuffle,
                                    label: 'Mix',
                                    active: intensity.value == Intensity.either,
                                    color: _gold,
                                    onTap: () {
                                      intensity.value = Intensity.either;
                                      generated.value = false;
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _OptionPill(
                                    icon: Icons.directions_run,
                                    label: 'Active',
                                    active: intensity.value == Intensity.active,
                                    color: _orange,
                                    onTap: () {
                                      intensity.value = Intensity.active;
                                      generated.value = false;
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Focus
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
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white54)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _OptionPill(
                                    icon: Icons.balance,
                                    label: 'Balanced',
                                    active:
                                        focusArea.value == _FocusArea.balanced,
                                    color: _green,
                                    onTap: () {
                                      focusArea.value = _FocusArea.balanced;
                                      generated.value = false;
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _OptionPill(
                                    icon: Icons.trending_up,
                                    label: 'Max XP',
                                    active:
                                        focusArea.value == _FocusArea.xpFocused,
                                    color: _gold,
                                    onTap: () {
                                      focusArea.value = _FocusArea.xpFocused;
                                      generated.value = false;
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _OptionPill(
                                    icon: Icons.bolt,
                                    label: 'Quick Wins',
                                    active:
                                        focusArea.value == _FocusArea.quickWins,
                                    color: _orange,
                                    onTap: () {
                                      focusArea.value = _FocusArea.quickWins;
                                      generated.value = false;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _OptionPill(
                                    icon: Icons.checklist,
                                    label: 'Dailies First',
                                    active: focusArea.value ==
                                        _FocusArea.dailiesFirst,
                                    color: _green,
                                    onTap: () {
                                      focusArea.value = _FocusArea.dailiesFirst;
                                      generated.value = false;
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _OptionPill(
                                    icon: Icons.shield,
                                    label: 'PvM Prep',
                                    active:
                                        focusArea.value == _FocusArea.pvmPrep,
                                    color: const Color(0xFFE53935),
                                    onTap: () {
                                      focusArea.value = _FocusArea.pvmPrep;
                                      generated.value = false;
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Generate button ──
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: hasStats
                              ? const LinearGradient(colors: [
                                  Color(0xFF2D5F27),
                                  Color(0xFF3B8132),
                                ])
                              : null,
                          color: hasStats ? null : Colors.white10,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap:
                                hasStats ? () => generated.value = true : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 18,
                                      color: hasStats
                                          ? Colors.white
                                          : Colors.white24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Generate Session Plan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: hasStats
                                          ? Colors.white
                                          : Colors.white24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!hasStats)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 12, color: Colors.white30),
                            SizedBox(width: 4),
                            Text(
                                'Add a character with stats to generate a plan',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.white38)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Results ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !generated.value
                    ? const _EmptyState(key: ValueKey('empty'))
                    : plan.isEmpty
                        ? const Center(
                            key: ValueKey('no-results'),
                            child: Text('No suggestions for current settings',
                                style: TextStyle(color: Colors.white38)),
                          )
                        : Row(
                            key: const ValueKey('results'),
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
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _gold.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color:
                                                _gold.withValues(alpha: 0.15)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.auto_awesome,
                                              size: 16, color: _gold),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${plan.length} activities planned',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: _gold),
                                          ),
                                          const Spacer(),
                                          _SmallStat(
                                              icon: Icons.schedule,
                                              label:
                                                  '${plan.fold<int>(0, (s, i) => s + i.minutes)} min',
                                              color: _blue),
                                          const SizedBox(width: 14),
                                          _SmallStat(
                                              icon: Icons.trending_up,
                                              label: _fmtXp(totalXp),
                                              color: _green),
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
                                  totalMinutes: selectedMinutes.value,
                                ),
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

// ─── Empty state ─────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, size: 36, color: Colors.white12),
          ),
          const SizedBox(height: 16),
          const Text('Ready to plan your session',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38)),
          const SizedBox(height: 6),
          const Text('Choose your time and preferences above, then generate',
              style: TextStyle(fontSize: 12, color: Colors.white24)),
        ],
      ),
    );
  }
}

// ─── Time chip ───────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TimeChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? _gold.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? _gold : Colors.white.withValues(alpha: 0.08),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _gold : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Option pill (intensity / focus) ─────────────────

class _OptionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _OptionPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? color : Colors.white.withValues(alpha: 0.08),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 16, color: active ? color : Colors.white30),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? color : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Focus Area ──────────────────────────────────────

enum _FocusArea { balanced, xpFocused, quickWins, dailiesFirst, pvmPrep }

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
  Set<String>? bankItems,
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
    bankItems: bankItems,
  );

  // Filter out methods that require bank items the player doesn't have
  final viableGoals = bankItems != null
      ? goals.where((g) {
          if (!g.bestMethod.needsBankItems) return true;
          return g.bestMethod.bankViable(bankItems);
        }).toList()
      : goals;

  if (viableGoals.isEmpty) return items;

  switch (focus) {
    case _FocusArea.balanced:
      // Spread time across 2-4 different skills
      final skillSet = <String>{};
      for (final g in viableGoals) {
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
      final sorted = [...viableGoals]..sort(
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
      final sorted = [...viableGoals]
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

    case _FocusArea.dailiesFirst:
      // Front-load all dailies/weeklies, then fill remaining time
      final dailies = <_SessionItem>[
        if (remaining >= 5)
          const _SessionItem(
            skill: 'Hunter',
            method: 'Birdhouse run',
            minutes: 5,
            xpGain: 15000,
            xpPerHour: 0,
            milestone: 'Passive Hunter XP + bird nests',
            intensity: Intensity.active,
            notes: 'Check every 50 min',
          ),
        if (remaining >= 10 && isIronman)
          const _SessionItem(
            skill: 'Farming',
            method: 'Farming contracts',
            minutes: 10,
            xpGain: 20000,
            xpPerHour: 0,
            milestone: 'Seed supply for herb runs',
            intensity: Intensity.active,
            notes: 'Guild contract + herb run',
          ),
        if (remaining >= 5 && isIronman)
          const _SessionItem(
            skill: 'Farming',
            method: 'Giant seaweed run',
            minutes: 5,
            xpGain: 4000,
            xpPerHour: 0,
            milestone: 'Crafting supply',
            intensity: Intensity.active,
            notes: 'Underwater patches',
          ),
        if (remaining >= 5 && isIronman)
          const _SessionItem(
            skill: 'Mining',
            method: 'Sandstone mining',
            minutes: 5,
            xpGain: 5000,
            xpPerHour: 0,
            milestone: 'Buckets of sand for Superglass Make',
            intensity: Intensity.active,
            notes: 'Desert quarry',
          ),
        if (remaining >= 5)
          const _SessionItem(
            skill: 'Magic',
            method: 'Daily battlestaves',
            minutes: 5,
            xpGain: 0,
            xpPerHour: 0,
            milestone: 'Free GP (Varrock diary)',
            intensity: Intensity.active,
            notes: 'Buy from Zaff',
          ),
      ];
      // Remove the initial herb+birdhouse if we're adding individual dailies
      if (dailies.isNotEmpty &&
          items.isNotEmpty &&
          items.first.method == 'Herb + Birdhouse Run') {
        remaining += items.first.minutes;
        items.removeAt(0);
      }
      for (final d in dailies) {
        if (remaining < d.minutes) continue;
        items.add(d);
        remaining -= d.minutes;
      }
      // Fill remaining with balanced training
      if (remaining > 10) {
        final skillSetD = <String>{};
        for (final g in viableGoals) {
          if (skillSetD.length >= 3 || remaining <= 0) break;
          if (skillSetD.contains(g.skill)) continue;
          skillSetD.add(g.skill);
          final slotMinutes = min(remaining, max(15, remaining ~/ 3));
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
      }
      break;

    case _FocusArea.pvmPrep:
      // Focus on skills that unlock bosses: Herblore for pots, Prayer, range/magic
      final pvmSkills = [
        'Herblore',
        'Prayer',
        'Ranged',
        'Magic',
        'Hitpoints',
        'Defence'
      ];
      // Remove default herb run for PvM focused plan
      if (items.isNotEmpty && items.first.method == 'Herb + Birdhouse Run') {
        remaining += items.first.minutes;
        items.removeAt(0);
      }
      // Add herb run back (important for PvM supplies)
      if (remaining >= 10) {
        items.add(const _SessionItem(
          skill: 'Herblore',
          method: 'Herb run → make potions',
          minutes: 10,
          xpGain: 25000,
          xpPerHour: 0,
          milestone: 'Prayer pots / Super restores supply',
          intensity: Intensity.active,
          notes: 'Farm herbs then make pots',
        ));
        remaining -= 10;
      }
      final pvmGoals = viableGoals
          .where((g) => pvmSkills.contains(g.skill))
          .toList()
        ..sort(
            (a, b) => b.bestMethod.xpPerHour.compareTo(a.bestMethod.xpPerHour));
      final skillSetP = <String>{};
      for (final g in pvmGoals) {
        if (skillSetP.length >= 3 || remaining <= 0) break;
        if (skillSetP.contains(g.skill)) continue;
        skillSetP.add(g.skill);
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
          notes: 'PvM prep: ${g.bestMethod.notes}',
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
