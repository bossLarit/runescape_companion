import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/idle_models.dart';
import '../data/idle_game_data.dart';
import '../data/idle_game_engine.dart';
import '../data/idle_items.dart';
import '../data/idle_achievements.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import 'providers/idle_game_provider.dart';
import 'widgets/pixel_sprite.dart';
import '../data/pixel_art_data.dart';
import '../data/gear_sprites.dart';

const _gold = Color(0xFFD4A017);
const _parchment = Color(0xFFD2C3A3);
const _darkBg = Color(0xFF1A1208);
const _cardBg = Color(0xFF231A0E);

String _formatGp(int amount) {
  if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
  if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
  return amount.toString();
}

class IdleAdventureScreen extends ConsumerWidget {
  const IdleAdventureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(idleGameProvider);
    final notifier = ref.read(idleGameProvider.notifier);
    final monster = getMonster(game.monsterIndex);
    final offlineResult = notifier.pendingOfflineResult;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline progress banner
            if (offlineResult != null && offlineResult.killsGained > 0)
              _OfflineProgressBanner(
                result: offlineResult,
                onDismiss: () => notifier.clearOfflineResult(),
              ),

            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Idle Adventurer',
                    style: Theme.of(context).textTheme.headlineMedium),
                if (game.prestigeLevel > 0) ...[
                  const SizedBox(width: 12),
                  _Badge(
                    text: 'Prestige ${game.prestigeLevel}',
                    color: Colors.purple,
                  ),
                ],
                const Spacer(),
                _GpDisplay(gp: game.gp),
                const SizedBox(width: 16),
                if (!game.isRunning)
                  ElevatedButton.icon(
                    onPressed: () => notifier.startCombat(),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Fight'),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB33831),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => notifier.stopCombat(),
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('Stop'),
                  ),
              ],
            ),

            // Drop notification
            if (game.lastDrop != null) ...[
              const SizedBox(height: 8),
              _DropBanner(dropName: game.lastDrop!),
            ],
            const SizedBox(height: 16),

            // Main content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Combat area
                  Expanded(
                    flex: 3,
                    child: _CombatArea(
                      game: game,
                      monster: monster,
                      onSpecialAttack: notifier.queueSpecialAttack,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right: Tabbed sidebar
                  SizedBox(
                    width: 320,
                    child: _SidebarTabs(game: game, notifier: notifier),
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

// ─── Sidebar Tabs ──────────────────────────────────────────────

class _SidebarTabs extends StatelessWidget {
  final IdleGameState game;
  final IdleGameNotifier notifier;

  const _SidebarTabs({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold.withValues(alpha: 0.15)),
            ),
            child: TabBar(
              labelColor: _gold,
              unselectedLabelColor: _parchment.withValues(alpha: 0.35),
              indicatorColor: _gold,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              labelPadding: EdgeInsets.zero,
              tabs: const [
                Tab(icon: Icon(Icons.sports_kabaddi, size: 16), text: 'Combat'),
                Tab(icon: Icon(Icons.auto_graph, size: 16), text: 'Skills'),
                Tab(icon: Icon(Icons.shield, size: 16), text: 'Gear'),
                Tab(icon: Icon(Icons.emoji_events, size: 16), text: 'Progress'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                // ── Combat tab ──
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _MonsterSelector(
                      currentIndex: game.monsterIndex,
                      onSelect: notifier.selectMonster,
                      autoAdvance: game.autoAdvance,
                      onToggleAutoAdvance: notifier.toggleAutoAdvance,
                    ),
                    const SizedBox(height: 12),
                    _TrainingStyleSelector(
                      current: game.trainingStyle,
                      onChanged: notifier.setTrainingStyle,
                    ),
                    const SizedBox(height: 12),
                    _StatsPanel(stats: game.stats),
                    const SizedBox(height: 12),
                    _RaidPanel(game: game, notifier: notifier),
                  ],
                ),
                // ── Skills tab ──
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _SlayerPanel(
                      game: game,
                      onGetTask: notifier.getNewSlayerTask,
                      onCancelTask: notifier.cancelSlayerTask,
                    ),
                    const SizedBox(height: 12),
                    _PrayerPanel(
                      game: game,
                      onSetPrayer: notifier.setActivePrayer,
                      onBuyPotion: notifier.buyPrayerPotion,
                      onBuyPotion10: notifier.buyPrayerPotion10,
                      onRecharge: notifier.rechargePrayerAtAltar,
                    ),
                    const SizedBox(height: 12),
                    _SkillingPanel(
                      game: game,
                      onStartSkilling: notifier.startSkilling,
                      onStopSkilling: notifier.stopSkilling,
                    ),
                  ],
                ),
                // ── Gear tab ──
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _EquipmentPanel(game: game, notifier: notifier),
                    const SizedBox(height: 12),
                    _GeneralShopPanel(game: game, notifier: notifier),
                    const SizedBox(height: 12),
                    _BankPanel(
                      game: game,
                      onWithdrawFood: notifier.withdrawFood,
                      notifier: notifier,
                    ),
                  ],
                ),
                // ── Progress tab ──
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _StatsComparisonPanel(game: game),
                    const SizedBox(height: 12),
                    _CollectionLogPanel(game: game),
                    const SizedBox(height: 12),
                    _AchievementsPanel(game: game),
                    const SizedBox(height: 12),
                    _PrestigeCard(
                      game: game,
                      onPrestige: notifier.doPrestige,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge ─────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

// ─── Drop Banner ───────────────────────────────────────────────

class _DropBanner extends StatelessWidget {
  final String dropName;
  const _DropBanner({required this.dropName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _gold.withValues(alpha: 0.2),
          _gold.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 18, color: _gold),
          const SizedBox(width: 8),
          Text('New gear drop: $dropName!',
              style: const TextStyle(
                  color: _gold, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Offline Progress Banner ─────────────────────────────────────

class _OfflineProgressBanner extends StatelessWidget {
  final OfflineProgressResult result;
  final VoidCallback onDismiss;

  const _OfflineProgressBanner({
    required this.result,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final hours = result.elapsed.inHours;
    final minutes = result.elapsed.inMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF2196F3).withValues(alpha: 0.2),
          const Color(0xFF2196F3).withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bedtime, size: 22, color: Color(0xFF64B5F6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back!',
                    style: TextStyle(
                        color: Color(0xFF64B5F6),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'While you were away ($timeStr): '
                  '${result.killsGained} kills, '
                  '+${_formatGp(result.gpGained)} gp',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white38),
            onPressed: onDismiss,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─── Slayer Panel ───────────────────────────────────────────────

class _SlayerPanel extends StatelessWidget {
  final IdleGameState game;
  final VoidCallback onGetTask;
  final VoidCallback onCancelTask;

  const _SlayerPanel({
    required this.game,
    required this.onGetTask,
    required this.onCancelTask,
  });

  @override
  Widget build(BuildContext context) {
    final task = game.currentSlayerTask;
    final slayerLvl = game.slayerLevel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Slayer',
                  style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Text('Lvl $slayerLvl',
                  style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              if (game.slayerTasksCompleted > 0) ...[
                const SizedBox(width: 8),
                Text('${game.slayerTasksCompleted} done',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.4),
                        fontSize: 10)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (task != null && !task.isComplete) ...[
            _SlayerTaskRow(task: task),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancelTask,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.withValues(alpha: 0.7),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
                child:
                    const Text('Cancel Task', style: TextStyle(fontSize: 11)),
              ),
            ),
          ] else ...[
            Text(
              task != null && task.isComplete
                  ? 'Task complete! Get a new one.'
                  : 'No active task. Visit the Slayer Master!',
              style: TextStyle(
                  color: _parchment.withValues(alpha: 0.5), fontSize: 11),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGetTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: const Text('Get Slayer Task',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlayerTaskRow extends StatelessWidget {
  final SlayerTask task;
  const _SlayerTaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final monsterDef = getMonsterDefById(task.monsterId);
    final name = monsterDef?.name ?? task.monsterId;
    final icon = monsterDef?.icon ?? '?';
    final progress = task.amountKilled / task.amountTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Kill $name',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
            Text('${task.amountKilled}/${task.amountTotal}',
                style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Reward: +${_formatGp(task.bonusGp)} gp, +${_formatGp(task.bonusSlayerXp)} slayer xp',
          style:
              TextStyle(color: _parchment.withValues(alpha: 0.35), fontSize: 9),
        ),
      ],
    );
  }
}

// ─── Prayer Panel ───────────────────────────────────────────────

class _PrayerPanel extends StatelessWidget {
  final IdleGameState game;
  final void Function(ActivePrayer) onSetPrayer;
  final void Function(String) onBuyPotion;
  final void Function(String) onBuyPotion10;
  final VoidCallback onRecharge;

  const _PrayerPanel({
    required this.game,
    required this.onSetPrayer,
    required this.onBuyPotion,
    required this.onBuyPotion10,
    required this.onRecharge,
  });

  @override
  Widget build(BuildContext context) {
    final prayerLvl = game.prayerLevel;
    final maxPts = game.maxPrayerPoints;
    final pts = game.prayerPoints;
    final prayerFraction = maxPts > 0 ? pts / maxPts : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF42A5F5).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Prayer',
                  style: TextStyle(
                      color: Color(0xFF42A5F5),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Text('Lvl $prayerLvl',
                  style: const TextStyle(
                      color: Color(0xFF90CAF9),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          // Prayer points bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prayerFraction,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$pts/$maxPts',
                  style:
                      const TextStyle(color: Color(0xFF90CAF9), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          // Prayer selectors
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _PrayerChip(
                label: 'Off',
                active: game.activePrayer == ActivePrayer.none,
                enabled: true,
                onTap: () => onSetPrayer(ActivePrayer.none),
              ),
              _PrayerChip(
                label: 'Protect Melee',
                active: game.activePrayer == ActivePrayer.protectFromMelee,
                enabled: prayerLvl >= 43 && pts > 0,
                onTap: () => onSetPrayer(ActivePrayer.protectFromMelee),
              ),
              _PrayerChip(
                label: 'Piety',
                active: game.activePrayer == ActivePrayer.piety,
                enabled: prayerLvl >= 70 && pts > 0,
                onTap: () => onSetPrayer(ActivePrayer.piety),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Altar recharge (free, out of combat only)
          if (!game.isRunning && pts < maxPts)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onRecharge,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF90CAF9),
                    side: BorderSide(
                        color: const Color(0xFF42A5F5).withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Recharge at Altar (free)',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            ),
          // Prayer potions
          Text('Prayer Potions',
              style: TextStyle(
                  color: _parchment.withValues(alpha: 0.5), fontSize: 10)),
          const SizedBox(height: 4),
          for (final potion in prayerPotions)
            _PrayerPotionRow(
              potion: potion,
              canBuy: game.gp >= potion.cost,
              onBuy: () => onBuyPotion(potion.id),
              onBuy10: () => onBuyPotion10(potion.id),
            ),
        ],
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _PrayerChip({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF42A5F5).withValues(alpha: 0.25)
              : enabled
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: active
                  ? const Color(0xFF42A5F5).withValues(alpha: 0.5)
                  : enabled
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.04)),
        ),
        child: Text(label,
            style: TextStyle(
                color: active
                    ? const Color(0xFF42A5F5)
                    : enabled
                        ? _parchment.withValues(alpha: 0.6)
                        : _parchment.withValues(alpha: 0.25),
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _PrayerPotionRow extends StatelessWidget {
  final PrayerPotion potion;
  final bool canBuy;
  final VoidCallback onBuy;
  final VoidCallback onBuy10;

  const _PrayerPotionRow({
    required this.potion,
    required this.canBuy,
    required this.onBuy,
    required this.onBuy10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(potion.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(potion.name,
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.7),
                        fontSize: 11)),
                Text(
                    '+${potion.restoreAmount} pts  ·  ${_formatGp(potion.cost)} gp',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.35),
                        fontSize: 9)),
              ],
            ),
          ),
          InkWell(
            onTap: canBuy ? onBuy : null,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: canBuy
                    ? _gold.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: canBuy
                        ? _gold.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text('Buy',
                  style: TextStyle(
                      color: canBuy ? _gold : Colors.white24, fontSize: 10)),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: canBuy ? onBuy10 : null,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: canBuy
                    ? _gold.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: canBuy
                        ? _gold.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.04)),
              ),
              child: Text('x10',
                  style: TextStyle(
                      color: canBuy
                          ? _gold.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.2),
                      fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GP Display ────────────────────────────────────────────────

class _GpDisplay extends StatelessWidget {
  final int gp;
  const _GpDisplay({required this.gp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.paid, size: 16, color: _gold),
          const SizedBox(width: 6),
          Text(_formatGp(gp),
              style: const TextStyle(
                  color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Combat Area ───────────────────────────────────────────────

class _CombatArea extends StatelessWidget {
  final IdleGameState game;
  final MonsterDef monster;
  final VoidCallback onSpecialAttack;

  const _CombatArea({
    required this.game,
    required this.monster,
    required this.onSpecialAttack,
  });

  @override
  Widget build(BuildContext context) {
    final monsterFrames =
        monsterSprites[monster.id] ?? monsterSprites['chicken']!;
    final playerFrames =
        getPlayerFramesFromEquipment(game.equipment, game.trainingStyle);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Combatants side-by-side (Player left, Monster right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player (left)
                Expanded(
                  child: Column(
                    children: [
                      AnimatedPixelSprite(
                        frames: playerFrames,
                        scale: 3,
                        attackTrigger: game.lastDamageDealt,
                        hitTrigger: game.lastDamageTaken,
                      ),
                      const SizedBox(height: 4),
                      const Text('You',
                          style: TextStyle(
                              color: _parchment,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      const Spacer(),
                      _HpBar(
                        label: 'You',
                        current: game.playerCurrentHp,
                        max: game.stats.hitpointsLevel,
                        color: const Color(0xFF4CAF50),
                        damage: game.lastDamageTaken,
                      ),
                    ],
                  ),
                ),
                // VS
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Text('VS',
                      style: TextStyle(
                          color: _gold.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                // Monster (right)
                Expanded(
                  child: Column(
                    children: [
                      AnimatedPixelSprite(
                        frames: monsterFrames,
                        scale: 3,
                        hitTrigger: game.lastDamageDealt,
                        attackTrigger: game.lastDamageTaken,
                      ),
                      const SizedBox(height: 4),
                      Text(monster.name,
                          style: const TextStyle(
                              color: _parchment,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      Text('CB Lv ${monster.combatLevel}',
                          style: TextStyle(
                              color: _gold.withValues(alpha: 0.5),
                              fontSize: 10)),
                      const SizedBox(height: 6),
                      const Spacer(),
                      _HpBar(
                        label: monster.name,
                        current: game.monsterCurrentHp,
                        max: monster.hitpoints,
                        color: const Color(0xFFB33831),
                        damage: game.lastDamageDealt,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Stats + special attack
          Divider(color: _gold.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech, size: 14, color: _gold),
              const SizedBox(width: 4),
              Text('${game.totalKills} kills',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.6), fontSize: 11)),
              if (game.deathCount > 0) ...[
                const SizedBox(width: 12),
                const Icon(Icons.dangerous, size: 12, color: Color(0xFFFF5252)),
                const SizedBox(width: 3),
                Text('${game.deathCount} deaths',
                    style: TextStyle(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                        fontSize: 10)),
              ],
              if (game.totalFood > 0) ...[
                const SizedBox(width: 12),
                Icon(Icons.restaurant,
                    size: 12, color: _gold.withValues(alpha: 0.5)),
                const SizedBox(width: 3),
                Text('${game.totalFood} food',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.5),
                        fontSize: 10)),
              ],
              const SizedBox(width: 16),
              _SpecialAttackButton(
                cooldown: game.specialAttackCooldown,
                queued: game.specialAttackQueued,
                isRunning: game.isRunning,
                onPressed: onSpecialAttack,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Combat log
          Expanded(
            child: game.combatLog.isEmpty && !game.isRunning
                ? Center(
                    child: Text('Press Fight to start',
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.3),
                            fontSize: 13)))
                : _ScrollableCombatLog(log: game.combatLog),
          ),
        ],
      ),
    );
  }
}

// ─── HP Bar ────────────────────────────────────────────────────

class _HpBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final int? damage;

  const _HpBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    this.damage,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
            const Spacer(),
            Text('$current / $max',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontFamily: 'monospace')),
            if (damage != null && damage! > 0) ...[
              const SizedBox(width: 8),
              Text('-$damage',
                  style: const TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

// ─── Scrollable Combat Log ──────────────────────────────────────

class _ScrollableCombatLog extends StatelessWidget {
  final List<String> log;
  const _ScrollableCombatLog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: log.length,
        itemBuilder: (_, i) {
          final line = log[log.length - 1 - i];
          Color color = _parchment.withValues(alpha: 0.5);
          if (line.contains('SPECIAL ATTACK')) {
            color = _gold;
          } else if (line.contains('defeated')) {
            color = const Color(0xFF4CAF50);
          } else if (line.contains('died')) {
            color = const Color(0xFFFF5252);
          } else if (line.contains('Gear drop')) {
            color = _gold;
          } else if (line.contains('You hit')) {
            color = const Color(0xFF4CAF50).withValues(alpha: 0.7);
          } else if (line.contains('hits you')) {
            color = const Color(0xFFFF5252).withValues(alpha: 0.7);
          } else if (line.contains('eat')) {
            color = const Color(0xFFFF9800);
          } else if (line.contains('Loot')) {
            color = const Color(0xFF8D6E63);
          } else if (line.contains('Lost') || line.contains('death tax')) {
            color = const Color(0xFFFF5252).withValues(alpha: 0.8);
          } else if (line.contains('Respawning')) {
            color = const Color(0xFFFF5252);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(line, style: TextStyle(color: color, fontSize: 11)),
          );
        },
      ),
    );
  }
}

// ─── Special Attack Button ──────────────────────────────────────

class _SpecialAttackButton extends StatelessWidget {
  final int cooldown;
  final bool queued;
  final bool isRunning;
  final VoidCallback onPressed;

  const _SpecialAttackButton({
    required this.cooldown,
    required this.queued,
    required this.isRunning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ready = cooldown <= 0 && !queued && isRunning;
    final label = queued
        ? 'Spec Queued...'
        : cooldown > 0
            ? 'Special ($cooldown)'
            : 'Special Attack';

    return SizedBox(
      width: 180,
      child: ElevatedButton.icon(
        onPressed: ready ? onPressed : null,
        icon: Icon(Icons.bolt, size: 16, color: ready ? _gold : Colors.white24),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: ready
              ? _gold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          foregroundColor: ready ? _gold : Colors.white38,
          side: BorderSide(
              color: ready
                  ? _gold.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

// ─── Stats Panel ───────────────────────────────────────────────

class _StatsPanel extends StatelessWidget {
  final CombatStats stats;

  const _StatsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Combat Stats',
              style: TextStyle(
                  color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _StatRow(
              icon: Icons.gps_fixed,
              label: 'Attack',
              level: stats.attackLevel,
              xp: stats.attackXp,
              color: const Color(0xFFFF5252)),
          _StatRow(
              icon: Icons.flash_on,
              label: 'Strength',
              level: stats.strengthLevel,
              xp: stats.strengthXp,
              color: const Color(0xFF4CAF50)),
          _StatRow(
              icon: Icons.shield,
              label: 'Defence',
              level: stats.defenceLevel,
              xp: stats.defenceXp,
              color: const Color(0xFF2196F3)),
          _StatRow(
              icon: Icons.favorite,
              label: 'Hitpoints',
              level: stats.hitpointsLevel,
              xp: stats.hitpointsXp,
              color: const Color(0xFFFF9800)),
          _StatRow(
              icon: Icons.my_location,
              label: 'Ranged',
              level: stats.rangedLevel,
              xp: stats.rangedXp,
              color: const Color(0xFF8BC34A)),
          _StatRow(
              icon: Icons.auto_fix_high,
              label: 'Magic',
              level: stats.magicLevel,
              xp: stats.magicXp,
              color: const Color(0xFF9C27B0)),
        ],
      ),
    );
  }
}

// ─── Raid Panel ─────────────────────────────────────────────────

class _RaidPanel extends StatelessWidget {
  final IdleGameState game;
  final IdleGameNotifier notifier;

  const _RaidPanel({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    const raid = coxRaidDef;
    final activeRaid = game.activeRaid;
    final isInRaid = activeRaid != null && activeRaid.raidId == raid.id;
    final completions = game.raidCompletions[raid.id] ?? 0;
    final meetsReqs = game.stats.attackLevel >= raid.minAttack &&
        game.stats.strengthLevel >= raid.minStrength &&
        game.stats.defenceLevel >= raid.minDefence;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isInRaid
                ? Colors.purpleAccent.withValues(alpha: 0.4)
                : _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${raid.icon} ${raid.name}',
                  style: const TextStyle(
                      color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text('$completions kc',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.5), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          // Boss list with progress
          ...List.generate(raid.bosses.length, (i) {
            final boss = raid.bosses[i];
            final isCurrentBoss = isInRaid && activeRaid.bossIndex == i;
            final isDefeated = isInRaid && activeRaid.bossIndex > i;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: Text(
                      isDefeated
                          ? '✅'
                          : isCurrentBoss
                              ? '⚔️'
                              : '⬜',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${boss.name} (${boss.hitpoints} HP)',
                      style: TextStyle(
                        color: isCurrentBoss
                            ? _gold
                            : isDefeated
                                ? _parchment.withValues(alpha: 0.3)
                                : _parchment.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight:
                            isCurrentBoss ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCurrentBoss)
                    Text(
                      '${game.raidBossCurrentHp}/${boss.hitpoints}',
                      style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            );
          }),
          if (isInRaid) ...[
            const SizedBox(height: 8),
            // Boss HP bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: game.raidBossCurrentHp /
                    raid.bosses[activeRaid.bossIndex].hitpoints,
                backgroundColor: Colors.red.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.redAccent.withValues(alpha: 0.7)),
                minHeight: 6,
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Action button
          if (!game.isRunning && !isInRaid)
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: meetsReqs ? () => notifier.startRaid(raid.id) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: meetsReqs
                      ? _gold.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  foregroundColor: meetsReqs ? _gold : Colors.grey,
                  side: BorderSide(
                      color: meetsReqs
                          ? _gold.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  meetsReqs ? 'Start Raid' : 'Requires 90+ Atk/Str/Def',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          if (isInRaid)
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () => notifier.stopRaid(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child:
                    const Text('Abandon Raid', style: TextStyle(fontSize: 11)),
              ),
            ),
          if (!meetsReqs && !isInRaid)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Atk: ${game.stats.attackLevel}/90  Str: ${game.stats.strengthLevel}/90  Def: ${game.stats.defenceLevel}/90',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.4), fontSize: 9),
              ),
            ),
          // Unique drop chance info
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '~${(raid.uniqueDropChance * 100).toStringAsFixed(0)}% unique drop chance per completion (1/${(1 / raid.uniqueDropChance).round()})',
              style: TextStyle(
                  color: Colors.purpleAccent.withValues(alpha: 0.5),
                  fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int level;
  final int xp;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.level,
    required this.xp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevelXp = level < 99 ? xpForLevel(level + 1) : xpForLevel(99);
    final currentLevelXp = xpForLevel(level);
    final progress = level >= 99
        ? 1.0
        : ((xp - currentLevelXp) / (nextLevelXp - currentLevelXp))
            .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          SizedBox(
            width: 64,
            child: Text(label,
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
          ),
          Text('$level',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                color: color.withValues(alpha: 0.5),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Comparison Panel (Idle vs Real) ──────────────────────

class _StatsComparisonPanel extends ConsumerWidget {
  final IdleGameState game;
  const _StatsComparisonPanel({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final hiscoreState = ref.watch(hiscoresProvider);

    // Build real player levels from hiscores
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

    if (playerLevels.isEmpty || activeChar == null) {
      return const SizedBox.shrink();
    }

    final comparisons = <_CompareRow>[
      _CompareRow(
        skill: 'Attack',
        icon: Icons.gps_fixed,
        idle: game.stats.attackLevel,
        real: playerLevels['Attack'] ?? 1,
        color: const Color(0xFFFF5252),
      ),
      _CompareRow(
        skill: 'Strength',
        icon: Icons.flash_on,
        idle: game.stats.strengthLevel,
        real: playerLevels['Strength'] ?? 1,
        color: const Color(0xFF4CAF50),
      ),
      _CompareRow(
        skill: 'Defence',
        icon: Icons.shield,
        idle: game.stats.defenceLevel,
        real: playerLevels['Defence'] ?? 1,
        color: const Color(0xFF2196F3),
      ),
      _CompareRow(
        skill: 'Hitpoints',
        icon: Icons.favorite,
        idle: game.stats.hitpointsLevel,
        real: playerLevels['Hitpoints'] ?? 10,
        color: const Color(0xFFFF9800),
      ),
      _CompareRow(
        skill: 'Ranged',
        icon: Icons.my_location,
        idle: game.stats.rangedLevel,
        real: playerLevels['Ranged'] ?? 1,
        color: const Color(0xFF8BC34A),
      ),
      _CompareRow(
        skill: 'Magic',
        icon: Icons.auto_fix_high,
        idle: game.stats.magicLevel,
        real: playerLevels['Magic'] ?? 1,
        color: const Color(0xFF9C27B0),
      ),
      _CompareRow(
        skill: 'Prayer',
        icon: Icons.brightness_7,
        idle: game.prayerLevel,
        real: playerLevels['Prayer'] ?? 1,
        color: const Color(0xFF42A5F5),
      ),
      _CompareRow(
        skill: 'Slayer',
        icon: Icons.dangerous,
        idle: game.slayerLevel,
        real: playerLevels['Slayer'] ?? 1,
        color: const Color(0xFF795548),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows,
                  size: 14, color: Color(0xFFCE93D8)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('Idle vs Real',
                    style: TextStyle(
                        color: Color(0xFFCE93D8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              Text(activeChar.displayName,
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.4), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: 64,
                  child: Text('Skill',
                      style: TextStyle(
                          color: _parchment.withValues(alpha: 0.3),
                          fontSize: 9)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text('Idle',
                      style: TextStyle(
                          color: _parchment.withValues(alpha: 0.3),
                          fontSize: 9),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(width: 4),
                Expanded(child: Container()),
                SizedBox(
                  width: 32,
                  child: Text('Real',
                      style: TextStyle(
                          color: _parchment.withValues(alpha: 0.3),
                          fontSize: 9),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          for (final c in comparisons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(c.icon, size: 12, color: c.color.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 64,
                    child: Text(c.skill,
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.6),
                            fontSize: 11)),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 32,
                    child: Text('${c.idle}',
                        style: TextStyle(
                            color: c.idle >= c.real
                                ? const Color(0xFF4CAF50)
                                : _parchment.withValues(alpha: 0.5),
                            fontWeight: c.idle >= c.real
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child:
                        _CompareBar(idle: c.idle, real: c.real, color: c.color),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 32,
                    child: Text('${c.real}',
                        style: TextStyle(
                            color: c.real >= c.idle
                                ? const Color(0xFF4CAF50)
                                : _parchment.withValues(alpha: 0.5),
                            fontWeight: c.real >= c.idle
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CompareRow {
  final String skill;
  final IconData icon;
  final int idle;
  final int real;
  final Color color;

  const _CompareRow({
    required this.skill,
    required this.icon,
    required this.idle,
    required this.real,
    required this.color,
  });
}

class _CompareBar extends StatelessWidget {
  final int idle;
  final int real;
  final Color color;
  const _CompareBar(
      {required this.idle, required this.real, required this.color});

  @override
  Widget build(BuildContext context) {
    const maxVal = 99.0;
    final idlePct = (idle / maxVal).clamp(0.0, 1.0);
    final realPct = (real / maxVal).clamp(0.0, 1.0);

    return SizedBox(
      height: 8,
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Idle bar (left side, colored)
          FractionallySizedBox(
            widthFactor: idlePct,
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Real bar (overlay, smaller height, different shade)
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: realPct,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Equipment Panel ─────────────────────────────────────────────

class _EquipmentPanel extends StatelessWidget {
  final IdleGameState game;
  final IdleGameNotifier notifier;

  const _EquipmentPanel({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final bonuses = calcEquipmentBonuses(game.equipment);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Equipment',
                  style: TextStyle(
                      color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text('${game.equipment.length}/11 slots',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.4), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          // Show equipped items by slot
          for (final slot in EquipmentSlot.values)
            _EquipSlotRow(
              slot: slot,
              equippedId: game.equipment[slot.name],
              onUnequip: () => notifier.unequipSlot(slot),
            ),
          const SizedBox(height: 8),
          // Bonus summary
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BonusStat('⚔️', bonuses.meleeAttack),
                _BonusStat('💪', bonuses.meleeStrength),
                _BonusStat('🛡️', bonuses.meleeDefence),
                _BonusStat('🏹', bonuses.rangedAttack),
                _BonusStat('🔮', bonuses.magicAttack),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Equip from bank
          if (game.bank.entries.any((e) => getEquipmentDefById(e.key) != null))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank equipment:',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.5),
                        fontSize: 10)),
                const SizedBox(height: 4),
                for (final entry in game.bank.entries)
                  if (getEquipmentDefById(entry.key) != null)
                    _BankEquipRow(
                      itemId: entry.key,
                      qty: entry.value,
                      onEquip: () => notifier.equipItem(entry.key),
                    ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BonusStat extends StatelessWidget {
  final String icon;
  final int value;
  const _BonusStat(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Text('$icon$value',
        style: TextStyle(
            color: value > 0 ? _parchment : _parchment.withValues(alpha: 0.3),
            fontSize: 11));
  }
}

class _GearIcon extends StatelessWidget {
  final String itemId;
  final String fallbackIcon;
  final double scale;

  const _GearIcon({
    required this.itemId,
    required this.fallbackIcon,
    // ignore: unused_element_parameter
    this.scale = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final sprite = gearSprites[itemId];
    if (sprite != null) {
      return SizedBox(
        width: 8 * scale,
        height: 8 * scale,
        child: PixelSprite(grid: sprite, scale: scale),
      );
    }
    return Text(fallbackIcon, style: const TextStyle(fontSize: 12));
  }
}

class _EquipSlotRow extends StatelessWidget {
  final EquipmentSlot slot;
  final String? equippedId;
  final VoidCallback onUnequip;

  const _EquipSlotRow({
    required this.slot,
    required this.equippedId,
    required this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
    final def = equippedId != null ? getEquipmentDefById(equippedId!) : null;
    final slotLabel = slot.name[0].toUpperCase() + slot.name.substring(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(slotLabel,
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.4), fontSize: 10)),
          ),
          if (def != null) ...[
            _GearIcon(itemId: equippedId!, fallbackIcon: def.icon),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: def != null
                ? Text(def.name,
                    style: const TextStyle(color: _parchment, fontSize: 11),
                    overflow: TextOverflow.ellipsis)
                : Text('Empty',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.2),
                        fontSize: 10)),
          ),
          if (def != null)
            InkWell(
              onTap: onUnequip,
              child: Icon(Icons.close,
                  size: 12, color: Colors.red.withValues(alpha: 0.5)),
            ),
        ],
      ),
    );
  }
}

class _BankEquipRow extends StatelessWidget {
  final String itemId;
  final int qty;
  final VoidCallback onEquip;

  const _BankEquipRow({
    required this.itemId,
    required this.qty,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    final def = getEquipmentDefById(itemId);
    if (def == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          _GearIcon(itemId: itemId, fallbackIcon: def.icon),
          const SizedBox(width: 4),
          Expanded(
            child: Text(def.name,
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
          Text('x$qty ',
              style: TextStyle(
                  color: _parchment.withValues(alpha: 0.3), fontSize: 10)),
          SizedBox(
            height: 22,
            child: OutlinedButton(
              onPressed: onEquip,
              style: OutlinedButton.styleFrom(
                foregroundColor: _gold,
                side: BorderSide(color: _gold.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Equip', style: TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Monster Selector ──────────────────────────────────────────

class _MonsterSelector extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onSelect;
  final bool autoAdvance;
  final VoidCallback onToggleAutoAdvance;

  const _MonsterSelector({
    required this.currentIndex,
    required this.onSelect,
    required this.autoAdvance,
    required this.onToggleAutoAdvance,
  });

  @override
  Widget build(BuildContext context) {
    const monsters = monsterDefs;
    const bosses = bossDefs;
    final bossStartIndex = monsters.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Combat Targets',
                  style: TextStyle(
                      color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              InkWell(
                onTap: onToggleAutoAdvance,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: autoAdvance
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: autoAdvance
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        autoAdvance
                            ? Icons.fast_forward
                            : Icons.fast_forward_outlined,
                        size: 12,
                        color: autoAdvance
                            ? const Color(0xFF4CAF50)
                            : _parchment.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 4),
                      Text('Auto',
                          style: TextStyle(
                              color: autoAdvance
                                  ? const Color(0xFF81C784)
                                  : _parchment.withValues(alpha: 0.3),
                              fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 380,
            child: ListView(
              children: [
                // ── Monsters section ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Monsters',
                      style: TextStyle(
                          color: _parchment.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ),
                for (int i = 0; i < monsters.length; i++)
                  _MonsterTile(
                    monster: monsters[i],
                    isSelected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                // ── Bosses section ──
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('Bosses',
                          style: TextStyle(
                              color: Colors.redAccent.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.redAccent.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < bosses.length; i++)
                  _MonsterTile(
                    monster: bosses[i],
                    isSelected: (bossStartIndex + i) == currentIndex,
                    onTap: () => onSelect(bossStartIndex + i),
                    isBoss: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonsterTile extends StatelessWidget {
  final MonsterDef monster;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isBoss;

  const _MonsterTile({
    required this.monster,
    required this.isSelected,
    required this.onTap,
    this.isBoss = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _gold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: _gold.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: PixelSprite(
                grid: (monsterSprites[monster.id] ??
                    monsterSprites['chicken']!)[0],
                scale: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(monster.name,
                  style: TextStyle(
                      color: isSelected
                          ? _gold
                          : isBoss
                              ? Colors.redAccent.withValues(alpha: 0.7)
                              : _parchment.withValues(alpha: 0.7),
                      fontSize: 12)),
            ),
            Text('HP ${monster.hitpoints}',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.4), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── Training Style Selector ────────────────────────────────────

class _TrainingStyleSelector extends StatelessWidget {
  final TrainingStyle current;
  final void Function(TrainingStyle) onChanged;

  const _TrainingStyleSelector({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Training Style',
              style: TextStyle(
                  color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: TrainingStyle.values.map((style) {
              final isActive = style == current;
              final label =
                  style.name[0].toUpperCase() + style.name.substring(1);
              final color = switch (style) {
                TrainingStyle.attack => const Color(0xFFFF5252),
                TrainingStyle.strength => const Color(0xFF4CAF50),
                TrainingStyle.defence => const Color(0xFF2196F3),
                TrainingStyle.balanced => _gold,
                TrainingStyle.ranged => const Color(0xFF8BC34A),
                TrainingStyle.magic => const Color(0xFF9C27B0),
              };
              return InkWell(
                onTap: () => onChanged(style),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive
                          ? color.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(label,
                      style: TextStyle(
                        color: isActive
                            ? color
                            : _parchment.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            switch (current) {
              TrainingStyle.attack => 'All combat XP goes to Attack',
              TrainingStyle.strength => 'All combat XP goes to Strength',
              TrainingStyle.defence => 'All combat XP goes to Defence',
              TrainingStyle.balanced => 'Combat XP split evenly across melee',
              TrainingStyle.ranged => 'All combat XP goes to Ranged',
              TrainingStyle.magic => 'All combat XP goes to Magic',
            },
            style: TextStyle(
                color: _parchment.withValues(alpha: 0.35), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─── General Shop Panel ─────────────────────────────────────────

class _GeneralShopPanel extends StatelessWidget {
  final IdleGameState game;
  final IdleGameNotifier notifier;

  const _GeneralShopPanel({required this.game, required this.notifier});

  static const _slotOrder = [
    EquipmentSlot.weapon,
    EquipmentSlot.head,
    EquipmentSlot.body,
    EquipmentSlot.legs,
    EquipmentSlot.shield,
    EquipmentSlot.cape,
    EquipmentSlot.neck,
    EquipmentSlot.hands,
    EquipmentSlot.feet,
    EquipmentSlot.ammo,
    EquipmentSlot.ring,
  ];

  static const _slotLabels = {
    EquipmentSlot.weapon: 'Weapons',
    EquipmentSlot.head: 'Helmets',
    EquipmentSlot.body: 'Bodies',
    EquipmentSlot.legs: 'Legs',
    EquipmentSlot.shield: 'Shields',
    EquipmentSlot.cape: 'Capes',
    EquipmentSlot.neck: 'Necklaces',
    EquipmentSlot.hands: 'Gloves',
    EquipmentSlot.feet: 'Boots',
    EquipmentSlot.ammo: 'Ammo',
    EquipmentSlot.ring: 'Rings',
  };

  @override
  Widget build(BuildContext context) {
    final items = shopEquipment;
    final grouped = <EquipmentSlot, List<EquipmentItemDef>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.slot, () => []).add(item);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('General Store',
                  style: TextStyle(
                      color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text('${items.length} items',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.4), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          for (final slot in _slotOrder)
            if (grouped.containsKey(slot)) ...[
              Text(_slotLabels[slot] ?? slot.name,
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              for (final item in grouped[slot]!)
                _ShopItemRow(
                  item: item,
                  canAfford: game.gp >= item.buyPrice,
                  meetsReqs: _meetsRequirements(item),
                  onBuyEquip: () => notifier.buyAndEquipItem(item.id),
                  onBuyToBank: () => notifier.buyItemToBank(item.id),
                ),
              const SizedBox(height: 4),
            ],
        ],
      ),
    );
  }

  bool _meetsRequirements(EquipmentItemDef item) {
    if (game.stats.attackLevel < item.attackReq) return false;
    if (game.stats.defenceLevel < item.defenceReq) return false;
    if (game.stats.rangedLevel < item.rangedReq) return false;
    if (game.stats.magicLevel < item.magicReq) return false;
    if (game.prayerLevel < item.prayerReq) return false;
    return true;
  }
}

class _ShopItemRow extends StatelessWidget {
  final EquipmentItemDef item;
  final bool canAfford;
  final bool meetsReqs;
  final VoidCallback onBuyEquip;
  final VoidCallback onBuyToBank;

  const _ShopItemRow({
    required this.item,
    required this.canAfford,
    required this.meetsReqs,
    required this.onBuyEquip,
    required this.onBuyToBank,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = canAfford && meetsReqs;
    final statParts = <String>[];
    if (item.meleeAttack > 0) statParts.add('⚔️${item.meleeAttack}');
    if (item.meleeStrength > 0) statParts.add('💪${item.meleeStrength}');
    if (item.meleeDefence > 0) statParts.add('🛡️${item.meleeDefence}');
    if (item.rangedAttack > 0) statParts.add('🏹${item.rangedAttack}');
    if (item.rangedStrength > 0) statParts.add('🏹str${item.rangedStrength}');
    if (item.magicAttack > 0) statParts.add('🔮${item.magicAttack}');
    if (item.prayerBonus > 0) statParts.add('🙏${item.prayerBonus}');

    final reqParts = <String>[];
    if (item.attackReq > 0) reqParts.add('Atk ${item.attackReq}');
    if (item.defenceReq > 0) reqParts.add('Def ${item.defenceReq}');
    if (item.rangedReq > 0) reqParts.add('Rng ${item.rangedReq}');
    if (item.magicReq > 0) reqParts.add('Mag ${item.magicReq}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          _GearIcon(itemId: item.id, fallbackIcon: item.icon),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(
                        color: enabled
                            ? _parchment.withValues(alpha: 0.8)
                            : _parchment.withValues(alpha: 0.35),
                        fontSize: 11),
                    overflow: TextOverflow.ellipsis),
                if (statParts.isNotEmpty)
                  Text(statParts.join(' '),
                      style: TextStyle(
                          color: _parchment.withValues(alpha: 0.35),
                          fontSize: 9)),
                if (reqParts.isNotEmpty && !meetsReqs)
                  Text(reqParts.join(', '),
                      style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.5),
                          fontSize: 9)),
              ],
            ),
          ),
          Text('${_formatGp(item.buyPrice)}gp ',
              style: TextStyle(
                  color: canAfford
                      ? _gold.withValues(alpha: 0.7)
                      : Colors.red.withValues(alpha: 0.5),
                  fontSize: 10)),
          SizedBox(
            height: 22,
            child: OutlinedButton(
              onPressed: enabled ? onBuyEquip : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: _gold,
                side: BorderSide(
                    color: enabled
                        ? _gold.withValues(alpha: 0.3)
                        : _parchment.withValues(alpha: 0.1)),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: const Text('Buy', style: TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bank Panel ─────────────────────────────────────────────────

class _BankPanel extends StatelessWidget {
  final IdleGameState game;
  final void Function(String cookedItemId, int qty) onWithdrawFood;
  final IdleGameNotifier notifier;

  const _BankPanel({
    required this.game,
    required this.onWithdrawFood,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final bank = game.bank;
    final foodInv = game.foodInventory;

    // Group items by category
    final categories = <String, List<MapEntry<String, int>>>{};
    for (final entry in bank.entries) {
      if (entry.value <= 0) continue;
      final equipDef = getEquipmentDefById(entry.key);
      final item = getItemById(entry.key);
      final cat = equipDef != null ? 'equipment' : (item?.category ?? 'misc');
      categories.putIfAbsent(cat, () => []).add(entry);
    }

    final categoryOrder = [
      'equipment',
      'fish_cooked',
      'fish_raw',
      'ore',
      'bar',
      'log',
      'hide',
      'bone',
      'rune',
      'misc'
    ];
    final categoryNames = {
      'equipment': 'Equipment',
      'fish_cooked': 'Cooked Food',
      'fish_raw': 'Raw Food',
      'ore': 'Ores',
      'bar': 'Bars',
      'log': 'Logs',
      'hide': 'Hides',
      'bone': 'Bones',
      'rune': 'Runes',
      'misc': 'Misc',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF795548).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Bank',
                  style: TextStyle(
                      color: Color(0xFF8D6E63),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Text('${bank.values.where((v) => v > 0).length} items',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.4), fontSize: 10)),
            ],
          ),
          // Show food inventory status
          if (foodInv.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Food inventory: ${game.totalFood} (auto-eats at 50% HP)',
              style: TextStyle(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.6),
                  fontSize: 9),
            ),
          ],
          const SizedBox(height: 8),
          if (bank.isEmpty || bank.values.every((v) => v <= 0))
            Text('Bank is empty. Kill monsters for loot!',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.3), fontSize: 11))
          else
            for (final cat in categoryOrder)
              if (categories.containsKey(cat)) ...[
                Text(categoryNames[cat] ?? cat,
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                for (final entry in categories[cat]!)
                  _BankItemRow(
                    itemId: entry.key,
                    qty: entry.value,
                    isFood: cat == 'fish_cooked',
                    isEquipment: cat == 'equipment',
                    onWithdraw: cat == 'fish_cooked'
                        ? () => onWithdrawFood(entry.key, 1)
                        : null,
                    onWithdrawAll: cat == 'fish_cooked'
                        ? () => onWithdrawFood(entry.key, entry.value)
                        : null,
                    onEquip: cat == 'equipment'
                        ? () => notifier.equipItem(entry.key)
                        : null,
                  ),
                const SizedBox(height: 4),
              ],
        ],
      ),
    );
  }
}

class _BankItemRow extends StatelessWidget {
  final String itemId;
  final int qty;
  final bool isFood;
  final bool isEquipment;
  final VoidCallback? onWithdraw;
  final VoidCallback? onWithdrawAll;
  final VoidCallback? onEquip;

  const _BankItemRow({
    required this.itemId,
    required this.qty,
    required this.isFood,
    this.isEquipment = false,
    this.onWithdraw,
    this.onWithdrawAll,
    this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    final item = getItemById(itemId);
    final equipDef = getEquipmentDefById(itemId);
    final name = item?.name ?? equipDef?.name ?? itemId;
    final icon = item?.icon ?? equipDef?.icon ?? '?';
    final heal = cookedFoodHealAmounts[itemId];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          _GearIcon(itemId: itemId, fallbackIcon: icon),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.7),
                        fontSize: 11)),
                if (heal != null)
                  Text('+$heal HP',
                      style: TextStyle(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.5),
                          fontSize: 9)),
              ],
            ),
          ),
          Text('×$qty',
              style: const TextStyle(
                  color: _gold, fontSize: 10, fontWeight: FontWeight.bold)),
          if (isEquipment && onEquip != null) ...[
            const SizedBox(width: 6),
            SizedBox(
              height: 22,
              child: OutlinedButton(
                onPressed: onEquip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _gold,
                  side: BorderSide(color: _gold.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Equip', style: TextStyle(fontSize: 9)),
              ),
            ),
          ],
          if (isFood && onWithdraw != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onWithdraw,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
                ),
                child: const Text('Take',
                    style: TextStyle(color: Color(0xFFFF9800), fontSize: 9)),
              ),
            ),
            const SizedBox(width: 3),
            InkWell(
              onTap: onWithdrawAll,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.2)),
                ),
                child: const Text('All',
                    style: TextStyle(color: Color(0xFFFFB74D), fontSize: 9)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Skilling Panel ─────────────────────────────────────────────

class _SkillingPanel extends StatelessWidget {
  final IdleGameState game;
  final void Function(SkillType skill, String resourceId) onStartSkilling;
  final VoidCallback onStopSkilling;

  const _SkillingPanel({
    required this.game,
    required this.onStartSkilling,
    required this.onStopSkilling,
  });

  @override
  Widget build(BuildContext context) {
    final active = game.activeSkilling;
    final stats = game.skillingStats;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF66BB6A).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Skills',
                  style: TextStyle(
                      color: Color(0xFF66BB6A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              if (active != null)
                InkWell(
                  onTap: onStopSkilling,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB33831).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color:
                              const Color(0xFFB33831).withValues(alpha: 0.4)),
                    ),
                    child: const Text('Stop',
                        style:
                            TextStyle(color: Color(0xFFFF5252), fontSize: 10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Skill level overview
          for (final skill in SkillType.values)
            _SkillLevelRow(
              skill: skill,
              level: stats.levelFor(skill),
              xp: stats.xpFor(skill),
              isActive: active?.skill == skill,
            ),
          const SizedBox(height: 8),
          // Active skilling info
          if (active != null) ...[
            Builder(builder: (_) {
              final resource = getSkillingResourceById(active.resourceId);
              if (resource == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFF66BB6A).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${resource.icon} ${resource.name}  (+${resource.xpPerAction} xp)',
                      style: const TextStyle(
                          color: Color(0xFF81C784),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    if (resource.consumesItems.isNotEmpty)
                      Text(
                        'Uses: ${resource.consumesItems.entries.map((e) {
                          final item = getItemById(e.key);
                          return '${item?.name ?? e.key} ×${e.value}';
                        }).join(', ')}',
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.4),
                            fontSize: 9),
                      ),
                  ],
                ),
              );
            }),
            // Skilling log
            if (game.skillingLog.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 80,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _darkBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: game.skillingLog.length,
                    itemBuilder: (_, i) {
                      final line =
                          game.skillingLog[game.skillingLog.length - 1 - i];
                      Color color = _parchment.withValues(alpha: 0.5);
                      if (line.contains('✅')) {
                        color = const Color(0xFF81C784);
                      } else if (line.contains('🔥')) {
                        color = const Color(0xFFFF9800);
                      } else if (line.contains('❌')) {
                        color = const Color(0xFFFF5252);
                      }
                      return Text(line,
                          style: TextStyle(color: color, fontSize: 10));
                    },
                  ),
                ),
              ),
            ],
          ] else ...[
            // Resource picker when not skilling
            Text('Choose a skill to train:',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.4), fontSize: 10)),
            const SizedBox(height: 4),
            for (final skill in SkillType.values) ...[
              _SkillResourcePicker(
                skill: skill,
                level: stats.levelFor(skill),
                bank: game.bank,
                onStart: (resourceId) => onStartSkilling(skill, resourceId),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SkillLevelRow extends StatelessWidget {
  final SkillType skill;
  final int level;
  final int xp;
  final bool isActive;

  const _SkillLevelRow({
    required this.skill,
    required this.level,
    required this.xp,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevelXp = level < 99 ? xpForLevel(level + 1) : xpForLevel(99);
    final currentLevelXp = xpForLevel(level);
    final progress = level >= 99
        ? 1.0
        : ((xp - currentLevelXp) / (nextLevelXp - currentLevelXp))
            .clamp(0.0, 1.0);

    final skillInfo = _skillDisplayInfo(skill);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(skillInfo.icon,
              size: 12,
              color: isActive
                  ? skillInfo.color
                  : skillInfo.color.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          SizedBox(
            width: 72,
            child: Text(skillInfo.name,
                style: TextStyle(
                    color: isActive
                        ? skillInfo.color
                        : _parchment.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ),
          Text('$level',
              style: TextStyle(
                  color: skillInfo.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                color: skillInfo.color.withValues(alpha: 0.4),
                minHeight: 3,
              ),
            ),
          ),
          if (isActive)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.play_arrow, size: 10, color: Color(0xFF66BB6A)),
            ),
        ],
      ),
    );
  }
}

class _SkillResourcePicker extends StatelessWidget {
  final SkillType skill;
  final int level;
  final Map<String, int> bank;
  final void Function(String resourceId) onStart;

  const _SkillResourcePicker({
    required this.skill,
    required this.level,
    required this.bank,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final resources = getResourcesForSkill(skill);
    final available = resources.where((r) => level >= r.levelRequired).toList();
    if (available.isEmpty) return const SizedBox.shrink();

    final skillInfo = _skillDisplayInfo(skill);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text('${skillInfo.name} (Lv $level)',
          style: TextStyle(
              color: skillInfo.color,
              fontSize: 11,
              fontWeight: FontWeight.w500)),
      leading: Icon(skillInfo.icon, size: 14, color: skillInfo.color),
      iconColor: _parchment.withValues(alpha: 0.3),
      collapsedIconColor: _parchment.withValues(alpha: 0.3),
      children: [
        for (final r in available)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: InkWell(
              onTap: () {
                // Check if materials are available for processing skills
                if (r.consumesItems.isNotEmpty) {
                  bool hasMats = true;
                  for (final req in r.consumesItems.entries) {
                    if ((bank[req.key] ?? 0) < req.value) {
                      hasMats = false;
                      break;
                    }
                  }
                  if (!hasMats) return; // Can't start without materials
                }
                onStart(r.id);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(r.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: TextStyle(
                                  color: _parchment.withValues(alpha: 0.7),
                                  fontSize: 10)),
                          if (r.consumesItems.isNotEmpty)
                            Text(
                              r.consumesItems.entries.map((e) {
                                final item = getItemById(e.key);
                                final have = bank[e.key] ?? 0;
                                return '${item?.name ?? e.key}: $have/${e.value}';
                              }).join(', '),
                              style: TextStyle(
                                  color: _parchment.withValues(alpha: 0.3),
                                  fontSize: 8),
                            ),
                        ],
                      ),
                    ),
                    Text('+${r.xpPerAction} xp',
                        style: TextStyle(
                            color: skillInfo.color.withValues(alpha: 0.6),
                            fontSize: 9)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

({String name, IconData icon, Color color}) _skillDisplayInfo(SkillType skill) {
  return switch (skill) {
    SkillType.woodcutting => (
        name: 'Woodcutting',
        icon: Icons.park,
        color: const Color(0xFF795548)
      ),
    SkillType.mining => (
        name: 'Mining',
        icon: Icons.hardware,
        color: const Color(0xFF78909C)
      ),
    SkillType.fishing => (
        name: 'Fishing',
        icon: Icons.water,
        color: const Color(0xFF42A5F5)
      ),
    SkillType.cooking => (
        name: 'Cooking',
        icon: Icons.restaurant,
        color: const Color(0xFFFF9800)
      ),
    SkillType.smithing => (
        name: 'Smithing',
        icon: Icons.build,
        color: const Color(0xFF607D8B)
      ),
    SkillType.crafting => (
        name: 'Crafting',
        icon: Icons.brush,
        color: const Color(0xFF8D6E63)
      ),
  };
}

// ─── Achievements Panel ─────────────────────────────────────────

class _AchievementsPanel extends StatefulWidget {
  final IdleGameState game;
  const _AchievementsPanel({required this.game});

  @override
  State<_AchievementsPanel> createState() => _AchievementsPanelState();
}

class _AchievementsPanelState extends State<_AchievementsPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final completed = completedAchievements(game);
    final locked = lockedAchievements(game);
    final total = achievements.length;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Achievements',
                          style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const Spacer(),
                      Text('${completed.length}/$total',
                          style: TextStyle(
                              color: _parchment.withValues(alpha: 0.5),
                              fontSize: 11)),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? completed.length / total : 0.0,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in completed)
                    _AchievementRow(
                        icon: a.icon,
                        name: a.name,
                        desc: a.description,
                        done: true),
                  for (final a in locked.take(3))
                    _AchievementRow(
                        icon: '🔒',
                        name: a.name,
                        desc: a.description,
                        done: false),
                  if (locked.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${locked.length - 3} more locked',
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.3),
                            fontSize: 9),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final String icon;
  final String name;
  final String desc;
  final bool done;

  const _AchievementRow({
    required this.icon,
    required this.name,
    required this.desc,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: done
                            ? const Color(0xFFFFD700)
                            : _parchment.withValues(alpha: 0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                Text(desc,
                    style: TextStyle(
                        color: done
                            ? _parchment.withValues(alpha: 0.4)
                            : _parchment.withValues(alpha: 0.2),
                        fontSize: 9)),
              ],
            ),
          ),
          if (done)
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
        ],
      ),
    );
  }
}

// ─── Collection Log Panel ────────────────────────────────────────

class _CollectionLogPanel extends StatefulWidget {
  final IdleGameState game;
  const _CollectionLogPanel({required this.game});

  @override
  State<_CollectionLogPanel> createState() => _CollectionLogPanelState();
}

class _CollectionLogPanelState extends State<_CollectionLogPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final allMonsters = allMonsterDefs;
    final killed =
        allMonsters.where((m) => (game.monsterKillCounts[m.id] ?? 0) > 0);
    final discovered = killed.length;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('Collection Log',
                      style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const Spacer(),
                  Text('$discovered/${allMonsters.length}',
                      style: TextStyle(
                          color: _parchment.withValues(alpha: 0.5),
                          fontSize: 11)),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: _gold.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.totalKills} total kills · ${game.totalGearDrops} gear drops',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.35),
                        fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  for (final m in allMonsters)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        children: [
                          Text(m.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              m.name,
                              style: TextStyle(
                                color: (game.monsterKillCounts[m.id] ?? 0) > 0
                                    ? _parchment.withValues(alpha: 0.7)
                                    : _parchment.withValues(alpha: 0.2),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            '${game.monsterKillCounts[m.id] ?? 0}',
                            style: TextStyle(
                              color: (game.monsterKillCounts[m.id] ?? 0) > 0
                                  ? _gold
                                  : _parchment.withValues(alpha: 0.15),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}

// ─── Prestige Card ─────────────────────────────────────────────

class _PrestigeCard extends StatefulWidget {
  final IdleGameState game;
  final VoidCallback onPrestige;

  const _PrestigeCard({required this.game, required this.onPrestige});

  @override
  State<_PrestigeCard> createState() => _PrestigeCardState();
}

class _PrestigeCardState extends State<_PrestigeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final canPrestige = game.stats.attackLevel >= 99 &&
        game.stats.strengthLevel >= 99 &&
        game.stats.defenceLevel >= 99 &&
        game.stats.hitpointsLevel >= 99;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: canPrestige
                ? Colors.purple.withValues(alpha: 0.4)
                : _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('Prestige',
                      style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  if (game.prestigeLevel > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${((game.prestigeMultiplier - 1) * 100).toStringAsFixed(0)}% XP bonus',
                      style: const TextStyle(
                          color: Colors.purpleAccent, fontSize: 10),
                    ),
                  ],
                  const Spacer(),
                  if (canPrestige)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('READY',
                          style: TextStyle(
                              color: Colors.purpleAccent, fontSize: 9)),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.purpleAccent.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canPrestige
                        ? 'Reset all stats for +10% XP permanently!'
                        : 'Max all combat stats (99) to prestige',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.5), fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canPrestige ? widget.onPrestige : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Colors.white.withValues(alpha: 0.05),
                      ),
                      child: const Text('Prestige'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
