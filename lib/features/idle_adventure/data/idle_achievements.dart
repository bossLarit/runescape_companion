import '../domain/idle_models.dart';

// ─── Achievement Definitions ────────────────────────────────────

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool Function(IdleGameState) check;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.check,
  });
}

final achievements = <Achievement>[
  // ── Combat Milestones ──────────────────────────────────────
  Achievement(
    id: 'first_blood',
    name: 'First Blood',
    description: 'Kill your first monster',
    icon: '🗡️',
    check: (s) => s.totalKills >= 1,
  ),
  Achievement(
    id: 'century',
    name: 'Century',
    description: 'Kill 100 monsters',
    icon: '💯',
    check: (s) => s.totalKills >= 100,
  ),
  Achievement(
    id: 'slaughter',
    name: 'Slaughter',
    description: 'Kill 1,000 monsters',
    icon: '☠️',
    check: (s) => s.totalKills >= 1000,
  ),
  Achievement(
    id: 'massacre',
    name: 'Massacre',
    description: 'Kill 10,000 monsters',
    icon: '💀',
    check: (s) => s.totalKills >= 10000,
  ),

  // ── Specific Monster Kills ─────────────────────────────────
  Achievement(
    id: 'giant_slayer',
    name: 'Giant Slayer',
    description: 'Defeat a Hill Giant',
    icon: '🗿',
    check: (s) => (s.monsterKillCounts['hill_giant'] ?? 0) >= 1,
  ),
  Achievement(
    id: 'demon_hunter',
    name: 'Demon Hunter',
    description: 'Defeat a Greater Demon',
    icon: '👿',
    check: (s) => (s.monsterKillCounts['greater_demon'] ?? 0) >= 1,
  ),
  Achievement(
    id: 'dragon_slayer',
    name: 'Dragon Slayer',
    description: 'Defeat a Black Dragon',
    icon: '🐉',
    check: (s) => (s.monsterKillCounts['black_dragon'] ?? 0) >= 1,
  ),
  Achievement(
    id: 'fire_cape',
    name: 'Fire Cape',
    description: 'Defeat TzTok-Jad',
    icon: '🔥',
    check: (s) => (s.monsterKillCounts['tztok_jad'] ?? 0) >= 1,
  ),

  // ── Skill Milestones ───────────────────────────────────────
  Achievement(
    id: 'attack_50',
    name: 'Warrior',
    description: 'Reach 50 Attack',
    icon: '⚔️',
    check: (s) => s.stats.attackLevel >= 50,
  ),
  Achievement(
    id: 'strength_50',
    name: 'Brute',
    description: 'Reach 50 Strength',
    icon: '💪',
    check: (s) => s.stats.strengthLevel >= 50,
  ),
  Achievement(
    id: 'defence_50',
    name: 'Tank',
    description: 'Reach 50 Defence',
    icon: '🛡️',
    check: (s) => s.stats.defenceLevel >= 50,
  ),
  Achievement(
    id: 'maxed_melee',
    name: 'Maxed Melee',
    description: 'Reach 99 in all melee stats',
    icon: '👑',
    check: (s) =>
        s.stats.attackLevel >= 99 &&
        s.stats.strengthLevel >= 99 &&
        s.stats.defenceLevel >= 99 &&
        s.stats.hitpointsLevel >= 99,
  ),

  // ── Slayer ─────────────────────────────────────────────────
  Achievement(
    id: 'slayer_apprentice',
    name: 'Slayer Apprentice',
    description: 'Complete your first slayer task',
    icon: '🗡️',
    check: (s) => s.slayerTasksCompleted >= 1,
  ),
  Achievement(
    id: 'slayer_expert',
    name: 'Slayer Expert',
    description: 'Complete 10 slayer tasks',
    icon: '🏅',
    check: (s) => s.slayerTasksCompleted >= 10,
  ),
  Achievement(
    id: 'slayer_master',
    name: 'Slayer Master',
    description: 'Reach 50 Slayer',
    icon: '🎖️',
    check: (s) => s.slayerLevel >= 50,
  ),

  // ── Prayer ─────────────────────────────────────────────────
  Achievement(
    id: 'faithful',
    name: 'Faithful',
    description: 'Reach 43 Prayer (Protect from Melee)',
    icon: '🙏',
    check: (s) => s.prayerLevel >= 43,
  ),
  Achievement(
    id: 'pious',
    name: 'Pious',
    description: 'Reach 70 Prayer (Piety)',
    icon: '✨',
    check: (s) => s.prayerLevel >= 70,
  ),

  // ── Gear ───────────────────────────────────────────────────
  Achievement(
    id: 'first_equip',
    name: 'Geared Up',
    description: 'Equip your first item',
    icon: '🔵',
    check: (s) => s.equipment.isNotEmpty,
  ),
  Achievement(
    id: 'full_gear',
    name: 'Fully Equipped',
    description: 'Fill all 11 equipment slots',
    icon: '🔴',
    check: (s) => s.equipment.length >= 11,
  ),
  Achievement(
    id: 'bandos_armour',
    name: 'Bandos Armour',
    description: 'Equip a Bandos piece',
    icon: '🟤',
    check: (s) => s.equipment.values.any((id) => id.startsWith('bandos')),
  ),

  // ── Economy ────────────────────────────────────────────────
  Achievement(
    id: 'rich',
    name: 'Getting Rich',
    description: 'Have 10,000 GP at once',
    icon: '💰',
    check: (s) => s.gp >= 10000,
  ),
  Achievement(
    id: 'wealthy',
    name: 'Wealthy',
    description: 'Have 100,000 GP at once',
    icon: '💎',
    check: (s) => s.gp >= 100000,
  ),
  Achievement(
    id: 'millionaire',
    name: 'Millionaire',
    description: 'Have 1,000,000 GP at once',
    icon: '🏆',
    check: (s) => s.gp >= 1000000,
  ),

  // ── Prestige ───────────────────────────────────────────────
  Achievement(
    id: 'prestige_1',
    name: 'Prestige I',
    description: 'Complete your first prestige',
    icon: '🌟',
    check: (s) => s.prestigeLevel >= 1,
  ),
  Achievement(
    id: 'prestige_5',
    name: 'Prestige V',
    description: 'Complete 5 prestiges',
    icon: '⭐',
    check: (s) => s.prestigeLevel >= 5,
  ),

  // ── Collection ─────────────────────────────────────────────
  Achievement(
    id: 'gear_collector',
    name: 'Gear Collector',
    description: 'Receive 10 gear drops',
    icon: '🎁',
    check: (s) => s.totalGearDrops >= 10,
  ),
  Achievement(
    id: 'bestiary',
    name: 'Bestiary',
    description: 'Kill every type of monster at least once',
    icon: '📖',
    check: (s) => s.monsterKillCounts.length >= 15, // 10 normal + 5 slayer
  ),

  // ── Deaths ──────────────────────────────────────────────────
  Achievement(
    id: 'first_death',
    name: 'Welcome to Lumbridge',
    description: 'Die for the first time',
    icon: '💀',
    check: (s) => s.deathCount >= 1,
  ),
  Achievement(
    id: 'deaths_10',
    name: 'Frequent Visitor',
    description: 'Die 10 times',
    icon: '☠️',
    check: (s) => s.deathCount >= 10,
  ),
  Achievement(
    id: 'deaths_100',
    name: 'Lumbridge Regular',
    description: 'Die 100 times',
    icon: '🪦',
    check: (s) => s.deathCount >= 100,
  ),

  // ── Skilling Milestones ─────────────────────────────────────
  Achievement(
    id: 'first_log',
    name: 'Lumberjack',
    description: 'Reach 10 Woodcutting',
    icon: '🪵',
    check: (s) => s.skillingStats.woodcuttingLevel >= 10,
  ),
  Achievement(
    id: 'first_ore',
    name: 'Prospector',
    description: 'Reach 10 Mining',
    icon: '⛏️',
    check: (s) => s.skillingStats.miningLevel >= 10,
  ),
  Achievement(
    id: 'first_fish',
    name: 'Angler',
    description: 'Reach 10 Fishing',
    icon: '🎣',
    check: (s) => s.skillingStats.fishingLevel >= 10,
  ),
  Achievement(
    id: 'first_cook',
    name: 'Chef',
    description: 'Reach 10 Cooking',
    icon: '🍳',
    check: (s) => s.skillingStats.cookingLevel >= 10,
  ),
  Achievement(
    id: 'first_smith',
    name: 'Blacksmith',
    description: 'Reach 10 Smithing',
    icon: '🔨',
    check: (s) => s.skillingStats.smithingLevel >= 10,
  ),
  Achievement(
    id: 'first_craft',
    name: 'Artisan',
    description: 'Reach 10 Crafting',
    icon: '🧵',
    check: (s) => s.skillingStats.craftingLevel >= 10,
  ),
  Achievement(
    id: 'skilling_50',
    name: 'Skilled',
    description: 'Reach 50 in any skilling skill',
    icon: '🌟',
    check: (s) =>
        s.skillingStats.woodcuttingLevel >= 50 ||
        s.skillingStats.miningLevel >= 50 ||
        s.skillingStats.fishingLevel >= 50 ||
        s.skillingStats.cookingLevel >= 50 ||
        s.skillingStats.smithingLevel >= 50 ||
        s.skillingStats.craftingLevel >= 50,
  ),
  Achievement(
    id: 'skilling_99',
    name: 'Master Skiller',
    description: 'Reach 99 in any skilling skill',
    icon: '🏆',
    check: (s) =>
        s.skillingStats.woodcuttingLevel >= 99 ||
        s.skillingStats.miningLevel >= 99 ||
        s.skillingStats.fishingLevel >= 99 ||
        s.skillingStats.cookingLevel >= 99 ||
        s.skillingStats.smithingLevel >= 99 ||
        s.skillingStats.craftingLevel >= 99,
  ),
];

/// Returns the list of completed achievements for the current state.
List<Achievement> completedAchievements(IdleGameState state) {
  return achievements.where((a) => a.check(state)).toList();
}

/// Returns the list of locked achievements for the current state.
List<Achievement> lockedAchievements(IdleGameState state) {
  return achievements.where((a) => !a.check(state)).toList();
}
