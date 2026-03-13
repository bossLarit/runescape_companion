import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/td_models.dart';
import '../data/td_game_data.dart';
import 'providers/td_game_provider.dart';
import 'widgets/td_game_canvas.dart';

const _gold = Color(0xFFD4A017);
const _parchment = Color(0xFFD2C3A3);
const _darkBg = Color(0xFF1A1208);
const _cardBg = Color(0xFF231A0E);

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

class TowerDefenseScreen extends ConsumerStatefulWidget {
  const TowerDefenseScreen({super.key});

  @override
  ConsumerState<TowerDefenseScreen> createState() => _TowerDefenseScreenState();
}

class _TowerDefenseScreenState extends ConsumerState<TowerDefenseScreen> {
  @override
  void initState() {
    super.initState();
    // If returning to screen with a paused wave, auto-resume
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tdGameProvider.notifier).resume();
    });
  }

  @override
  void deactivate() {
    ref.read(tdGameProvider.notifier).pause();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    ref.read(tdGameProvider.notifier).resume();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(tdGameProvider);
    final notifier = ref.read(tdGameProvider.notifier);

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.digit1) {
          notifier.useAbility(AbilityType.iceBarrage);
        } else if (key == LogicalKeyboardKey.digit2) {
          notifier.useAbility(AbilityType.cannonBlast);
        } else if (key == LogicalKeyboardKey.digit3) {
          notifier.useAbility(AbilityType.heal);
        } else if (key == LogicalKeyboardKey.space) {
          notifier.sendWave();
        } else if (key == LogicalKeyboardKey.escape) {
          notifier.selectSlot(null);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Header(game: game),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3,
                        child: _GameArea(game: game, notifier: notifier)),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 280,
                        child: _Sidebar(game: game, notifier: notifier)),
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

// ─── Header ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TdGameState game;
  const _Header({required this.game});

  ({double logs, double runes, double ore}) _productionRates() {
    const ticksPerSec = 62.5; // 1000ms / 16ms
    double logs = 0, runes = 0, ore = 0;
    for (final p in game.peasants) {
      if (p.assignedNodeIndex < 0 ||
          p.assignedNodeIndex >= game.resourceNodes.length) {
        continue;
      }
      final node = game.resourceNodes[p.assignedNodeIndex];
      final gatherTicks = peasantGatherTicksForLevel(node.level);
      final rate = ticksPerSec / gatherTicks;
      switch (node.type) {
        case NodeType.tree:
          logs += rate;
        case NodeType.runeAltar:
          runes += rate;
        case NodeType.mine:
          ore += rate;
      }
    }
    return (logs: logs, runes: runes, ore: ore);
  }

  @override
  Widget build(BuildContext context) {
    final rates = _productionRates();
    return Row(
      children: [
        Text('Tower Defense',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(width: 12),
        _Badge('Wave ${game.wave}', const Color(0xFF2196F3)),
        if (game.highestWave > 0) ...[
          const SizedBox(width: 6),
          _Badge('Best: ${game.highestWave}', const Color(0xFF9C27B0)),
        ],
        const Spacer(),
        _ResChip(Icons.monetization_on, _gold, _fmt(game.resources.gold), 'GP'),
        const SizedBox(width: 8),
        _ResChip(Icons.park, const Color(0xFF8D6E63), '${game.resources.logs}',
            'Logs',
            rate: rates.logs),
        const SizedBox(width: 8),
        _ResChip(Icons.auto_awesome, const Color(0xFF2196F3),
            '${game.resources.runes}', 'Runes',
            rate: rates.runes),
        const SizedBox(width: 8),
        _ResChip(Icons.diamond, const Color(0xFF808080),
            '${game.resources.ore}', 'Ore',
            rate: rates.ore),
        if (game.totalPrestigePoints > 0 || game.prestigePoints > 0) ...[
          const SizedBox(width: 8),
          _ResChip(Icons.stars, const Color(0xFF9C27B0),
              '${game.prestigePoints}', 'Prestige'),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

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

class _ResChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final double? rate;
  const _ResChip(this.icon, this.color, this.value, this.label, {this.rate});

  @override
  Widget build(BuildContext context) {
    final rateStr =
        rate != null && rate! > 0 ? ' (${rate!.toStringAsFixed(1)}/s)' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text('$value $label',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          if (rateStr.isNotEmpty)
            Text(rateStr,
                style: TextStyle(
                    color: color.withValues(alpha: 0.6), fontSize: 9)),
        ],
      ),
    );
  }
}

// ─── Game Canvas Area ────────────────────────────────────────────

class _GameArea extends StatelessWidget {
  final TdGameState game;
  final TdGameNotifier notifier;
  const _GameArea({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (ctx, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: (details) =>
              _onCanvasTap(context, canvasSize, details.localPosition),
          child: Stack(
            children: [
              Positioned.fill(
                  child:
                      CustomPaint(painter: TdGameCanvasPainter(state: game))),
              if (game.phase == TdPhase.idle)
                const _Overlay('Send Wave to Begin!', Icons.play_arrow),
              if (game.phase == TdPhase.waveComplete)
                _Overlay('Wave ${game.wave} Complete!', Icons.check_circle,
                    sub: 'Build towers & upgrade, then send next wave'),
              if (game.phase == TdPhase.gameOver)
                _Overlay('Game Over!', Icons.dangerous,
                    sub: 'Reached Wave ${game.wave}', isErr: true),
              if (game.phase == TdPhase.waveActive)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: _WaveBar(
                      game.enemiesKilledThisWave,
                      game.totalEnemiesThisWave,
                      game.wave,
                      game.currentModifier),
                ),
            ],
          ),
        );
      }),
    );
  }

  void _onCanvasTap(BuildContext context, Size size, Offset pos) {
    // Tower slot tap
    final slotIdx = hitTestTowerSlot(game, size, pos);
    if (slotIdx != null) {
      notifier.selectSlot(slotIdx);
      final slot = game.towerSlots[slotIdx];
      if (slot.isEmpty) {
        _showBuildMenu(context, slotIdx);
      } else {
        _showUpgradeMenu(context, slotIdx, slot);
      }
      return;
    }
    // Resource node tap
    final nodeIdx = hitTestResourceNode(game, size, pos);
    if (nodeIdx != null) {
      _showNodeUpgradeMenu(context, nodeIdx);
      return;
    }
    // Wall slot tap
    final wallIdx = hitTestWallSlot(game, size, pos);
    if (wallIdx != null) {
      _showWallMenu(context, wallIdx);
      return;
    }
    notifier.selectSlot(null);
  }

  void _showBuildMenu(BuildContext ctx, int slotIdx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: _darkBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Build Tower',
                style: TextStyle(
                    color: _gold, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Flexible(
                child: ListView(
              shrinkWrap: true,
              children: TowerType.values.map((type) {
                final def = towerDefs[type]!;
                final canAfford = game.resources.canAfford(def.cost);
                final icon = switch (type) {
                  TowerType.archer => Icons.gps_fixed,
                  TowerType.mage => Icons.auto_awesome,
                  TowerType.warrior => Icons.shield,
                  TowerType.house => Icons.house,
                  TowerType.cannon => Icons.track_changes,
                  TowerType.ballista => Icons.arrow_upward,
                  TowerType.poisonTrap => Icons.pest_control,
                };
                return ListTile(
                  leading: Icon(icon, color: canAfford ? _gold : Colors.grey),
                  title: Text(def.name,
                      style: TextStyle(
                          color: canAfford ? _parchment : Colors.grey)),
                  subtitle: Text(
                      canAfford
                          ? _costString(def.cost)
                          : '${_costString(def.cost)}\n${_missingString(def.cost, game.resources)}',
                      style: TextStyle(
                          color: canAfford
                              ? _parchment.withValues(alpha: 0.5)
                              : const Color(0xFFFF5252).withValues(alpha: 0.7),
                          fontSize: 11)),
                  trailing: canAfford
                      ? const Icon(Icons.add_circle, color: _gold, size: 20)
                      : const Icon(Icons.lock, color: Colors.grey, size: 20),
                  onTap: canAfford
                      ? () {
                          notifier.buildTower(slotIdx, type);
                          Navigator.pop(ctx);
                        }
                      : null,
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  void _showUpgradeMenu(BuildContext ctx, int slotIdx, TowerSlot slot) {
    final isHouse = slot.towerType == TowerType.house;
    final cost = isHouse
        ? houseUpgradeCost(slot.level)
        : towerUpgradeCost(slot.towerType!, slot.level);
    final canAfford = game.resources.canAfford(cost);
    final statStyle =
        TextStyle(color: _parchment.withValues(alpha: 0.7), fontSize: 12);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: _darkBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(builder: (sCtx, setSheetState) {
        final currentSlot = game.towerSlots[slotIdx];
        final targetLabel = switch (currentSlot.targetMode) {
          TargetMode.first => 'First',
          TargetMode.last => 'Last',
          TargetMode.strongest => 'Strongest',
          TargetMode.closest => 'Closest',
        };
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                      '${towerTypeName(slot.towerType!)} Lv${slot.level}',
                      style: const TextStyle(
                          color: _gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
                Text('${slot.kills} kills',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.5),
                        fontSize: 11)),
              ]),
              const SizedBox(height: 8),
              if (isHouse)
                Text('Peasant Cap: +1 per level (current: ${game.peasantCap})',
                    style: statStyle)
              else ...[
                Text(
                    'DMG: ${towerDamageAtLevel(slot.towerType!, slot.level).toStringAsFixed(1)} → ${towerDamageAtLevel(slot.towerType!, slot.level + 1).toStringAsFixed(1)}',
                    style: statStyle),
                Text(
                    'Range: ${(towerRangeAtLevel(slot.towerType!, slot.level) * 100).toStringAsFixed(0)}% → ${(towerRangeAtLevel(slot.towerType!, slot.level + 1) * 100).toStringAsFixed(0)}%',
                    style: statStyle),
                Text(
                    'Fire Rate: ${towerFireRateAtLevel(slot.towerType!, slot.level).toStringAsFixed(0)} ticks',
                    style: statStyle),
                if (slot.equippedLootId != null)
                  Text(
                      'Loot: ${game.inventory.where((l) => l.id == slot.equippedLootId).firstOrNull?.name ?? "?"}',
                      style: TextStyle(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                          fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('Target: ', style: statStyle),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2196F3).withValues(alpha: 0.2),
                      foregroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      notifier.cycleTargetMode(slotIdx);
                      setSheetState(() {});
                    },
                    child:
                        Text(targetLabel, style: const TextStyle(fontSize: 11)),
                  ),
                ]),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? const Color(0xFF2D5A1E)
                        : Colors.grey.shade800,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canAfford
                      ? () {
                          notifier.upgradeTowerAtSlot(slotIdx);
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: Text(
                      'Upgrade → Lv${slot.level + 1}  (${_costString(cost)})'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showNodeUpgradeMenu(BuildContext ctx, int nodeIdx) {
    final node = game.resourceNodes[nodeIdx];
    // No level cap — endless upgrades
    final cost = nodeUpgradeCost(node.type, node.level);
    final canAfford = game.resources.canAfford(cost);
    final currentName = nodeTierName(node.type, node.level);
    final nextName = nodeTierName(node.type, node.level + 1);
    final currentTicks = peasantGatherTicksForLevel(node.level);
    final nextTicks = peasantGatherTicksForLevel(node.level + 1);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: _darkBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upgrade $currentName',
                style: const TextStyle(
                    color: _gold, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$currentName → $nextName',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
            Text(
                'Gather: ${(currentTicks / 60).toStringAsFixed(1)}s → ${(nextTicks / 60).toStringAsFixed(1)}s',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford
                      ? const Color(0xFF2D5A1E)
                      : Colors.grey.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: canAfford
                    ? () {
                        notifier.doUpgradeNode(nodeIdx);
                        Navigator.pop(ctx);
                      }
                    : null,
                child: Text('Upgrade (${_costString(cost)})'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWallMenu(BuildContext ctx, int wallIdx) {
    final wall = game.wallSlots[wallIdx];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: _darkBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                wall.isEmpty
                    ? 'Build Wall'
                    : wall.isDestroyed
                        ? 'Repair Wall'
                        : 'Wall Lv${wall.level}',
                style: const TextStyle(
                    color: _gold, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (wall.isEmpty) ...[
              Text('HP: ${wallMaxHpAtLevel(1)}',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
              Text('Blocks enemies on the path',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.5), fontSize: 11)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A1E),
                      foregroundColor: Colors.white),
                  onPressed: game.resources.canAfford(wallBuildCost)
                      ? () {
                          notifier.doBuildWall(wallIdx);
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: Text('Build (${_costString(wallBuildCost)})'),
                ),
              ),
            ],
            if (wall.isDestroyed) ...[
              Text('Wall destroyed — repair to restore',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.5), fontSize: 11)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A1E),
                      foregroundColor: Colors.white),
                  onPressed: game.resources.ore >= 10
                      ? () {
                          notifier.doRepairWall(wallIdx);
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: const Text('Repair (10 Ore)'),
                ),
              ),
            ],
            if (wall.isBuilt) ...[
              Text('HP: ${wall.hp}/${wall.maxHp}',
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
              if (wall.isBuilt) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A1E),
                        foregroundColor: Colors.white),
                    onPressed:
                        game.resources.canAfford(wallUpgradeCost(wall.level))
                            ? () {
                                notifier.doUpgradeWall(wallIdx);
                                Navigator.pop(ctx);
                              }
                            : null,
                    child: Text(
                        'Upgrade → Lv${wall.level + 1} (${_costString(wallUpgradeCost(wall.level))})'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

String _costString(Resources cost) {
  final parts = <String>[];
  if (cost.gold > 0) parts.add('${cost.gold} GP');
  if (cost.logs > 0) parts.add('${cost.logs} Logs');
  if (cost.runes > 0) parts.add('${cost.runes} Runes');
  if (cost.ore > 0) parts.add('${cost.ore} Ore');
  return parts.join(' + ');
}

String _missingString(Resources cost, Resources have) {
  final parts = <String>[];
  if (cost.gold > have.gold) parts.add('${cost.gold - have.gold} GP');
  if (cost.logs > have.logs) parts.add('${cost.logs - have.logs} Logs');
  if (cost.runes > have.runes) parts.add('${cost.runes - have.runes} Runes');
  if (cost.ore > have.ore) parts.add('${cost.ore - have.ore} Ore');
  return parts.isEmpty ? '' : 'Need ${parts.join(', ')} more';
}

// ─── Overlays ────────────────────────────────────────────────────

class _Overlay extends StatelessWidget {
  final String text;
  final IconData icon;
  final String? sub;
  final bool isErr;
  const _Overlay(this.text, this.icon, {this.sub, this.isErr = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _darkBg.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isErr
                  ? const Color(0xFFB33831).withValues(alpha: 0.5)
                  : _gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isErr ? const Color(0xFFB33831) : _gold, size: 32),
            const SizedBox(height: 8),
            Text(text,
                style: TextStyle(
                    color: isErr ? const Color(0xFFFF5252) : _gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(sub!,
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.6), fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  final int killed, total, wave;
  final WaveModifier modifier;
  const _WaveBar(this.killed, this.total, this.wave, this.modifier);

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (killed / total).clamp(0.0, 1.0) : 0.0;
    final boss = isBossWave(wave);
    final treasure = isTreasureWave(wave);
    final label = treasure
        ? 'TREASURE WAVE $wave'
        : boss
            ? 'BOSS WAVE $wave'
            : 'Wave $wave';
    final barColor = treasure
        ? const Color(0xFFFFD700)
        : boss
            ? const Color(0xFFFF5252)
            : _gold;
    final modName = waveModifierName(modifier);
    final modColor = switch (modifier) {
      WaveModifier.armoured => const Color(0xFF90A4AE),
      WaveModifier.swift => const Color(0xFF4FC3F7),
      WaveModifier.horde => const Color(0xFFFF8A65),
      WaveModifier.regen => const Color(0xFF81C784),
      WaveModifier.shielded => const Color(0xFF64B5F6),
      WaveModifier.none => Colors.transparent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: _darkBg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Text(label,
                style: TextStyle(
                    color: barColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            if (modName.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: modColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: modColor.withValues(alpha: 0.4)),
                ),
                child: Text(modName,
                    style: TextStyle(
                        color: modColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ],
            const Spacer(),
            Text('$killed / $total killed',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.6), fontSize: 10)),
          ]),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation(barColor)),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final TdGameState game;
  final TdGameNotifier notifier;
  const _Sidebar({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final g = game.garrison;
    final nextWave =
        game.phase == TdPhase.waveComplete ? game.wave + 1 : game.wave;
    return ListView(
      children: [
        // ── Wave Control ──
        if (game.phase == TdPhase.idle || game.phase == TdPhase.waveComplete)
          _ActionBtn(
            label: isTreasureWave(nextWave)
                ? 'Treasure Wave $nextWave'
                : isBossWave(nextWave)
                    ? 'Boss Wave $nextWave'
                    : 'Send Wave $nextWave',
            icon: isTreasureWave(nextWave)
                ? Icons.card_giftcard
                : Icons.play_arrow,
            color: isTreasureWave(nextWave)
                ? const Color(0xFFB8860B)
                : isBossWave(nextWave)
                    ? const Color(0xFF8B0000)
                    : const Color(0xFF2D5A1E),
            onTap: notifier.sendWave,
          ),
        // ── Wave Preview ──
        if (game.phase == TdPhase.idle || game.phase == TdPhase.waveComplete)
          _WavePreview(
              wave: game.phase == TdPhase.waveComplete
                  ? game.wave + 1
                  : game.wave),
        // ── Auto-Continue Toggle ──
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: notifier.autoContinue ? const Color(0xFF2D5A1E) : _cardBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: notifier.toggleAutoContinue,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      notifier.autoContinue
                          ? Icons.fast_forward
                          : Icons.fast_forward_outlined,
                      color: notifier.autoContinue
                          ? Colors.white
                          : _parchment.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      notifier.autoContinue ? 'Auto: ON' : 'Auto: OFF',
                      style: TextStyle(
                        color: notifier.autoContinue
                            ? Colors.white
                            : _parchment.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── Speed Control ──
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: notifier.speedMultiplier > 1
                ? const Color(0xFF1565C0)
                : _cardBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: notifier.cycleSpeed,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speed,
                        color: notifier.speedMultiplier > 1
                            ? Colors.white
                            : _parchment.withValues(alpha: 0.5),
                        size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Speed: ${notifier.speedMultiplier}×',
                      style: TextStyle(
                        color: notifier.speedMultiplier > 1
                            ? Colors.white
                            : _parchment.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── Prestige Button ──
        if (game.wave >= 100 && game.phase != TdPhase.gameOver)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: const Color(0xFF6A1B9A),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _confirmPrestige(context, notifier, game.wave),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'PRESTIGE (+${prestigePointsForPrestige(game.wave)} pts)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (game.phase == TdPhase.waveActive)
          _InfoChip(
              'Wave in progress... ${game.enemiesKilledThisWave}/${game.totalEnemiesThisWave}'),
        if (game.phase == TdPhase.gameOver)
          _GameOverCard(
              wave: game.wave,
              highestWave: game.highestWave,
              prestigeEarned: prestigePointsEarned(game.wave),
              prestigePoints: game.prestigePoints,
              bonuses: game.prestigeBonuses,
              onReset: notifier.reset,
              onBuyPrestige: notifier.doBuyPrestige),
        const SizedBox(height: 10),

        // ── Abilities ──
        const _SectionTitle('Abilities'),
        _AbilityBtn(
          label: 'Ice Barrage',
          icon: Icons.ac_unit,
          color: const Color(0xFF64B5F6),
          cost: abilityCost(AbilityType.iceBarrage),
          cooldown: game.abilityCooldowns.cooldownLeft(AbilityType.iceBarrage),
          canUse: game.phase == TdPhase.waveActive &&
              game.abilityCooldowns.canUse(AbilityType.iceBarrage) &&
              game.resources.canAfford(abilityCost(AbilityType.iceBarrage)),
          onTap: () => notifier.useAbility(AbilityType.iceBarrage),
        ),
        _AbilityBtn(
          label: 'Cannon Blast',
          icon: Icons.flash_on,
          color: const Color(0xFFFF9800),
          cost: abilityCost(AbilityType.cannonBlast),
          cooldown: game.abilityCooldowns.cooldownLeft(AbilityType.cannonBlast),
          canUse: game.phase == TdPhase.waveActive &&
              game.abilityCooldowns.canUse(AbilityType.cannonBlast) &&
              game.resources.canAfford(abilityCost(AbilityType.cannonBlast)),
          onTap: () => notifier.useAbility(AbilityType.cannonBlast),
        ),
        _AbilityBtn(
          label: 'Heal',
          icon: Icons.healing,
          color: const Color(0xFF4CAF50),
          cost: abilityCost(AbilityType.heal),
          cooldown: game.abilityCooldowns.cooldownLeft(AbilityType.heal),
          canUse: game.phase == TdPhase.waveActive &&
              game.abilityCooldowns.canUse(AbilityType.heal) &&
              game.resources.canAfford(abilityCost(AbilityType.heal)),
          onTap: () => notifier.useAbility(AbilityType.heal),
        ),
        const SizedBox(height: 10),

        // ── Garrison ──
        const _SectionTitle('Garrison'),
        _GarrisonUpgrade(
            label: 'Damage',
            level: g.damageLevel,
            stat: 'DMG ${garrisonDamage(g.damageLevel).toStringAsFixed(1)}',
            cost: garrisonUpgradeCost(g.damageLevel),
            gold: game.resources.gold,
            icon: Icons.local_fire_department,
            color: const Color(0xFFFF5252),
            onTap: notifier.upgradeGarrisonDmg),
        _GarrisonUpgrade(
            label: 'Health',
            level: g.healthLevel,
            stat: 'HP ${g.maxHp}',
            cost: garrisonUpgradeCost(g.healthLevel),
            gold: game.resources.gold,
            icon: Icons.favorite,
            color: const Color(0xFF4CAF50),
            onTap: notifier.upgradeGarrisonHp),
        _GarrisonUpgrade(
            label: 'Armour',
            level: g.armourLevel,
            stat: '${(g.armourReduction * 100).toStringAsFixed(1)}% reduction',
            cost: garrisonUpgradeCost(g.armourLevel + 1),
            gold: game.resources.gold,
            icon: Icons.shield,
            color: const Color(0xFF2196F3),
            onTap: notifier.upgradeGarrisonArm),
        const SizedBox(height: 10),

        // ── Hero ──
        const _SectionTitle('Hero'),
        if (game.hero == null)
          _ActionBtn(
            label: 'Hire Hero ($heroPurchaseCost GP)',
            icon: Icons.person,
            color: const Color(0xFF5C4033),
            onTap: game.resources.gold >= heroPurchaseCost
                ? notifier.hireHero
                : null,
          )
        else ...[
          _HeroCard(
              hero: game.hero!,
              gold: game.resources.gold,
              onUpgrade: notifier.doUpgradeHero),
        ],
        const SizedBox(height: 10),

        // ── Peasants ──
        _SectionTitle('Peasants (${game.peasants.length}/${game.peasantCap})'),
        _ActionBtn(
          label: 'Buy Peasant (${peasantCost(game.peasants.length)} GP)',
          icon: Icons.person_add,
          color: const Color(0xFF5C4033),
          onTap: game.peasants.length < game.peasantCap &&
                  game.resources.gold >= peasantCost(game.peasants.length)
              ? notifier.purchasePeasant
              : null,
        ),
        ...game.peasants.map((p) {
          final nodes = game.resourceNodes;
          final hasNode =
              p.assignedNodeIndex >= 0 && p.assignedNodeIndex < nodes.length;
          final nodeName = hasNode
              ? nodeResourceName(nodes[p.assignedNodeIndex].type)
              : 'Idle';
          final stateColor = switch (p.state) {
            PeasantState.idle => Colors.grey,
            PeasantState.walking => const Color(0xFFFFD700),
            PeasantState.gathering => const Color(0xFF4CAF50),
          };
          final stateLabel = switch (p.state) {
            PeasantState.idle => 'Idle',
            PeasantState.walking => 'Walking',
            PeasantState.gathering => nodeName,
          };
          // Count workers at each node for the popup
          final workerCounts = List.filled(nodes.length, 0);
          for (final pp in game.peasants) {
            if (pp.assignedNodeIndex >= 0 &&
                pp.assignedNodeIndex < nodes.length) {
              workerCounts[pp.assignedNodeIndex]++;
            }
          }
          return ListTile(
            dense: true,
            leading: Icon(Icons.person, color: stateColor, size: 16),
            title: Text(p.name,
                style: TextStyle(
                    color: stateColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(stateLabel,
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.5), fontSize: 10)),
            trailing: PopupMenuButton<int>(
              icon: Icon(Icons.swap_horiz,
                  color: _gold.withValues(alpha: 0.7), size: 16),
              onSelected: (nodeIdx) => notifier.movePeasant(p.id, nodeIdx),
              itemBuilder: (_) => [
                for (int i = 0; i < nodes.length; i++)
                  PopupMenuItem(
                      value: i,
                      child: Text(
                          '${nodeTierName(nodes[i].type, nodes[i].level)} (${nodeResourceName(nodes[i].type)}) [${workerCounts[i]}]')),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),

        // ── Loot Inventory ──
        if (game.inventory.isNotEmpty) ...[
          _SectionTitle('Loot (${game.inventory.length}/$maxInventorySize)'),
          ...game.inventory.map((item) {
            final rarityColor = switch (item.rarity) {
              LootRarity.common => const Color(0xFFBDBDBD),
              LootRarity.uncommon => const Color(0xFF4CAF50),
              LootRarity.rare => const Color(0xFF2196F3),
              LootRarity.legendary => const Color(0xFFFF9800),
            };
            final equipped = _isEquipped(item, game);
            final slotIcon =
                item.slot == LootSlot.tower ? Icons.cell_tower : Icons.person;
            final slotLabel =
                item.slot == LootSlot.tower ? 'Tower Boost' : 'Hero Boost';
            // Find which tower this item is equipped on
            String equippedOnLabel = '';
            if (equipped) {
              if (item.slot == LootSlot.tower) {
                for (final s in game.towerSlots) {
                  if (s.equippedLootId == item.id && s.hasTower) {
                    equippedOnLabel =
                        ' → ${towerTypeName(s.towerType!)} Lv${s.level}';
                    break;
                  }
                }
              } else {
                equippedOnLabel = ' → Hero';
              }
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: equipped
                        ? rarityColor.withValues(alpha: 0.5)
                        : rarityColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(slotIcon, color: rarityColor, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: Text(item.name,
                                style: TextStyle(
                                    color: rarityColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10)),
                          ),
                          const SizedBox(width: 4),
                          Text(slotLabel,
                              style: TextStyle(
                                  color: rarityColor.withValues(alpha: 0.5),
                                  fontSize: 7,
                                  fontStyle: FontStyle.italic)),
                        ]),
                        Text(
                            _lootStatLine(item) +
                                (equipped ? ' [EQUIPPED$equippedOnLabel]' : ''),
                            style: TextStyle(
                                color: _parchment.withValues(alpha: 0.5),
                                fontSize: 8)),
                      ],
                    ),
                  ),
                  if (!equipped &&
                      item.slot == LootSlot.hero &&
                      game.hero != null)
                    _tinyBtn('Equip Hero', rarityColor,
                        () => notifier.doEquipHero(item.id)),
                  if (!equipped && item.slot == LootSlot.tower)
                    _tinyBtn('Equip Tower', rarityColor, () {
                      final sel = game.selectedSlotIndex;
                      if (sel != null && game.towerSlots[sel].hasTower) {
                        notifier.doEquipTower(item.id, sel);
                      }
                    }),
                  if (equipped)
                    _tinyBtn('Unequip', Colors.grey,
                        () => notifier.doUnequip(item.id)),
                  if (!equipped)
                    _tinyBtn(
                        'Sell ${lootSellPrice(item.rarity)}g',
                        const Color(0xFFFFD700),
                        () => notifier.doSellLoot(item.id)),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 10),

        // ── Prestige Shop ──
        if (game.prestigePoints > 0) ...[
          const _SectionTitle('Prestige Shop'),
          _PrestigeItem(
              'Startup Gold +15',
              'startingGold',
              1,
              game.prestigeBonuses.startingGoldBonus,
              game.prestigePoints,
              notifier.doBuyPrestige),
          _PrestigeItem(
              'Peasant Cap +1',
              'peasantCap',
              2,
              game.prestigeBonuses.peasantCapBonus,
              game.prestigePoints,
              notifier.doBuyPrestige),
          _PrestigeItem(
              'Tower DMG +5%',
              'towerDmg',
              2,
              game.prestigeBonuses.towerDmgPercent,
              game.prestigePoints,
              notifier.doBuyPrestige),
          _PrestigeItem(
              'Garrison HP +10%',
              'garrisonHp',
              1,
              game.prestigeBonuses.garrisonHpPercent,
              game.prestigePoints,
              notifier.doBuyPrestige),
          const SizedBox(height: 10),
        ],

        // ── Stats ──
        const _SectionTitle('Statistics'),
        if (game.prestigeLevel > 0)
          _StatRow('Prestige Level', '${game.prestigeLevel}'),
        _StatRow('Highest Wave', '${game.highestWave}'),
        _StatRow('Total Kills', '${game.totalKills}'),
        _StatRow('Total GP Earned', _fmt(game.totalGpEarned)),
        if (game.prestigeLevel > 0) ...[
          _StatRow('Passive Gold', '+${game.prestigeLevel}/sec'),
          _StatRow('Tower DMG Bonus',
              '+${(game.prestigeLevel * 15 + game.prestigeBonuses.towerDmgPercent * 5)}%'),
          _StatRow('Enemy HP Bonus', '+${game.prestigeLevel * 30}%'),
        ],
        if (game.prestigeBonuses.towerDmgPercent > 0 && game.prestigeLevel == 0)
          _StatRow('Prestige Tower DMG',
              '+${game.prestigeBonuses.towerDmgPercent * 5}%'),
        if (game.prestigeBonuses.garrisonHpPercent > 0 &&
            game.prestigeLevel == 0)
          _StatRow('Prestige Garrison HP',
              '+${game.prestigeBonuses.garrisonHpPercent * 10}%'),
      ],
    );
  }

  String _lootStatLine(LootItem item) {
    final parts = <String>[];
    if (item.dmgBonus > 0) parts.add('+${(item.dmgBonus * 100).round()}% DMG');
    if (item.rangeBonus > 0) {
      parts.add('+${(item.rangeBonus * 100).round()}% Range');
    }
    if (item.speedBonus > 0) {
      parts.add('+${(item.speedBonus * 100).round()}% Speed');
    }
    if (item.hpBonus > 0) parts.add('+${item.hpBonus.round()} HP');
    if (item.gpBonus > 0) parts.add('+${(item.gpBonus * 100).round()}% GP');
    return parts.join(', ');
  }

  bool _isEquipped(LootItem item, TdGameState g) {
    if (g.hero?.equippedLootId == item.id) return true;
    for (final s in g.towerSlots) {
      if (s.equippedLootId == item.id) return true;
    }
    return false;
  }

  void _confirmPrestige(
      BuildContext context, TdGameNotifier notifier, int wave) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF231A0E),
        title:
            const Text('Prestige?', style: TextStyle(color: Color(0xFF9C27B0))),
        content: Text(
          'Reset all towers, peasants, and progress.\n'
          'Earn ${prestigePointsForPrestige(wave)} prestige points.\n'
          'Enemies will be harder next time, but you\'ll start stronger.',
          style: TextStyle(color: _parchment.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A)),
            onPressed: () {
              Navigator.pop(ctx);
              notifier.prestige();
            },
            child:
                const Text('PRESTIGE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _tinyBtn(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 8)),
      ),
    );
  }
}

// ─── Wave Preview ───────────────────────────────────────────────

class _WavePreview extends StatelessWidget {
  final int wave;
  const _WavePreview({required this.wave});

  @override
  Widget build(BuildContext context) {
    final enemyName = enemyNameForWave(wave);
    final mod = previewModifier(wave);
    final modLabel = modifierLabel(mod);
    final count = isTreasureWave(wave)
        ? treasureEnemyCount(wave)
        : modifierEnemyCountMult(mod, enemiesInWave(wave));
    final isBoss = isBossWave(wave);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isBoss
                ? const Color(0xFFFF5252).withValues(alpha: 0.3)
                : _gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next: $enemyName',
              style: TextStyle(
                  color: isBoss ? const Color(0xFFFF5252) : _parchment,
                  fontWeight: FontWeight.bold,
                  fontSize: 10)),
          const SizedBox(height: 2),
          Row(children: [
            Text('$count enemies',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.6), fontSize: 9)),
            if (modLabel.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(modLabel,
                  style:
                      const TextStyle(fontSize: 9, color: Color(0xFFFFB74D))),
            ],
          ]),
        ],
      ),
    );
  }
}

// ─── Sidebar Widgets ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Text(text,
          style: const TextStyle(
              color: _gold, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: onTap != null ? color : color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gold.withValues(alpha: 0.15))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_gold))),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: _parchment, fontSize: 11)),
        ],
      ),
    );
  }
}

class _AbilityBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Resources cost;
  final int cooldown;
  final bool canUse;
  final VoidCallback onTap;
  const _AbilityBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.cost,
      required this.cooldown,
      required this.canUse,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final costStr = _costString(cost);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Row(
        children: [
          Icon(icon, color: canUse ? color : Colors.grey, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: canUse ? color : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              Text(cooldown > 0 ? 'CD: $cooldown waves' : costStr,
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.5), fontSize: 9)),
            ],
          )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canUse
                  ? color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.03),
              foregroundColor:
                  canUse ? color : _parchment.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: canUse ? onTap : null,
            child: const Text('Cast', style: TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

class _GarrisonUpgrade extends StatelessWidget {
  final String label;
  final int level;
  final String stat;
  final int cost;
  final int gold;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _GarrisonUpgrade(
      {required this.label,
      required this.level,
      required this.stat,
      required this.cost,
      required this.gold,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ok = gold >= cost;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
                const SizedBox(width: 4),
                Text('Lv $level',
                    style: TextStyle(
                        color: _parchment.withValues(alpha: 0.4), fontSize: 9)),
              ]),
              Text(stat,
                  style: TextStyle(
                      color: _parchment.withValues(alpha: 0.6), fontSize: 9)),
            ],
          )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ok
                  ? color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.03),
              foregroundColor: ok ? color : _parchment.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: ok ? onTap : null,
            child:
                Text('${_fmt(cost)} GP', style: const TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroUnit hero;
  final int gold;
  final VoidCallback onUpgrade;
  const _HeroCard(
      {required this.hero, required this.gold, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final cost = heroUpgradeCost(hero.damageLevel);
    final ok = gold >= cost;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gold.withValues(alpha: 0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(hero.alive ? Icons.person : Icons.person_off,
                color: hero.alive ? _gold : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text('Hero Lv${hero.damageLevel}',
                style: TextStyle(
                    color: hero.alive ? _gold : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            const Spacer(),
            Text('HP: ${hero.hp}/${hero.maxHp}',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.6), fontSize: 9)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text(
                'DMG: ${heroDamageAtLevel(hero.damageLevel).toStringAsFixed(1)}',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.6), fontSize: 9)),
            const Spacer(),
            if (!hero.alive)
              Text('Respawn: ${max(0, (hero.respawnTimer / 60).ceil())}s',
                  style:
                      const TextStyle(color: Color(0xFFFF5252), fontSize: 9)),
          ]),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ok ? const Color(0xFF2D5A1E) : Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: Size.zero,
              ),
              onPressed: ok ? onUpgrade : null,
              child: Text('Upgrade (${_fmt(cost)} GP)',
                  style: const TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverCard extends StatelessWidget {
  final int wave, highestWave, prestigeEarned, prestigePoints;
  final PrestigeBonuses bonuses;
  final VoidCallback onReset;
  final void Function(String) onBuyPrestige;
  const _GameOverCard(
      {required this.wave,
      required this.highestWave,
      required this.prestigeEarned,
      required this.prestigePoints,
      required this.bonuses,
      required this.onReset,
      required this.onBuyPrestige});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1010),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFFB33831).withValues(alpha: 0.4)),
      ),
      child: Column(children: [
        const Text('Lumbridge Has Fallen!',
            style: TextStyle(
                color: Color(0xFFFF5252),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 6),
        Text('Reached Wave $wave',
            style: TextStyle(
                color: _parchment.withValues(alpha: 0.6), fontSize: 11)),
        if (prestigeEarned > 0) ...[
          const SizedBox(height: 4),
          Text('Earned $prestigeEarned Prestige Points!',
              style: const TextStyle(
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ],
        const SizedBox(height: 8),
        // Prestige shop
        if (prestigePoints > 0) ...[
          const Text('Prestige Shop',
              style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 4),
          _PrestigeItem('Startup Gold +15', 'startingGold', 1,
              bonuses.startingGoldBonus, prestigePoints, onBuyPrestige),
          _PrestigeItem('Peasant Cap +1', 'peasantCap', 2,
              bonuses.peasantCapBonus, prestigePoints, onBuyPrestige),
          _PrestigeItem('Tower DMG +5%', 'towerDmg', 2, bonuses.towerDmgPercent,
              prestigePoints, onBuyPrestige),
          _PrestigeItem('Garrison HP +10%', 'garrisonHp', 1,
              bonuses.garrisonHpPercent, prestigePoints, onBuyPrestige),
          const SizedBox(height: 4),
        ],
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A1E),
                foregroundColor: Colors.white),
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('New Game'),
          ),
        ),
      ]),
    );
  }
}

class _PrestigeItem extends StatelessWidget {
  final String label, bonusKey;
  final int cost, owned, points;
  final void Function(String) onBuy;
  const _PrestigeItem(this.label, this.bonusKey, this.cost, this.owned,
      this.points, this.onBuy);

  @override
  Widget build(BuildContext context) {
    final canBuy = points >= cost;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text('$label (x$owned)',
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 10)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canBuy
                  ? const Color(0xFF9C27B0).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.03),
              foregroundColor: canBuy
                  ? const Color(0xFF9C27B0)
                  : _parchment.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: canBuy ? () => onBuy(bonusKey) : null,
            child: Text('$cost pt', style: const TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: _parchment.withValues(alpha: 0.5), fontSize: 10)),
          Text(value,
              style: TextStyle(
                  color: _parchment.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
