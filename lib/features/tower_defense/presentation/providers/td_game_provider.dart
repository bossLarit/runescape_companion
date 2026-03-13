import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/td_models.dart';
import '../../data/td_game_data.dart';
import '../../data/td_game_engine.dart';

const _saveFile = 'tower_defense_v2.json';
const _tickDuration = Duration(milliseconds: 16);

final tdGameProvider =
    StateNotifierProvider<TdGameNotifier, TdGameState>((ref) {
  return TdGameNotifier();
});

class TdGameNotifier extends StateNotifier<TdGameState> {
  Timer? _tickTimer;
  Timer? _saveTimer;

  TdGameNotifier()
      : super(TdGameState(
          towerSlots: createTowerSlots(),
          resourceNodes: createResourceNodes(),
          wallSlots: createWallSlots(),
        )) {
    _load();
  }

  // ── Persistence ──────────────────────────────────────────────

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_saveFile');
  }

  Future<void> _load() async {
    try {
      final f = await _file;
      if (await f.exists()) {
        final data = await f.readAsString();
        if (data.isNotEmpty) {
          var loaded = TdGameState.deserialize(data);
          if (loaded.towerSlots.isEmpty) {
            loaded = loaded.copyWith(towerSlots: createTowerSlots());
          }
          if (loaded.resourceNodes.isEmpty) {
            loaded = loaded.copyWith(resourceNodes: createResourceNodes());
          }
          if (loaded.wallSlots.isEmpty) {
            loaded = loaded.copyWith(wallSlots: createWallSlots());
          }
          state = loaded;
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
    } catch (_) {}
  }

  // ── Game Loop ────────────────────────────────────────────────

  void _startLoop() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(_tickDuration, (_) {
      state = processTick(state);
      if (state.phase == TdPhase.waveComplete ||
          state.phase == TdPhase.gameOver) {
        _stopLoop();
        _save();
      }
    });
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _save());
  }

  void _stopLoop() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _saveTimer?.cancel();
    _saveTimer = null;
  }

  // ── Wave Control ─────────────────────────────────────────────

  void sendWave() {
    if (state.phase != TdPhase.idle && state.phase != TdPhase.waveComplete) {
      return;
    }
    state = startWave(state);
    _startLoop();
  }

  // ── Tower Placement & Upgrade ────────────────────────────────

  void buildTower(int slotIndex, TowerType type) {
    state = placeTower(state, slotIndex, type);
    _save();
  }

  void upgradeTowerAtSlot(int slotIndex) {
    state = upgradeTower(state, slotIndex);
    _save();
  }

  // ── Peasant Management ───────────────────────────────────────

  void purchasePeasant() {
    state = buyPeasant(state);
    _save();
  }

  void movePeasant(int peasantId, int nodeIndex) {
    state = relocatePeasant(state, peasantId, nodeIndex);
  }

  // ── Garrison Upgrades ────────────────────────────────────────

  void upgradeGarrisonDmg() {
    state = upgradeGarrisonDamage(state);
    _save();
  }

  void upgradeGarrisonHp() {
    state = upgradeGarrisonHealth(state);
    _save();
  }

  void upgradeGarrisonArm() {
    state = upgradeGarrisonArmour(state);
    _save();
  }

  // ── Abilities ──────────────────────────────────────────────

  void useAbility(AbilityType type) {
    state = castAbility(state, type);
  }

  // ── Node Upgrade ──────────────────────────────────────────

  void doUpgradeNode(int nodeIndex) {
    state = upgradeNode(state, nodeIndex);
    _save();
  }

  // ── Hero ──────────────────────────────────────────────────

  void hireHero() {
    state = purchaseHero(state);
    _save();
  }

  void doUpgradeHero() {
    state = upgradeHero(state);
    _save();
  }

  // ── Walls ─────────────────────────────────────────────────

  void doBuildWall(int wallIndex) {
    state = buildWall(state, wallIndex);
    _save();
  }

  void doRepairWall(int wallIndex) {
    state = repairWall(state, wallIndex);
    _save();
  }

  void doUpgradeWall(int wallIndex) {
    state = upgradeWall(state, wallIndex);
    _save();
  }

  // ── Prestige ────────────────────────────────────────────────

  void doBuyPrestige(String bonusKey) {
    state = buyPrestige(state, bonusKey);
    _save();
  }

  // ── Loot Equip / Unequip ──────────────────────────────────

  void doEquipHero(String lootId) {
    state = equipLootToHero(state, lootId);
    _save();
  }

  void doEquipTower(String lootId, int slotIndex) {
    state = equipLootToTower(state, lootId, slotIndex);
    _save();
  }

  void doUnequip(String lootId) {
    state = unequipLoot(state, lootId);
    _save();
  }

  void doDiscardLoot(String lootId) {
    state = discardLoot(state, lootId);
    _save();
  }

  // ── Selection ────────────────────────────────────────────────

  void selectSlot(int? index) {
    state = state.copyWith(selectedSlotIndex: () => index);
  }

  // ── Reset ────────────────────────────────────────────────────

  void reset() {
    _stopLoop();
    state = resetGame(state);
    _save();
  }

  @override
  void dispose() {
    _stopLoop();
    _save();
    super.dispose();
  }
}
