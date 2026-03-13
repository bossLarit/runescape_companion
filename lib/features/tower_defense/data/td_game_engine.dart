import 'dart:math';

import '../domain/td_models.dart';
import 'td_game_data.dart';

// ─── Main Tick ───────────────────────────────────────────────────

TdGameState processTick(TdGameState state) {
  if (state.phase != TdPhase.waveActive) return state;

  final enemies = List<ActiveEnemy>.from(state.enemies);
  final projectiles = List<Projectile>.from(state.projectiles);
  final damageNumbers = List<DamageNumber>.from(state.damageNumbers);
  final towerSlots = List<TowerSlot>.from(state.towerSlots);
  final peasants = List<Peasant>.from(state.peasants);
  final wallSlots = List<WallSlot>.from(state.wallSlots);
  final nodes = state.resourceNodes;
  var res = state.resources;
  var garrison = state.garrison;
  var kills = state.enemiesKilledThisWave;
  var totalKills = state.totalKills;
  var totalGpEarned = state.totalGpEarned;
  var enemiesLeftToSpawn = state.enemiesLeftToSpawn;
  var spawnCooldown = state.spawnCooldown;
  var freezeTicks = state.freezeTicksLeft;
  final hero = state.hero;

  final mod = state.currentModifier;
  final inventory = List<LootItem>.from(state.inventory);

  // ── 1. Spawn enemies ───────────────────────────────────────
  if (enemiesLeftToSpawn > 0 && enemies.length < maxActiveEnemies) {
    spawnCooldown -= 1;
    if (spawnCooldown <= 0) {
      final e = spawnEnemy(state.wave);
      // Apply wave modifier
      e.hp = (e.hp * modifierHpMult(mod)).roundToDouble();
      // Need to create with adjusted maxHp too, but maxHp is final, so re-create
      final adjusted = ActiveEnemy(
        defIndex: e.defIndex,
        hp: (e.maxHp * modifierHpMult(mod)).roundToDouble(),
        maxHp: (e.maxHp * modifierHpMult(mod)).roundToDouble(),
        speed: e.speed * modifierSpeedMult(mod),
        gpReward: e.gpReward,
        damage: e.damage,
        isTreasure: e.isTreasure,
        shielded: modifierShielded(mod),
      );
      enemies.add(adjusted);
      enemiesLeftToSpawn--;
      spawnCooldown = spawnDelayTicks(state.wave);
    }
  }

  // ── 2. Freeze tick ─────────────────────────────────────────
  if (freezeTicks > 0) freezeTicks--;

  // ── 3. Move enemies (skip if frozen) ───────────────────────
  for (final e in enemies) {
    if (!e.alive) continue;
    if (freezeTicks > 0) continue;

    // Check wall collision
    bool blockedByWall = false;
    for (final wall in wallSlots) {
      if (wall.isBuilt &&
          (e.pathProgress - wall.pathProgress).abs() < 0.01 &&
          e.pathProgress <= wall.pathProgress + 0.01) {
        blockedByWall = true;
        wall.hp -= 1;
        break;
      }
    }
    if (blockedByWall) continue;

    // Check hero collision — hero blocks enemies like a wall
    if (hero != null && hero.alive) {
      final diff = (e.pathProgress - hero.patrolProgress).abs();
      if (diff < 0.02 && e.pathProgress <= hero.patrolProgress + 0.02) {
        continue; // enemy blocked by hero
      }
    }

    e.pathProgress += e.speed;
    if (e.pathProgress >= 1.0) {
      e.alive = false;
      if (!e.isTreasure) {
        final rawDmg = e.damage.toDouble();
        final reduced =
            (rawDmg * (1.0 - garrison.armourReduction)).round().clamp(1, 9999);
        garrison = garrison.copyWith(
            hp: (garrison.hp - reduced).clamp(0, garrison.maxHp));
      }
    }
  }

  // ── 4. Garrison attack ─────────────────────────────────────
  var gFireCd = (garrison.fireCooldown - 1).clamp(0.0, 999.0);
  if (gFireCd <= 0 && enemies.any((e) => e.alive)) {
    final gDmg = garrisonDamage(garrison.damageLevel);
    final gRange = garrisonRange();
    final targetIdx = _findTarget(enemies, garrisonX, garrisonY, gRange);
    if (targetIdx >= 0) {
      gFireCd = garrisonFireRate(garrison.damageLevel);
      if (projectiles.length < maxActiveProjectiles) {
        final enemy = enemies[targetIdx];
        final ePos = positionOnPath(enemy.pathProgress);
        projectiles.add(Projectile(
          x: garrisonX,
          y: garrisonY,
          targetX: ePos.x,
          targetY: ePos.y,
          damage: gDmg,
          type: ProjectileType.garrisonArrow,
          targetEnemyIndex: targetIdx,
        ));
      } else {
        _instantHit(enemies[targetIdx], gDmg, damageNumbers, res, kills,
            totalKills, totalGpEarned, (r, k, tk, tg) {
          res = r;
          kills = k;
          totalKills = tk;
          totalGpEarned = tg;
        });
      }
    }
  }
  garrison = garrison.copyWith(fireCooldown: gFireCd);

  // ── 4b. Regen modifier ────────────────────────────────────
  if (modifierRegen(mod)) {
    for (final e in enemies) {
      if (!e.alive) continue;
      e.hp = min(e.maxHp, e.hp + e.maxHp * 0.005 / 60.0); // 0.5% per second
    }
  }

  // ── 4c. Poison tick ──────────────────────────────────────
  for (final e in enemies) {
    if (!e.alive || e.poisonTicksLeft <= 0) continue;
    e.poisonTicksLeft--;
    e.hp -= poisonDps / 60.0;
    if (e.hp <= 0) {
      e.alive = false;
      res = res.copyWith(gold: res.gold + e.gpReward);
      totalGpEarned += e.gpReward;
      kills++;
      totalKills++;
    }
  }

  // ── 5. Tower attacks ───────────────────────────────────────
  final prestigeDmgMult = prestigeTowerDmgMult(state.prestigeBonuses);
  for (final slot in towerSlots) {
    if (slot.isEmpty || slot.towerType == TowerType.house) continue;
    slot.fireCooldown = (slot.fireCooldown - 1).clamp(0, 999);
    if (slot.fireCooldown > 0) continue;
    final baseDmg =
        towerDamageAtLevel(slot.towerType!, slot.level) * prestigeDmgMult;
    // Apply equipped loot bonus
    final lootDmgBonus = _lootDmgBonus(slot.equippedLootId, state.inventory);
    final dmg = baseDmg * (1.0 + lootDmgBonus);
    final baseRange = towerRangeAtLevel(slot.towerType!, slot.level);
    final lootRangeBonus =
        _lootRangeBonus(slot.equippedLootId, state.inventory);
    final range = baseRange * (1.0 + lootRangeBonus);

    // Poison trap: apply poison to nearby enemies
    if (slot.towerType == TowerType.poisonTrap) {
      bool applied = false;
      for (final e in enemies) {
        if (!e.alive) continue;
        final ePos = positionOnPath(e.pathProgress);
        final dx = ePos.x - slot.x;
        final dy = ePos.y - slot.y;
        if (sqrt(dx * dx + dy * dy) <= range && e.poisonTicksLeft <= 0) {
          e.poisonTicksLeft = poisonDurationTicks;
          applied = true;
        }
      }
      if (applied) {
        slot.fireCooldown = towerFireRateAtLevel(slot.towerType!, slot.level);
      }
      continue;
    }

    final targetIdx = _findTarget(enemies, slot.x, slot.y, range);
    if (targetIdx < 0) continue;
    slot.fireCooldown = towerFireRateAtLevel(slot.towerType!, slot.level);
    final projType = towerDefs[slot.towerType!]!.projectile;
    if (projectiles.length < maxActiveProjectiles) {
      final enemy = enemies[targetIdx];
      final ePos = positionOnPath(enemy.pathProgress);
      projectiles.add(Projectile(
        x: slot.x,
        y: slot.y,
        targetX: ePos.x,
        targetY: ePos.y,
        damage: dmg,
        type: projType,
        targetEnemyIndex: targetIdx,
      ));
    } else {
      _instantHit(enemies[targetIdx], dmg, damageNumbers, res, kills,
          totalKills, totalGpEarned, (r, k, tk, tg) {
        res = r;
        kills = k;
        totalKills = tk;
        totalGpEarned = tg;
      });
    }
  }

  // ── 6. Hero combat ─────────────────────────────────────────
  if (hero != null) {
    if (hero.alive) {
      // Check if any enemy is in melee range
      final engagedIdx = _findTarget(enemies, hero.x, hero.y, heroMeleeRange);
      final inCombat = engagedIdx >= 0;

      // Patrol movement — only when NOT fighting
      if (!inCombat) {
        if (hero.patrolForward) {
          hero.patrolProgress += heroPatrolSpeed;
          if (hero.patrolProgress >= 0.85) hero.patrolForward = false;
        } else {
          hero.patrolProgress -= heroPatrolSpeed;
          if (hero.patrolProgress <= 0.15) hero.patrolForward = true;
        }
        final hPos = positionOnPath(hero.patrolProgress);
        hero.x = hPos.x;
        hero.y = hPos.y;
      }

      // Attack nearest enemy
      hero.attackCooldown = (hero.attackCooldown - 1).clamp(0, 999);
      if (hero.attackCooldown <= 0 && inCombat) {
        hero.attackCooldown = heroAttackSpeed;
        final dmg = heroDamageAtLevel(hero.damageLevel);
        _instantHit(enemies[engagedIdx], dmg, damageNumbers, res, kills,
            totalKills, totalGpEarned, (r, k, tk, tg) {
          res = r;
          kills = k;
          totalKills = tk;
          totalGpEarned = tg;
        });
      }

      // Take damage from blocked enemies (use pathProgress, same as blocking check)
      for (final e in enemies) {
        if (!e.alive) continue;
        final diff = (e.pathProgress - hero.patrolProgress).abs();
        if (diff < 0.03) {
          hero.hp -= 1;
          if (hero.hp <= 0) {
            hero.alive = false;
            hero.respawnTimer = heroRespawnTicks;
            break;
          }
        }
      }
    } else {
      // Respawn countdown
      hero.respawnTimer--;
      if (hero.respawnTimer <= 0) {
        hero.alive = true;
        hero.hp = hero.maxHp;
        hero.patrolProgress = 0.3;
        final hPos = positionOnPath(0.3);
        hero.x = hPos.x;
        hero.y = hPos.y;
      }
    }
  }

  // ── 7. Move projectiles ────────────────────────────────────
  for (final p in projectiles) {
    if (!p.active) continue;
    if (p.targetEnemyIndex >= 0 && p.targetEnemyIndex < enemies.length) {
      final target = enemies[p.targetEnemyIndex];
      if (target.alive) {
        final tPos = positionOnPath(target.pathProgress);
        p.targetX = tPos.x;
        p.targetY = tPos.y;
      }
    }
    final dx = p.targetX - p.x;
    final dy = p.targetY - p.y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < projectileSpeed * 1.5) {
      p.active = false;
      if (p.targetEnemyIndex >= 0 && p.targetEnemyIndex < enemies.length) {
        final target = enemies[p.targetEnemyIndex];
        if (target.alive) {
          // Shield absorbs first hit
          if (target.shielded) {
            target.shielded = false;
            damageNumbers
                .add(DamageNumber(x: p.targetX, y: p.targetY, amount: 0));
          } else {
            target.hp -= p.damage;
            damageNumbers.add(DamageNumber(
                x: p.targetX, y: p.targetY, amount: p.damage.round()));
            if (target.hp <= 0) {
              target.alive = false;
              final gpMult = 1.0 + _lootGpBonus(null, inventory);
              final gp = (target.gpReward * gpMult).round();
              res = res.copyWith(gold: res.gold + gp);
              totalGpEarned += gp;
              kills++;
              totalKills++;
              // Loot drop roll
              if (inventory.length < maxInventorySize) {
                final loot = rollLootDrop(state.wave);
                if (loot != null) inventory.add(loot);
              }
            }
          }
          // Cannon splash
          if (p.type == ProjectileType.cannonBall) {
            final splashDmg = p.damage * cannonSplashDamageFraction;
            for (int si = 0; si < enemies.length; si++) {
              if (si == p.targetEnemyIndex || !enemies[si].alive) continue;
              final sPos = positionOnPath(enemies[si].pathProgress);
              final sdx = sPos.x - p.targetX;
              final sdy = sPos.y - p.targetY;
              if (sqrt(sdx * sdx + sdy * sdy) <= cannonSplashRadius) {
                if (enemies[si].shielded) {
                  enemies[si].shielded = false;
                } else {
                  enemies[si].hp -= splashDmg;
                  damageNumbers.add(DamageNumber(
                      x: sPos.x, y: sPos.y, amount: splashDmg.round()));
                  if (enemies[si].hp <= 0) {
                    enemies[si].alive = false;
                    res = res.copyWith(gold: res.gold + enemies[si].gpReward);
                    totalGpEarned += enemies[si].gpReward;
                    kills++;
                    totalKills++;
                  }
                }
              }
            }
          }
        }
      }
    } else {
      p.x += (dx / dist) * projectileSpeed;
      p.y += (dy / dist) * projectileSpeed;
    }
  }

  // ── 8. Peasant movement & gathering ────────────────────────
  for (final p in peasants) {
    if (p.assignedNodeIndex < 0 || p.assignedNodeIndex >= nodes.length) {
      p.state = PeasantState.idle;
      continue;
    }
    final node = nodes[p.assignedNodeIndex];
    final dx = node.x - p.x;
    final dy = node.y - p.y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > 0.02) {
      p.state = PeasantState.walking;
      p.x += (dx / dist) * peasantMoveSpeed;
      p.y += (dy / dist) * peasantMoveSpeed;
    } else {
      p.state = PeasantState.gathering;
      p.gatherTimer += 1;
      final gatherTicks = peasantGatherTicksForLevel(node.level);
      if (p.gatherTimer >= gatherTicks) {
        p.gatherTimer = 0;
        switch (node.type) {
          case NodeType.tree:
            res = res.copyWith(logs: res.logs + 1);
          case NodeType.runeAltar:
            res = res.copyWith(runes: res.runes + 1);
          case NodeType.mine:
            res = res.copyWith(ore: res.ore + 1);
        }
      }
    }
  }

  // ── 9. Tick damage numbers ─────────────────────────────────
  for (final d in damageNumbers) {
    d.ticksLeft--;
    d.y -= 0.002;
  }

  // ── 10. Cleanup ────────────────────────────────────────────
  enemies.removeWhere((e) => !e.alive);
  projectiles.removeWhere((p) => !p.active);
  damageNumbers.removeWhere((d) => d.ticksLeft <= 0);

  // ── 11. Game over ──────────────────────────────────────────
  if (garrison.hp <= 0) {
    final earned = prestigePointsEarned(state.wave);
    return state.copyWith(
      garrison: garrison,
      resources: res,
      enemies: enemies,
      projectiles: projectiles,
      damageNumbers: damageNumbers,
      towerSlots: towerSlots,
      peasants: peasants,
      wallSlots: wallSlots,
      phase: TdPhase.gameOver,
      enemiesKilledThisWave: kills,
      totalKills: totalKills,
      totalGpEarned: totalGpEarned,
      enemiesLeftToSpawn: enemiesLeftToSpawn,
      spawnCooldown: spawnCooldown,
      highestWave: max(state.highestWave, state.wave),
      freezeTicksLeft: freezeTicks,
      hero: () => hero,
      inventory: inventory,
      prestigePoints: state.prestigePoints + earned,
      totalPrestigePoints: state.totalPrestigePoints + earned,
    );
  }

  // ── 12. Wave complete ──────────────────────────────────────
  if (enemies.isEmpty && enemiesLeftToSpawn <= 0) {
    final bonus = waveCompletionBonus(state.wave);
    return state.copyWith(
      garrison: garrison,
      resources: res.copyWith(gold: res.gold + bonus),
      enemies: const [],
      projectiles: const [],
      damageNumbers: damageNumbers,
      towerSlots: towerSlots,
      peasants: peasants,
      wallSlots: wallSlots,
      phase: TdPhase.waveComplete,
      enemiesKilledThisWave: kills,
      totalKills: totalKills,
      totalGpEarned: totalGpEarned + bonus,
      enemiesLeftToSpawn: 0,
      spawnCooldown: 0,
      highestWave: max(state.highestWave, state.wave),
      abilityCooldowns: state.abilityCooldowns.tickWave(),
      freezeTicksLeft: 0,
      hero: () => hero,
      inventory: inventory,
    );
  }

  return state.copyWith(
    garrison: garrison,
    resources: res,
    enemies: enemies,
    projectiles: projectiles,
    damageNumbers: damageNumbers,
    towerSlots: towerSlots,
    peasants: peasants,
    wallSlots: wallSlots,
    enemiesKilledThisWave: kills,
    totalKills: totalKills,
    totalGpEarned: totalGpEarned,
    enemiesLeftToSpawn: enemiesLeftToSpawn,
    spawnCooldown: spawnCooldown,
    freezeTicksLeft: freezeTicks,
    hero: () => hero,
    inventory: inventory,
  );
}

// ─── Instant Hit Helper ──────────────────────────────────────────

void _instantHit(
  ActiveEnemy enemy,
  double dmg,
  List<DamageNumber> damageNumbers,
  Resources res,
  int kills,
  int totalKills,
  int totalGpEarned,
  void Function(Resources, int, int, int) update,
) {
  enemy.hp -= dmg;
  final pos = positionOnPath(enemy.pathProgress);
  damageNumbers.add(DamageNumber(x: pos.x, y: pos.y, amount: dmg.round()));
  if (enemy.hp <= 0) {
    enemy.alive = false;
    update(res.copyWith(gold: res.gold + enemy.gpReward), kills + 1,
        totalKills + 1, totalGpEarned + enemy.gpReward);
  }
}

// ─── Targeting ───────────────────────────────────────────────────

int _findTarget(List<ActiveEnemy> enemies, double tx, double ty, double range) {
  int bestIdx = -1;
  double bestProgress = -1;
  for (int i = 0; i < enemies.length; i++) {
    final e = enemies[i];
    if (!e.alive) continue;
    final pos = positionOnPath(e.pathProgress);
    final dx = pos.x - tx;
    final dy = pos.y - ty;
    if (sqrt(dx * dx + dy * dy) > range) continue;
    if (e.pathProgress > bestProgress) {
      bestProgress = e.pathProgress;
      bestIdx = i;
    }
  }
  return bestIdx;
}

// ─── Wave Start ──────────────────────────────────────────────────

TdGameState startWave(TdGameState state) {
  if (state.phase != TdPhase.idle && state.phase != TdPhase.waveComplete) {
    return state;
  }
  final wave =
      state.phase == TdPhase.waveComplete ? state.wave + 1 : state.wave;
  final isTreasure = isTreasureWave(wave);
  final modifier = isTreasure ? WaveModifier.none : rollModifier(wave);
  final baseCount = isTreasure ? treasureEnemyCount(wave) : enemiesInWave(wave);
  final count = modifierEnemyCountMult(modifier, baseCount);
  return state.copyWith(
    wave: wave,
    phase: TdPhase.waveActive,
    enemies: const [],
    projectiles: const [],
    damageNumbers: const [],
    enemiesKilledThisWave: 0,
    totalEnemiesThisWave: count,
    enemiesLeftToSpawn: count,
    spawnCooldown: 1,
    freezeTicksLeft: 0,
    currentModifier: modifier,
  );
}

// ─── Tower Placement ─────────────────────────────────────────────

TdGameState placeTower(TdGameState state, int slotIndex, TowerType type) {
  if (slotIndex < 0 || slotIndex >= state.towerSlots.length) return state;
  final slot = state.towerSlots[slotIndex];
  if (slot.hasTower) return state;
  final def = towerDefs[type]!;
  if (!state.resources.canAfford(def.cost)) return state;
  final slots = List<TowerSlot>.from(state.towerSlots);
  slots[slotIndex] = TowerSlot(x: slot.x, y: slot.y, towerType: type, level: 1);
  final newRes = state.resources.subtract(def.cost);
  var cap = state.peasantCap;
  if (type == TowerType.house) cap += 2;
  return state.copyWith(resources: newRes, towerSlots: slots, peasantCap: cap);
}

TdGameState upgradeTower(TdGameState state, int slotIndex) {
  if (slotIndex < 0 || slotIndex >= state.towerSlots.length) return state;
  final slot = state.towerSlots[slotIndex];
  if (slot.isEmpty) return state;
  // House upgrade: grants +1 peasant cap per level
  if (slot.towerType == TowerType.house) {
    final cost = houseUpgradeCost(slot.level);
    if (!state.resources.canAfford(cost)) return state;
    final slots = List<TowerSlot>.from(state.towerSlots);
    slots[slotIndex] = TowerSlot(
        x: slot.x,
        y: slot.y,
        towerType: TowerType.house,
        level: slot.level + 1);
    return state.copyWith(
        resources: state.resources.subtract(cost),
        towerSlots: slots,
        peasantCap: state.peasantCap + 1);
  }
  final cost = towerUpgradeCost(slot.towerType!, slot.level);
  if (!state.resources.canAfford(cost)) return state;
  final slots = List<TowerSlot>.from(state.towerSlots);
  slots[slotIndex] = TowerSlot(
      x: slot.x,
      y: slot.y,
      towerType: slot.towerType,
      level: slot.level + 1,
      equippedLootId: slot.equippedLootId);
  return state.copyWith(
      resources: state.resources.subtract(cost), towerSlots: slots);
}

// ─── Peasant Management ──────────────────────────────────────────

TdGameState buyPeasant(TdGameState state) {
  if (state.peasants.length >= state.peasantCap) return state;
  final cost = peasantCost(state.peasants.length);
  if (state.resources.gold < cost) return state;
  final peasants = List<Peasant>.from(state.peasants);
  final id = peasants.isEmpty ? 1 : peasants.map((p) => p.id).reduce(max) + 1;
  final nodeIdx = _leastBusyNode(peasants, state.resourceNodes.length);
  peasants.add(
      Peasant(id: id, assignedNodeIndex: nodeIdx, x: garrisonX, y: garrisonY));
  return state.copyWith(
    resources: state.resources.copyWith(gold: state.resources.gold - cost),
    peasants: peasants,
  );
}

TdGameState relocatePeasant(TdGameState state, int peasantId, int nodeIndex) {
  if (nodeIndex < 0 || nodeIndex >= state.resourceNodes.length) return state;
  final peasants = List<Peasant>.from(state.peasants);
  final idx = peasants.indexWhere((p) => p.id == peasantId);
  if (idx < 0) return state;
  peasants[idx].assignedNodeIndex = nodeIndex;
  peasants[idx].gatherTimer = 0;
  return state.copyWith(peasants: peasants);
}

int _leastBusyNode(List<Peasant> peasants, int nodeCount) {
  final counts = List.filled(nodeCount, 0);
  for (final p in peasants) {
    if (p.assignedNodeIndex >= 0 && p.assignedNodeIndex < nodeCount) {
      counts[p.assignedNodeIndex]++;
    }
  }
  int minIdx = 0;
  for (int i = 1; i < counts.length; i++) {
    if (counts[i] < counts[minIdx]) minIdx = i;
  }
  return minIdx;
}

// ─── Garrison Upgrades ───────────────────────────────────────────

TdGameState upgradeGarrisonDamage(TdGameState state) {
  final cost = garrisonUpgradeCost(state.garrison.damageLevel);
  if (state.resources.gold < cost) return state;
  return state.copyWith(
    resources: state.resources.copyWith(gold: state.resources.gold - cost),
    garrison:
        state.garrison.copyWith(damageLevel: state.garrison.damageLevel + 1),
  );
}

TdGameState upgradeGarrisonHealth(TdGameState state) {
  final cost = garrisonUpgradeCost(state.garrison.healthLevel);
  if (state.resources.gold < cost) return state;
  final newLevel = state.garrison.healthLevel + 1;
  final newMax = garrisonMaxHp(newLevel);
  return state.copyWith(
    resources: state.resources.copyWith(gold: state.resources.gold - cost),
    garrison: state.garrison.copyWith(
        healthLevel: newLevel,
        maxHp: newMax,
        hp: min(state.garrison.hp + 20, newMax)),
  );
}

TdGameState upgradeGarrisonArmour(TdGameState state) {
  final cost = garrisonUpgradeCost(state.garrison.armourLevel + 1);
  if (state.resources.gold < cost) return state;
  return state.copyWith(
    resources: state.resources.copyWith(gold: state.resources.gold - cost),
    garrison:
        state.garrison.copyWith(armourLevel: state.garrison.armourLevel + 1),
  );
}

// ─── Abilities ──────────────────────────────────────────────────

TdGameState castAbility(TdGameState state, AbilityType type) {
  if (state.phase != TdPhase.waveActive) return state;
  if (!state.abilityCooldowns.canUse(type)) return state;
  final cost = abilityCost(type);
  if (!state.resources.canAfford(cost)) return state;

  var newState = state.copyWith(
    resources: state.resources.subtract(cost),
    abilityCooldowns: state.abilityCooldowns.withUsed(type),
  );

  switch (type) {
    case AbilityType.iceBarrage:
      newState = newState.copyWith(freezeTicksLeft: freezeDuration);
    case AbilityType.cannonBlast:
      final dmg = cannonBlastDamage(state.wave);
      final enemies = List<ActiveEnemy>.from(newState.enemies);
      final damageNumbers = List<DamageNumber>.from(newState.damageNumbers);
      for (final e in enemies) {
        if (!e.alive) continue;
        e.hp -= dmg;
        final pos = positionOnPath(e.pathProgress);
        damageNumbers
            .add(DamageNumber(x: pos.x, y: pos.y, amount: dmg.round()));
        if (e.hp <= 0) e.alive = false;
      }
      newState =
          newState.copyWith(enemies: enemies, damageNumbers: damageNumbers);
    case AbilityType.heal:
      final healHp = (state.garrison.maxHp * healAmount()).round();
      newState = newState.copyWith(
        garrison: state.garrison.copyWith(
            hp: min(state.garrison.hp + healHp, state.garrison.maxHp)),
      );
  }
  return newState;
}

// ─── Node Upgrade ───────────────────────────────────────────────

TdGameState upgradeNode(TdGameState state, int nodeIndex) {
  if (nodeIndex < 0 || nodeIndex >= state.resourceNodes.length) return state;
  final node = state.resourceNodes[nodeIndex];
  // No level cap — endless upgrades
  final cost = nodeUpgradeCost(node.type, node.level);
  if (!state.resources.canAfford(cost)) return state;
  final nodes = List<ResourceNode>.from(state.resourceNodes);
  nodes[nodeIndex].level++;
  return state.copyWith(
      resources: state.resources.subtract(cost), resourceNodes: nodes);
}

// ─── Hero Purchase & Upgrade ────────────────────────────────────

TdGameState purchaseHero(TdGameState state) {
  if (state.hero != null) return state;
  if (state.resources.gold < heroPurchaseCost) return state;
  final hPos = positionOnPath(0.3);
  return state.copyWith(
    resources:
        state.resources.copyWith(gold: state.resources.gold - heroPurchaseCost),
    hero: () => HeroUnit(x: hPos.x, y: hPos.y, patrolProgress: 0.3),
  );
}

TdGameState upgradeHero(TdGameState state) {
  if (state.hero == null) return state;
  final cost = heroUpgradeCost(state.hero!.damageLevel);
  if (state.resources.gold < cost) return state;
  final h = state.hero!;
  final newLevel = h.damageLevel + 1;
  final newMaxHp = heroMaxHpAtLevel(newLevel);
  h.damageLevel = newLevel;
  h.maxHp = newMaxHp;
  h.hp = min(h.hp + 10, newMaxHp);
  return state.copyWith(
    resources: state.resources.copyWith(gold: state.resources.gold - cost),
    hero: () => h,
  );
}

// ─── Wall Build & Upgrade ───────────────────────────────────────

TdGameState buildWall(TdGameState state, int wallIndex) {
  if (wallIndex < 0 || wallIndex >= state.wallSlots.length) return state;
  final wall = state.wallSlots[wallIndex];
  if (wall.isBuilt) return state;
  if (!state.resources.canAfford(wallBuildCost)) return state;
  final walls = List<WallSlot>.from(state.wallSlots);
  final hp = wallMaxHpAtLevel(1);
  walls[wallIndex] = WallSlot(
      x: wall.x,
      y: wall.y,
      pathProgress: wall.pathProgress,
      hp: hp,
      maxHp: hp,
      level: 1);
  return state.copyWith(
      resources: state.resources.subtract(wallBuildCost), wallSlots: walls);
}

TdGameState repairWall(TdGameState state, int wallIndex) {
  if (wallIndex < 0 || wallIndex >= state.wallSlots.length) return state;
  final wall = state.wallSlots[wallIndex];
  if (!wall.isDestroyed) return state;
  const repairCost = Resources(ore: 10);
  if (!state.resources.canAfford(repairCost)) return state;
  final walls = List<WallSlot>.from(state.wallSlots);
  walls[wallIndex].hp = walls[wallIndex].maxHp;
  return state.copyWith(
      resources: state.resources.subtract(repairCost), wallSlots: walls);
}

TdGameState upgradeWall(TdGameState state, int wallIndex) {
  if (wallIndex < 0 || wallIndex >= state.wallSlots.length) return state;
  final wall = state.wallSlots[wallIndex];
  if (wall.isEmpty) return state;
  final cost = wallUpgradeCost(wall.level);
  if (!state.resources.canAfford(cost)) return state;
  final walls = List<WallSlot>.from(state.wallSlots);
  final newLevel = wall.level + 1;
  final newMax = wallMaxHpAtLevel(newLevel);
  walls[wallIndex] = WallSlot(
      x: wall.x,
      y: wall.y,
      pathProgress: wall.pathProgress,
      hp: newMax,
      maxHp: newMax,
      level: newLevel);
  return state.copyWith(
      resources: state.resources.subtract(cost), wallSlots: walls);
}

// ─── Loot Helpers ───────────────────────────────────────────────

double _lootDmgBonus(String? lootId, List<LootItem> inventory) {
  if (lootId == null) return 0;
  final item = inventory.where((l) => l.id == lootId).firstOrNull;
  return item?.dmgBonus ?? 0;
}

double _lootRangeBonus(String? lootId, List<LootItem> inventory) {
  if (lootId == null) return 0;
  final item = inventory.where((l) => l.id == lootId).firstOrNull;
  return item?.rangeBonus ?? 0;
}

double _lootGpBonus(String? lootId, List<LootItem> inventory) {
  if (lootId == null) return 0;
  final item = inventory.where((l) => l.id == lootId).firstOrNull;
  return item?.gpBonus ?? 0;
}

// ─── Equip / Unequip Loot ──────────────────────────────────────

TdGameState equipLootToTower(TdGameState state, String lootId, int slotIndex) {
  if (slotIndex < 0 || slotIndex >= state.towerSlots.length) return state;
  final item = state.inventory.where((l) => l.id == lootId).firstOrNull;
  if (item == null || item.slot != LootSlot.tower) return state;
  final slots = List<TowerSlot>.from(state.towerSlots);
  // Unequip from any other tower that has this item
  for (final s in slots) {
    if (s.equippedLootId == lootId) s.equippedLootId = null;
  }
  slots[slotIndex].equippedLootId = lootId;
  return state.copyWith(towerSlots: slots);
}

TdGameState equipLootToHero(TdGameState state, String lootId) {
  if (state.hero == null) return state;
  final item = state.inventory.where((l) => l.id == lootId).firstOrNull;
  if (item == null || item.slot != LootSlot.hero) return state;
  state.hero!.equippedLootId = lootId;
  return state.copyWith(hero: () => state.hero);
}

TdGameState unequipLoot(TdGameState state, String lootId) {
  // Check towers
  final slots = List<TowerSlot>.from(state.towerSlots);
  for (final s in slots) {
    if (s.equippedLootId == lootId) s.equippedLootId = null;
  }
  // Check hero
  if (state.hero?.equippedLootId == lootId) {
    state.hero!.equippedLootId = null;
  }
  return state.copyWith(towerSlots: slots, hero: () => state.hero);
}

TdGameState discardLoot(TdGameState state, String lootId) {
  final s = unequipLoot(state, lootId);
  final inv = List<LootItem>.from(s.inventory);
  inv.removeWhere((l) => l.id == lootId);
  return s.copyWith(inventory: inv);
}

// ─── Prestige Shop ──────────────────────────────────────────────

TdGameState buyPrestige(TdGameState state, String bonusKey) {
  final cost = prestigeCosts[bonusKey];
  if (cost == null || state.prestigePoints < cost) return state;
  final b = state.prestigeBonuses;
  PrestigeBonuses newBonuses;
  switch (bonusKey) {
    case 'startingGold':
      newBonuses = b.copyWith(startingGoldBonus: b.startingGoldBonus + 1);
    case 'peasantCap':
      newBonuses = b.copyWith(peasantCapBonus: b.peasantCapBonus + 1);
    case 'towerDmg':
      newBonuses = b.copyWith(towerDmgPercent: b.towerDmgPercent + 1);
    case 'garrisonHp':
      newBonuses = b.copyWith(garrisonHpPercent: b.garrisonHpPercent + 1);
    default:
      return state;
  }
  return state.copyWith(
    prestigePoints: state.prestigePoints - cost,
    prestigeBonuses: newBonuses,
  );
}

// ─── Reset Game ──────────────────────────────────────────────────

TdGameState resetGame(TdGameState state) {
  final b = state.prestigeBonuses;
  final startGold = prestigeStartingGold(b);
  final startCap = prestigePeasantCap(b);
  final gMaxHp = prestigeGarrisonMaxHp(b, 1);
  return TdGameState(
    highestWave: max(state.highestWave, state.wave),
    towerSlots: createTowerSlots(),
    resourceNodes: createResourceNodes(),
    wallSlots: createWallSlots(),
    resources: Resources(gold: startGold),
    peasantCap: startCap,
    garrison: GarrisonState(hp: gMaxHp, maxHp: gMaxHp),
    prestigePoints: state.prestigePoints,
    totalPrestigePoints: state.totalPrestigePoints,
    prestigeBonuses: b,
    inventory: state.inventory,
  );
}
