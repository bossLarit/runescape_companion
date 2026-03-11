import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/idle_models.dart';
import '../../data/idle_game_data.dart';
import '../../data/idle_game_engine.dart';
import '../../data/idle_items.dart';

const _saveFile = 'idle_adventure.json';

final idleGameProvider =
    StateNotifierProvider<IdleGameNotifier, IdleGameState>((ref) {
  return IdleGameNotifier();
});

/// Holds the last offline progress result so the UI can show a welcome-back
/// banner. Cleared after the user dismisses it.
final offlineResultProvider =
    StateProvider<OfflineProgressResult?>((ref) => null);

class IdleGameNotifier extends StateNotifier<IdleGameState> {
  Timer? _tickTimer;
  Timer? _saveTimer;
  Timer? _skillingTimer;

  IdleGameNotifier() : super(const IdleGameState()) {
    _load();
  }

  // ── Persistence ──────────────────────────────────────────────

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_saveFile');
  }

  OfflineProgressResult? _pendingOfflineResult;
  OfflineProgressResult? get pendingOfflineResult => _pendingOfflineResult;

  void clearOfflineResult() {
    _pendingOfflineResult = null;
  }

  Future<void> _load() async {
    try {
      final f = await _file;
      if (await f.exists()) {
        final data = await f.readAsString();
        if (data.isNotEmpty) {
          var loaded = IdleGameState.deserialize(data);

          // Simulate offline progress if combat was running
          if (loaded.isRunning && loaded.lastSaveEpochMs > 0) {
            final offlineResult = simulateOfflineProgress(loaded);
            loaded = offlineResult.state;
            if (offlineResult.result.killsGained > 0) {
              _pendingOfflineResult = offlineResult.result;
            }
          }

          final monster = getMonster(loaded.monsterIndex, loaded.zone);
          state = loaded.copyWith(
            monsterCurrentHp: monster.maxHp,
            playerCurrentHp: loaded.stats.hitpointsLevel,
          );

          // Auto-resume combat if it was running
          if (loaded.isRunning) {
            _tickTimer?.cancel();
            _tickTimer =
                Timer.periodic(const Duration(milliseconds: 1200), (_) {
              state = processTick(state);
            });
            _saveTimer?.cancel();
            _saveTimer =
                Timer.periodic(const Duration(seconds: 30), (_) => _save());
          }
        }
      }
    } catch (_) {
      // Fresh state on error
    }
  }

  Future<void> _save() async {
    try {
      final f = await _file;
      await f.writeAsString(state.serialize());
    } catch (_) {
      // Silent fail
    }
  }

  // ── Game Controls ────────────────────────────────────────────

  void startCombat() {
    if (state.isRunning) return;
    // Mutual exclusion: stop skilling first
    _stopSkillingInternal();
    final monster = getMonster(state.monsterIndex, state.zone);
    state = state.copyWith(
      isRunning: true,
      monsterCurrentHp: monster.maxHp,
      playerCurrentHp: state.stats.hitpointsLevel,
    );
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      state = processTick(state);
    });
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _save());
  }

  void stopCombat() {
    _tickTimer?.cancel();
    _saveTimer?.cancel();
    state = state.copyWith(isRunning: false);
    _save();
  }

  void selectMonster(int index, int zone) {
    final wasRunning = state.isRunning;
    if (wasRunning) stopCombat();
    final monster = getMonster(index, zone);
    state = state.copyWith(
      monsterIndex: index,
      zone: zone,
      monsterCurrentHp: monster.maxHp,
      playerCurrentHp: state.stats.hitpointsLevel,
    );
    if (wasRunning) startCombat();
  }

  void nextZone() {
    selectMonster(0, state.zone + 1);
  }

  void setTrainingStyle(TrainingStyle style) {
    state = state.copyWith(trainingStyle: style);
  }

  void withdrawFood(String cookedItemId, int qty) {
    state = moveFoodToInventory(state, cookedItemId, qty);
  }

  void buyGearUpgrade() {
    final cost = gearUpgradeCost(state.gearLevel);
    if (state.gp < cost) return;
    state = state.copyWith(
      gp: state.gp - cost,
      gearLevel: state.gearLevel + 1,
    );
  }

  void buyRangedGearUpgrade() {
    final cost = gearUpgradeCost(state.rangedGearLevel);
    if (state.gp < cost) return;
    state = state.copyWith(
      gp: state.gp - cost,
      rangedGearLevel: state.rangedGearLevel + 1,
    );
  }

  void buyMagicGearUpgrade() {
    final cost = gearUpgradeCost(state.magicGearLevel);
    if (state.gp < cost) return;
    state = state.copyWith(
      gp: state.gp - cost,
      magicGearLevel: state.magicGearLevel + 1,
    );
  }

  void queueSpecialAttack() {
    if (state.specialAttackCooldown > 0) return;
    state = state.copyWith(specialAttackQueued: true);
  }

  void setActivePrayer(ActivePrayer prayer) {
    if (prayer == ActivePrayer.none) {
      state = state.copyWith(activePrayer: ActivePrayer.none);
      return;
    }
    if (state.prayerLevel < prayerLevelRequired(prayer)) return;
    if (state.prayerPoints <= 0) return;
    state = state.copyWith(activePrayer: prayer);
  }

  void buyPrayerPotion(String potionId) {
    final potion = getPrayerPotionById(potionId);
    if (potion == null) return;
    if (state.gp < potion.cost) return;
    final restored = (state.prayerPoints + potion.restoreAmount)
        .clamp(0, state.maxPrayerPoints);
    state = state.copyWith(
      gp: state.gp - potion.cost,
      prayerPoints: restored,
    );
  }

  void buyPrayerPotion10(String potionId) {
    final potion = getPrayerPotionById(potionId);
    if (potion == null) return;
    final canAfford = state.gp ~/ potion.cost;
    final qty = canAfford.clamp(0, 10);
    if (qty <= 0) return;
    final totalRestore = potion.restoreAmount * qty;
    final restored =
        (state.prayerPoints + totalRestore).clamp(0, state.maxPrayerPoints);
    state = state.copyWith(
      gp: state.gp - (potion.cost * qty),
      prayerPoints: restored,
    );
  }

  void toggleAutoAdvance() {
    state = state.copyWith(autoAdvance: !state.autoAdvance);
    _save();
  }

  void rechargePrayerAtAltar() {
    if (state.isRunning) return; // can't recharge during combat
    state = state.copyWith(prayerPoints: state.maxPrayerPoints);
  }

  void getNewSlayerTask() {
    final task = assignSlayerTask(state.slayerLevel);
    state = state.copyWith(currentSlayerTask: task);
    _save();
  }

  void cancelSlayerTask() {
    state = state.copyWith(clearSlayerTask: true);
    _save();
  }

  void doPrestige() {
    stopCombat();
    _stopSkillingInternal();
    state = prestige(state);
    _save();
  }

  // ── Skilling Controls ─────────────────────────────────────────

  void _stopSkillingInternal() {
    _skillingTimer?.cancel();
    _skillingTimer = null;
    if (state.activeSkilling != null) {
      state = state.copyWith(clearActiveSkilling: true);
    }
  }

  void startSkilling(SkillType skill, String resourceId) {
    final resource = getSkillingResourceById(resourceId);
    if (resource == null) return;
    if (state.skillingStats.levelFor(skill) < resource.levelRequired) return;

    // Mutual exclusion: stop combat first
    if (state.isRunning) stopCombat();
    _stopSkillingInternal();

    state = state.copyWith(
      activeSkilling: ActiveSkillingState(skill: skill, resourceId: resourceId),
    );

    _skillingTimer?.cancel();
    _skillingTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      state = processSkillingTick(state);
    });
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _save());
  }

  void stopSkilling() {
    _stopSkillingInternal();
    _save();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _skillingTimer?.cancel();
    _saveTimer?.cancel();
    _save();
    super.dispose();
  }
}
