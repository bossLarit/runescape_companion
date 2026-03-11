import 'dart:math';

import '../domain/idle_models.dart';

// ─── Base Monster Definitions ────────────────────────────────────
// These loop endlessly across zones with scaling stats.

const monsterDefs = <MonsterDef>[
  MonsterDef(
    id: 'chicken',
    name: 'Chicken',
    icon: '🐔',
    baseHp: 3,
    baseAttack: 1,
    baseStrength: 1,
    baseDefence: 1,
    baseGpMin: 1,
    baseGpMax: 5,
    dropChance: 0.08,
  ),
  MonsterDef(
    id: 'cow',
    name: 'Cow',
    icon: '🐄',
    baseHp: 8,
    baseAttack: 1,
    baseStrength: 1,
    baseDefence: 1,
    baseGpMin: 3,
    baseGpMax: 12,
    dropChance: 0.10,
  ),
  MonsterDef(
    id: 'goblin',
    name: 'Goblin',
    icon: '👺',
    baseHp: 5,
    baseAttack: 1,
    baseStrength: 1,
    baseDefence: 1,
    baseGpMin: 5,
    baseGpMax: 20,
    dropChance: 0.10,
  ),
  MonsterDef(
    id: 'guard',
    name: 'Al-Kharid Warrior',
    icon: '⚔️',
    baseHp: 19,
    baseAttack: 8,
    baseStrength: 7,
    baseDefence: 5,
    baseGpMin: 15,
    baseGpMax: 50,
    dropChance: 0.12,
  ),
  MonsterDef(
    id: 'hill_giant',
    name: 'Hill Giant',
    icon: '🗿',
    baseHp: 35,
    baseAttack: 18,
    baseStrength: 22,
    baseDefence: 18,
    baseGpMin: 30,
    baseGpMax: 120,
    dropChance: 0.14,
  ),
  MonsterDef(
    id: 'moss_giant',
    name: 'Moss Giant',
    icon: '🌿',
    baseHp: 60,
    baseAttack: 30,
    baseStrength: 30,
    baseDefence: 30,
    baseGpMin: 60,
    baseGpMax: 250,
    dropChance: 0.16,
  ),
  MonsterDef(
    id: 'lesser_demon',
    name: 'Lesser Demon',
    icon: '😈',
    baseHp: 79,
    baseAttack: 42,
    baseStrength: 45,
    baseDefence: 40,
    baseGpMin: 100,
    baseGpMax: 500,
    dropChance: 0.18,
  ),
  MonsterDef(
    id: 'greater_demon',
    name: 'Greater Demon',
    icon: '👿',
    baseHp: 87,
    baseAttack: 56,
    baseStrength: 58,
    baseDefence: 53,
    baseGpMin: 200,
    baseGpMax: 800,
    dropChance: 0.20,
  ),
  MonsterDef(
    id: 'black_dragon',
    name: 'Black Dragon',
    icon: '🐉',
    baseHp: 190,
    baseAttack: 68,
    baseStrength: 72,
    baseDefence: 70,
    baseGpMin: 400,
    baseGpMax: 1500,
    dropChance: 0.22,
  ),
  MonsterDef(
    id: 'tztok_jad',
    name: 'TzTok-Jad',
    icon: '🔥',
    baseHp: 250,
    baseAttack: 85,
    baseStrength: 90,
    baseDefence: 80,
    baseGpMin: 2000,
    baseGpMax: 8000,
    dropChance: 0.30,
  ),
];

/// Get a ScaledMonster by its index in the base list + zone.
ScaledMonster getMonster(int index, int zone) {
  final def = monsterDefs[index.clamp(0, monsterDefs.length - 1)];
  return ScaledMonster(def, zone);
}

// ─── Food Definitions ─────────────────────────────────────────────

const foodItems = <FoodItem>[
  FoodItem(id: 'shrimp', name: 'Shrimps', icon: '🦐', healAmount: 3, cost: 10),
  FoodItem(id: 'trout', name: 'Trout', icon: '🐟', healAmount: 7, cost: 30),
  FoodItem(
      id: 'lobster', name: 'Lobster', icon: '🦞', healAmount: 12, cost: 80),
  FoodItem(
      id: 'swordfish',
      name: 'Swordfish',
      icon: '🐡',
      healAmount: 14,
      cost: 150),
  FoodItem(
      id: 'monkfish', name: 'Monkfish', icon: '🐠', healAmount: 16, cost: 250),
  FoodItem(id: 'shark', name: 'Shark', icon: '🦈', healAmount: 20, cost: 500),
  FoodItem(
      id: 'manta_ray',
      name: 'Manta Ray',
      icon: '🪸',
      healAmount: 22,
      cost: 800),
  FoodItem(
      id: 'anglerfish',
      name: 'Anglerfish',
      icon: '🎣',
      healAmount: 22,
      cost: 1200),
];

FoodItem? getFoodById(String id) {
  for (final f in foodItems) {
    if (f.id == id) return f;
  }
  return null;
}

// ─── Prayer Potions ──────────────────────────────────────────────

class PrayerPotion {
  final String id;
  final String name;
  final String icon;
  final int restoreAmount;
  final int cost;

  const PrayerPotion({
    required this.id,
    required this.name,
    required this.icon,
    required this.restoreAmount,
    required this.cost,
  });
}

const prayerPotions = <PrayerPotion>[
  PrayerPotion(
      id: 'prayer_potion',
      name: 'Prayer Potion',
      icon: '🧪',
      restoreAmount: 7, // OSRS: 7 + floor(level/4), simplified to 7
      cost: 300),
  PrayerPotion(
      id: 'super_restore',
      name: 'Super Restore',
      icon: '💎',
      restoreAmount: 8, // OSRS: 8 + floor(level/4), simplified to 8
      cost: 600),
];

PrayerPotion? getPrayerPotionById(String id) {
  for (final p in prayerPotions) {
    if (p.id == id) return p;
  }
  return null;
}

// ─── Bones (prayer XP from kills) ───────────────────────────────

/// Prayer XP gained from burying bones dropped by a monster.
/// Scales with monster HP like OSRS (stronger monsters = better bones).
int prayerXpPerKill(int monsterBaseHp) {
  if (monsterBaseHp <= 5) return 5; // regular bones
  if (monsterBaseHp <= 35) return 15; // big bones
  if (monsterBaseHp <= 100) return 50; // dragon bones tier
  if (monsterBaseHp <= 300) return 72; // superior dragon bones
  return 125; // boss-tier bones
}

// ─── Gear Upgrade Shop ────────────────────────────────────────────

/// Cost to upgrade gear from [currentLevel] to [currentLevel + 1].
int gearUpgradeCost(int currentLevel) {
  return 100 + (currentLevel * currentLevel * 25);
}

// ─── Special Attack ───────────────────────────────────────────────

const int specCooldownTicks = 8; // ~10 seconds at 1.2s per tick
const double specDamageMultiplier = 2.5;

// ─── Slayer-Only Monsters ────────────────────────────────────────
// Stats sourced from OSRS wiki. These are NOT in the normal monster
// rotation — they unlock via Slayer level and only appear as tasks.

const slayerMonsterDefs = <MonsterDef>[
  MonsterDef(
    id: 'dust_devil',
    name: 'Dust Devil',
    icon: '🌪️',
    baseHp: 105,
    baseAttack: 60,
    baseStrength: 60,
    baseDefence: 30,
    baseGpMin: 300,
    baseGpMax: 1200,
    dropChance: 0.20,
  ),
  MonsterDef(
    id: 'wyvern',
    name: 'Skeletal Wyvern',
    icon: '🦴',
    baseHp: 140,
    baseAttack: 65,
    baseStrength: 72,
    baseDefence: 80,
    baseGpMin: 500,
    baseGpMax: 2000,
    dropChance: 0.22,
  ),
  MonsterDef(
    id: 'abyssal_demon',
    name: 'Abyssal Demon',
    icon: '👁️',
    baseHp: 150,
    baseAttack: 97,
    baseStrength: 67,
    baseDefence: 135,
    baseGpMin: 600,
    baseGpMax: 2500,
    dropChance: 0.24,
  ),
  MonsterDef(
    id: 'cerberus',
    name: 'Cerberus',
    icon: '🐕',
    baseHp: 600,
    baseAttack: 220,
    baseStrength: 220,
    baseDefence: 100,
    baseGpMin: 3000,
    baseGpMax: 12000,
    dropChance: 0.28,
  ),
  MonsterDef(
    id: 'hydra',
    name: 'Alchemical Hydra',
    icon: '🐲',
    baseHp: 1100,
    baseAttack: 250,
    baseStrength: 250,
    baseDefence: 150,
    baseGpMin: 5000,
    baseGpMax: 25000,
    dropChance: 0.30,
  ),
];

/// Slayer level required to fight each slayer-only monster.
const slayerRequirements = <String, int>{
  'dust_devil': 55,
  'wyvern': 72,
  'abyssal_demon': 85,
  'cerberus': 91,
  'hydra': 95,
};

/// All monsters combined (normal + slayer).
List<MonsterDef> get allMonsterDefs => [...monsterDefs, ...slayerMonsterDefs];

/// Find a MonsterDef by id across both lists.
MonsterDef? getMonsterDefById(String id) {
  for (final m in monsterDefs) {
    if (m.id == id) return m;
  }
  for (final m in slayerMonsterDefs) {
    if (m.id == id) return m;
  }
  return null;
}

// ─── Slayer Task Assignment ──────────────────────────────────────

final _slayerRng = Random();

/// Task definitions: (monsterId, minAmount, maxAmount, slayerLevelRequired)
const _slayerTaskPool = <(String, int, int, int)>[
  ('chicken', 15, 30, 1),
  ('cow', 15, 30, 1),
  ('goblin', 15, 30, 1),
  ('guard', 20, 40, 1),
  ('hill_giant', 25, 50, 1),
  ('moss_giant', 25, 50, 1),
  ('lesser_demon', 30, 60, 1),
  ('greater_demon', 30, 60, 1),
  ('black_dragon', 15, 35, 1),
  ('tztok_jad', 3, 8, 1),
  ('dust_devil', 40, 80, 55),
  ('wyvern', 20, 50, 72),
  ('abyssal_demon', 40, 80, 85),
  ('cerberus', 5, 15, 91),
  ('hydra', 3, 10, 95),
];

/// Assign a new slayer task based on the player's slayer level.
SlayerTask assignSlayerTask(int slayerLevel) {
  final eligible = _slayerTaskPool.where((t) => slayerLevel >= t.$4).toList();
  if (eligible.isEmpty) {
    return const SlayerTask(monsterId: 'chicken', amountTotal: 10);
  }

  final pick = eligible[_slayerRng.nextInt(eligible.length)];
  final amount = pick.$2 + _slayerRng.nextInt(pick.$3 - pick.$2 + 1);

  // Bonus scales with monster difficulty and amount
  final monsterDef = getMonsterDefById(pick.$1);
  final int baseBonusGp =
      monsterDef != null ? (monsterDef.baseHp * amount) ~/ 2 : amount * 50;
  final int baseBonusXp =
      monsterDef != null ? (monsterDef.baseHp * amount) ~/ 3 : amount * 30;

  return SlayerTask(
    monsterId: pick.$1,
    amountTotal: amount,
    bonusGp: baseBonusGp,
    bonusSlayerXp: baseBonusXp,
  );
}
