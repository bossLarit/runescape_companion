import 'dart:math';

import '../domain/idle_models.dart';
import 'idle_game_data.dart';
import 'idle_items.dart';

final _rng = Random();

/// Calculates max hit based on strength level + gear bonus.
int maxHit(int strengthLevel, int strengthBonus) {
  final effective = strengthLevel + 8;
  return ((effective * (strengthBonus + 64) + 320) / 640).floor().clamp(1, 999);
}

/// Calculates hit chance (0.0–1.0).
double hitChance(int attackLevel, int attackBonus, int monsterDefence) {
  final attackRoll = (attackLevel + 8) * (attackBonus + 64);
  final defenceRoll = (monsterDefence + 8) * (monsterDefence + 64);
  if (attackRoll > defenceRoll) {
    return 1.0 - (defenceRoll + 2) / (2 * (attackRoll + 1));
  } else {
    return attackRoll / (2 * (defenceRoll + 1));
  }
}

/// Roll player damage against a monster.
/// Uses the appropriate stats based on the active training style.
int rollPlayerDamage(
  CombatStats stats,
  EquipmentBonuses gear,
  MonsterDef m, {
  bool pietyActive = false,
  TrainingStyle style = TrainingStyle.balanced,
}) {
  int atkBonus;
  int strBonus;
  int effectiveAtk;
  int effectiveStr;

  switch (style) {
    case TrainingStyle.ranged:
      atkBonus = gear.rangedAttack;
      strBonus = gear.rangedStrength;
      effectiveAtk = stats.rangedLevel;
      effectiveStr = stats.rangedLevel;
      break;
    case TrainingStyle.magic:
      atkBonus = gear.magicAttack;
      strBonus = gear.magicStrength;
      effectiveAtk = stats.magicLevel;
      effectiveStr = stats.magicLevel;
      break;
    default: // melee styles
      atkBonus = gear.meleeAttack;
      strBonus = gear.meleeStrength;
      // Piety: +20% attack, +23% strength (OSRS accurate)
      effectiveAtk =
          pietyActive ? (stats.attackLevel * 1.20).floor() : stats.attackLevel;
      effectiveStr = pietyActive
          ? (stats.strengthLevel * 1.23).floor()
          : stats.strengthLevel;
      break;
  }

  final chance = hitChance(effectiveAtk, atkBonus, m.defence);
  if (_rng.nextDouble() > chance) return 0;
  final max = maxHit(effectiveStr, strBonus);
  return _rng.nextInt(max + 1);
}

/// Roll monster damage against the player.
/// Monsters use their maxHit directly (OSRS-style).
int rollMonsterDamage(MonsterDef m, CombatStats stats, EquipmentBonuses gear) {
  final defBonus = gear.meleeDefence;
  final chance = hitChance(m.attack, 0, stats.defenceLevel + defBonus);
  if (_rng.nextDouble() > chance) return 0;
  // Use monster's pre-defined maxHit from OSRS wiki
  return _rng.nextInt(m.maxHit + 1);
}

/// XP gained per kill.
int combatXpPerKill(MonsterDef m, double prestigeMultiplier) {
  return (m.hitpoints * 4 * prestigeMultiplier).floor();
}

int hpXpPerKill(MonsterDef m, double prestigeMultiplier) {
  return (m.hitpoints * 1.33 * prestigeMultiplier).floor();
}

/// GP drop from a monster.
int rollGpDrop(MonsterDef m) {
  if (m.gpMax <= m.gpMin) return m.gpMin;
  return m.gpMin + _rng.nextInt(m.gpMax - m.gpMin + 1);
}

/// Roll loot drops from a monster's drop table.
/// Returns a map of itemId → quantity gained.
Map<String, int> rollLootDrops(MonsterDef m) {
  final table = monsterDropTables[m.id];
  if (table == null) return {};
  final drops = <String, int>{};
  for (final entry in table) {
    if (_rng.nextDouble() <= entry.chance) {
      final qty = entry.minQty == entry.maxQty
          ? entry.minQty
          : entry.minQty + _rng.nextInt(entry.maxQty - entry.minQty + 1);
      drops[entry.itemId] = (drops[entry.itemId] ?? 0) + qty;
    }
  }
  return drops;
}

/// Calculate total equipment bonuses from equipped items.
EquipmentBonuses calcEquipmentBonuses(Map<String, String> equipment) {
  int mAtk = 0,
      mStr = 0,
      mDef = 0,
      rAtk = 0,
      rStr = 0,
      magAtk = 0,
      magStr = 0,
      pray = 0;
  for (final itemId in equipment.values) {
    final def = getEquipmentDefById(itemId);
    if (def == null) continue;
    mAtk += def.meleeAttack;
    mStr += def.meleeStrength;
    mDef += def.meleeDefence;
    rAtk += def.rangedAttack;
    rStr += def.rangedStrength;
    magAtk += def.magicAttack;
    magStr += def.magicStrength;
    pray += def.prayerBonus;
  }
  return EquipmentBonuses(
    meleeAttack: mAtk,
    meleeStrength: mStr,
    meleeDefence: mDef,
    rangedAttack: rAtk,
    rangedStrength: rStr,
    magicAttack: magAtk,
    magicStrength: magStr,
    prayerBonus: pray,
  );
}

/// Add items to a bank map, returning the new bank.
Map<String, int> addToBank(Map<String, int> bank, Map<String, int> items) {
  if (items.isEmpty) return bank;
  final newBank = Map<String, int>.from(bank);
  for (final entry in items.entries) {
    newBank[entry.key] = (newBank[entry.key] ?? 0) + entry.value;
  }
  return newBank;
}

/// Append to combat log, keeping only last 20 entries.
List<String> _appendLog(List<String> log, String entry) {
  final newLog = [...log, entry];
  if (newLog.length > 20) return newLog.sublist(newLog.length - 20);
  return newLog;
}

/// Try to auto-eat food when HP drops below 50% of max.
IdleGameState _tryAutoEat(IdleGameState s, int maxHp) {
  if (s.playerCurrentHp > maxHp ~/ 2) return s; // HP is fine
  if (s.foodInventory.isEmpty) return s; // no food

  // Find best food that doesn't overheal too much
  String? bestId;
  int bestHeal = 0;
  for (final entry in s.foodInventory.entries) {
    if (entry.value <= 0) continue;
    // Try cooked food heal amounts first, fall back to legacy food shop items
    final heal =
        cookedFoodHealAmounts[entry.key] ?? getFoodById(entry.key)?.healAmount;
    if (heal == null) continue;
    if (bestId == null || heal > bestHeal) {
      bestId = entry.key;
      bestHeal = heal;
    }
  }
  if (bestId == null) return s;

  final newInv = Map<String, int>.from(s.foodInventory);
  newInv[bestId] = (newInv[bestId] ?? 1) - 1;
  if (newInv[bestId]! <= 0) newInv.remove(bestId);

  final healed = (s.playerCurrentHp + bestHeal).clamp(0, maxHp);
  final itemName =
      getItemById(bestId)?.name ?? getFoodById(bestId)?.name ?? bestId;
  return s.copyWith(
    playerCurrentHp: healed,
    foodInventory: newInv,
    combatLog:
        _appendLog(s.combatLog, 'You eat $itemName and heal $bestHeal HP'),
  );
}

/// Roll a unique drop from a raid's unique drop table.
/// Returns the itemId or null if no unique.
String? rollRaidUnique(RaidDef raid) {
  if (_rng.nextDouble() > raid.uniqueDropChance) return null;
  if (raid.uniqueDropTable.isEmpty) return null;
  final totalWeight =
      raid.uniqueDropTable.fold<int>(0, (sum, e) => sum + e.weight);
  int roll = _rng.nextInt(totalWeight);
  for (final entry in raid.uniqueDropTable) {
    roll -= entry.weight;
    if (roll < 0) return entry.itemId;
  }
  return raid.uniqueDropTable.last.itemId;
}

/// Process one raid combat tick. Returns the updated game state.
IdleGameState processRaidTick(IdleGameState state) {
  if (!state.isRunning) return state;
  final raid = state.activeRaid;
  if (raid == null || !raid.isActive) return state;

  final raidDef = getRaidDefById(raid.raidId);
  if (raidDef == null) {
    return state.copyWith(clearActiveRaid: true);
  }

  final boss = raidDef.bosses[raid.bossIndex];
  final gear = calcEquipmentBonuses(state.equipment);
  final maxHp = state.stats.hitpointsLevel;

  // Auto-eat before combat
  var s = _tryAutoEat(state, maxHp);

  // Player attacks boss
  final playerDmg = rollPlayerDamage(
    s.stats,
    gear,
    boss,
    pietyActive: s.activePrayer == ActivePrayer.piety,
    style: s.trainingStyle,
  );
  final bossHp = s.raidBossCurrentHp - playerDmg;
  var log =
      _appendLog(s.combatLog, 'You hit ${boss.name} for $playerDmg damage');

  // Boss attacks player
  final bossDmg = rollMonsterDamage(boss, s.stats, gear);
  final adjustedDmg =
      s.activePrayer == ActivePrayer.protectFromMelee ? 0 : bossDmg;
  final playerHp = s.playerCurrentHp - adjustedDmg;
  if (adjustedDmg > 0) {
    log = _appendLog(log, '${boss.name} hits you for $adjustedDmg damage');
  }

  // Prayer drain
  var prayerPts = s.prayerPoints;
  if (s.activePrayer != ActivePrayer.none) {
    prayerPts -= prayerDrainPerTick(s.activePrayer);
    if (prayerPts < 0) prayerPts = 0;
  }

  // XP from damage dealt
  var stats = s.stats;
  if (playerDmg > 0) {
    final xp = (playerDmg * 4 * s.prestigeMultiplier).floor();
    final hpXp = (playerDmg * 1.33 * s.prestigeMultiplier).floor();
    switch (s.trainingStyle) {
      case TrainingStyle.attack:
        stats = stats.copyWith(
            attackXp: stats.attackXp + xp,
            hitpointsXp: stats.hitpointsXp + hpXp);
        break;
      case TrainingStyle.strength:
        stats = stats.copyWith(
            strengthXp: stats.strengthXp + xp,
            hitpointsXp: stats.hitpointsXp + hpXp);
        break;
      case TrainingStyle.defence:
        stats = stats.copyWith(
            defenceXp: stats.defenceXp + xp,
            hitpointsXp: stats.hitpointsXp + hpXp);
        break;
      case TrainingStyle.balanced:
        final share = xp ~/ 3;
        stats = stats.copyWith(
            attackXp: stats.attackXp + share,
            strengthXp: stats.strengthXp + share,
            defenceXp: stats.defenceXp + share,
            hitpointsXp: stats.hitpointsXp + hpXp);
        break;
      case TrainingStyle.ranged:
        stats = stats.copyWith(
            rangedXp: stats.rangedXp + xp,
            hitpointsXp: stats.hitpointsXp + hpXp);
        break;
      case TrainingStyle.magic:
        stats = stats.copyWith(
            magicXp: stats.magicXp + xp, hitpointsXp: stats.hitpointsXp + hpXp);
        break;
    }
  }

  // Player died → raid fails
  if (playerHp <= 0) {
    log = _appendLog(log, '☠️ You died! Raid failed.');
    return s.copyWith(
      stats: stats,
      playerCurrentHp: maxHp,
      raidBossCurrentHp: 0,
      clearActiveRaid: true,
      combatLog: log,
      deathCount: s.deathCount + 1,
      prayerPoints: prayerPts,
      lastDamageDealt: playerDmg,
      lastDamageTaken: adjustedDmg,
    );
  }

  // Boss died → advance or complete
  if (bossHp <= 0) {
    final nextBoss = raid.bossIndex + 1;
    log = _appendLog(log, '✅ ${boss.name} defeated!');

    if (nextBoss >= raidDef.bosses.length) {
      // Raid complete!
      log = _appendLog(log, '🏆 ${raidDef.name} complete!');

      // Roll for unique
      final uniqueId = rollRaidUnique(raidDef);
      final bank = Map<String, int>.from(s.bank);
      if (uniqueId != null) {
        bank[uniqueId] = (bank[uniqueId] ?? 0) + 1;
        final equipDef = getEquipmentDefById(uniqueId);
        final item = getItemById(uniqueId);
        final name = equipDef?.name ?? item?.name ?? uniqueId;
        log = _appendLog(log, '💜 UNIQUE DROP: $name!');
      } else {
        // Common loot: GP
        final gpReward = 50000 + _rng.nextInt(100000);
        log = _appendLog(log, 'Common loot: ${gpReward}gp');
        return s.copyWith(
          stats: stats,
          gp: s.gp + gpReward,
          playerCurrentHp: playerHp,
          raidBossCurrentHp: 0,
          clearActiveRaid: true,
          combatLog: log,
          prayerPoints: prayerPts,
          raidCompletions: {
            ...s.raidCompletions,
            raidDef.id: (s.raidCompletions[raidDef.id] ?? 0) + 1,
          },
          lastDamageDealt: playerDmg,
          lastDamageTaken: adjustedDmg,
        );
      }

      final completions = Map<String, int>.from(s.raidCompletions);
      completions[raidDef.id] = (completions[raidDef.id] ?? 0) + 1;

      return s.copyWith(
        stats: stats,
        playerCurrentHp: playerHp,
        raidBossCurrentHp: 0,
        clearActiveRaid: true,
        bank: bank,
        combatLog: log,
        prayerPoints: prayerPts,
        raidCompletions: completions,
        lastDamageDealt: playerDmg,
        lastDamageTaken: adjustedDmg,
      );
    } else {
      // Advance to next boss
      final nextBossDef = raidDef.bosses[nextBoss];
      log = _appendLog(
          log, '➡️ Next: ${nextBossDef.name} (${nextBossDef.hitpoints} HP)');
      return s.copyWith(
        stats: stats,
        playerCurrentHp: playerHp,
        raidBossCurrentHp: nextBossDef.hitpoints,
        activeRaid: raid.copyWith(bossIndex: nextBoss),
        combatLog: log,
        prayerPoints: prayerPts,
        lastDamageDealt: playerDmg,
        lastDamageTaken: adjustedDmg,
      );
    }
  }

  // Normal tick — both alive
  s = s.copyWith(
    stats: stats,
    playerCurrentHp: playerHp,
    raidBossCurrentHp: bossHp,
    combatLog: log,
    prayerPoints: prayerPts,
    lastDamageDealt: playerDmg,
    lastDamageTaken: adjustedDmg,
  );
  return _tryAutoEat(s, maxHp);
}

/// Process one combat tick. Returns the updated game state.
IdleGameState processTick(IdleGameState state) {
  if (!state.isRunning) return state;

  // Respawn delay — skip combat ticks while dead
  if (state.respawnTicksLeft > 0) {
    return state.copyWith(
      respawnTicksLeft: state.respawnTicksLeft - 1,
    );
  }

  final monster = getMonster(state.monsterIndex);
  final gear = calcEquipmentBonuses(state.equipment);
  var log = List<String>.from(state.combatLog);

  // ── Prayer drain ──────────────────────────────────────────
  var currentPrayer = state.activePrayer;
  var prayerPts = state.prayerPoints;
  if (currentPrayer != ActivePrayer.none) {
    final drain = prayerDrainPerTick(currentPrayer);
    prayerPts -= drain;
    if (prayerPts <= 0) {
      prayerPts = 0;
      log = _appendLog(log, '🙏 Your prayer has run out!');
      currentPrayer = ActivePrayer.none;
    }
  }

  // Tick down special attack cooldown
  final specCd =
      (state.specialAttackCooldown > 0) ? state.specialAttackCooldown - 1 : 0;

  // Player attacks monster
  int playerDmg = rollPlayerDamage(state.stats, gear, monster,
      pietyActive: currentPrayer == ActivePrayer.piety,
      style: state.trainingStyle);
  bool usedSpec = false;
  if (state.specialAttackQueued &&
      state.specialAttackCooldown <= 0 &&
      playerDmg > 0) {
    playerDmg = (playerDmg * specDamageMultiplier).floor();
    usedSpec = true;
    log = _appendLog(
        log, '⚔️ SPECIAL ATTACK! You smash ${monster.name} for $playerDmg!');
  } else if (playerDmg > 0) {
    log = _appendLog(log, 'You hit ${monster.name} for $playerDmg');
  } else {
    log = _appendLog(log, 'You missed!');
  }

  final monsterHp = state.monsterCurrentHp - playerDmg;

  // Monster attacks player
  int monsterDmg = rollMonsterDamage(monster, state.stats, gear);
  if (currentPrayer == ActivePrayer.protectFromMelee && monsterDmg > 0) {
    monsterDmg = 0;
  }
  final playerHp = state.playerCurrentHp - monsterDmg;

  if (monsterDmg > 0) {
    log = _appendLog(log, '${monster.name} hits you for $monsterDmg');
  } else if (currentPrayer == ActivePrayer.protectFromMelee) {
    log = _appendLog(log, '🛡️ Prayer blocks ${monster.name}\'s attack!');
  } else {
    log = _appendLog(log, '${monster.name} missed!');
  }

  final updated = state.copyWith(
    specialAttackCooldown: usedSpec ? specCooldownTicks : specCd,
    specialAttackQueued: usedSpec ? false : state.specialAttackQueued,
    combatLog: log,
    prayerPoints: prayerPts,
    activePrayer: currentPrayer,
  );

  // Player died → death penalty + respawn delay
  if (playerHp <= 0) {
    final gpLost = (state.gp * 0.10).floor();
    final foodLost = state.totalFood;
    log = _appendLog(log, '☠️ You died! Respawning in Lumbridge...');
    if (gpLost > 0) {
      log = _appendLog(log, '💸 Lost ${gpLost}gp as a death tax');
    }
    if (foodLost > 0) {
      log = _appendLog(log, '🍖 Lost all food ($foodLost items)');
    }
    return updated.copyWith(
      playerCurrentHp: state.stats.hitpointsLevel,
      monsterCurrentHp: monster.hitpoints,
      gp: state.gp - gpLost,
      foodInventory: const {},
      deathCount: state.deathCount + 1,
      respawnTicksLeft: 3,
      lastDamageDealt: playerDmg,
      lastDamageTaken: monsterDmg,
      clearDrop: true,
      combatLog: log,
    );
  }

  // Monster died → award XP + GP, spawn next
  if (monsterHp <= 0) {
    final xpGain = combatXpPerKill(monster, state.prestigeMultiplier);
    final hpGain = hpXpPerKill(monster, state.prestigeMultiplier);
    final gpGain = rollGpDrop(monster);

    // Distribute combat XP based on training style
    var newStats = state.stats;
    switch (state.trainingStyle) {
      case TrainingStyle.attack:
        newStats = newStats.copyWith(attackXp: newStats.attackXp + xpGain);
        break;
      case TrainingStyle.strength:
        newStats = newStats.copyWith(strengthXp: newStats.strengthXp + xpGain);
        break;
      case TrainingStyle.defence:
        newStats = newStats.copyWith(defenceXp: newStats.defenceXp + xpGain);
        break;
      case TrainingStyle.balanced:
        final third = xpGain ~/ 3;
        newStats = newStats.copyWith(
          attackXp: newStats.attackXp + third,
          strengthXp: newStats.strengthXp + third,
          defenceXp: newStats.defenceXp + third,
        );
        break;
      case TrainingStyle.ranged:
        newStats = newStats.copyWith(rangedXp: newStats.rangedXp + xpGain);
        break;
      case TrainingStyle.magic:
        newStats = newStats.copyWith(magicXp: newStats.magicXp + xpGain);
        break;
    }
    newStats = newStats.copyWith(hitpointsXp: newStats.hitpointsXp + hpGain);

    log = _appendLog(
        log, '💀 ${monster.name} defeated! +${gpGain}gp +${xpGain}xp');

    // Slayer task progress
    var slayerXpGain = 0;
    var slayerBonusGp = 0;
    SlayerTask? updatedTask = state.currentSlayerTask;
    bool taskJustCompleted = false;
    int tasksCompleted = state.slayerTasksCompleted;

    if (updatedTask != null && !updatedTask.isComplete) {
      if (monster.id == updatedTask.monsterId) {
        updatedTask = updatedTask.copyWith(
          amountKilled: updatedTask.amountKilled + 1,
        );
        slayerXpGain = monster.hitpoints;

        if (updatedTask.isComplete) {
          taskJustCompleted = true;
          tasksCompleted++;
          slayerXpGain += updatedTask.bonusSlayerXp;
          slayerBonusGp = updatedTask.bonusGp;
          log = _appendLog(log,
              '🗡️ Slayer task complete! +${updatedTask.bonusGp}gp +${updatedTask.bonusSlayerXp} slayer xp');
        }
      }
    }

    // Prayer XP from auto-burying bones
    final prayerXpGain = prayerXpPerKill(monster.hitpoints);

    // Collection log: track kills per monster
    final newKillCounts = Map<String, int>.from(state.monsterKillCounts);
    newKillCounts[monster.id] = (newKillCounts[monster.id] ?? 0) + 1;

    // Roll loot drops and add to bank
    final lootDrops = rollLootDrops(monster);
    final newBank = addToBank(state.bank, lootDrops);
    if (lootDrops.isNotEmpty) {
      final lootSummary = lootDrops.entries.map((e) {
        final item = getItemById(e.key);
        final equipDef = item == null ? getEquipmentDefById(e.key) : null;
        final name = item?.name ?? equipDef?.name ?? e.key;
        return '$name x${e.value}';
      }).join(', ');
      log = _appendLog(log, '📦 Loot: $lootSummary');
    }

    final result = updated.copyWith(
      stats: newStats,
      gp: state.gp + gpGain + slayerBonusGp,
      monsterCurrentHp: monster.hitpoints,
      playerCurrentHp: playerHp,
      totalKills: state.totalKills + 1,
      prayerXp: state.prayerXp + prayerXpGain,
      lastDamageDealt: playerDmg,
      lastDamageTaken: monsterDmg,
      clearDrop: true,
      combatLog: log,
      slayerXp: state.slayerXp + slayerXpGain,
      currentSlayerTask: updatedTask,
      clearSlayerTask: taskJustCompleted,
      slayerTasksCompleted: tasksCompleted,
      monsterKillCounts: newKillCounts,
      totalGearDrops: state.totalGearDrops,
      bank: newBank,
    );

    // Auto-eat after kill if needed
    var afterEat = _tryAutoEat(result, newStats.hitpointsLevel);

    // Auto-advance: if the monster died in one tick, move to next monster
    if (afterEat.autoAdvance && playerDmg >= monster.hitpoints) {
      final nextIdx = state.monsterIndex + 1;
      if (nextIdx < monsterDefs.length) {
        final nextMonster = getMonster(nextIdx);
        afterEat = afterEat.copyWith(
          monsterIndex: nextIdx,
          monsterCurrentHp: nextMonster.hitpoints,
          combatLog: _appendLog(
              afterEat.combatLog, '⏩ Auto-advancing to ${nextMonster.name}...'),
        );
      }
    }

    return afterEat;
  }

  // Both alive, continue fighting
  final result = updated.copyWith(
    monsterCurrentHp: monsterHp,
    playerCurrentHp: playerHp,
    lastDamageDealt: playerDmg,
    lastDamageTaken: monsterDmg,
    clearDrop: true,
  );

  // Auto-eat if HP is low
  return _tryAutoEat(result, state.stats.hitpointsLevel);
}

// ─── Offline Progress ────────────────────────────────────────────

const int _maxOfflineTicks = 24000; // 8 hours at 1.2s per tick
const int _msPerTick = 1200;

/// Simulate offline progress using statistical averages for speed.
({IdleGameState state, OfflineProgressResult result}) simulateOfflineProgress(
    IdleGameState state) {
  if (state.lastSaveEpochMs <= 0) {
    return (state: state, result: const OfflineProgressResult());
  }
  if (!state.isRunning) {
    return (state: state, result: const OfflineProgressResult());
  }

  final now = DateTime.now().millisecondsSinceEpoch;
  final elapsedMs = now - state.lastSaveEpochMs;
  if (elapsedMs < _msPerTick * 5) {
    return (state: state, result: const OfflineProgressResult());
  }

  final elapsed = Duration(milliseconds: elapsedMs);
  final ticks = (elapsedMs / _msPerTick).floor().clamp(0, _maxOfflineTicks);

  final monster = getMonster(state.monsterIndex);
  final gear = calcEquipmentBonuses(state.equipment);

  // Average player hit
  final playerHitChance =
      hitChance(state.stats.attackLevel, gear.meleeAttack, monster.defence);
  final playerMaxHit = maxHit(state.stats.strengthLevel, gear.meleeStrength);
  final avgPlayerDmg = playerHitChance * (playerMaxHit / 2.0);

  // Average monster hit
  final monsterHitChance = hitChance(
      monster.attack, 0, state.stats.defenceLevel + gear.meleeDefence);
  final avgMonsterDmg = monsterHitChance * (monster.maxHit / 2.0);

  // Estimated ticks per kill
  final ticksPerKill =
      avgPlayerDmg > 0 ? (monster.hitpoints / avgPlayerDmg).ceil() : 999;

  // Estimated damage taken per kill
  final dmgPerKill = (avgMonsterDmg * ticksPerKill).ceil();
  final maxHpVal = state.stats.hitpointsLevel;

  var s = state;
  int totalKills = 0;
  int totalGp = 0;
  int ticksUsed = 0;

  while (ticksUsed + ticksPerKill <= ticks) {
    if (dmgPerKill >= maxHpVal && s.foodInventory.isEmpty) {
      break;
    }

    ticksUsed += ticksPerKill;
    totalKills++;

    // XP
    final xpGain = combatXpPerKill(monster, s.prestigeMultiplier);
    final hpGain = hpXpPerKill(monster, s.prestigeMultiplier);
    var newStats = s.stats;
    switch (s.trainingStyle) {
      case TrainingStyle.attack:
        newStats = newStats.copyWith(attackXp: newStats.attackXp + xpGain);
        break;
      case TrainingStyle.strength:
        newStats = newStats.copyWith(strengthXp: newStats.strengthXp + xpGain);
        break;
      case TrainingStyle.defence:
        newStats = newStats.copyWith(defenceXp: newStats.defenceXp + xpGain);
        break;
      case TrainingStyle.balanced:
        final third = xpGain ~/ 3;
        newStats = newStats.copyWith(
          attackXp: newStats.attackXp + third,
          strengthXp: newStats.strengthXp + third,
          defenceXp: newStats.defenceXp + third,
        );
        break;
      case TrainingStyle.ranged:
        newStats = newStats.copyWith(rangedXp: newStats.rangedXp + xpGain);
        break;
      case TrainingStyle.magic:
        newStats = newStats.copyWith(magicXp: newStats.magicXp + xpGain);
        break;
    }
    newStats = newStats.copyWith(hitpointsXp: newStats.hitpointsXp + hpGain);

    // GP
    final gpGain = rollGpDrop(monster);
    totalGp += gpGain;

    s = s.copyWith(
      stats: newStats,
      gp: s.gp + gpGain,
      totalKills: s.totalKills + 1,
    );
  }

  // Reset HP to full after offline session
  final finalMonster = getMonster(s.monsterIndex);
  s = s.copyWith(
    monsterCurrentHp: finalMonster.hitpoints,
    playerCurrentHp: s.stats.hitpointsLevel,
    lastSaveEpochMs: now,
    combatLog: totalKills > 0
        ? [
            '📴 Offline progress: ${elapsed.inHours}h ${elapsed.inMinutes % 60}m',
            '💀 Killed $totalKills ${monster.name}s',
            '💰 Earned ${totalGp}gp',
          ]
        : s.combatLog,
  );

  return (
    state: s,
    result: OfflineProgressResult(
      ticksSimulated: ticksUsed,
      killsGained: totalKills,
      gpGained: totalGp,
      elapsed: elapsed,
    ),
  );
}

// ─── Skilling Tick ──────────────────────────────────────────────

/// Append to skilling log, keeping only last 20 entries.
List<String> _appendSkillingLog(List<String> log, String entry) {
  final newLog = [...log, entry];
  if (newLog.length > 20) return newLog.sublist(newLog.length - 20);
  return newLog;
}

/// Process one skilling tick. Returns the updated game state.
IdleGameState processSkillingTick(IdleGameState state) {
  final active = state.activeSkilling;
  if (active == null) return state;

  final resource = getSkillingResourceById(active.resourceId);
  if (resource == null) return state;

  var log = List<String>.from(state.skillingLog);
  final bank = Map<String, int>.from(state.bank);

  // Check if player has required materials
  for (final req in resource.consumesItems.entries) {
    final have = bank[req.key] ?? 0;
    if (have < req.value) {
      final item = getItemById(req.key);
      log = _appendSkillingLog(
          log, '❌ Not enough ${item?.name ?? req.key}! Need ${req.value}.');
      return state.copyWith(
        skillingLog: log,
        clearActiveSkilling: true,
      );
    }
  }

  // Consume input materials
  for (final req in resource.consumesItems.entries) {
    bank[req.key] = (bank[req.key] ?? 0) - req.value;
    if (bank[req.key]! <= 0) bank.remove(req.key);
  }

  // Check success (burn chance for cooking, fail chance for iron smelting, etc.)
  final succeeded = _rng.nextDouble() <= resource.successRate;

  // Award XP regardless of success (OSRS gives XP even on burns for some skills)
  // Actually in OSRS you don't get XP for burning. Let's only give XP on success.
  var newSkillingStats = state.skillingStats;

  if (succeeded) {
    newSkillingStats =
        newSkillingStats.addXp(resource.skill, resource.xpPerAction);

    // Add produced item to bank
    if (resource.producesItemId != null) {
      bank[resource.producesItemId!] =
          (bank[resource.producesItemId!] ?? 0) + resource.producesQty;
    }

    final producedItem = resource.producesItemId != null
        ? getItemById(resource.producesItemId!)
        : null;
    final producedName = producedItem?.name ?? resource.name;
    log = _appendSkillingLog(log,
        '✅ ${resource.name} → $producedName (+${resource.xpPerAction} xp)');
  } else {
    log = _appendSkillingLog(log, '🔥 You burned the ${resource.name}!');
  }

  return state.copyWith(
    skillingStats: newSkillingStats,
    bank: bank,
    skillingLog: log,
  );
}

/// Check if the player has enough materials in bank for a skilling resource.
bool canDoSkillingAction(IdleGameState state, SkillingResource resource) {
  for (final req in resource.consumesItems.entries) {
    if ((state.bank[req.key] ?? 0) < req.value) return false;
  }
  return true;
}

/// Move cooked food from bank to food inventory for combat use.
IdleGameState moveFoodToInventory(
    IdleGameState state, String cookedItemId, int qty) {
  final bankQty = state.bank[cookedItemId] ?? 0;
  if (bankQty <= 0 || qty <= 0) return state;
  final actualQty = qty.clamp(0, bankQty);

  final newBank = Map<String, int>.from(state.bank);
  newBank[cookedItemId] = bankQty - actualQty;
  if (newBank[cookedItemId]! <= 0) newBank.remove(cookedItemId);

  final newFood = Map<String, int>.from(state.foodInventory);
  newFood[cookedItemId] = (newFood[cookedItemId] ?? 0) + actualQty;

  return state.copyWith(bank: newBank, foodInventory: newFood);
}

/// Prestige: reset stats, keep prestige bonuses.
IdleGameState prestige(IdleGameState state) {
  final newPrestige = state.prestigeLevel + 1;
  final newMultiplier = 1.0 + (newPrestige * 0.1);
  return IdleGameState(
    prestigeLevel: newPrestige,
    prestigeMultiplier: newMultiplier,
    gp: 0,
    equipment: const {},
    monsterIndex: 0,
    isRunning: false,
  );
}
