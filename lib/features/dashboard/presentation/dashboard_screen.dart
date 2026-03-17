import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../../goals/presentation/providers/goals_provider.dart';
import '../../sessions/presentation/providers/sessions_provider.dart';
import '../../goal_planner/presentation/providers/goal_planner_provider.dart';
import '../../goal_planner/data/training_methods_data.dart';
import '../../goal_planner/data/micro_goals_engine.dart';
import '../../ironman_supply/data/supply_chain_data.dart';
import '../../idle_adventure/presentation/providers/idle_game_provider.dart';
import '../../idle_adventure/data/idle_game_data.dart';
import 'providers/daily_checklist_provider.dart';

// Local aliases for semantic accent colors used throughout this screen.
const _gold = kGold;
const _cream = kCream;
const _parchment = kParchment;
const _green = kAccentGreen;
const _blue = kAccentBlue;
const _orange = kAccentOrange;
const _red = kAccentRed;

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final nextBest = ref.watch(nextBestGoalsProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final allSessions = ref.watch(activeCharacterSessionsProvider);

    final isIronman = activeChar != null &&
        {
          CharacterType.iron,
          CharacterType.hcim,
          CharacterType.uim,
          CharacterType.gim,
          CharacterType.hcgim
        }.contains(activeChar.characterType);

    // Build player levels from hiscores
    final playerLevels = <String, int>{};
    int? totalLevel;
    int? combatLevel;
    hiscoreState.whenData((result) {
      if (result != null) {
        for (final entry in result.skills.entries) {
          if (entry.value.level > 0) {
            playerLevels[entry.key] = entry.value.level;
          }
        }
        totalLevel = result.totalLevel;
        combatLevel = result.combatLevel;
      }
    });

    final hasStats = playerLevels.isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome header ──
            Row(
              children: [
                Flexible(
                  child: Text('Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                if (activeChar != null) ...[
                  const SizedBox(width: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person,
                            size: 13, color: _gold.withValues(alpha: 0.7)),
                        const SizedBox(width: 5),
                        Text(activeChar.displayName,
                            style: const TextStyle(
                                color: _gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (isIronman) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E9E9E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(activeChar.characterType.displayName,
                          style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: 4),
            if (activeChar == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: _gold.withValues(alpha: 0.4)),
                    const SizedBox(width: 6),
                    Text('No active character. Go to Characters to create one.',
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.4),
                            fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // ── Active session banner ──
            if (activeSession != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF1B3A1B).withValues(alpha: 0.7),
                    const Color(0xFF2D5F27).withValues(alpha: 0.4),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _green.withValues(alpha: 0.5),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Active Session',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _cream)),
                    const SizedBox(width: 8),
                    Text(activeSession.type.name,
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.7),
                            fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(activeSession.durationFormatted,
                          style: const TextStyle(
                              color: _green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ═══ TOP ROW: Progress Ring + Stats + Quick Actions ═══
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Skill Progress Ring ──
                if (hasStats)
                  _ProgressRingCard(
                    totalLevel: totalLevel ?? 0,
                    combatLevel: combatLevel ?? 3,
                  ),
                if (hasStats) const SizedBox(width: 12),

                // ── Stats Column ──
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _StatCard(
                            title: 'Active Goals',
                            value: goalsAsync.whenOrNull(
                                  data: (goals) => activeChar != null
                                      ? goals
                                          .where((g) =>
                                              g.characterId == activeChar.id &&
                                              g.status.name == 'active')
                                          .length
                                          .toString()
                                      : '0',
                                ) ??
                                '-',
                            icon: Icons.flag_rounded,
                            color: _blue,
                            bgColor: const Color(0xFF1A2940),
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            title: 'Sessions',
                            value: sessionsAsync.whenOrNull(
                                  data: (sessions) => activeChar != null
                                      ? sessions
                                          .where((s) =>
                                              s.characterId == activeChar.id &&
                                              !s.isActive)
                                          .length
                                          .toString()
                                      : '0',
                                ) ??
                                '-',
                            icon: Icons.timer_rounded,
                            color: _green,
                            bgColor: const Color(0xFF1A2E1A),
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            title: 'Next Steps',
                            value: nextBest.length.toString(),
                            icon: Icons.account_tree_rounded,
                            color: _orange,
                            bgColor: const Color(0xFF2E2410),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ── Quick Actions ──
                      _QuickActionsCard(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ═══ MIDDLE ROW: Daily Checklist + Weekly Playtime + Milestones ═══
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Daily Checklist ──
                const Expanded(flex: 2, child: _DailyChecklistCard()),
                const SizedBox(width: 12),
                // ── Weekly Playtime ──
                Expanded(
                  flex: 2,
                  child: _WeeklyPlaytimeCard(sessions: allSessions),
                ),
                const SizedBox(width: 12),
                // ── Milestones ──
                Expanded(
                  flex: 2,
                  child: _MilestoneCard(playerLevels: playerLevels),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ═══ BOTTOM ROW: Lowest Skills + Supply Chain + Tips ═══
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lowest Skills ──
                if (hasStats)
                  Expanded(
                    flex: 3,
                    child: _LowestSkillsCard(
                      playerLevels: playerLevels,
                      isIronman: isIronman,
                    ),
                  ),
                if (hasStats) const SizedBox(width: 12),

                // ── Supply Chain Alert (ironman) or Suggested Goals ──
                Expanded(
                  flex: 3,
                  child: isIronman && hasStats
                      ? _SupplyChainAlertCard(playerLevels: playerLevels)
                      : _SuggestedGoalsCard(nextBest: nextBest),
                ),
                const SizedBox(width: 12),

                // ── Random Tip ──
                Expanded(
                  flex: 2,
                  child: _RandomTipCard(
                    playerLevels: playerLevels,
                    isIronman: isIronman,
                  ),
                ),
              ],
            ),

            // ── Idle Adventurer status ──
            const SizedBox(height: 14),
            _IdleAdventurerCard(),

            // ── Current grind + Next login ──
            if (activeChar != null &&
                (activeChar.currentGrind.isNotEmpty ||
                    activeChar.nextLoginPurpose.isNotEmpty)) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeChar.currentGrind.isNotEmpty)
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFF6D00),
                        title: 'Current Grind',
                        content: activeChar.currentGrind,
                      ),
                    ),
                  if (activeChar.currentGrind.isNotEmpty &&
                      activeChar.nextLoginPurpose.isNotEmpty)
                    const SizedBox(width: 12),
                  if (activeChar.nextLoginPurpose.isNotEmpty)
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.login_rounded,
                        iconColor: _blue,
                        title: 'Next Login',
                        content: activeChar.nextLoginPurpose,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PROGRESS RING — Total level / 2277 with combat level center
// ═══════════════════════════════════════════════════════════════════

class _ProgressRingCard extends StatelessWidget {
  final int totalLevel;
  final int combatLevel;
  const _ProgressRingCard(
      {required this.totalLevel, required this.combatLevel});

  @override
  Widget build(BuildContext context) {
    final progress = totalLevel / 2277;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _RingPainter(progress: progress),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$combatLevel',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _gold)),
                      const Text('Combat',
                          style: TextStyle(fontSize: 9, color: Colors.white38)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('$totalLevel / 2277',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _cream)),
            Text('${(progress * 100).toStringAsFixed(1)}% to max',
                style: TextStyle(
                    fontSize: 10, color: _parchment.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════
//  QUICK ACTIONS — session shortcuts
// ═══════════════════════════════════════════════════════════════════

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: _orange),
                const SizedBox(width: 6),
                const Text('Quick Start',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _orange)),
                const Spacer(),
                Text('Plan a session',
                    style: TextStyle(
                        fontSize: 9, color: _parchment.withValues(alpha: 0.3))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _QuickBtn(
                    label: '30m',
                    icon: Icons.schedule,
                    onTap: () => context.go('/time-budget')),
                const SizedBox(width: 6),
                _QuickBtn(
                    label: '1 hr',
                    icon: Icons.schedule,
                    onTap: () => context.go('/time-budget')),
                const SizedBox(width: 6),
                _QuickBtn(
                    label: '2 hr',
                    icon: Icons.schedule,
                    onTap: () => context.go('/time-budget')),
                const SizedBox(width: 6),
                _QuickBtn(
                    label: 'Goals',
                    icon: Icons.flag,
                    color: _blue,
                    onTap: () => context.go('/planner')),
                const SizedBox(width: 6),
                _QuickBtn(
                    label: 'Pets',
                    icon: Icons.pets,
                    color: const Color(0xFF9C27B0),
                    onTap: () => context.go('/pet-hunter')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn({
    required this.label,
    required this.icon,
    this.color = _gold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DAILY CHECKLIST — interactive toggles
// ═══════════════════════════════════════════════════════════════════

class _DailyChecklistCard extends ConsumerWidget {
  const _DailyChecklistCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checks = ref.watch(dailyChecklistProvider);
    final done = checks.values.where((v) => v).length;
    final total = checks.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, size: 14, color: _green),
                const SizedBox(width: 6),
                const Text('Daily Checklist',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _green)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: done == total
                        ? _green.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$done/$total',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: done == total ? _green : Colors.white38,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...checks.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () =>
                        ref.read(dailyChecklistProvider.notifier).toggle(e.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            e.value
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 16,
                            color: e.value ? _green : Colors.white24,
                          ),
                          const SizedBox(width: 8),
                          Text(e.key,
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    e.value ? Colors.white38 : Colors.white70,
                                decoration:
                                    e.value ? TextDecoration.lineThrough : null,
                              )),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WEEKLY PLAYTIME — bar chart from sessions
// ═══════════════════════════════════════════════════════════════════

class _WeeklyPlaytimeCard extends StatelessWidget {
  final List sessions;
  const _WeeklyPlaytimeCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final minutesPerDay = List.filled(7, 0);

    for (final s in sessions) {
      if (s.isActive) continue;
      final daysDiff = now.difference(s.startTime).inDays;
      if (daysDiff < 7) {
        final dayIndex = (s.startTime.weekday - 1) % 7;
        minutesPerDay[dayIndex] =
            minutesPerDay[dayIndex] + s.duration.inMinutes as int;
      }
    }

    final maxMinutes = minutesPerDay.reduce((a, b) => a > b ? a : b);
    final totalMinutes = minutesPerDay.reduce((a, b) => a + b);
    final todayIndex = (now.weekday - 1) % 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 14, color: _blue),
                const SizedBox(width: 6),
                const Text('This Week',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _blue)),
                const Spacer(),
                Text(_fmtMinutes(totalMinutes),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _blue)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final pct =
                      maxMinutes > 0 ? minutesPerDay[i] / maxMinutes : 0.0;
                  final isToday = i == todayIndex;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (minutesPerDay[i] > 0)
                            Text(_fmtMinutes(minutesPerDay[i]),
                                style: TextStyle(
                                    fontSize: 7,
                                    color: isToday ? _gold : Colors.white30)),
                          const SizedBox(height: 2),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: max(pct, 0.04),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? _gold
                                        : _blue.withValues(alpha: 0.5),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(3)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(weekDays[i],
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w400,
                                color: isToday ? _gold : Colors.white30,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtMinutes(int m) {
    if (m >= 60) return '${m ~/ 60}h ${m % 60}m';
    return '${m}m';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  MILESTONE COUNTDOWN — closest level-ups
// ═══════════════════════════════════════════════════════════════════

class _MilestoneCard extends StatelessWidget {
  final Map<String, int> playerLevels;
  const _MilestoneCard({required this.playerLevels});

  @override
  Widget build(BuildContext context) {
    if (playerLevels.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, size: 14, color: _gold),
                  SizedBox(width: 6),
                  Text('Milestones',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _gold)),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('Look up a character to see milestones',
                    style: TextStyle(
                        fontSize: 10,
                        color: _parchment.withValues(alpha: 0.3))),
              ),
            ],
          ),
        ),
      );
    }

    // Find skills closest to next level
    final milestones = <_MilestoneInfo>[];
    for (final entry in playerLevels.entries) {
      if (entry.key == 'Overall') continue;
      final level = entry.value;
      if (level >= 99) continue;
      final currentXp = xpForLevel(level);
      final nextXp = xpForLevel(level + 1);
      final xpNeeded = nextXp - currentXp;
      milestones.add(_MilestoneInfo(
        skill: entry.key,
        level: level,
        xpToNext: xpNeeded,
      ));
    }
    milestones.sort((a, b) => a.xpToNext.compareTo(b.xpToNext));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, size: 14, color: _gold),
                SizedBox(width: 6),
                Text('Closest Level-Ups',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _gold)),
              ],
            ),
            const SizedBox(height: 8),
            ...milestones.take(5).map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(m.skill,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white60),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('${m.level} → ${m.level + 1}',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _gold)),
                      ),
                      const Spacer(),
                      Text(_fmtXp(m.xpToNext),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white38)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _MilestoneInfo {
  final String skill;
  final int level;
  final int xpToNext;
  const _MilestoneInfo(
      {required this.skill, required this.level, required this.xpToNext});
}

// ═══════════════════════════════════════════════════════════════════
//  LOWEST SKILLS — with mini progress bars + best method
// ═══════════════════════════════════════════════════════════════════

class _LowestSkillsCard extends StatelessWidget {
  final Map<String, int> playerLevels;
  final bool isIronman;
  const _LowestSkillsCard({required this.playerLevels, this.isIronman = false});

  @override
  Widget build(BuildContext context) {
    final skills = playerLevels.entries
        .where((e) => e.key != 'Overall')
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, size: 14, color: _orange),
                const SizedBox(width: 6),
                const Text('Lowest Skills',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _orange)),
                const Spacer(),
                Text('Train these for max total',
                    style: TextStyle(
                        fontSize: 9, color: _parchment.withValues(alpha: 0.3))),
              ],
            ),
            const SizedBox(height: 10),
            ...skills.take(5).map((e) {
              final pct = e.value / 99;
              final info = trainingData[e.key];
              final method = info?.bestMethodAt(e.value, isIronman: isIronman);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 75,
                      child: Text(e.key,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      width: 28,
                      alignment: Alignment.center,
                      child: Text('${e.value}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: e.value < 30
                                ? _red
                                : e.value < 60
                                    ? _orange
                                    : _green,
                          )),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(
                            e.value < 30
                                ? _red.withValues(alpha: 0.6)
                                : e.value < 60
                                    ? _orange.withValues(alpha: 0.6)
                                    : _green.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        method?.method ?? '',
                        style: TextStyle(
                            fontSize: 9,
                            color: _parchment.withValues(alpha: 0.4)),
                        overflow: TextOverflow.ellipsis,
                      ),
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

// ═══════════════════════════════════════════════════════════════════
//  SUPPLY CHAIN ALERT — ironman bottlenecks
// ═══════════════════════════════════════════════════════════════════

class _SupplyChainAlertCard extends StatelessWidget {
  final Map<String, int> playerLevels;
  const _SupplyChainAlertCard({required this.playerLevels});

  @override
  Widget build(BuildContext context) {
    final bottlenecks = SupplyChainEngine.findBottlenecks(playerLevels);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber,
                    size: 14, color: bottlenecks.isEmpty ? _green : _orange),
                const SizedBox(width: 6),
                Text('Supply Chain',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: bottlenecks.isEmpty ? _green : _orange)),
                const Spacer(),
                InkWell(
                  onTap: () => context.go('/ironman-supply'),
                  child: Text('View all →',
                      style: TextStyle(
                          fontSize: 9, color: _gold.withValues(alpha: 0.6))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (bottlenecks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: _green),
                    SizedBox(width: 8),
                    Text('No critical bottlenecks!',
                        style: TextStyle(fontSize: 11, color: _green)),
                  ],
                ),
              )
            else
              ...bottlenecks.take(3).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.block, size: 12, color: _red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${b.skill} Lv${b.currentLevel} → ${b.neededLevel}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                              Text('Blocks: ${b.blockedSkills.join(", ")}',
                                  style: const TextStyle(
                                      fontSize: 9, color: Colors.white38)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SUGGESTED GOALS — for non-ironman or no stats
// ═══════════════════════════════════════════════════════════════════

class _SuggestedGoalsCard extends StatelessWidget {
  final List nextBest;
  const _SuggestedGoalsCard({required this.nextBest});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: _gold),
                const SizedBox(width: 6),
                const Text('Suggested Goals',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _gold)),
                const Spacer(),
                InkWell(
                  onTap: () => context.go('/planner'),
                  child: Text('View all →',
                      style: TextStyle(
                          fontSize: 9, color: _gold.withValues(alpha: 0.6))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (nextBest.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Add goals in the Goal Planner',
                      style: TextStyle(
                          fontSize: 10,
                          color: _parchment.withValues(alpha: 0.3))),
                ),
              )
            else
              ...nextBest.take(4).map((node) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right,
                            size: 14, color: _gold.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(node.title,
                              style:
                                  const TextStyle(fontSize: 11, color: _cream),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  RANDOM TIPS — contextual tips based on account
// ═══════════════════════════════════════════════════════════════════

class _RandomTipCard extends HookWidget {
  final Map<String, int> playerLevels;
  final bool isIronman;
  const _RandomTipCard({required this.playerLevels, this.isIronman = false});

  @override
  Widget build(BuildContext context) {
    final tipIndex = useState(Random().nextInt(_allTips.length));

    // Pick contextual tips when possible
    final tips = <String>[];
    final slayer = playerLevels['Slayer'] ?? 1;
    final herb = playerLevels['Herblore'] ?? 1;
    final agility = playerLevels['Agility'] ?? 1;
    final con = playerLevels['Construction'] ?? 1;

    if (slayer < 87) {
      tips.add(
          '87 Slayer unlocks Kraken — one of the most AFK and profitable Slayer bosses.');
    }
    if (herb < 78) {
      tips.add(
          '78 Herblore lets you boost to make Super antifires — essential for Vorkath.');
    }
    if (agility < 70) {
      tips.add(
          '70 Agility unlocks the Saradomin GWD shortcut and improves run energy significantly.');
    }
    if (con < 82) {
      tips.add(
          '82 Construction with a crystal saw + spicy stew builds the Ornate rejuvenation pool — massive QoL.');
    }
    if (isIronman) {
      tips.add(
          'Do your Farming contracts every day — they\'re the best seed source for ironmen.');
      tips.add(
          'Giant seaweed + sandstone = Superglass Make. Most efficient Crafting XP for ironmen.');
    }

    tips.addAll(_allTips);
    final tip = tips[tipIndex.value % tips.length];

    return Card(
      color: _gold.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, size: 14, color: _gold),
                const SizedBox(width: 6),
                const Text('Tip',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _gold)),
                const Spacer(),
                InkWell(
                  onTap: () => tipIndex.value = Random().nextInt(tips.length),
                  child: const Icon(Icons.refresh,
                      size: 14, color: Colors.white24),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(tip,
                style: TextStyle(
                    fontSize: 11,
                    color: _parchment.withValues(alpha: 0.6),
                    height: 1.4)),
          ],
        ),
      ),
    );
  }
}

const _allTips = [
  'Start every session with herb + birdhouse runs. Free XP adds up fast over time.',
  'Tears of Guthix every week gives XP in your lowest skill. Never skip it.',
  'Diary rewards compound over time. Prioritize Varrock Medium (battlestaves) and Ardougne Medium (thieving).',
  'Quest XP rewards can skip slow early training. Check the Quest XP Calculator before grinding.',
  'NMZ is best done in Rumble (Hard) with absorption potions. Locator orb to 1 HP.',
  'Slayer is one of the most important skills — it funds Prayer, Herblore, and gear upgrades.',
  'The Bone Voyage quest unlocks Fossil Island — birdhouse runs, herbiboar, and volcanic mine.',
  'Fire cape should be a priority. It\'s the best melee cape until Infernal and boosts your DPS significantly.',
  'Managing Miscellania (after Royal Trouble) gives passive herbs, seeds, coal, and planks. Keep favor at 100%.',
  'Questing early is the most efficient way to build an account. Aim for Recipe for Disaster completion.',
];

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  const _InfoCard(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 6),
                Text(title,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _parchment.withValues(alpha: 0.5))),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, color: _cream)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    Text(title,
                        style: TextStyle(
                            fontSize: 10,
                            color: _parchment.withValues(alpha: 0.5))),
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

// ═══════════════════════════════════════════════════════════════════
//  IDLE ADVENTURER STATUS — quick view of idle game on dashboard
// ═══════════════════════════════════════════════════════════════════

class _IdleAdventurerCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(idleGameProvider);
    final notifier = ref.read(idleGameProvider.notifier);
    final monster = getMonster(game.monsterIndex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_esports, size: 14, color: _gold),
                const SizedBox(width: 6),
                const Text('Idle Adventurer',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _gold)),
                const SizedBox(width: 8),
                if (game.isRunning)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: _green.withValues(alpha: 0.5),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('Fighting',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: _green)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Idle',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white30)),
                  ),
                const Spacer(),
                InkWell(
                  onTap: () => context.go('/idle-adventure'),
                  child: Text('Open →',
                      style: TextStyle(
                          fontSize: 9, color: _gold.withValues(alpha: 0.6))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Stats row
            Row(
              children: [
                // Current monster
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(monster.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(monster.name,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _cream),
                                overflow: TextOverflow.ellipsis),
                            Text(
                                'HP ${game.monsterCurrentHp}/${monster.hitpoints}',
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white38)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Kill count
                _IdleMiniStat(
                  icon: Icons.military_tech,
                  value: _fmtIdleNum(game.totalKills),
                  label: 'Kills',
                  color: _orange,
                ),
                const SizedBox(width: 12),
                // GP
                _IdleMiniStat(
                  icon: Icons.paid,
                  value: _fmtIdleNum(game.gp),
                  label: 'GP',
                  color: _gold,
                ),
                const SizedBox(width: 12),
                // Gear level
                _IdleMiniStat(
                  icon: Icons.shield,
                  value: '${game.equipment.length}/11',
                  label: 'Gear',
                  color: _blue,
                ),
                const SizedBox(width: 12),
                // Combat levels summary
                _IdleMiniStat(
                  icon: Icons.flash_on,
                  value:
                      '${game.stats.attackLevel}/${game.stats.strengthLevel}/${game.stats.defenceLevel}',
                  label: 'Atk/Str/Def',
                  color: _red,
                ),
                const SizedBox(width: 16),
                // Quick start/stop
                SizedBox(
                  height: 30,
                  child: game.isRunning
                      ? OutlinedButton.icon(
                          onPressed: () => notifier.stopCombat(),
                          icon: const Icon(Icons.stop, size: 12),
                          label: const Text('Stop',
                              style: TextStyle(fontSize: 10)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _red,
                            side:
                                BorderSide(color: _red.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => notifier.startCombat(),
                          icon: const Icon(Icons.play_arrow, size: 12),
                          label: const Text('Fight',
                              style: TextStyle(fontSize: 10)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _green,
                            side: BorderSide(
                                color: _green.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                ),
              ],
            ),
            // Slayer task progress (if active)
            if (game.currentSlayerTask != null &&
                !game.currentSlayerTask!.isComplete) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.assignment, size: 12, color: _green),
                  const SizedBox(width: 4),
                  Text(
                    'Slayer: ${getMonsterDefById(game.currentSlayerTask!.monsterId)?.name ?? game.currentSlayerTask!.monsterId} '
                    '${game.currentSlayerTask!.amountKilled}/${game.currentSlayerTask!.amountTotal}',
                    style: TextStyle(
                        fontSize: 9, color: _parchment.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IdleMiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _IdleMiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: color),
            overflow: TextOverflow.ellipsis),
        Text(label,
            style: TextStyle(
                fontSize: 7, color: _parchment.withValues(alpha: 0.35))),
      ],
    );
  }
}

String _fmtIdleNum(int amount) {
  if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
  if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
  return amount.toString();
}

String _fmtXp(int xp) {
  if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
  if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
  return '$xp';
}
