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

          final monster = getMonster(loaded.monsterIndex);
          state = loaded.copyWith(
            monsterCurrentHp: monster.hitpoints,
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
    final monster = getMonster(state.monsterIndex);
    state = state.copyWith(
      isRunning: true,
      monsterCurrentHp: monster.hitpoints,
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

  void selectMonster(int index) {
    final wasRunning = state.isRunning;
    if (wasRunning) stopCombat();
    final monster = getMonster(index);
    state = state.copyWith(
      monsterIndex: index,
      monsterCurrentHp: monster.hitpoints,
      playerCurrentHp: state.stats.hitpointsLevel,
    );
    if (wasRunning) startCombat();
  }

  void setTrainingStyle(TrainingStyle style) {
    state = state.copyWith(trainingStyle: style);
  }

  void withdrawFood(String cookedItemId, int qty) {
    state = moveFoodToInventory(state, cookedItemId, qty);
  }

  // ── Raids ─────────────────────────────────────────────────────

  /// Start a raid. Requires 90+ Attack, Strength, Defence.
  bool startRaid(String raidId) {
    if (state.isRunning) return false;
    final raidDef = getRaidDefById(raidId);
    if (raidDef == null) return false;

    // Check stat requirements
    if (state.stats.attackLevel < raidDef.minAttack) return false;
    if (state.stats.strengthLevel < raidDef.minStrength) return false;
    if (state.stats.defenceLevel < raidDef.minDefence) return false;

    _stopSkillingInternal();
    final firstBoss = raidDef.bosses.first;

    state = state.copyWith(
      isRunning: true,
      activeRaid: RaidState(raidId: raidId, bossIndex: 0),
      raidBossCurrentHp: firstBoss.hitpoints,
      playerCurrentHp: state.stats.hitpointsLevel,
      combatLog: ['⚔️ ${raidDef.name} begins! First boss: ${firstBoss.name}'],
    );

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      _raidTick();
    });
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _save());
    return true;
  }

  void _raidTick() {
    state = processRaidTick(state);
    // If raid ended (completed or failed), stop the timer
    if (state.activeRaid == null) {
      _tickTimer?.cancel();
      _saveTimer?.cancel();
      state = state.copyWith(isRunning: false);
      _save();
    }
  }

  void stopRaid() {
    _tickTimer?.cancel();
    _saveTimer?.cancel();
    state = state.copyWith(
      isRunning: false,
      clearActiveRaid: true,
      raidBossCurrentHp: 0,
      combatLog: [...state.combatLog, '🚪 Raid abandoned.'],
    );
    _save();
  }

  // ── Equipment ──────────────────────────────────────────────────

  /// Equip an item from the bank or shop purchase.
  /// Returns false if player doesn't meet requirements.
  bool equipItem(String itemId) {
    final def = getEquipmentDefById(itemId);
    if (def == null) return false;
    // Check level requirements
    if (state.stats.attackLevel < def.attackReq) return false;
    if (state.stats.defenceLevel < def.defenceReq) return false;
    if (state.stats.rangedLevel < def.rangedReq) return false;
    if (state.stats.magicLevel < def.magicReq) return false;
    if (state.prayerLevel < def.prayerReq) return false;

    final slotName = def.slot.name;
    final newEquipment = Map<String, String>.from(state.equipment);

    // Unequip current item in that slot → return to bank
    final oldItemId = newEquipment[slotName];
    final newBank = Map<String, int>.from(state.bank);
    if (oldItemId != null) {
      newBank[oldItemId] = (newBank[oldItemId] ?? 0) + 1;
    }

    // Remove item from bank (use original itemId as bank key)
    final bankQty = newBank[itemId] ?? 0;
    if (bankQty > 0) {
      newBank[itemId] = bankQty - 1;
      if (newBank[itemId]! <= 0) newBank.remove(itemId);
    }

    // Store the canonical equipment def ID (handles aliases like fire_cape → fire_cape_eq)
    newEquipment[slotName] = def.id;
    state = state.copyWith(equipment: newEquipment, bank: newBank);
    _save();
    return true;
  }

  /// Unequip an item from a slot → goes to bank.
  void unequipSlot(EquipmentSlot slot) {
    final slotName = slot.name;
    final itemId = state.equipment[slotName];
    if (itemId == null) return;

    final newEquipment = Map<String, String>.from(state.equipment);
    newEquipment.remove(slotName);

    final newBank = Map<String, int>.from(state.bank);
    newBank[itemId] = (newBank[itemId] ?? 0) + 1;

    state = state.copyWith(equipment: newEquipment, bank: newBank);
    _save();
  }

  /// Buy equipment from the shop and equip it.
  bool buyAndEquipItem(String itemId) {
    final def = getEquipmentDefById(itemId);
    if (def == null || def.buyPrice <= 0) return false;
    if (state.gp < def.buyPrice) return false;
    // Check level requirements
    if (state.stats.attackLevel < def.attackReq) return false;
    if (state.stats.defenceLevel < def.defenceReq) return false;
    if (state.stats.rangedLevel < def.rangedReq) return false;
    if (state.stats.magicLevel < def.magicReq) return false;
    if (state.prayerLevel < def.prayerReq) return false;

    // Deduct GP
    state = state.copyWith(gp: state.gp - def.buyPrice);

    // Add to bank first, then equip
    final newBank = Map<String, int>.from(state.bank);
    newBank[itemId] = (newBank[itemId] ?? 0) + 1;
    state = state.copyWith(bank: newBank);

    return equipItem(itemId);
  }

  /// Buy equipment to bank (without equipping).
  bool buyItemToBank(String itemId) {
    final def = getEquipmentDefById(itemId);
    if (def == null || def.buyPrice <= 0) return false;
    if (state.gp < def.buyPrice) return false;

    final newBank = Map<String, int>.from(state.bank);
    newBank[itemId] = (newBank[itemId] ?? 0) + 1;
    state = state.copyWith(gp: state.gp - def.buyPrice, bank: newBank);
    _save();
    return true;
  }

  /// Buy a tool item (axe, pickaxe, etc.) from the shop.
  bool buyTool(String toolId) {
    final item = getItemById(toolId);
    if (item == null || item.buyPrice == null) return false;
    if (state.gp < item.buyPrice!) return false;
    // Already own it — tools don't stack, one is enough
    if ((state.bank[toolId] ?? 0) > 0) return false;

    final newBank = Map<String, int>.from(state.bank);
    newBank[toolId] = 1;
    state = state.copyWith(gp: state.gp - item.buyPrice!, bank: newBank);
    _save();
    return true;
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
    // Strict tool requirement: must own the required tool in bank
    if (resource.requiredToolId != null &&
        (state.bank[resource.requiredToolId!] ?? 0) <= 0) {
      return;
    }

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
