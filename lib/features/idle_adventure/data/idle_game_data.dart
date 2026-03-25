import 'dart:math';

import '../domain/idle_models.dart';

// ─── Monster Definitions (1:1 OSRS wiki stats, no zone scaling) ──

const monsterDefs = <MonsterDef>[
  // ── Tier 1: Beginner (Combat 1–10) ─────────────────────────────
  MonsterDef(
      id: 'chicken',
      name: 'Chicken',
      icon: '🐔',
      hitpoints: 3,
      attack: 1,
      strength: 1,
      defence: 1,
      maxHit: 1,
      combatLevel: 1,
      gpMin: 1,
      gpMax: 5),
  MonsterDef(
      id: 'cow',
      name: 'Cow',
      icon: '🐄',
      hitpoints: 8,
      attack: 1,
      strength: 1,
      defence: 1,
      maxHit: 1,
      combatLevel: 2,
      gpMin: 3,
      gpMax: 12),
  MonsterDef(
      id: 'goblin',
      name: 'Goblin',
      icon: '👺',
      hitpoints: 5,
      attack: 1,
      strength: 1,
      defence: 1,
      maxHit: 1,
      combatLevel: 2,
      gpMin: 5,
      gpMax: 20),
  MonsterDef(
      id: 'giant_rat',
      name: 'Giant Rat',
      icon: '🐀',
      hitpoints: 5,
      attack: 2,
      strength: 3,
      defence: 2,
      maxHit: 1,
      combatLevel: 3,
      gpMin: 1,
      gpMax: 8),
  MonsterDef(
      id: 'dark_wizard',
      name: 'Dark Wizard',
      icon: '🧙',
      hitpoints: 12,
      attack: 7,
      strength: 5,
      defence: 5,
      maxHit: 2,
      combatLevel: 7,
      gpMin: 5,
      gpMax: 25),
  MonsterDef(
      id: 'al_kharid_warrior',
      name: 'Al-Kharid Warrior',
      icon: '⚔️',
      hitpoints: 19,
      attack: 8,
      strength: 7,
      defence: 5,
      maxHit: 2,
      combatLevel: 9,
      gpMin: 15,
      gpMax: 50),

  // ── Tier 2: Low Level (Combat 10–42) ───────────────────────────
  MonsterDef(
      id: 'barbarian',
      name: 'Barbarian',
      icon: '🪓',
      hitpoints: 18,
      attack: 9,
      strength: 8,
      defence: 5,
      maxHit: 2,
      combatLevel: 10,
      gpMin: 10,
      gpMax: 40),
  MonsterDef(
      id: 'skeleton',
      name: 'Skeleton',
      icon: '💀',
      hitpoints: 22,
      attack: 15,
      strength: 17,
      defence: 15,
      maxHit: 3,
      combatLevel: 21,
      gpMin: 10,
      gpMax: 50),
  MonsterDef(
      id: 'guard',
      name: 'Guard',
      icon: '🛡️',
      hitpoints: 22,
      attack: 18,
      strength: 14,
      defence: 18,
      maxHit: 3,
      combatLevel: 21,
      gpMin: 20,
      gpMax: 60),
  MonsterDef(
      id: 'hill_giant',
      name: 'Hill Giant',
      icon: '🗿',
      hitpoints: 35,
      attack: 18,
      strength: 22,
      defence: 26,
      maxHit: 4,
      combatLevel: 28,
      gpMin: 30,
      gpMax: 120),
  MonsterDef(
      id: 'hobgoblin',
      name: 'Hobgoblin',
      icon: '👹',
      hitpoints: 29,
      attack: 22,
      strength: 24,
      defence: 24,
      maxHit: 4,
      combatLevel: 28,
      gpMin: 20,
      gpMax: 80),
  MonsterDef(
      id: 'moss_giant',
      name: 'Moss Giant',
      icon: '🌿',
      hitpoints: 60,
      attack: 30,
      strength: 30,
      defence: 30,
      maxHit: 5,
      combatLevel: 42,
      gpMin: 60,
      gpMax: 250),

  // ── Tier 3: Mid Level (Combat 53–92) ───────────────────────────
  MonsterDef(
      id: 'ice_giant',
      name: 'Ice Giant',
      icon: '🧊',
      hitpoints: 70,
      attack: 45,
      strength: 42,
      defence: 40,
      maxHit: 7,
      combatLevel: 53,
      gpMin: 80,
      gpMax: 300),
  MonsterDef(
      id: 'cyclops',
      name: 'Cyclops',
      icon: '👁️',
      hitpoints: 56,
      attack: 48,
      strength: 48,
      defence: 48,
      maxHit: 7,
      combatLevel: 56,
      gpMin: 50,
      gpMax: 200),
  MonsterDef(
      id: 'crocodile',
      name: 'Crocodile',
      icon: '🐊',
      hitpoints: 52,
      attack: 48,
      strength: 48,
      defence: 48,
      maxHit: 6,
      combatLevel: 63,
      gpMin: 40,
      gpMax: 150),
  MonsterDef(
      id: 'green_dragon',
      name: 'Green Dragon',
      icon: '🐲',
      hitpoints: 50,
      attack: 55,
      strength: 55,
      defence: 40,
      maxHit: 8,
      combatLevel: 79,
      gpMin: 100,
      gpMax: 400),
  MonsterDef(
      id: 'lesser_demon',
      name: 'Lesser Demon',
      icon: '😈',
      hitpoints: 79,
      attack: 68,
      strength: 68,
      defence: 68,
      maxHit: 8,
      combatLevel: 82,
      gpMin: 100,
      gpMax: 500),
  MonsterDef(
      id: 'fire_giant',
      name: 'Fire Giant',
      icon: '🔥',
      hitpoints: 111,
      attack: 65,
      strength: 65,
      defence: 65,
      maxHit: 11,
      combatLevel: 86,
      gpMin: 150,
      gpMax: 600),
  MonsterDef(
      id: 'greater_demon',
      name: 'Greater Demon',
      icon: '👿',
      hitpoints: 87,
      attack: 82,
      strength: 80,
      defence: 78,
      maxHit: 10,
      combatLevel: 92,
      gpMin: 200,
      gpMax: 800),

  // ── Tier 4: High Level (Combat 100–246) ────────────────────────
  MonsterDef(
      id: 'blue_dragon',
      name: 'Blue Dragon',
      icon: '💎',
      hitpoints: 105,
      attack: 78,
      strength: 78,
      defence: 78,
      maxHit: 11,
      combatLevel: 111,
      gpMin: 200,
      gpMax: 700),
  MonsterDef(
      id: 'spiritual_mage',
      name: 'Spiritual Mage',
      icon: '🔮',
      hitpoints: 75,
      attack: 120,
      strength: 120,
      defence: 107,
      maxHit: 18,
      combatLevel: 120,
      gpMin: 300,
      gpMax: 1200),
  MonsterDef(
      id: 'hellhound',
      name: 'Hellhound',
      icon: '🐕‍🦺',
      hitpoints: 116,
      attack: 105,
      strength: 105,
      defence: 105,
      maxHit: 11,
      combatLevel: 122,
      gpMin: 200,
      gpMax: 800),
  MonsterDef(
      id: 'monkey_guard',
      name: 'Monkey Guard',
      icon: '🐵',
      hitpoints: 167,
      attack: 110,
      strength: 110,
      defence: 110,
      maxHit: 14,
      combatLevel: 149,
      gpMin: 300,
      gpMax: 1000),
  MonsterDef(
      id: 'black_demon',
      name: 'Black Demon',
      icon: '�',
      hitpoints: 157,
      attack: 120,
      strength: 120,
      defence: 120,
      maxHit: 16,
      combatLevel: 172,
      gpMin: 400,
      gpMax: 1500),
  MonsterDef(
      id: 'iron_dragon',
      name: 'Iron Dragon',
      icon: '⚙️',
      hitpoints: 165,
      attack: 120,
      strength: 120,
      defence: 140,
      maxHit: 16,
      combatLevel: 189,
      gpMin: 500,
      gpMax: 2000),
  MonsterDef(
      id: 'black_dragon',
      name: 'Black Dragon',
      icon: '🐉',
      hitpoints: 190,
      attack: 155,
      strength: 155,
      defence: 120,
      maxHit: 19,
      combatLevel: 227,
      gpMin: 400,
      gpMax: 1500),
  MonsterDef(
      id: 'steel_dragon',
      name: 'Steel Dragon',
      icon: '🤖',
      hitpoints: 210,
      attack: 175,
      strength: 175,
      defence: 175,
      maxHit: 19,
      combatLevel: 246,
      gpMin: 700,
      gpMax: 3000),
];

// ─── Boss Definitions ────────────────────────────────────────────

const bossDefs = <MonsterDef>[
  // Mid-game bosses
  MonsterDef(
      id: 'barrows',
      name: 'Barrows Brothers',
      icon: '⚰️',
      hitpoints: 600,
      attack: 100,
      strength: 100,
      defence: 100,
      maxHit: 24,
      combatLevel: 115,
      gpMin: 5000,
      gpMax: 20000,
      isBoss: true),
  MonsterDef(
      id: 'king_black_dragon',
      name: 'King Black Dragon',
      icon: '🐉',
      hitpoints: 255,
      attack: 240,
      strength: 240,
      defence: 240,
      maxHit: 25,
      combatLevel: 276,
      gpMin: 3000,
      gpMax: 15000,
      isBoss: true),
  MonsterDef(
      id: 'dagannoth_rex',
      name: 'Dagannoth Rex',
      icon: '🦎',
      hitpoints: 255,
      attack: 255,
      strength: 255,
      defence: 255,
      maxHit: 26,
      combatLevel: 303,
      gpMin: 3000,
      gpMax: 12000,
      isBoss: true),
  MonsterDef(
      id: 'dagannoth_supreme',
      name: 'Dagannoth Supreme',
      icon: '🦈',
      hitpoints: 255,
      attack: 255,
      strength: 255,
      defence: 128,
      maxHit: 21,
      combatLevel: 303,
      gpMin: 3000,
      gpMax: 12000,
      isBoss: true),
  MonsterDef(
      id: 'dagannoth_prime',
      name: 'Dagannoth Prime',
      icon: '🌊',
      hitpoints: 255,
      attack: 255,
      strength: 255,
      defence: 128,
      maxHit: 50,
      combatLevel: 303,
      gpMin: 3000,
      gpMax: 12000,
      isBoss: true),
  MonsterDef(
      id: 'kalphite_queen',
      name: 'Kalphite Queen',
      icon: '🪲',
      hitpoints: 510,
      attack: 220,
      strength: 220,
      defence: 200,
      maxHit: 31,
      combatLevel: 333,
      gpMin: 5000,
      gpMax: 25000,
      isBoss: true),

  // God Wars Dungeon
  MonsterDef(
      id: 'kreearra',
      name: 'Kree\'arra',
      icon: '🦅',
      hitpoints: 255,
      attack: 210,
      strength: 210,
      defence: 260,
      maxHit: 71,
      combatLevel: 580,
      gpMin: 10000,
      gpMax: 50000,
      isBoss: true),
  MonsterDef(
      id: 'commander_zilyana',
      name: 'Commander Zilyana',
      icon: '⚡',
      hitpoints: 255,
      attack: 250,
      strength: 250,
      defence: 250,
      maxHit: 31,
      combatLevel: 596,
      gpMin: 10000,
      gpMax: 50000,
      isBoss: true),
  MonsterDef(
      id: 'general_graardor',
      name: 'General Graardor',
      icon: '💪',
      hitpoints: 255,
      attack: 280,
      strength: 350,
      defence: 250,
      maxHit: 60,
      combatLevel: 624,
      gpMin: 10000,
      gpMax: 50000,
      isBoss: true),
  MonsterDef(
      id: 'kril_tsutsaroth',
      name: 'K\'ril Tsutsaroth',
      icon: '😈',
      hitpoints: 255,
      attack: 280,
      strength: 280,
      defence: 270,
      maxHit: 49,
      combatLevel: 650,
      gpMin: 10000,
      gpMax: 50000,
      isBoss: true),

  // Endgame
  MonsterDef(
      id: 'tztok_jad',
      name: 'TzTok-Jad',
      icon: '🌋',
      hitpoints: 250,
      attack: 480,
      strength: 480,
      defence: 480,
      maxHit: 97,
      combatLevel: 702,
      gpMin: 20000,
      gpMax: 80000,
      isBoss: true),
  MonsterDef(
      id: 'nex',
      name: 'Nex',
      icon: '�',
      hitpoints: 3400,
      attack: 260,
      strength: 260,
      defence: 260,
      maxHit: 60,
      combatLevel: 1001,
      gpMin: 50000,
      gpMax: 200000,
      isBoss: true),
];

// ─── Slayer-Only Monsters ────────────────────────────────────────

const slayerMonsterDefs = <MonsterDef>[
  MonsterDef(
      id: 'dust_devil',
      name: 'Dust Devil',
      icon: '🌪️',
      hitpoints: 105,
      attack: 60,
      strength: 60,
      defence: 30,
      maxHit: 8,
      combatLevel: 93,
      gpMin: 300,
      gpMax: 1200),
  MonsterDef(
      id: 'wyvern',
      name: 'Skeletal Wyvern',
      icon: '🦴',
      hitpoints: 140,
      attack: 65,
      strength: 72,
      defence: 80,
      maxHit: 12,
      combatLevel: 140,
      gpMin: 500,
      gpMax: 2000),
  MonsterDef(
      id: 'abyssal_demon',
      name: 'Abyssal Demon',
      icon: '👁️',
      hitpoints: 150,
      attack: 97,
      strength: 67,
      defence: 135,
      maxHit: 8,
      combatLevel: 124,
      gpMin: 600,
      gpMax: 2500),
  MonsterDef(
      id: 'cerberus',
      name: 'Cerberus',
      icon: '🐕',
      hitpoints: 600,
      attack: 220,
      strength: 220,
      defence: 100,
      maxHit: 23,
      combatLevel: 318,
      gpMin: 3000,
      gpMax: 12000,
      isBoss: true),
  MonsterDef(
      id: 'hydra',
      name: 'Alchemical Hydra',
      icon: '🐲',
      hitpoints: 1100,
      attack: 250,
      strength: 250,
      defence: 150,
      maxHit: 28,
      combatLevel: 426,
      gpMin: 5000,
      gpMax: 25000,
      isBoss: true),
];

/// Combined selectable list: regular monsters, then slayer monsters, then bosses.
List<MonsterDef> get selectableDefs =>
    [...monsterDefs, ...slayerMonsterDefs, ...bossDefs];

/// Index where slayer monsters begin in [selectableDefs].
int get slayerStartIndex => monsterDefs.length;

/// Index where bosses begin in [selectableDefs].
int get bossStartIndex => monsterDefs.length + slayerMonsterDefs.length;

/// Find a monster's index in [selectableDefs] by its id. Returns -1 if not found.
int indexOfMonster(String id) {
  final all = selectableDefs;
  for (int i = 0; i < all.length; i++) {
    if (all[i].id == id) return i;
  }
  return -1;
}

/// Get a monster from the combined selectable list by index.
MonsterDef getMonster(int index) {
  final all = selectableDefs;
  return all[index.clamp(0, all.length - 1)];
}

/// All monsters combined (normal + slayer + bosses).
List<MonsterDef> get allMonsterDefs =>
    [...monsterDefs, ...slayerMonsterDefs, ...bossDefs];

/// Find a MonsterDef by id across all lists.
MonsterDef? getMonsterDefById(String id) {
  for (final m in allMonsterDefs) {
    if (m.id == id) return m;
  }
  return null;
}

// ─── Raid Definitions ────────────────────────────────────────────

const coxBossDefs = <MonsterDef>[
  MonsterDef(
    id: 'cox_tekton',
    name: 'Tekton',
    icon: '🔨',
    hitpoints: 300,
    attack: 206,
    strength: 206,
    defence: 174,
    maxHit: 43,
    combatLevel: 732,
    isBoss: true,
  ),
  MonsterDef(
    id: 'cox_vasa',
    name: 'Vasa Nistirio',
    icon: '💎',
    hitpoints: 400,
    attack: 206,
    strength: 206,
    defence: 100,
    maxHit: 30,
    combatLevel: 854,
    isBoss: true,
  ),
  MonsterDef(
    id: 'cox_muttadiles',
    name: 'Muttadiles',
    icon: '🐊',
    hitpoints: 400,
    attack: 100,
    strength: 100,
    defence: 50,
    maxHit: 30,
    combatLevel: 450,
    isBoss: true,
  ),
  MonsterDef(
    id: 'cox_vanguards',
    name: 'Vanguards',
    icon: '⚔️',
    hitpoints: 450,
    attack: 150,
    strength: 150,
    defence: 60,
    maxHit: 25,
    combatLevel: 500,
    isBoss: true,
  ),
  MonsterDef(
    id: 'cox_great_olm',
    name: 'Great Olm',
    icon: '🐉',
    hitpoints: 800,
    attack: 250,
    strength: 250,
    defence: 175,
    maxHit: 26,
    combatLevel: 1043,
    isBoss: true,
  ),
];

const coxRaidDef = RaidDef(
  id: 'chambers_of_xeric',
  name: 'Chambers of Xeric',
  icon: '⚔️',
  bosses: coxBossDefs,
  uniqueDropChance: 0.03, // ~3% solo (≈25K pts / 8,676 per 1%)
  uniqueDropTable: [
    RaidDropEntry(itemId: 'dexterous_prayer_scroll'),
    RaidDropEntry(itemId: 'arcane_prayer_scroll'),
    RaidDropEntry(itemId: 'twisted_buckler'),
    RaidDropEntry(itemId: 'dragon_hunter_crossbow'),
    RaidDropEntry(itemId: 'dinhs_bulwark'),
    RaidDropEntry(itemId: 'ancestral_hat'),
    RaidDropEntry(itemId: 'ancestral_robe_top'),
    RaidDropEntry(itemId: 'ancestral_robe_bottom'),
    RaidDropEntry(itemId: 'dragon_claws'),
    RaidDropEntry(itemId: 'elder_maul'),
    RaidDropEntry(itemId: 'kodai_insignia'),
    RaidDropEntry(itemId: 'twisted_bow'),
  ],
);

/// All available raids.
const allRaidDefs = <RaidDef>[coxRaidDef];

/// Find a raid by id.
RaidDef? getRaidDefById(String id) {
  for (final r in allRaidDefs) {
    if (r.id == id) return r;
  }
  return null;
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
      restoreAmount: 7,
      cost: 300),
  PrayerPotion(
      id: 'super_restore',
      name: 'Super Restore',
      icon: '💎',
      restoreAmount: 8,
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
int prayerXpPerKill(int monsterHp) {
  if (monsterHp <= 5) return 5; // regular bones
  if (monsterHp <= 35) return 15; // big bones
  if (monsterHp <= 100) return 50; // dragon bones tier
  if (monsterHp <= 300) return 72; // superior dragon bones
  return 125; // boss-tier bones
}

// ─── Special Attack ───────────────────────────────────────────────

const int specCooldownTicks = 8; // ~10 seconds at 1.2s per tick
const double specDamageMultiplier = 2.5;

// ─── Slayer ─────────────────────────────────────────────────────

/// Slayer level required to fight each slayer-only monster.
const slayerRequirements = <String, int>{
  'dust_devil': 55,
  'wyvern': 72,
  'abyssal_demon': 85,
  'cerberus': 91,
  'hydra': 95,
};

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
  final mDef = getMonsterDefById(pick.$1);
  final int baseBonusGp =
      mDef != null ? (mDef.hitpoints * amount) ~/ 2 : amount * 50;
  final int baseBonusXp =
      mDef != null ? (mDef.hitpoints * amount) ~/ 3 : amount * 30;

  return SlayerTask(
    monsterId: pick.$1,
    amountTotal: amount,
    bonusGp: baseBonusGp,
    bonusSlayerXp: baseBonusXp,
  );
}
