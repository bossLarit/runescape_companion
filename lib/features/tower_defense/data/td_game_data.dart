import 'dart:math';

import '../domain/td_models.dart';

// ─── Enemy Definitions (OSRS monsters) ───────────────────────────

const enemyDefs = <EnemyDef>[
  EnemyDef(
      id: 'chicken',
      name: 'Chicken',
      baseHp: 4,
      baseSpeed: 0.0015,
      baseGpReward: 3,
      baseDamage: 1),
  EnemyDef(
      id: 'goblin',
      name: 'Goblin',
      baseHp: 8,
      baseSpeed: 0.0018,
      baseGpReward: 5,
      baseDamage: 1),
  EnemyDef(
      id: 'guard',
      name: 'Al-Kharid Warrior',
      baseHp: 16,
      baseSpeed: 0.0018,
      baseGpReward: 10,
      baseDamage: 2),
  EnemyDef(
      id: 'hill_giant',
      name: 'Hill Giant',
      baseHp: 28,
      baseSpeed: 0.0014,
      baseGpReward: 18,
      baseDamage: 3),
  EnemyDef(
      id: 'moss_giant',
      name: 'Moss Giant',
      baseHp: 45,
      baseSpeed: 0.0014,
      baseGpReward: 30,
      baseDamage: 4),
  EnemyDef(
      id: 'lesser_demon',
      name: 'Lesser Demon',
      baseHp: 70,
      baseSpeed: 0.0016,
      baseGpReward: 50,
      baseDamage: 5),
  EnemyDef(
      id: 'greater_demon',
      name: 'Greater Demon',
      baseHp: 100,
      baseSpeed: 0.0016,
      baseGpReward: 80,
      baseDamage: 7),
  EnemyDef(
      id: 'black_dragon',
      name: 'Black Dragon',
      baseHp: 160,
      baseSpeed: 0.0012,
      baseGpReward: 150,
      baseDamage: 10),
  EnemyDef(
      id: 'tztok_jad',
      name: 'TzTok-Jad',
      baseHp: 300,
      baseSpeed: 0.001,
      baseGpReward: 400,
      baseDamage: 25),
];

// Imp definition for treasure waves (index 9)
const impDef = EnemyDef(
    id: 'imp',
    name: 'Imp',
    baseHp: 3,
    baseSpeed: 0.003,
    baseGpReward: 8,
    baseDamage: 0);

// ─── Wave Scaling (REBALANCED) ──────────────────────────────────

int enemiesInWave(int wave) => (3 + (wave * 0.8)).floor().clamp(3, 40);

int enemyDefIndexForWave(int wave) => ((wave - 1) % enemyDefs.length);

double waveHpMultiplier(int wave) {
  final cycle = (wave - 1) ~/ enemyDefs.length;
  return 1.0 + cycle * 0.45;
}

double waveSpeedMultiplier(int wave) {
  final cycle = (wave - 1) ~/ enemyDefs.length;
  return (1.0 + cycle * 0.12).clamp(1.0, 2.5);
}

double waveGpMultiplier(int wave) {
  final cycle = (wave - 1) ~/ enemyDefs.length;
  return 1.0 + cycle * 0.8;
}

double spawnDelayTicks(int wave) => (50 - wave * 0.8).clamp(12.0, 50.0);

// ─── Treasure Waves ─────────────────────────────────────────────

bool isTreasureWave(int wave) => wave > 1 && wave % 5 == 0;
int treasureEnemyCount(int wave) => 10 + wave;

ActiveEnemy spawnTreasureEnemy() {
  return ActiveEnemy(
    defIndex: -1,
    hp: impDef.baseHp.toDouble(),
    maxHp: impDef.baseHp.toDouble(),
    speed: impDef.baseSpeed,
    gpReward: impDef.baseGpReward,
    damage: 0,
    isTreasure: true,
  );
}

ActiveEnemy spawnEnemy(int wave) {
  if (isTreasureWave(wave)) return spawnTreasureEnemy();
  final defIdx = enemyDefIndexForWave(wave);
  final def = enemyDefs[defIdx];
  final hpMult = waveHpMultiplier(wave);
  final spdMult = waveSpeedMultiplier(wave);
  final gpMult = waveGpMultiplier(wave);
  final hp = (def.baseHp * hpMult).roundToDouble();
  return ActiveEnemy(
    defIndex: defIdx,
    hp: hp,
    maxHp: hp,
    speed: def.baseSpeed * spdMult,
    gpReward: (def.baseGpReward * gpMult).round(),
    damage: def.baseDamage + ((wave - 1) ~/ enemyDefs.length),
  );
}

bool isBossWave(int wave) =>
    wave % enemyDefs.length == 0 && !isTreasureWave(wave);

int waveCompletionBonus(int wave) => 20 + wave * 8;

// ─── Tower Definitions ──────────────────────────────────────────

class TowerDef {
  final TowerType type;
  final String name;
  final Resources cost;
  final double baseDamage;
  final double baseFireRate;
  final double baseRange;
  final ProjectileType projectile;

  const TowerDef({
    required this.type,
    required this.name,
    required this.cost,
    required this.baseDamage,
    required this.baseFireRate,
    required this.baseRange,
    required this.projectile,
  });
}

const towerDefs = <TowerType, TowerDef>{
  TowerType.archer: TowerDef(
    type: TowerType.archer,
    name: 'Archer Tower',
    cost: Resources(logs: 15, gold: 10),
    baseDamage: 8.0,
    baseFireRate: 14,
    baseRange: 0.20,
    projectile: ProjectileType.arrow,
  ),
  TowerType.mage: TowerDef(
    type: TowerType.mage,
    name: 'Mage Tower',
    cost: Resources(runes: 15, gold: 10),
    baseDamage: 14.0,
    baseFireRate: 28,
    baseRange: 0.28,
    projectile: ProjectileType.magicBolt,
  ),
  TowerType.warrior: TowerDef(
    type: TowerType.warrior,
    name: 'Warrior Tower',
    cost: Resources(ore: 20, gold: 10),
    baseDamage: 22.0,
    baseFireRate: 38,
    baseRange: 0.12,
    projectile: ProjectileType.arrow,
  ),
  TowerType.cannon: TowerDef(
    type: TowerType.cannon,
    name: 'Dwarf Cannon',
    cost: Resources(ore: 30, gold: 20),
    baseDamage: 18.0,
    baseFireRate: 50,
    baseRange: 0.18,
    projectile: ProjectileType.cannonBall,
  ),
  TowerType.ballista: TowerDef(
    type: TowerType.ballista,
    name: 'Ballista',
    cost: Resources(logs: 25, ore: 25, gold: 15),
    baseDamage: 45.0,
    baseFireRate: 80,
    baseRange: 0.30,
    projectile: ProjectileType.ballistaBolt,
  ),
  TowerType.poisonTrap: TowerDef(
    type: TowerType.poisonTrap,
    name: 'Poison Trap',
    cost: Resources(logs: 15, runes: 10),
    baseDamage: 0,
    baseFireRate: 90,
    baseRange: 0.04,
    projectile: ProjectileType.arrow,
  ),
  TowerType.house: TowerDef(
    type: TowerType.house,
    name: 'House',
    cost: Resources(logs: 20),
    baseDamage: 0,
    baseFireRate: 999,
    baseRange: 0,
    projectile: ProjectileType.arrow,
  ),
};

const cannonSplashRadius = 0.06;
const cannonSplashDamageFraction = 0.70;
const poisonDps = 3.0;
const poisonDurationTicks = 300; // 5 seconds

double towerDamageAtLevel(TowerType type, int level) {
  final def = towerDefs[type]!;
  return def.baseDamage * pow(1.35, level - 1).toDouble();
}

double towerFireRateAtLevel(TowerType type, int level) {
  final def = towerDefs[type]!;
  return max(4.0, def.baseFireRate - (level - 1) * 3.5);
}

double towerRangeAtLevel(TowerType type, int level) {
  final def = towerDefs[type]!;
  return (def.baseRange + (level - 1) * 0.015).clamp(0.05, 0.50);
}

Resources towerUpgradeCost(TowerType type, int currentLevel) {
  final def = towerDefs[type]!;
  final mult = pow(1.35, currentLevel - 1).toDouble();
  return Resources(
    gold: max(1, (def.cost.gold * mult).round()),
    logs: (def.cost.logs * mult).round(),
    runes: (def.cost.runes * mult).round(),
    ore: (def.cost.ore * mult).round(),
  );
}

// House upgrade: each level grants +1 peasant cap
Resources houseUpgradeCost(int currentLevel) => Resources(
      logs: (20 * pow(1.4, currentLevel - 1)).round(),
      gold: (10 * pow(1.4, currentLevel - 1)).round(),
    );

// ─── Garrison Stats ─────────────────────────────────────────────

double garrisonDamage(int damageLevel) => 5.0 + (damageLevel - 1) * 3.0;
double garrisonFireRate(int damageLevel) =>
    max(12.0, 30.0 - (damageLevel - 1) * 0.8);
double garrisonRange() => 0.30;
int garrisonMaxHp(int healthLevel) => 100 + (healthLevel - 1) * 20;
int garrisonUpgradeCost(int currentLevel) =>
    (15 * pow(1.15, currentLevel - 1)).round();

// ─── Peasant ────────────────────────────────────────────────────

int peasantCost(int ownedCount) => 10 + ownedCount * 5;
const peasantMoveSpeed = 0.004;

// Gather ticks by node level — diminishing returns, min 20 ticks
int peasantGatherTicksForLevel(int nodeLevel) =>
    max(20, (180 * pow(0.7, nodeLevel - 1)).round());

// ─── Node Upgrade Costs ─────────────────────────────────────────

Resources nodeUpgradeCost(NodeType type, int currentLevel) {
  final mult = pow(1.5, currentLevel - 1).toDouble();
  final resAmount = (20 * mult).round();
  final goldAmount = (15 * mult).round();
  return switch (type) {
    NodeType.tree => Resources(logs: resAmount, gold: goldAmount),
    NodeType.runeAltar => Resources(runes: resAmount, gold: goldAmount),
    NodeType.mine => Resources(ore: resAmount, gold: goldAmount),
  };
}

// ─── Ability Costs ──────────────────────────────────────────────

Resources abilityCost(AbilityType type) => switch (type) {
      AbilityType.iceBarrage => const Resources(runes: 10),
      AbilityType.cannonBlast => const Resources(ore: 15, gold: 10),
      AbilityType.heal => const Resources(gold: 20),
    };

const freezeDuration = 180; // 3 seconds at 60tps

double cannonBlastDamage(int wave) => 50.0 + wave * 5.0;
double healAmount() => 0.30; // 30% of max HP

// ─── Hero Stats ─────────────────────────────────────────────────

const heroPurchaseCost = 50;
const heroBaseHp = 30;
const heroBaseDamage = 3.0;
const heroAttackSpeed = 40.0; // ticks
const heroMeleeRange = 0.05;
const heroPatrolSpeed = 0.002;
const heroRespawnTicks = 300;

double heroDamageAtLevel(int level) => heroBaseDamage + (level - 1) * 1.0;
int heroMaxHpAtLevel(int level) => heroBaseHp + (level - 1) * 10;
int heroUpgradeCost(int currentLevel) =>
    (25 * pow(1.2, currentLevel - 1)).round();

// ─── Wall Stats ─────────────────────────────────────────────────

const wallBuildCost = Resources(ore: 20);
const wallBaseHp = 50;
const wallHpPerLevel = 30;
int wallMaxHpAtLevel(int level) => wallBaseHp + (level - 1) * wallHpPerLevel;
Resources wallUpgradeCost(int currentLevel) => Resources(
      ore: (20 * pow(1.3, currentLevel - 1)).round(),
    );

// ─── Path Waypoints ──────────────────────────────────────────────

const pathWaypoints = <({double x, double y})>[
  (x: 0.5, y: -0.02),
  (x: 0.5, y: 0.08),
  (x: 0.85, y: 0.12),
  (x: 0.85, y: 0.28),
  (x: 0.15, y: 0.34),
  (x: 0.15, y: 0.50),
  (x: 0.85, y: 0.54),
  (x: 0.85, y: 0.70),
  (x: 0.50, y: 0.76),
  (x: 0.50, y: 0.90),
];

double get totalPathLength {
  double len = 0;
  for (int i = 1; i < pathWaypoints.length; i++) {
    final dx = pathWaypoints[i].x - pathWaypoints[i - 1].x;
    final dy = pathWaypoints[i].y - pathWaypoints[i - 1].y;
    len += sqrt(dx * dx + dy * dy);
  }
  return len;
}

({double x, double y}) positionOnPath(double progress) {
  if (progress <= 0) return pathWaypoints.first;
  if (progress >= 1) return pathWaypoints.last;
  final targetDist = progress * totalPathLength;
  double walked = 0;
  for (int i = 1; i < pathWaypoints.length; i++) {
    final dx = pathWaypoints[i].x - pathWaypoints[i - 1].x;
    final dy = pathWaypoints[i].y - pathWaypoints[i - 1].y;
    final segLen = sqrt(dx * dx + dy * dy);
    if (walked + segLen >= targetDist) {
      final t = (targetDist - walked) / segLen;
      return (
        x: pathWaypoints[i - 1].x + dx * t,
        y: pathWaypoints[i - 1].y + dy * t
      );
    }
    walked += segLen;
  }
  return pathWaypoints.last;
}

// ─── Garrison Position ───────────────────────────────────────────

const garrisonX = 0.50;
const garrisonY = 0.92;

// ─── Tower Slot Positions ────────────────────────────────────────

List<TowerSlot> createTowerSlots() => [
      TowerSlot(x: 0.30, y: 0.10),
      TowerSlot(x: 0.70, y: 0.20),
      TowerSlot(x: 0.30, y: 0.30),
      TowerSlot(x: 0.50, y: 0.42),
      TowerSlot(x: 0.70, y: 0.42),
      TowerSlot(x: 0.30, y: 0.55),
      TowerSlot(x: 0.70, y: 0.62),
      TowerSlot(x: 0.35, y: 0.72),
    ];

// ─── Resource Node Positions ─────────────────────────────────────

List<ResourceNode> createResourceNodes() => [
      ResourceNode(type: NodeType.tree, x: 0.06, y: 0.15),
      ResourceNode(type: NodeType.tree, x: 0.94, y: 0.45),
      ResourceNode(type: NodeType.runeAltar, x: 0.06, y: 0.70),
      ResourceNode(type: NodeType.runeAltar, x: 0.94, y: 0.75),
      ResourceNode(type: NodeType.mine, x: 0.06, y: 0.42),
      ResourceNode(type: NodeType.mine, x: 0.94, y: 0.15),
    ];

// ─── Wall Slot Positions ────────────────────────────────────────

List<WallSlot> createWallSlots() => [
      WallSlot(x: 0.50, y: 0.08, pathProgress: 0.04),
      WallSlot(x: 0.85, y: 0.28, pathProgress: 0.25),
      WallSlot(x: 0.15, y: 0.50, pathProgress: 0.50),
      WallSlot(x: 0.85, y: 0.70, pathProgress: 0.75),
    ];

// ─── Projectile Speed ────────────────────────────────────────────

const projectileSpeed = 0.025;

// ─── Performance Caps ────────────────────────────────────────────

const maxActiveEnemies = 40;
const maxActiveProjectiles = 80;

// ─── Wave Modifiers ─────────────────────────────────────────────

final _rng = Random();

WaveModifier rollModifier(int wave) {
  if (wave <= 10) return WaveModifier.none;
  const mods = [
    WaveModifier.armoured,
    WaveModifier.swift,
    WaveModifier.horde,
    WaveModifier.regen,
    WaveModifier.shielded,
  ];
  return mods[_rng.nextInt(mods.length)];
}

double modifierHpMult(WaveModifier m) => switch (m) {
      WaveModifier.armoured => 1.6,
      WaveModifier.horde => 0.6,
      _ => 1.0,
    };

double modifierSpeedMult(WaveModifier m) => switch (m) {
      WaveModifier.swift => 1.5,
      _ => 1.0,
    };

int modifierEnemyCountMult(WaveModifier m, int base) => switch (m) {
      WaveModifier.horde => base * 2,
      _ => base,
    };

bool modifierShielded(WaveModifier m) => m == WaveModifier.shielded;
bool modifierRegen(WaveModifier m) => m == WaveModifier.regen;

// ─── Prestige ───────────────────────────────────────────────────

int prestigePointsEarned(int wave) => wave ~/ 5;

const prestigeCosts = <String, int>{
  'startingGold': 1,
  'peasantCap': 2,
  'towerDmg': 2,
  'garrisonHp': 1,
};

int prestigeStartingGold(PrestigeBonuses b) => 25 + b.startingGoldBonus * 15;
int prestigePeasantCap(PrestigeBonuses b) => 2 + b.peasantCapBonus;
double prestigeTowerDmgMult(PrestigeBonuses b) =>
    1.0 + b.towerDmgPercent * 0.05;
int prestigeGarrisonMaxHp(PrestigeBonuses b, int healthLevel) =>
    ((100 + (healthLevel - 1) * 20) * (1.0 + b.garrisonHpPercent * 0.10))
        .round();

// ─── Loot Table ─────────────────────────────────────────────────

const lootTable = <LootItem>[
  LootItem(
      id: 'bronze_scimitar',
      name: 'Bronze Scimitar',
      rarity: LootRarity.common,
      slot: LootSlot.hero,
      dmgBonus: 0.10),
  LootItem(
      id: 'iron_chainbody',
      name: 'Iron Chainbody',
      rarity: LootRarity.common,
      slot: LootSlot.hero,
      hpBonus: 15),
  LootItem(
      id: 'amulet_of_strength',
      name: 'Amulet of Strength',
      rarity: LootRarity.uncommon,
      slot: LootSlot.tower,
      dmgBonus: 0.15),
  LootItem(
      id: 'ring_of_wealth',
      name: 'Ring of Wealth',
      rarity: LootRarity.uncommon,
      slot: LootSlot.tower,
      gpBonus: 0.20),
  LootItem(
      id: 'dragon_dagger',
      name: 'Dragon Dagger',
      rarity: LootRarity.rare,
      slot: LootSlot.hero,
      dmgBonus: 0.30),
  LootItem(
      id: 'amulet_of_fury',
      name: 'Amulet of Fury',
      rarity: LootRarity.rare,
      slot: LootSlot.tower,
      dmgBonus: 0.20,
      rangeBonus: 0.10),
  LootItem(
      id: 'armadyl_crossbow',
      name: 'Armadyl Crossbow',
      rarity: LootRarity.legendary,
      slot: LootSlot.tower,
      dmgBonus: 0.35,
      rangeBonus: 0.15),
  LootItem(
      id: 'bandos_godsword',
      name: 'Bandos Godsword',
      rarity: LootRarity.legendary,
      slot: LootSlot.hero,
      dmgBonus: 0.50,
      hpBonus: 25),
];

const maxInventorySize = 12;

LootItem? rollLootDrop(int wave) {
  final isBoss = isBossWave(wave);
  final roll = _rng.nextDouble();
  final mult = isBoss ? 3.0 : 1.0;
  // Legendary: 0.1%, Rare: 0.5%, Uncommon: 1.5%, Common: 3%
  LootRarity? rarity;
  if (roll < 0.001 * mult) {
    rarity = LootRarity.legendary;
  } else if (roll < 0.006 * mult) {
    rarity = LootRarity.rare;
  } else if (roll < 0.021 * mult) {
    rarity = LootRarity.uncommon;
  } else if (roll < 0.051 * mult) {
    rarity = LootRarity.common;
  }
  if (rarity == null) return null;
  final candidates = lootTable.where((l) => l.rarity == rarity).toList();
  if (candidates.isEmpty) return null;
  final template = candidates[_rng.nextInt(candidates.length)];
  // Give each drop a unique ID so duplicates can be equipped independently
  final uid =
      '${template.id}_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}';
  return LootItem(
    id: uid,
    name: template.name,
    rarity: template.rarity,
    slot: template.slot,
    dmgBonus: template.dmgBonus,
    rangeBonus: template.rangeBonus,
    speedBonus: template.speedBonus,
    hpBonus: template.hpBonus,
    gpBonus: template.gpBonus,
  );
}
