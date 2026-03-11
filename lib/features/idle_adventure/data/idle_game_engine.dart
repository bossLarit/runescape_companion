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
  int meleeGearLevel,
  ScaledMonster m, {
  bool pietyActive = false,
  TrainingStyle style = TrainingStyle.balanced,
  int rangedGearLevel = 0,
  int magicGearLevel = 0,
}) {
  int atkBonus;
  int strBonus;
  int effectiveAtk;
  int effectiveStr;

  switch (style) {
    case TrainingStyle.ranged:
      atkBonus = gearRangedAttackBonus(rangedGearLevel);
      strBonus = gearRangedStrengthBonus(rangedGearLevel);
      effectiveAtk = stats.rangedLevel;
      effectiveStr = stats.rangedLevel; // ranged uses same stat for atk+str
      break;
    case TrainingStyle.magic:
      atkBonus = gearMagicAttackBonus(magicGearLevel);
      strBonus = gearMagicStrengthBonus(magicGearLevel);
      effectiveAtk = stats.magicLevel;
      effectiveStr = stats.magicLevel;
      break;
    default: // melee styles
      atkBonus = gearAttackBonus(meleeGearLevel);
      strBonus = gearStrengthBonus(meleeGearLevel);
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
int rollMonsterDamage(ScaledMonster m, CombatStats stats, int gearLevel) {
  final defBonus = gearDefenceBonus(gearLevel);
  final chance = hitChance(m.attack, 0, stats.defenceLevel + defBonus);
  if (_rng.nextDouble() > chance) return 0;
  final max = maxHit(m.strength, 0);
  return _rng.nextInt(max + 1);
}

/// XP gained per kill.
int combatXpPerKill(ScaledMonster m, double prestigeMultiplier) {
  return (m.maxHp * 4 * prestigeMultiplier).floor();
}

int hpXpPerKill(ScaledMonster m, double prestigeMultiplier) {
  return (m.maxHp * 1.33 * prestigeMultiplier).floor();
}

/// GP drop from a monster.
int rollGpDrop(ScaledMonster m) {
  if (m.gpMax <= m.gpMin) return m.gpMin;
  return m.gpMin + _rng.nextInt(m.gpMax - m.gpMin + 1);
}

/// Roll for a gear drop. Returns true if the monster dropped an upgrade.
bool rollGearDrop(ScaledMonster m) {
  return _rng.nextDouble() < m.dropChance;
}

/// Roll loot drops from a monster's drop table.
/// Returns a map of itemId → quantity gained.
Map<String, int> rollLootDrops(ScaledMonster m) {
  final table = monsterDropTables[m.def.id];
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

/// Process one combat tick. Returns the updated game state.
IdleGameState processTick(IdleGameState state) {
  if (!state.isRunning) return state;

  // Respawn delay — skip combat ticks while dead
  if (state.respawnTicksLeft > 0) {
    return state.copyWith(
      respawnTicksLeft: state.respawnTicksLeft - 1,
    );
  }

  final monster = getMonster(state.monsterIndex, state.zone);
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

  // Player attacks monster (with possible special attack)
  // Piety: +20% attack accuracy, +23% strength (max hit)
  int playerDmg = rollPlayerDamage(state.stats, state.gearLevel, monster,
      pietyActive: currentPrayer == ActivePrayer.piety,
      style: state.trainingStyle,
      rangedGearLevel: state.rangedGearLevel,
      magicGearLevel: state.magicGearLevel);
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
  // Protect from Melee: 100% damage reduction (like OSRS)
  int monsterDmg = rollMonsterDamage(monster, state.stats, state.gearLevel);
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
      monsterCurrentHp: monster.maxHp,
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

  // Monster died → award XP + GP + possible gear drop, spawn next
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

    // Roll for gear drop — applies to the active combat style's gear track
    final gotDrop = rollGearDrop(monster);
    final isRanged = state.trainingStyle == TrainingStyle.ranged;
    final isMagic = state.trainingStyle == TrainingStyle.magic;
    final newGearLevel = gotDrop && !isRanged && !isMagic
        ? state.gearLevel + 1
        : state.gearLevel;
    final newRangedGear =
        gotDrop && isRanged ? state.rangedGearLevel + 1 : state.rangedGearLevel;
    final newMagicGear =
        gotDrop && isMagic ? state.magicGearLevel + 1 : state.magicGearLevel;
    final dropGearLvl = isRanged
        ? newRangedGear
        : isMagic
            ? newMagicGear
            : newGearLevel;
    final dropName = gotDrop ? gearName(dropGearLvl) : null;

    log = _appendLog(
        log, '💀 ${monster.name} defeated! +${gpGain}gp +${xpGain}xp');
    if (gotDrop) {
      log = _appendLog(log, '🎉 Gear drop: ${gearName(dropGearLvl)}!');
    }

    // Slayer task progress
    var slayerXpGain = 0;
    var slayerBonusGp = 0;
    SlayerTask? updatedTask = state.currentSlayerTask;
    bool taskJustCompleted = false;
    int tasksCompleted = state.slayerTasksCompleted;

    if (updatedTask != null && !updatedTask.isComplete) {
      // Check if killed monster matches the task (base id without zone)
      if (monster.def.id == updatedTask.monsterId) {
        updatedTask = updatedTask.copyWith(
          amountKilled: updatedTask.amountKilled + 1,
        );
        // Base slayer XP per kill = monster's HP
        slayerXpGain = monster.maxHp;

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
    final prayerXpGain = prayerXpPerKill(monster.def.baseHp);

    // Collection log: track kills per monster
    final newKillCounts = Map<String, int>.from(state.monsterKillCounts);
    newKillCounts[monster.def.id] = (newKillCounts[monster.def.id] ?? 0) + 1;

    // Roll loot drops and add to bank
    final lootDrops = rollLootDrops(monster);
    final newBank = addToBank(state.bank, lootDrops);
    if (lootDrops.isNotEmpty) {
      final lootSummary = lootDrops.entries.map((e) {
        final item = getItemById(e.key);
        return '${item?.name ?? e.key} x${e.value}';
      }).join(', ');
      log = _appendLog(log, '📦 Loot: $lootSummary');
    }

    final result = updated.copyWith(
      stats: newStats,
      gp: state.gp + gpGain + slayerBonusGp,
      gearLevel: newGearLevel,
      rangedGearLevel: newRangedGear,
      magicGearLevel: newMagicGear,
      monsterCurrentHp: monster.maxHp,
      playerCurrentHp: playerHp,
      totalKills: state.totalKills + 1,
      prayerXp: state.prayerXp + prayerXpGain,
      lastDamageDealt: playerDmg,
      lastDamageTaken: monsterDmg,
      lastDrop: dropName,
      clearDrop: !gotDrop,
      combatLog: log,
      slayerXp: state.slayerXp + slayerXpGain,
      currentSlayerTask: updatedTask,
      clearSlayerTask: taskJustCompleted,
      slayerTasksCompleted: tasksCompleted,
      monsterKillCounts: newKillCounts,
      totalGearDrops: state.totalGearDrops + (gotDrop ? 1 : 0),
      bank: newBank,
    );

    // Auto-eat after kill if needed
    var afterEat = _tryAutoEat(result, newStats.hitpointsLevel);

    // Auto-advance: if the monster died in one tick, move to next monster
    if (afterEat.autoAdvance && playerDmg >= monster.maxHp) {
      final nextIdx = state.monsterIndex + 1;
      if (nextIdx < monsterDefs.length) {
        final nextMonster = getMonster(nextIdx, state.zone);
        afterEat = afterEat.copyWith(
          monsterIndex: nextIdx,
          monsterCurrentHp: nextMonster.maxHp,
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
/// Returns the updated state and a summary of gains.
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
    // Less than ~6 seconds, not worth simulating
    return (state: state, result: const OfflineProgressResult());
  }

  final elapsed = Duration(milliseconds: elapsedMs);
  final ticks = (elapsedMs / _msPerTick).floor().clamp(0, _maxOfflineTicks);

  final monster = getMonster(state.monsterIndex, state.zone);
  final atkBonus = gearAttackBonus(state.gearLevel);
  final strBonus = gearStrengthBonus(state.gearLevel);
  final defBonus = gearDefenceBonus(state.gearLevel);

  // Average player hit
  final playerHitChance =
      hitChance(state.stats.attackLevel, atkBonus, monster.defence);
  final playerMaxHit = maxHit(state.stats.strengthLevel, strBonus);
  final avgPlayerDmg = playerHitChance * (playerMaxHit / 2.0);

  // Average monster hit
  final monsterHitChance =
      hitChance(monster.attack, 0, state.stats.defenceLevel + defBonus);
  final monsterMaxHit = maxHit(monster.strength, 0);
  final avgMonsterDmg = monsterHitChance * (monsterMaxHit / 2.0);

  // Estimated ticks per kill
  final ticksPerKill =
      avgPlayerDmg > 0 ? (monster.maxHp / avgPlayerDmg).ceil() : 999;

  // Estimated damage taken per kill
  final dmgPerKill = (avgMonsterDmg * ticksPerKill).ceil();
  final maxHpVal = state.stats.hitpointsLevel;

  var s = state;
  int totalKills = 0;
  int totalGp = 0;
  int totalGearLevels = 0;
  int ticksUsed = 0;

  while (ticksUsed + ticksPerKill <= ticks) {
    // Check if player can survive the fight
    if (dmgPerKill >= maxHpVal && s.foodInventory.isEmpty) {
      // Player would die every fight with no food — stop simulating
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

    // Gear drop — applies to active style's gear track
    final gotDrop = rollGearDrop(monster);
    if (gotDrop) totalGearLevels++;
    final offIsRanged = s.trainingStyle == TrainingStyle.ranged;
    final offIsMagic = s.trainingStyle == TrainingStyle.magic;

    s = s.copyWith(
      stats: newStats,
      gp: s.gp + gpGain,
      gearLevel: s.gearLevel + (gotDrop && !offIsRanged && !offIsMagic ? 1 : 0),
      rangedGearLevel: s.rangedGearLevel + (gotDrop && offIsRanged ? 1 : 0),
      magicGearLevel: s.magicGearLevel + (gotDrop && offIsMagic ? 1 : 0),
      totalKills: s.totalKills + 1,
    );
  }

  // Reset HP to full after offline session
  final finalMonster = getMonster(s.monsterIndex, s.zone);
  s = s.copyWith(
    monsterCurrentHp: finalMonster.maxHp,
    playerCurrentHp: s.stats.hitpointsLevel,
    lastSaveEpochMs: now,
    combatLog: totalKills > 0
        ? [
            '📴 Offline progress: ${elapsed.inHours}h ${elapsed.inMinutes % 60}m',
            '💀 Killed $totalKills ${monster.def.name}s',
            '💰 Earned ${totalGp}gp',
            if (totalGearLevels > 0)
              '🎉 Found $totalGearLevels gear upgrade${totalGearLevels > 1 ? 's' : ''}!',
          ]
        : s.combatLog,
  );

  return (
    state: s,
    result: OfflineProgressResult(
      ticksSimulated: ticksUsed,
      killsGained: totalKills,
      gpGained: totalGp,
      gearLevelsGained: totalGearLevels,
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
    gearLevel: 0,
    zone: 0,
    monsterIndex: 0,
    isRunning: false,
  );
}
