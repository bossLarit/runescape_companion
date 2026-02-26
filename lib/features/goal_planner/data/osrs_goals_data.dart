// Curated OSRS milestone goals with skill requirements.
// Used by the suggestion engine to recommend goals based on player stats.

enum GoalCategory {
  essentialUnlock,
  quest,
  achievementDiary,
  combat,
  skilling,
  pvm,
  moneyMaking,
  gearProgression,
}

const _categoryLabels = {
  GoalCategory.essentialUnlock: 'Essential Unlocks',
  GoalCategory.quest: 'Important Quests',
  GoalCategory.achievementDiary: 'Achievement Diaries',
  GoalCategory.combat: 'Combat Milestones',
  GoalCategory.skilling: 'Skilling Milestones',
  GoalCategory.pvm: 'PvM Goals',
  GoalCategory.moneyMaking: 'Money Making',
  GoalCategory.gearProgression: 'Gear Progression',
};

String categoryLabel(GoalCategory c) => _categoryLabels[c] ?? c.name;

const _categoryIcons = {
  GoalCategory.essentialUnlock: 0xe3b0, // lock_open
  GoalCategory.quest: 0xe24e, // auto_stories
  GoalCategory.achievementDiary: 0xe613, // workspace_premium
  GoalCategory.combat: 0xf05b6, // swords (gavel)
  GoalCategory.skilling: 0xe5d5, // trending_up
  GoalCategory.pvm: 0xe88a, // whatshot
  GoalCategory.moneyMaking: 0xf04b6, // paid
  GoalCategory.gearProgression: 0xe8b8, // shield
};

int categoryIconCode(GoalCategory c) => _categoryIcons[c] ?? 0xe88a;

class OsrsGoal {
  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final String subcategory;
  final Map<String, int> skillRequirements; // skill name -> level
  final int priority; // 1-5, 5 = most important
  final String rewards;
  final String wikiPath;

  const OsrsGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory = '',
    this.skillRequirements = const {},
    this.priority = 3,
    this.rewards = '',
    this.wikiPath = '',
  });

  String get wikiUrl =>
      wikiPath.isNotEmpty ? 'https://oldschool.runescape.wiki/w/$wikiPath' : '';

  int get totalLevelRequired =>
      skillRequirements.values.fold(0, (sum, v) => sum + v);
}

/// All curated OSRS milestone goals.
const List<OsrsGoal> osrsGoals = [
  // ═══════════════════════════════════════════════════════
  //  ESSENTIAL UNLOCKS
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'unlock_fairy_rings',
    title: 'Fairy Rings',
    description:
        'Complete A Fairy Tale Part II (started) to unlock fairy ring teleportation network.',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Herblore': 57, 'Farming': 49, 'Thieving': 40},
    priority: 5,
    rewards: 'Fairy ring teleportation across Gielinor',
    wikiPath: 'Fairy_ring',
  ),
  OsrsGoal(
    id: 'unlock_spirit_trees',
    title: 'Spirit Trees',
    description:
        'Complete Tree Gnome Village to unlock spirit tree teleportation.',
    category: GoalCategory.essentialUnlock,
    priority: 4,
    rewards: 'Spirit tree teleport network',
    wikiPath: 'Spirit_tree',
  ),
  OsrsGoal(
    id: 'unlock_ancient_magicks',
    title: 'Ancient Magicks',
    description:
        'Complete Desert Treasure I to unlock the Ancient spellbook (Ice Barrage, etc.).',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {
      'Magic': 50,
      'Firemaking': 50,
      'Slayer': 10,
      'Thieving': 53
    },
    priority: 5,
    rewards: 'Ancient spellbook — Ice Barrage, Blood spells, etc.',
    wikiPath: 'Desert_Treasure_I',
  ),
  OsrsGoal(
    id: 'unlock_lunars',
    title: 'Lunar Spellbook',
    description:
        'Complete Lunar Diplomacy to unlock the Lunar spellbook (Vengeance, NPC Contact, etc.).',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {
      'Magic': 65,
      'Mining': 60,
      'Crafting': 61,
      'Woodcutting': 55,
      'Firemaking': 49,
      'Defence': 40,
      'Herblore': 5
    },
    priority: 4,
    rewards: 'Lunar spellbook — Vengeance, NPC Contact, Plank Make',
    wikiPath: 'Lunar_Diplomacy',
  ),
  OsrsGoal(
    id: 'unlock_piety',
    title: 'Piety Prayer',
    description:
        "Complete King's Ransom and Knight Waves Training Grounds to unlock Piety (+25% Atk/Str/Def).",
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Defence': 70, 'Prayer': 70, 'Magic': 45},
    priority: 5,
    rewards: 'Piety prayer — +25% Attack, Strength, Defence',
    wikiPath: 'Piety',
  ),
  OsrsGoal(
    id: 'unlock_rigour',
    title: 'Rigour Prayer',
    description:
        'Use a Dexterous Prayer Scroll to unlock Rigour (+20% Ranged Atk, +23% Ranged Str).',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Defence': 70, 'Prayer': 74},
    priority: 5,
    rewards: 'Rigour prayer — Best ranged prayer',
    wikiPath: 'Rigour',
  ),
  OsrsGoal(
    id: 'unlock_augury',
    title: 'Augury Prayer',
    description:
        'Use an Arcane Prayer Scroll to unlock Augury (+25% Magic Atk, +25% Magic Def).',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Defence': 70, 'Prayer': 77},
    priority: 4,
    rewards: 'Augury prayer — Best magic prayer',
    wikiPath: 'Augury',
  ),
  OsrsGoal(
    id: 'unlock_tears_of_guthix',
    title: 'Tears of Guthix',
    description:
        'Complete Tears of Guthix quest for weekly free XP in your lowest skill.',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Firemaking': 49, 'Crafting': 20, 'Mining': 20},
    priority: 5,
    rewards: 'Weekly free XP in lowest skill',
    wikiPath: 'Tears_of_Guthix',
  ),
  OsrsGoal(
    id: 'unlock_kingdom',
    title: 'Managing Miscellania',
    description:
        'Complete Throne of Miscellania for passive resource income from kingdom management.',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {
      'Woodcutting': 45,
      'Farming': 45,
      'Mining': 30,
      'Smithing': 35,
      'Fishing': 35,
      'Cooking': 31,
      'Firemaking': 40
    },
    priority: 4,
    rewards: 'Passive daily resources from kingdom',
    wikiPath: 'Managing_Miscellania',
  ),
  OsrsGoal(
    id: 'unlock_graceful',
    title: 'Full Graceful Outfit',
    description:
        'Obtain the full Graceful outfit from Marks of Grace for weight reduction and run energy restoration.',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Agility': 60},
    priority: 5,
    rewards: 'Weight reduction, faster run energy restoration',
    wikiPath: 'Graceful_outfit',
  ),

  // ═══════════════════════════════════════════════════════
  //  IMPORTANT QUESTS
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'quest_rfd',
    title: 'Recipe for Disaster',
    description:
        'Complete all RFD subquests to unlock Barrows Gloves — the best melee gloves in the game.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Cooking': 70,
      'Agility': 48,
      'Mining': 52,
      'Fishing': 53,
      'Thieving': 53,
      'Herblore': 25,
      'Magic': 59,
      'Smithing': 40,
      'Firemaking': 50,
      'Ranged': 40,
      'Crafting': 40,
      'Fletching': 10,
      'Woodcutting': 36,
      'Quest Points': 175
    },
    priority: 5,
    rewards: 'Barrows Gloves — best melee gloves',
    wikiPath: 'Recipe_for_Disaster',
  ),
  OsrsGoal(
    id: 'quest_ds2',
    title: 'Dragon Slayer II',
    description:
        'Complete DS2 to unlock Vorkath, one of the best money makers in the game.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Quest Points': 200,
      'Magic': 75,
      'Smithing': 70,
      'Mining': 68,
      'Crafting': 62,
      'Agility': 60,
      'Thieving': 60,
      'Construction': 50,
      'Hitpoints': 50
    },
    priority: 5,
    rewards: 'Vorkath access, Ava\'s Assembler, Dragon crossbow',
    wikiPath: 'Dragon_Slayer_II',
  ),
  OsrsGoal(
    id: 'quest_sote',
    title: 'Song of the Elves',
    description:
        'Complete SotE to unlock Prifddinas — the elf city with many high-level activities.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Agility': 70,
      'Construction': 70,
      'Farming': 70,
      'Herblore': 70,
      'Hunter': 70,
      'Mining': 70,
      'Smithing': 70,
      'Woodcutting': 70
    },
    priority: 4,
    rewards: 'Prifddinas, Gauntlet, Crystal equipment',
    wikiPath: 'Song_of_the_Elves',
  ),
  OsrsGoal(
    id: 'quest_mm2',
    title: 'Monkey Madness II',
    description:
        'Complete MM2 to unlock Demonic Gorillas and the Zenyte jewellery crafting.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Slayer': 69,
      'Crafting': 70,
      'Hunter': 60,
      'Agility': 55,
      'Thieving': 55,
      'Firemaking': 60
    },
    priority: 4,
    rewards: 'Demonic Gorillas, Zenyte jewellery',
    wikiPath: 'Monkey_Madness_II',
  ),
  OsrsGoal(
    id: 'quest_sins_of_father',
    title: 'Sins of the Father',
    description:
        'Complete SotF to unlock Darkmeyer and the Hallowed Sepulchre.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Woodcutting': 62,
      'Fletching': 60,
      'Crafting': 56,
      'Agility': 52,
      'Attack': 50,
      'Slayer': 50,
      'Magic': 49
    },
    priority: 4,
    rewards: 'Darkmeyer, Hallowed Sepulchre, Blood Shard',
    wikiPath: 'Sins_of_the_Father',
  ),
  OsrsGoal(
    id: 'quest_beneath_cursed_sands',
    title: 'Beneath Cursed Sands',
    description: 'Complete BCS to unlock the Tombs of Amascut (ToA) raid.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Agility': 62,
      'Crafting': 55,
      'Firemaking': 55,
      'Mining': 55
    },
    priority: 4,
    rewards: 'Tombs of Amascut raid access',
    wikiPath: 'Beneath_Cursed_Sands',
  ),
  OsrsGoal(
    id: 'quest_regicide',
    title: 'Regicide',
    description: 'Complete Regicide to unlock Tirannwn and Zulrah access.',
    category: GoalCategory.quest,
    skillRequirements: {'Agility': 56, 'Crafting': 10},
    priority: 4,
    rewards: 'Tirannwn access, path to Zulrah',
    wikiPath: 'Regicide',
  ),
  OsrsGoal(
    id: 'quest_bone_voyage',
    title: 'Bone Voyage',
    description:
        'Complete Bone Voyage to unlock Fossil Island — Birdhouse runs, Ammonite Crabs, Volcanic Mine.',
    category: GoalCategory.quest,
    skillRequirements: {},
    priority: 4,
    rewards: 'Fossil Island — Birdhouses, Ammonite Crabs, Volcanic Mine',
    wikiPath: 'Bone_Voyage',
  ),
  OsrsGoal(
    id: 'quest_quest_cape',
    title: 'Quest Cape',
    description: 'Complete all quests in OSRS to earn the Quest Point Cape.',
    category: GoalCategory.quest,
    priority: 3,
    rewards: 'Quest Cape — unlimited teleport to Legends\' Guild',
    wikiPath: 'Quest_point_cape',
  ),

  // ═══════════════════════════════════════════════════════
  //  ACHIEVEMENT DIARIES
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'diary_ardy_easy',
    title: 'Ardougne Diary (Easy)',
    description: 'Complete the easy Ardougne Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Ardougne',
    priority: 3,
    rewards: 'Ardougne Cloak 1 — unlimited teleport to Ardougne Monastery',
    wikiPath: 'Ardougne_Diary',
  ),
  OsrsGoal(
    id: 'diary_ardy_medium',
    title: 'Ardougne Diary (Medium)',
    description: 'Complete the medium Ardougne Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Ardougne',
    skillRequirements: {
      'Agility': 39,
      'Cooking': 53,
      'Farming': 46,
      'Firemaking': 50,
      'Fletching': 5,
      'Hunter': 31,
      'Magic': 51,
      'Strength': 38,
      'Thieving': 38,
      'Crafting': 49
    },
    priority: 3,
    rewards: 'Ardougne Cloak 2 — 3 teleports/day to Ardougne farming patch',
    wikiPath: 'Ardougne_Diary',
  ),
  OsrsGoal(
    id: 'diary_ardy_hard',
    title: 'Ardougne Diary (Hard)',
    description: 'Complete the hard Ardougne Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Ardougne',
    skillRequirements: {
      'Agility': 56,
      'Construction': 50,
      'Cooking': 53,
      'Farming': 70,
      'Firemaking': 50,
      'Fletching': 5,
      'Hunter': 59,
      'Magic': 66,
      'Prayer': 42,
      'Ranged': 60,
      'Smithing': 68,
      'Strength': 50,
      'Thieving': 72,
      'Woodcutting': 50,
      'Crafting': 50
    },
    priority: 4,
    rewards: 'Ardougne Cloak 3 — unlimited Ardougne farming patch teleport',
    wikiPath: 'Ardougne_Diary',
  ),
  OsrsGoal(
    id: 'diary_varrock_easy',
    title: 'Varrock Diary (Easy)',
    description: 'Complete the easy Varrock Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Varrock',
    priority: 3,
    rewards: 'Varrock Armour 1 — chance of smelting 2 bars at once up to steel',
    wikiPath: 'Varrock_Diary',
  ),
  OsrsGoal(
    id: 'diary_varrock_medium',
    title: 'Varrock Diary (Medium)',
    description: 'Complete the medium Varrock Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Varrock',
    skillRequirements: {
      'Agility': 30,
      'Crafting': 36,
      'Farming': 30,
      'Firemaking': 40,
      'Hunter': 50,
      'Magic': 25,
      'Thieving': 25
    },
    priority: 3,
    rewards: 'Varrock Armour 2, 15 daily battlestaffs from Zaff',
    wikiPath: 'Varrock_Diary',
  ),
  OsrsGoal(
    id: 'diary_varrock_hard',
    title: 'Varrock Diary (Hard)',
    description:
        'Complete the hard Varrock Achievement Diary for 30 daily battlestaffs.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Varrock',
    skillRequirements: {
      'Agility': 51,
      'Construction': 50,
      'Crafting': 36,
      'Farming': 68,
      'Firemaking': 60,
      'Herblore': 52,
      'Hunter': 66,
      'Magic': 54,
      'Prayer': 52,
      'Thieving': 53,
      'Woodcutting': 60
    },
    priority: 4,
    rewards: 'Varrock Armour 3, 30 daily battlestaffs (~200k/day)',
    wikiPath: 'Varrock_Diary',
  ),
  OsrsGoal(
    id: 'diary_lumbridge_easy',
    title: 'Lumbridge Diary (Easy)',
    description: 'Complete the easy Lumbridge & Draynor Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Lumbridge',
    priority: 3,
    rewards: 'Explorer\'s Ring 1 — 30 charges of Low Alchemy/day',
    wikiPath: 'Lumbridge_%26_Draynor_Diary',
  ),
  OsrsGoal(
    id: 'diary_lumbridge_hard',
    title: 'Lumbridge Diary (Hard)',
    description: 'Complete the hard Lumbridge & Draynor Achievement Diary.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Lumbridge',
    skillRequirements: {
      'Agility': 46,
      'Crafting': 70,
      'Farming': 63,
      'Firemaking': 65,
      'Magic': 60,
      'Mining': 63,
      'Prayer': 52,
      'Runecraft': 59,
      'Smithing': 68,
      'Strength': 50,
      'Thieving': 50,
      'Woodcutting': 57
    },
    priority: 3,
    rewards:
        'Explorer\'s Ring 3 — unlimited run energy replenish (50%), Fairy ring access without staff',
    wikiPath: 'Lumbridge_%26_Draynor_Diary',
  ),
  OsrsGoal(
    id: 'diary_morytania_hard',
    title: 'Morytania Diary (Hard)',
    description:
        'Complete the hard Morytania Achievement Diary for double Barrows loot and bonecrusher.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Morytania',
    skillRequirements: {
      'Agility': 71,
      'Construction': 50,
      'Defence': 70,
      'Farming': 53,
      'Firemaking': 50,
      'Herblore': 22,
      'Magic': 66,
      'Mining': 55,
      'Prayer': 70,
      'Slayer': 58,
      'Smithing': 50,
      'Thieving': 42,
      'Woodcutting': 50
    },
    priority: 4,
    rewards: 'Morytania Legs 3 — 50% more Barrows runes, bonecrusher necklace',
    wikiPath: 'Morytania_Diary',
  ),
  OsrsGoal(
    id: 'diary_western_hard',
    title: 'Western Provinces Diary (Hard)',
    description:
        'Complete the hard Western Provinces diary for Crystal Halberd access.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Western Provinces',
    skillRequirements: {
      'Agility': 56,
      'Construction': 65,
      'Cooking': 70,
      'Farming': 68,
      'Firemaking': 50,
      'Fishing': 62,
      'Fletching': 5,
      'Hunter': 69,
      'Magic': 64,
      'Mining': 70,
      'Ranged': 70,
      'Thieving': 75,
      'Woodcutting': 50
    },
    priority: 3,
    rewards: 'Crystal Halberd, extra Zulrah loot',
    wikiPath: 'Western_Provinces_Diary',
  ),
  OsrsGoal(
    id: 'diary_kandarin_hard',
    title: 'Kandarin Diary (Hard)',
    description:
        'Complete the hard Kandarin diary for 10% bolt proc chance increase.',
    category: GoalCategory.achievementDiary,
    subcategory: 'Kandarin',
    skillRequirements: {
      'Agility': 60,
      'Crafting': 65,
      'Farming': 79,
      'Firemaking': 65,
      'Fishing': 76,
      'Fletching': 70,
      'Herblore': 72,
      'Magic': 56,
      'Mining': 60,
      'Prayer': 70,
      'Smithing': 75,
      'Strength': 50,
      'Thieving': 53
    },
    priority: 4,
    rewards: '10% increased bolt enchantment proc chance — huge for PvM',
    wikiPath: 'Kandarin_Diary',
  ),

  // ═══════════════════════════════════════════════════════
  //  COMBAT MILESTONES
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'combat_fire_cape',
    title: 'Fire Cape',
    description:
        'Defeat TzTok-Jad in the TzHaar Fight Caves to earn the Fire Cape.',
    category: GoalCategory.combat,
    skillRequirements: {'Ranged': 70, 'Prayer': 43, 'Hitpoints': 70},
    priority: 5,
    rewards: 'Fire Cape — +4 Strength, best cape until Infernal',
    wikiPath: 'Fire_cape',
  ),
  OsrsGoal(
    id: 'combat_infernal_cape',
    title: 'Infernal Cape',
    description:
        'Defeat TzKal-Zuk in the Inferno to earn the Infernal Cape — the best melee cape.',
    category: GoalCategory.combat,
    skillRequirements: {
      'Ranged': 90,
      'Prayer': 77,
      'Hitpoints': 90,
      'Defence': 90,
      'Magic': 75
    },
    priority: 3,
    rewards: 'Infernal Cape — +8 Strength, best melee cape',
    wikiPath: 'Infernal_cape',
  ),
  OsrsGoal(
    id: 'combat_fighter_torso',
    title: 'Fighter Torso',
    description:
        'Earn the Fighter Torso from Barbarian Assault for a free +4 Strength bonus body.',
    category: GoalCategory.combat,
    skillRequirements: {},
    priority: 4,
    rewards: 'Fighter Torso — +4 Strength body slot (free BCP alternative)',
    wikiPath: 'Fighter_torso',
  ),
  OsrsGoal(
    id: 'combat_dragon_defender',
    title: 'Dragon Defender',
    description:
        'Obtain the Dragon Defender from the Warriors\' Guild basement.',
    category: GoalCategory.combat,
    skillRequirements: {'Attack': 60, 'Strength': 60},
    priority: 5,
    rewards: 'Dragon Defender — best offensive shield slot for melee',
    wikiPath: 'Dragon_defender',
  ),
  OsrsGoal(
    id: 'combat_avas_assembler',
    title: "Ava's Assembler",
    description:
        'Upgrade Ava\'s Accumulator after Dragon Slayer II to get the best ranged cape.',
    category: GoalCategory.combat,
    skillRequirements: {'Ranged': 70},
    priority: 4,
    rewards: 'Ava\'s Assembler — best ranged cape, +2 ranged str',
    wikiPath: "Ava%27s_assembler",
  ),
  OsrsGoal(
    id: 'combat_imbued_slayer_helm',
    title: 'Imbued Slayer Helm',
    description:
        'Imbue your Slayer Helmet at Soul Wars or NMZ for 15% ranged/magic boost on task.',
    category: GoalCategory.combat,
    skillRequirements: {'Slayer': 55, 'Crafting': 55},
    priority: 5,
    rewards: 'Slayer Helm (i) — 15% boost to all styles on task',
    wikiPath: 'Slayer_helmet_(i)',
  ),
  OsrsGoal(
    id: 'combat_imbued_berserker',
    title: 'Imbued Berserker Ring',
    description: 'Imbue the Berserker Ring for +8 melee Strength bonus.',
    category: GoalCategory.combat,
    skillRequirements: {},
    priority: 4,
    rewards: 'Berserker Ring (i) — +8 melee Strength',
    wikiPath: 'Berserker_ring_(i)',
  ),

  // ═══════════════════════════════════════════════════════
  //  SKILLING MILESTONES
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'skill_base_50',
    title: 'Base 50 Stats',
    description: 'Get all skills to at least level 50.',
    category: GoalCategory.skilling,
    skillRequirements: {
      'Attack': 50,
      'Strength': 50,
      'Defence': 50,
      'Ranged': 50,
      'Prayer': 50,
      'Magic': 50,
      'Hitpoints': 50,
      'Cooking': 50,
      'Woodcutting': 50,
      'Fletching': 50,
      'Fishing': 50,
      'Firemaking': 50,
      'Crafting': 50,
      'Smithing': 50,
      'Mining': 50,
      'Herblore': 50,
      'Agility': 50,
      'Thieving': 50,
      'Slayer': 50,
      'Farming': 50,
      'Runecraft': 50,
      'Hunter': 50,
      'Construction': 50
    },
    priority: 3,
    rewards: 'Solid account foundation, unlocks many quests/diaries',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'skill_base_70',
    title: 'Base 70 Stats',
    description: 'Get all skills to at least level 70 — unlocks most content.',
    category: GoalCategory.skilling,
    skillRequirements: {
      'Attack': 70,
      'Strength': 70,
      'Defence': 70,
      'Ranged': 70,
      'Prayer': 70,
      'Magic': 70,
      'Hitpoints': 70,
      'Cooking': 70,
      'Woodcutting': 70,
      'Fletching': 70,
      'Fishing': 70,
      'Firemaking': 70,
      'Crafting': 70,
      'Smithing': 70,
      'Mining': 70,
      'Herblore': 70,
      'Agility': 70,
      'Thieving': 70,
      'Slayer': 70,
      'Farming': 70,
      'Runecraft': 70,
      'Hunter': 70,
      'Construction': 70
    },
    priority: 3,
    rewards: 'Access to nearly all content in the game',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'skill_total_1500',
    title: '1500 Total Level',
    description: 'Reach 1500 total level for 1500-total worlds.',
    category: GoalCategory.skilling,
    priority: 3,
    rewards: '1500-total worlds (less crowded)',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'skill_total_2000',
    title: '2000 Total Level',
    description: 'Reach 2000 total level for 2000-total worlds.',
    category: GoalCategory.skilling,
    priority: 3,
    rewards: '2000-total worlds, maxed main territory',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'skill_99_slayer',
    title: '99 Slayer',
    description:
        'Achieve 99 Slayer — the ultimate combat grind, massive GP along the way.',
    category: GoalCategory.skilling,
    skillRequirements: {'Slayer': 99},
    priority: 3,
    rewards: 'Slayer Cape, huge GP from drops along the way',
    wikiPath: 'Slayer',
  ),
  OsrsGoal(
    id: 'skill_87_slayer',
    title: '87 Slayer',
    description:
        'Reach 87 Slayer to unlock Kraken — a profitable and afk boss task.',
    category: GoalCategory.skilling,
    skillRequirements: {'Slayer': 87},
    priority: 4,
    rewards: 'Kraken boss — Trident, Kraken tentacle',
    wikiPath: 'Kraken',
  ),
  OsrsGoal(
    id: 'skill_77_prayer',
    title: '77 Prayer',
    description: 'Reach 77 Prayer to unlock Rigour — the best ranged prayer.',
    category: GoalCategory.skilling,
    skillRequirements: {'Prayer': 77},
    priority: 4,
    rewards: 'Unlocks Augury (+ Rigour at 74)',
    wikiPath: 'Prayer',
  ),
  OsrsGoal(
    id: 'skill_85_herblore',
    title: '85 Herblore',
    description:
        'Reach 85 Herblore to make Super Combat potions (boostable to 90 with a spicy stew).',
    category: GoalCategory.skilling,
    skillRequirements: {'Herblore': 85},
    priority: 4,
    rewards: 'Super Combat potions — essential for PvM',
    wikiPath: 'Super_combat_potion',
  ),
  OsrsGoal(
    id: 'skill_83_construction',
    title: '83 Construction',
    description:
        'Reach 83 Construction (boostable) to build Ornate Jewellery Box and Rejuvenation Pool.',
    category: GoalCategory.skilling,
    skillRequirements: {'Construction': 83},
    priority: 4,
    rewards:
        'Ornate jewellery box, Rejuvenation pool — essential POH teleports and stat restore',
    wikiPath: 'Construction',
  ),

  // ═══════════════════════════════════════════════════════
  //  SKILLING BOSSES
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'skilling_boss_wintertodt',
    title: 'Wintertodt',
    description:
        'Fight the Wintertodt skilling boss for Firemaking XP, supply crates, and the Tome of Fire. Best done at low HP for less food usage.',
    category: GoalCategory.skilling,
    subcategory: 'Skilling Bosses',
    skillRequirements: {'Firemaking': 50},
    priority: 5,
    rewards: 'Pyromancer outfit, Tome of Fire, Phoenix pet, supply crates',
    wikiPath: 'Wintertodt',
  ),
  OsrsGoal(
    id: 'skilling_boss_tempoross',
    title: 'Tempoross',
    description:
        'Battle the Tempoross skilling boss for Fishing XP, reward permits, and unique drops. Semi-AFK group activity.',
    category: GoalCategory.skilling,
    subcategory: 'Skilling Bosses',
    skillRequirements: {'Fishing': 35},
    priority: 4,
    rewards:
        'Angler outfit, Fish barrel, Tackle box, Spirit flakes, Tiny Tempor pet',
    wikiPath: 'Tempoross',
  ),
  OsrsGoal(
    id: 'skilling_boss_zalcano',
    title: 'Zalcano',
    description:
        'Defeat the Zalcano skilling boss beneath Prifddinas using Mining, Smithing, and Runecraft. Requires Song of the Elves. Good GP and chance at Crystal tool seed.',
    category: GoalCategory.skilling,
    subcategory: 'Skilling Bosses',
    skillRequirements: {
      'Mining': 70,
      'Smithing': 70,
      'Agility': 70,
      'Construction': 70,
      'Farming': 70,
      'Herblore': 70,
      'Hunter': 70,
      'Woodcutting': 70,
    },
    priority: 3,
    rewards: 'Crystal tool seed, Smolcano pet, ore/bar drops, good GP',
    wikiPath: 'Zalcano',
  ),
  OsrsGoal(
    id: 'skilling_boss_gotr',
    title: 'Guardians of the Rift',
    description:
        'Play the Guardians of the Rift minigame for Runecraft XP and Raiments of the Eye outfit. Good XP rates and useful rewards.',
    category: GoalCategory.skilling,
    subcategory: 'Skilling Bosses',
    skillRequirements: {'Runecraft': 27},
    priority: 4,
    rewards:
        'Raiments of the Eye (10% more runes), Abyssal Needle, Rift Guardian pet',
    wikiPath: 'Guardians_of_the_Rift',
  ),

  // ═══════════════════════════════════════════════════════
  //  PVM GOALS
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'pvm_barrows',
    title: 'Barrows Brothers',
    description:
        'Complete Barrows runs for Barrows equipment — great early-mid PvM.',
    category: GoalCategory.pvm,
    skillRequirements: {'Magic': 50, 'Prayer': 43},
    priority: 4,
    rewards: 'Barrows equipment, decent GP',
    wikiPath: 'Barrows',
  ),
  OsrsGoal(
    id: 'pvm_zulrah',
    title: 'Zulrah',
    description:
        'Learn and farm Zulrah for Blowpipe, Magic fang, and consistent GP.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Ranged': 80,
      'Magic': 80,
      'Prayer': 45,
      'Hitpoints': 75
    },
    priority: 4,
    rewards: 'Toxic Blowpipe, Serpentine Helm, Magic Fang, ~2M gp/hr',
    wikiPath: 'Zulrah',
  ),
  OsrsGoal(
    id: 'pvm_vorkath',
    title: 'Vorkath',
    description: 'Farm Vorkath after DS2 for consistent 3M+/hr GP.',
    category: GoalCategory.pvm,
    skillRequirements: {'Ranged': 85, 'Prayer': 70, 'Hitpoints': 80},
    priority: 4,
    rewards: '~3M gp/hr, Dragonbone Necklace, Skeletal Visage',
    wikiPath: 'Vorkath',
  ),
  OsrsGoal(
    id: 'pvm_gauntlet',
    title: 'Corrupted Gauntlet',
    description:
        'Complete the Corrupted Gauntlet for Enhanced Crystal Weapon Seed — requires no gear.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Ranged': 80,
      'Magic': 80,
      'Prayer': 77,
      'Hitpoints': 80
    },
    priority: 4,
    rewards:
        'Enhanced Crystal Weapon Seed (~100M), Blade of Saeldor, Bow of Faerdhinen',
    wikiPath: 'Corrupted_Gauntlet',
  ),
  OsrsGoal(
    id: 'pvm_cox',
    title: 'Chambers of Xeric (CoX)',
    description: 'Complete Chambers of Xeric raids for endgame gear drops.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Ranged': 85,
      'Magic': 80,
      'Prayer': 77,
      'Hitpoints': 85,
      'Herblore': 78
    },
    priority: 3,
    rewards: 'Twisted Bow, Dragon Claws, Ancestral robes, etc.',
    wikiPath: 'Chambers_of_Xeric',
  ),
  OsrsGoal(
    id: 'pvm_tob',
    title: 'Theatre of Blood (ToB)',
    description:
        'Complete Theatre of Blood raids — one of the hardest PvM challenges.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Attack': 90,
      'Strength': 90,
      'Defence': 90,
      'Ranged': 90,
      'Magic': 90,
      'Prayer': 77,
      'Hitpoints': 90
    },
    priority: 3,
    rewards:
        'Scythe of Vitur, Sanguinesti Staff, Ghrazi Rapier, Avernic Defender',
    wikiPath: 'Theatre_of_Blood',
  ),
  OsrsGoal(
    id: 'pvm_toa',
    title: 'Tombs of Amascut (ToA)',
    description:
        'Complete Tombs of Amascut — scalable difficulty raid with great rewards.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Ranged': 80,
      'Magic': 80,
      'Prayer': 70,
      'Hitpoints': 80
    },
    priority: 4,
    rewards: "Tumeken's Shadow, Masori armour, Osmumten's Fang",
    wikiPath: 'Tombs_of_Amascut',
  ),

  // ═══════════════════════════════════════════════════════
  //  MONEY MAKING
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'money_birdhouses',
    title: 'Birdhouse Runs',
    description:
        'Unlock birdhouse runs on Fossil Island for passive Hunter XP and bird nests.',
    category: GoalCategory.moneyMaking,
    skillRequirements: {'Hunter': 9, 'Crafting': 5},
    priority: 4,
    rewards: 'Passive Hunter XP + bird nests (~100k per run)',
    wikiPath: 'Bird_house_trapping',
  ),
  OsrsGoal(
    id: 'money_herb_runs',
    title: 'Herb Farming Runs',
    description:
        'Start doing regular herb runs for consistent passive GP (Ranarr/Snapdragon).',
    category: GoalCategory.moneyMaking,
    skillRequirements: {'Farming': 32},
    priority: 5,
    rewards: '~100-200k per herb run, 5-10 min each',
    wikiPath: 'Farming',
  ),
  OsrsGoal(
    id: 'money_blast_furnace',
    title: 'Blast Furnace',
    description:
        'Use the Blast Furnace for profitable Smithing training (Rune bars).',
    category: GoalCategory.moneyMaking,
    skillRequirements: {'Smithing': 85},
    priority: 3,
    rewards: '~800k-1M gp/hr smelting Rune bars',
    wikiPath: 'Blast_Furnace',
  ),
  OsrsGoal(
    id: 'money_slayer_boss',
    title: 'Slayer Bossing',
    description:
        'Unlock slayer bosses at high Slayer levels for consistent GP.',
    category: GoalCategory.moneyMaking,
    skillRequirements: {'Slayer': 75},
    priority: 4,
    rewards: 'Gargoyle Boss, Kraken, Cerberus, Hydra — millions GP/hr',
    wikiPath: 'Slayer',
  ),
  OsrsGoal(
    id: 'money_95_slayer',
    title: '95 Slayer — Alchemical Hydra',
    description:
        'Reach 95 Slayer to kill the Alchemical Hydra — one of the best solo money makers.',
    category: GoalCategory.moneyMaking,
    skillRequirements: {'Slayer': 95, 'Ranged': 85},
    priority: 4,
    rewards: 'Alchemical Hydra — ~3-4M gp/hr, Hydra Claw, Hydra Leather',
    wikiPath: 'Alchemical_Hydra',
  ),

  // ═══════════════════════════════════════════════════════
  //  QUEST TIER MILESTONES (from Optimal Quest Guide)
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'quest_tier_novice',
    title: 'All Novice Quests',
    description:
        'Complete all Novice-difficulty quests. A great early milestone for new accounts.',
    category: GoalCategory.quest,
    subcategory: 'Quest Tiers',
    skillRequirements: {
      'Mining': 20,
      'Smithing': 20,
      'Crafting': 10,
      'Woodcutting': 20,
      'Farming': 15,
      'Hunter': 27,
      'Slayer': 22,
      'Cooking': 10,
      'Firemaking': 15,
      'Construction': 10,
    },
    priority: 4,
    rewards: 'Foundation quests done — unlocks many intermediate quests',
    wikiPath: 'Optimal_quest_guide',
  ),
  OsrsGoal(
    id: 'quest_tier_intermediate',
    title: 'All Intermediate Quests',
    description: 'Complete all Intermediate-difficulty quests.',
    category: GoalCategory.quest,
    subcategory: 'Quest Tiers',
    skillRequirements: {
      'Attack': 20,
      'Strength': 16,
      'Mining': 40,
      'Agility': 35,
      'Smithing': 35,
      'Herblore': 31,
      'Crafting': 10,
      'Ranged': 40,
      'Thieving': 42,
      'Firemaking': 36,
      'Prayer': 31,
      'Woodcutting': 49,
      'Fletching': 10,
      'Magic': 46,
      'Farming': 50,
      'Runecraft': 35,
      'Slayer': 30,
      'Cooking': 30,
      'Construction': 38,
      'Hunter': 46,
      'Fishing': 12,
    },
    priority: 3,
    rewards: 'Solid quest progress, many area and content unlocks',
    wikiPath: 'Optimal_quest_guide',
  ),
  OsrsGoal(
    id: 'quest_tier_experienced',
    title: 'All Experienced Quests',
    description: 'Complete all Experienced-difficulty quests.',
    category: GoalCategory.quest,
    subcategory: 'Quest Tiers',
    skillRequirements: {
      'Attack': 40,
      'Strength': 60,
      'Defence': 65,
      'Ranged': 47,
      'Prayer': 50,
      'Magic': 65,
      'Mining': 60,
      'Agility': 56,
      'Herblore': 57,
      'Thieving': 56,
      'Woodcutting': 61,
      'Fletching': 50,
      'Smithing': 65,
      'Crafting': 53,
      'Firemaking': 53,
      'Farming': 55,
      'Runecraft': 50,
      'Slayer': 56,
      'Cooking': 49,
      'Construction': 48,
      'Hunter': 52,
      'Fishing': 45,
    },
    priority: 3,
    rewards: 'Access to most mid-game content and areas',
    wikiPath: 'Optimal_quest_guide',
  ),
  OsrsGoal(
    id: 'quest_tier_master',
    title: 'All Master Quests',
    description: 'Complete all Master-difficulty quests. Major milestone.',
    category: GoalCategory.quest,
    subcategory: 'Quest Tiers',
    skillRequirements: {
      'Attack': 50,
      'Strength': 58,
      'Ranged': 62,
      'Prayer': 42,
      'Magic': 66,
      'Mining': 72,
      'Agility': 69,
      'Herblore': 52,
      'Thieving': 66,
      'Woodcutting': 65,
      'Fletching': 60,
      'Smithing': 60,
      'Crafting': 62,
      'Firemaking': 62,
      'Farming': 71,
      'Runecraft': 55,
      'Slayer': 60,
      'Construction': 35,
      'Hunter': 56,
      'Cooking': 66,
    },
    priority: 3,
    rewards: 'Near quest cape — access to high-level content',
    wikiPath: 'Optimal_quest_guide',
  ),
  OsrsGoal(
    id: 'quest_tier_grandmaster',
    title: 'All Grandmaster Quests',
    description:
        'Complete all Grandmaster-difficulty quests — the hardest in the game.',
    category: GoalCategory.quest,
    subcategory: 'Quest Tiers',
    skillRequirements: {
      'Hitpoints': 50,
      'Mining': 70,
      'Agility': 70,
      'Smithing': 70,
      'Herblore': 70,
      'Thieving': 72,
      'Woodcutting': 70,
      'Fletching': 75,
      'Magic': 75,
      'Farming': 70,
      'Runecraft': 60,
      'Slayer': 69,
      'Cooking': 70,
      'Construction': 70,
      'Hunter': 70,
    },
    priority: 4,
    rewards: 'All quests complete — Quest Cape unlocked',
    wikiPath: 'Optimal_quest_guide',
  ),

  // ═══════════════════════════════════════════════════════
  //  ACHIEVEMENT DIARY TIER MILESTONES (aggregate requirements)
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'diary_all_easy',
    title: 'All Easy Achievement Diaries',
    description:
        'Complete all Easy tier Achievement Diaries across every region.',
    category: GoalCategory.achievementDiary,
    subcategory: 'All Diaries',
    skillRequirements: {
      'Mining': 40,
      'Agility': 20,
      'Smithing': 20,
      'Crafting': 12,
      'Thieving': 25,
      'Woodcutting': 15,
      'Fletching': 15,
      'Magic': 21,
      'Construction': 9,
      'Slayer': 15,
      'Cooking': 20,
      'Hunter': 11,
      'Firemaking': 15,
      'Fishing': 23,
      'Runecraft': 5,
      'Farming': 15,
      'Strength': 10,
      'Prayer': 25,
    },
    priority: 4,
    rewards:
        'All Easy diary rewards — Ardougne Cloak 1, Explorer\'s Ring 1, etc.',
    wikiPath: 'Achievement_Diary',
  ),
  OsrsGoal(
    id: 'diary_all_medium',
    title: 'All Medium Achievement Diaries',
    description:
        'Complete all Medium tier Achievement Diaries across every region.',
    category: GoalCategory.achievementDiary,
    subcategory: 'All Diaries',
    skillRequirements: {
      'Attack': 38,
      'Strength': 52,
      'Defence': 30,
      'Ranged': 50,
      'Prayer': 42,
      'Magic': 56,
      'Hitpoints': 22,
      'Mining': 55,
      'Agility': 48,
      'Herblore': 48,
      'Thieving': 47,
      'Crafting': 49,
      'Fletching': 50,
      'Slayer': 50,
      'Hunter': 50,
      'Woodcutting': 50,
      'Firemaking': 50,
      'Farming': 46,
      'Cooking': 53,
      'Fishing': 46,
      'Smithing': 50,
      'Runecraft': 44,
      'Construction': 50,
    },
    priority: 4,
    rewards:
        'All Medium diary rewards — 15 battlestaffs, better teleports, etc.',
    wikiPath: 'Achievement_Diary',
  ),
  OsrsGoal(
    id: 'diary_all_hard',
    title: 'All Hard Achievement Diaries',
    description:
        'Complete all Hard tier Achievement Diaries across every region. Huge account upgrade.',
    category: GoalCategory.achievementDiary,
    subcategory: 'All Diaries',
    skillRequirements: {
      'Attack': 70,
      'Strength': 76,
      'Defence': 70,
      'Ranged': 70,
      'Prayer': 70,
      'Magic': 75,
      'Hitpoints': 70,
      'Mining': 70,
      'Agility': 71,
      'Herblore': 72,
      'Thieving': 75,
      'Crafting': 70,
      'Fletching': 70,
      'Slayer': 72,
      'Hunter': 69,
      'Woodcutting': 71,
      'Firemaking': 68,
      'Farming': 79,
      'Cooking': 70,
      'Fishing': 76,
      'Smithing': 75,
      'Runecraft': 65,
      'Construction': 65,
    },
    priority: 5,
    rewards:
        'All Hard diary rewards — 30 battlestaffs, double Barrows runes, Kandarin hard bolt proc, etc.',
    wikiPath: 'Achievement_Diary',
  ),
  OsrsGoal(
    id: 'diary_all_elite',
    title: 'All Elite Achievement Diaries',
    description:
        'Complete all Elite tier Achievement Diaries. One of the hardest non-max goals in OSRS.',
    category: GoalCategory.achievementDiary,
    subcategory: 'All Diaries',
    skillRequirements: {
      'Attack': 85,
      'Strength': 85,
      'Defence': 85,
      'Ranged': 85,
      'Prayer': 85,
      'Magic': 91,
      'Hitpoints': 85,
      'Mining': 85,
      'Agility': 85,
      'Herblore': 90,
      'Thieving': 91,
      'Crafting': 85,
      'Fletching': 81,
      'Slayer': 93,
      'Hunter': 82,
      'Woodcutting': 90,
      'Firemaking': 85,
      'Farming': 91,
      'Cooking': 95,
      'Fishing': 91,
      'Smithing': 91,
      'Runecraft': 86,
      'Construction': 84,
    },
    priority: 3,
    rewards:
        'All Elite diary rewards — unlimited teleports, best diary gear, Elite Void effect',
    wikiPath: 'Achievement_Diary',
  ),

  // ═══════════════════════════════════════════════════════
  //  ADDITIONAL SKILLING & ENDGAME
  // ═══════════════════════════════════════════════════════
  OsrsGoal(
    id: 'skill_max_cape',
    title: 'Max Cape',
    description:
        'Achieve level 99 in all skills — the ultimate skilling achievement.',
    category: GoalCategory.skilling,
    skillRequirements: {
      'Attack': 99,
      'Strength': 99,
      'Defence': 99,
      'Ranged': 99,
      'Prayer': 99,
      'Magic': 99,
      'Hitpoints': 99,
      'Mining': 99,
      'Agility': 99,
      'Herblore': 99,
      'Thieving': 99,
      'Crafting': 99,
      'Fletching': 99,
      'Slayer': 99,
      'Hunter': 99,
      'Woodcutting': 99,
      'Firemaking': 99,
      'Farming': 99,
      'Cooking': 99,
      'Fishing': 99,
      'Smithing': 99,
      'Runecraft': 99,
      'Construction': 99,
    },
    priority: 2,
    rewards:
        'Max Cape — best in slot for many situations, all skill cape perks',
    wikiPath: 'Max_cape',
  ),
  OsrsGoal(
    id: 'skill_total_1750',
    title: '1750 Total Level',
    description: 'Reach 1750 total level for 1750-total worlds.',
    category: GoalCategory.skilling,
    priority: 3,
    rewards: '1750-total worlds — less competition at popular resources',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'skill_total_2200',
    title: '2200 Total Level',
    description:
        'Reach 2200 total level for 2200-total worlds — the most exclusive.',
    category: GoalCategory.skilling,
    priority: 2,
    rewards: '2200-total worlds — nearly empty resources',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'skill_99_farming',
    title: '99 Farming',
    description:
        'Achieve 99 Farming — one of the easiest 99s via tree/herb runs.',
    category: GoalCategory.skilling,
    skillRequirements: {'Farming': 99},
    priority: 2,
    rewards: 'Farming Cape — unlimited teleport to Farming Guild',
    wikiPath: 'Farming',
  ),
  OsrsGoal(
    id: 'combat_75_all',
    title: '75 All Combat Stats',
    description:
        'Get 75 Attack, Strength, Defence, Ranged, Magic — unlocks Godswords, Blowpipe, Trident.',
    category: GoalCategory.combat,
    skillRequirements: {
      'Attack': 75,
      'Strength': 75,
      'Defence': 75,
      'Ranged': 75,
      'Magic': 75
    },
    priority: 4,
    rewards: 'Godswords, Toxic Blowpipe, Trident of the Seas, etc.',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'combat_90_all',
    title: '90+ All Combat Stats',
    description:
        'Get 90+ Attack, Strength, Defence, Ranged, Magic, Hitpoints — raid-ready.',
    category: GoalCategory.combat,
    skillRequirements: {
      'Attack': 90,
      'Strength': 90,
      'Defence': 90,
      'Ranged': 90,
      'Magic': 90,
      'Hitpoints': 90
    },
    priority: 3,
    rewards: 'Efficient raids, access to all PvM content',
    wikiPath: '',
  ),
  OsrsGoal(
    id: 'pvm_grotesque_guardians',
    title: 'Grotesque Guardians',
    description:
        'Kill the Grotesque Guardians slayer boss (75 Slayer, Gargoyle task).',
    category: GoalCategory.pvm,
    skillRequirements: {'Slayer': 75},
    priority: 3,
    rewards: 'Granite Maul, Black Tourmaline Core — decent GP',
    wikiPath: 'Grotesque_Guardians',
  ),
  OsrsGoal(
    id: 'pvm_cerberus',
    title: 'Cerberus',
    description:
        'Kill Cerberus for Primordial/Pegasian/Eternal crystals (91 Slayer).',
    category: GoalCategory.pvm,
    skillRequirements: {'Slayer': 91},
    priority: 3,
    rewards: 'Primordial/Pegasian/Eternal Boots — best boots in game',
    wikiPath: 'Cerberus',
  ),
  OsrsGoal(
    id: 'pvm_nightmare',
    title: 'The Nightmare / Phosani',
    description:
        'Defeat The Nightmare or Phosani\'s Nightmare for endgame gear.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Attack': 85,
      'Strength': 85,
      'Hitpoints': 85,
      'Defence': 80
    },
    priority: 2,
    rewards:
        'Inquisitor\'s Armour, Nightmare Staff, Harmonised/Eldritch/Volatile Orbs',
    wikiPath: 'The_Nightmare',
  ),
  OsrsGoal(
    id: 'pvm_nex',
    title: 'Nex',
    description: 'Defeat Nex in a team for Torva armour and Zaryte crossbow.',
    category: GoalCategory.pvm,
    skillRequirements: {
      'Ranged': 90,
      'Hitpoints': 90,
      'Defence': 85,
      'Prayer': 70
    },
    priority: 3,
    rewards: 'Torva Armour, Zaryte Crossbow — best melee armour',
    wikiPath: 'Nex',
  ),
  OsrsGoal(
    id: 'unlock_poh_max',
    title: 'Maxed POH (Player-Owned House)',
    description:
        'Build the key POH rooms: Ornate Pool, Ornate Jewellery Box, Occult Altar, Fairy Ring + Spirit Tree.',
    category: GoalCategory.essentialUnlock,
    skillRequirements: {'Construction': 83},
    priority: 5,
    rewards:
        'Full stat restore, all teleports, spellbook swap — the ultimate hub',
    wikiPath: 'Player-owned_house',
  ),
  OsrsGoal(
    id: 'unlock_mm1_dscim',
    title: 'Dragon Scimitar (Monkey Madness I)',
    description:
        'Complete Monkey Madness I to wield the Dragon Scimitar — best F2P-to-early-member weapon upgrade.',
    category: GoalCategory.quest,
    skillRequirements: {'Attack': 60},
    priority: 5,
    rewards: 'Dragon Scimitar — best melee training weapon until Whip',
    wikiPath: 'Monkey_Madness_I',
  ),
  OsrsGoal(
    id: 'unlock_whip',
    title: 'Abyssal Whip (70 Attack)',
    description:
        'Reach 70 Attack to wield the Abyssal Whip — a massive upgrade.',
    category: GoalCategory.combat,
    skillRequirements: {'Attack': 70},
    priority: 5,
    rewards: 'Abyssal Whip — +82 slash, +82 strength, iconic weapon',
    wikiPath: 'Abyssal_whip',
  ),
  OsrsGoal(
    id: 'unlock_trident',
    title: 'Trident of the Seas (75 Magic)',
    description:
        'Reach 75 Magic to use the Trident of the Seas — essential for PvM.',
    category: GoalCategory.combat,
    skillRequirements: {'Magic': 75},
    priority: 4,
    rewards:
        'Trident of the Seas — built-in spell, essential for Zulrah/Barrows',
    wikiPath: 'Trident_of_the_seas',
  ),
  OsrsGoal(
    id: 'quest_priest_in_peril',
    title: 'Priest in Peril',
    description:
        'Complete Priest in Peril to unlock Morytania — essential area for Slayer, Barrows, etc.',
    category: GoalCategory.quest,
    skillRequirements: {},
    priority: 5,
    rewards: 'Morytania access — Barrows, Slayer Tower, Canifis',
    wikiPath: 'Priest_in_Peril',
  ),
  OsrsGoal(
    id: 'quest_animal_magnetism',
    title: "Animal Magnetism (Ava's Device)",
    description:
        "Complete Animal Magnetism to get Ava's Accumulator — auto-retrieves ammo.",
    category: GoalCategory.quest,
    skillRequirements: {
      'Slayer': 18,
      'Crafting': 19,
      'Ranged': 30,
      'Woodcutting': 35
    },
    priority: 5,
    rewards: "Ava's Accumulator — auto-picks up ammo, essential for Ranged",
    wikiPath: 'Animal_Magnetism',
  ),
  OsrsGoal(
    id: 'quest_lost_city',
    title: 'Lost City (Dragon Weapons)',
    description:
        'Complete Lost City to access Zanaris and wield Dragon longsword/dagger.',
    category: GoalCategory.quest,
    skillRequirements: {'Crafting': 31, 'Woodcutting': 36},
    priority: 4,
    rewards: 'Zanaris access, Dragon longsword/dagger',
    wikiPath: 'Lost_City',
  ),
  OsrsGoal(
    id: 'quest_dt2',
    title: 'Desert Treasure II',
    description:
        'Complete DT2 to access the four new bosses — Duke Sucellus, The Leviathan, The Whisperer, Vardorvis.',
    category: GoalCategory.quest,
    skillRequirements: {
      'Firemaking': 75,
      'Magic': 75,
      'Thieving': 62,
      'Herblore': 62,
      'Runecraft': 60,
      'Construction': 60,
    },
    priority: 3,
    rewards:
        'Four new bosses — Virtus, Masori (i), Voidwaker, Bellator Ring, etc.',
    wikiPath: 'Desert_Treasure_II_-_The_Fallen_Empire',
  ),

  // ═══════════════════════════════════════════════════════
  //  GEAR PROGRESSION (Ironman — from Yazi's 2025 Guide)
  // ═══════════════════════════════════════════════════════

  // ── 1. EARLY GAME ──────────────────────────────────────
  OsrsGoal(
    id: 'gear_early_diaries',
    title: 'Easy Diaries (Ardougne, Kourend, Lumbridge)',
    description:
        'Complete easy Achievement Diaries for Rada\'s blessing 1, Ardougne cloak 1, and Explorer\'s ring 1.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    priority: 4,
    rewards: 'Rada\'s blessing 1, Ardougne cloak 1, Explorer\'s ring 1',
    wikiPath: 'Achievement_Diary',
  ),
  OsrsGoal(
    id: 'gear_early_dragon_slayer1_start',
    title: 'Start Dragon Slayer I',
    description:
        'Start Dragon Slayer I to obtain the Anti-dragon shield — needed for all dragon fights.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Attack': 1},
    priority: 4,
    rewards: 'Anti-dragon shield',
    wikiPath: 'Dragon_Slayer_I',
  ),
  OsrsGoal(
    id: 'gear_early_feud',
    title: 'Complete The Feud',
    description:
        'Complete The Feud to buy an Adamant scimitar from Ali Morrisane.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Thieving': 30},
    priority: 3,
    rewards: 'Adamant scimitar',
    wikiPath: 'The_Feud',
  ),
  OsrsGoal(
    id: 'gear_early_climbing_boots',
    title: 'Complete Death Plateau',
    description:
        'Complete Death Plateau to obtain Climbing boots — best early-game strength bonus boots.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    priority: 3,
    rewards: 'Climbing boots',
    wikiPath: 'Death_Plateau',
  ),
  OsrsGoal(
    id: 'gear_early_rune_armour',
    title: 'Complete Dragon Slayer I',
    description:
        'Complete Dragon Slayer I to wear Rune platebody and access full Rune armour set.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Attack': 40, 'Defence': 40},
    priority: 5,
    rewards: 'Rune platebody, Rune full helm, Rune platelegs, Rune kiteshield',
    wikiPath: 'Dragon_Slayer_I',
  ),
  OsrsGoal(
    id: 'gear_early_dragon_scim',
    title: 'Complete Monkey Madness I',
    description:
        'Complete Monkey Madness I to wield the Dragon scimitar — best melee weapon until Whip.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Attack': 60},
    priority: 5,
    rewards: 'Dragon scimitar',
    wikiPath: 'Monkey_Madness_I',
  ),
  OsrsGoal(
    id: 'gear_early_mystic',
    title: 'Access the Wizards\' Guild',
    description:
        'Buy Mystic robes from the Wizards\' Guild — requires 66 Magic.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Magic': 66},
    priority: 3,
    rewards:
        'Mystic robe top, Mystic robe bottom, Mystic hat, Mystic gloves, Mystic boots',
    wikiPath: 'Wizards%27_Guild',
  ),
  OsrsGoal(
    id: 'gear_early_dorgeshuun_cbow',
    title: 'Complete The Lost Tribe',
    description:
        'Complete The Lost Tribe to obtain Dorgeshuun crossbow + Bone bolts — best early Ranged weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Ranged': 28},
    priority: 3,
    rewards: 'Dorgeshuun crossbow, Bone bolts',
    wikiPath: 'The_Lost_Tribe',
  ),
  OsrsGoal(
    id: 'gear_early_avas',
    title: 'Complete Animal Magnetism',
    description:
        'Complete Animal Magnetism for Ava\'s accumulator — saves ammo on every Ranged attack.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {
      'Ranged': 30,
      'Slayer': 18,
      'Crafting': 19,
      'Woodcutting': 35
    },
    priority: 5,
    rewards: 'Ava\'s accumulator',
    wikiPath: 'Animal_Magnetism',
  ),
  OsrsGoal(
    id: 'gear_early_ibans',
    title: 'Complete Underground Pass',
    description:
        'Complete Underground Pass for Iban\'s staff (u) — best early Magic weapon for Barrows and Slayer.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Ranged': 25, 'Agility': 50},
    priority: 5,
    rewards: 'Iban\'s staff (u)',
    wikiPath: 'Underground_Pass_(quest)',
  ),
  OsrsGoal(
    id: 'gear_early_neitiznot',
    title: 'Complete The Fremennik Isles',
    description:
        'Complete The Fremennik Isles for Helm of neitiznot — BiS melee helm until Barrows/Serpentine.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Defence': 55, 'Woodcutting': 56, 'Construction': 20},
    priority: 5,
    rewards: 'Helm of neitiznot',
    wikiPath: 'The_Fremennik_Isles',
  ),
  OsrsGoal(
    id: 'gear_early_ddefender',
    title: 'Obtain Dragon Defender',
    description:
        'Kill Cyclopes in the Warriors\' Guild for a Dragon defender — BiS melee off-hand.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Attack': 60, 'Defence': 60},
    priority: 5,
    rewards: 'Dragon defender',
    wikiPath: 'Dragon_defender',
  ),
  OsrsGoal(
    id: 'gear_early_fighter_torso',
    title: 'Obtain Fighter Torso',
    description:
        'Complete Barbarian Assault for the Fighter torso — BiS melee body until Bandos/Blood Moon.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Defence': 40},
    priority: 5,
    rewards: 'Fighter torso',
    wikiPath: 'Fighter_torso',
  ),
  OsrsGoal(
    id: 'gear_early_god_cape',
    title: 'Complete Mage Arena I',
    description:
        'Complete Mage Arena I in the Wilderness for a God cape — BiS Magic cape until Imbued.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Magic': 60},
    priority: 4,
    rewards: 'God cape (Saradomin/Zamorak/Guthix)',
    wikiPath: 'Mage_Arena',
  ),
  OsrsGoal(
    id: 'gear_early_red_dhide',
    title: 'Red D\'hide + Rune Crossbow',
    description:
        'Craft or obtain Red d\'hide body/chaps and a Rune crossbow — pre-Barrows ranged setup.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Ranged': 60, 'Defence': 40},
    priority: 4,
    rewards: 'Red d\'hide body, Red d\'hide chaps, Rune crossbow',
  ),
  OsrsGoal(
    id: 'gear_early_fire_cape',
    title: 'Obtain Fire Cape',
    description:
        'Defeat TzTok-Jad in the TzHaar Fight Cave for the Fire cape — massive melee upgrade.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {'Ranged': 60, 'Prayer': 43, 'Hitpoints': 60},
    priority: 5,
    rewards: 'Fire cape',
    wikiPath: 'TzTok-Jad',
  ),
  OsrsGoal(
    id: 'gear_early_bgloves',
    title: 'Obtain Barrows Gloves',
    description:
        'Complete Recipe for Disaster for Barrows gloves — BiS gloves for all combat styles.',
    category: GoalCategory.gearProgression,
    subcategory: 'Early Game',
    skillRequirements: {
      'Cooking': 70,
      'Agility': 48,
      'Mining': 50,
      'Smithing': 40,
      'Herblore': 25,
      'Fishing': 53,
      'Thieving': 53,
      'Magic': 59,
      'Firemaking': 50,
      'Crafting': 40,
      'Fletching': 10,
      'Woodcutting': 36,
    },
    priority: 5,
    rewards: 'Barrows gloves — BiS all-round gloves',
    wikiPath: 'Recipe_for_Disaster',
  ),

  // ── 2. MID GAME ────────────────────────────────────────
  OsrsGoal(
    id: 'gear_mid_med_kourend',
    title: 'Medium Kourend Diary',
    description: 'Complete Medium Kourend Diary for Rada\'s blessing 2.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    priority: 3,
    rewards: 'Rada\'s blessing 2',
    wikiPath: 'Kourend_%26_Kebos_Diary',
  ),
  OsrsGoal(
    id: 'gear_mid_barrows',
    title: 'Grind Barrows Equipment',
    description:
        'Farm Barrows brothers for melee Barrows platebody + platelegs — big Defence upgrade.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Magic': 50, 'Defence': 70, 'Prayer': 43},
    priority: 4,
    rewards: 'Barrows platebody, Barrows platelegs (any melee set)',
    wikiPath: 'Barrows',
  ),
  OsrsGoal(
    id: 'gear_mid_mage_arena2',
    title: 'Complete Mage Arena II',
    description:
        'Complete Mage Arena II in the Wilderness for an Imbued God cape — BiS Magic cape.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Magic': 75},
    priority: 4,
    rewards: 'Imbued God cape',
    wikiPath: 'Mage_Arena_II',
  ),
  OsrsGoal(
    id: 'gear_mid_steel_ring',
    title: 'Obtain Steel Ring',
    description:
        'Kill the Deranged Archaeologist on Fossil Island for the Steel ring — all-combat ring.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Ranged': 50},
    priority: 3,
    rewards: 'Steel ring',
    wikiPath: 'Deranged_Archaeologist',
  ),
  OsrsGoal(
    id: 'gear_mid_moons_melee',
    title: 'Obtain Blood Moon Armour + Dual Macuahuitl',
    description:
        'Kill Blood Moon at Moons of Peril for Blood Moon helm/chestplate/tassets and Dual macuahuitl.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {
      'Attack': 70,
      'Strength': 70,
      'Defence': 70,
      'Hitpoints': 70
    },
    priority: 5,
    rewards:
        'Blood moon helm, Blood moon chestplate, Blood moon tassets, Dual macuahuitl',
    wikiPath: 'Blood_Moon',
  ),
  OsrsGoal(
    id: 'gear_mid_moons_ranged',
    title: 'Obtain Eclipse Moon Armour + Eclipse Atlatl',
    description:
        'Kill Eclipse Moon at Moons of Peril for Eclipse armour and Eclipse atlatl + Sunlight crossbow.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Ranged': 70, 'Defence': 70, 'Hitpoints': 70},
    priority: 4,
    rewards:
        'Eclipse moon armour set, Eclipse atlatl, Hunters\' sunlight crossbow',
    wikiPath: 'Eclipse_Moon',
  ),
  OsrsGoal(
    id: 'gear_mid_moons_mage',
    title: 'Obtain Blue Moon Armour + Blue Moon Spear',
    description:
        'Kill Blue Moon at Moons of Peril for Blue Moon armour set and Blue Moon spear.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Magic': 70, 'Defence': 70, 'Hitpoints': 70},
    priority: 4,
    rewards: 'Blue moon armour set, Blue moon spear',
    wikiPath: 'Blue_Moon',
  ),
  OsrsGoal(
    id: 'gear_mid_glory',
    title: 'Craft Amulet of Glory',
    description:
        'Craft an Amulet of glory — good all-round combat amulet before Fury.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Crafting': 80},
    priority: 4,
    rewards: 'Amulet of glory',
    wikiPath: 'Amulet_of_glory',
  ),
  OsrsGoal(
    id: 'gear_mid_twinflame',
    title: 'Obtain Twinflame Staff + Mage\'s Book',
    description:
        'Kill Royal Titans for Twinflame staff and Mage\'s book — strong mage offhand.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Magic': 60},
    priority: 3,
    rewards: 'Twinflame staff, Mage\'s book',
    wikiPath: 'Royal_Titans',
  ),
  OsrsGoal(
    id: 'gear_mid_warped_sceptre',
    title: 'Complete Path of Glouphrie + Warped Sceptre',
    description:
        'Complete The Path of Glouphrie to access Warped terrorbirds — drop the Warped sceptre.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Magic': 50},
    priority: 3,
    rewards: 'Warped sceptre',
    wikiPath: 'The_Path_of_Glouphrie',
  ),
  OsrsGoal(
    id: 'gear_mid_zombie_axe',
    title: 'Obtain Zombie Axe',
    description:
        'Obtain the Zombie axe from undead activities — decent slash weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'Mid Game',
    skillRequirements: {'Attack': 65},
    priority: 2,
    rewards: 'Zombie axe',
    wikiPath: 'Zombie_axe',
  ),

  // ── 3. LATE GAME ───────────────────────────────────────
  OsrsGoal(
    id: 'gear_late_hard_kourend',
    title: 'Hard Kourend Diary',
    description: 'Complete Hard Kourend Diary for Rada\'s blessing 3.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    priority: 3,
    rewards: 'Rada\'s blessing 3',
    wikiPath: 'Kourend_%26_Kebos_Diary',
  ),
  OsrsGoal(
    id: 'gear_late_bowfa',
    title: 'Obtain Bow of Faerdhinen (c) + Crystal Armour',
    description:
        'Grind Corrupted Gauntlet for Bow of faerdhinen (c), Crystal helm/body/legs — BiS ranged set pre-Tbow.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {
      'Ranged': 80,
      'Defence': 70,
      'Agility': 70,
      'Construction': 70,
      'Herblore': 70,
      'Farming': 70,
      'Mining': 70,
      'Smithing': 70,
      'Woodcutting': 70,
      'Fishing': 70,
      'Cooking': 70,
      'Crafting': 70,
      'Hunter': 70
    },
    priority: 5,
    rewards: 'Bow of faerdhinen (c), Crystal helm, Crystal body, Crystal legs',
    wikiPath: 'Corrupted_Gauntlet',
  ),
  OsrsGoal(
    id: 'gear_late_fury',
    title: 'Craft Amulet of Fury',
    description:
        'Craft an Amulet of fury with an onyx — all-round BiS amulet before Zenyte.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Crafting': 90},
    priority: 4,
    rewards: 'Amulet of fury',
    wikiPath: 'Amulet_of_fury',
  ),
  OsrsGoal(
    id: 'gear_late_assembler',
    title: 'Obtain Ava\'s Assembler',
    description:
        'Kill Vorkath for Vorkath\'s head → Ava\'s assembler — BiS Ranged cape slot.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Ranged': 70},
    priority: 5,
    rewards: 'Ava\'s assembler',
    wikiPath: 'Ava%27s_assembler',
  ),
  OsrsGoal(
    id: 'gear_late_arclight',
    title: 'Obtain Arclight',
    description: 'Create Arclight from Darklight — BiS against demons.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Attack': 75},
    priority: 4,
    rewards: 'Arclight',
    wikiPath: 'Arclight',
  ),
  OsrsGoal(
    id: 'gear_late_tormented_demons',
    title: 'Grind Tormented Demons',
    description:
        'Kill Tormented Demons for Emberlight, Burning claws, Scorching bow, Purging staff.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Attack': 80, 'Ranged': 80, 'Magic': 80, 'Slayer': 80},
    priority: 4,
    rewards: 'Emberlight, Burning claws, Scorching bow, Purging staff',
    wikiPath: 'Tormented_Demon',
  ),
  OsrsGoal(
    id: 'gear_late_zenyte_melee',
    title: 'Craft Amulet of Torture',
    description:
        'Kill Demonic Gorillas for zenyte shard → Amulet of torture — BiS melee amulet.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Crafting': 89, 'Magic': 93},
    priority: 5,
    rewards: 'Amulet of torture',
    wikiPath: 'Amulet_of_torture',
  ),
  OsrsGoal(
    id: 'gear_late_zenyte_ranged',
    title: 'Craft Necklace of Anguish',
    description:
        'Kill Demonic Gorillas for zenyte shard → Necklace of anguish — BiS Ranged amulet.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Crafting': 92, 'Magic': 93},
    priority: 5,
    rewards: 'Necklace of anguish',
    wikiPath: 'Necklace_of_anguish',
  ),
  OsrsGoal(
    id: 'gear_late_zenyte_mage',
    title: 'Craft Tormented Bracelet',
    description:
        'Kill Demonic Gorillas for zenyte shard → Tormented bracelet — BiS Magic gloves.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Crafting': 84, 'Magic': 93},
    priority: 4,
    rewards: 'Tormented bracelet',
    wikiPath: 'Tormented_bracelet',
  ),
  OsrsGoal(
    id: 'gear_late_ring_suffering',
    title: 'Craft Ring of Suffering (i)',
    description:
        'Kill Demonic Gorillas for zenyte shard → Ring of suffering, then imbue — stores recoil charges.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Crafting': 89, 'Magic': 93},
    priority: 4,
    rewards: 'Ring of suffering (i)',
    wikiPath: 'Ring_of_suffering_(i)',
  ),
  OsrsGoal(
    id: 'gear_late_serp_helm',
    title: 'Obtain Serpentine Helm',
    description:
        'Kill Zulrah for Serpentine visage → Serpentine helm — venom immunity.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Ranged': 75, 'Magic': 75},
    priority: 3,
    rewards: 'Serpentine helm',
    wikiPath: 'Serpentine_helm',
  ),
  OsrsGoal(
    id: 'gear_late_infernal',
    title: 'Obtain Infernal Cape',
    description:
        'Complete the Inferno by defeating TzKal-Zuk — BiS melee cape, massive upgrade.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {
      'Ranged': 90,
      'Prayer': 77,
      'Defence': 70,
      'Hitpoints': 85
    },
    priority: 5,
    rewards: 'Infernal cape',
    wikiPath: 'Infernal_cape',
  ),
  OsrsGoal(
    id: 'gear_late_dragon_boots',
    title: 'Obtain Dragon Boots',
    description:
        'Kill Spiritual Mages in the God Wars Dungeon for Dragon boots — melee boot upgrade.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 83, 'Defence': 60},
    priority: 3,
    rewards: 'Dragon boots',
    wikiPath: 'Dragon_boots',
  ),
  OsrsGoal(
    id: 'gear_late_whip',
    title: 'Obtain Abyssal Whip',
    description:
        'Kill Abyssal Demons for the Abyssal whip — primary melee weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 85, 'Attack': 70},
    priority: 5,
    rewards: 'Abyssal whip',
    wikiPath: 'Abyssal_whip',
  ),
  OsrsGoal(
    id: 'gear_late_trident_seas',
    title: 'Obtain Trident of the Seas',
    description:
        'Kill Kraken boss for the Trident of the seas — primary Magic weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 87, 'Magic': 75},
    priority: 5,
    rewards: 'Trident of the seas',
    wikiPath: 'Trident_of_the_seas',
  ),
  OsrsGoal(
    id: 'gear_late_trident_swamp',
    title: 'Obtain Trident of the Swamp',
    description:
        'Combine Trident with Magic fang from Zulrah — upgraded Magic weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 87, 'Magic': 75, 'Ranged': 75},
    priority: 4,
    rewards: 'Trident of the swamp',
    wikiPath: 'Trident_of_the_swamp',
  ),
  OsrsGoal(
    id: 'gear_late_occult',
    title: 'Obtain Occult Necklace',
    description:
        'Kill Thermonuclear Smoke Devil for the Occult necklace — BiS Magic necklace.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 93},
    priority: 5,
    rewards: 'Occult necklace',
    wikiPath: 'Occult_necklace',
  ),
  OsrsGoal(
    id: 'gear_late_void',
    title: 'Obtain Elite Void (Ranger)',
    description:
        'Complete Pest Control for Void ranger helm + Elite void top/robe + Void knight gloves.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {
      'Ranged': 42,
      'Prayer': 22,
      'Defence': 42,
      'Hitpoints': 42
    },
    priority: 4,
    rewards:
        'Void ranger helm, Elite void top, Elite void robe, Void knight gloves',
    wikiPath: 'Void_Knight_equipment',
  ),
  OsrsGoal(
    id: 'gear_late_avernic_treads',
    title: 'Obtain Avernic Treads',
    description:
        'Complete Doom of Mokhaiotl for Avernic treads — upgraded boots for all combat styles.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Attack': 80, 'Defence': 70},
    priority: 4,
    rewards: 'Avernic treads',
    wikiPath: 'Avernic_treads',
  ),
  OsrsGoal(
    id: 'gear_late_confliction',
    title: 'Obtain Confliction Gauntlets + Eye of Ayak',
    description:
        'Complete Doom of Mokhaiotl for Confliction gauntlets (BiS mage gloves) and Eye of ayak.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Magic': 80, 'Defence': 70},
    priority: 4,
    rewards: 'Confliction gauntlets, Eye of ayak',
    wikiPath: 'Doom_of_Mokhaiotl',
  ),
  OsrsGoal(
    id: 'gear_late_oathplate',
    title: 'Obtain Oathplate Armour',
    description:
        'Kill Yama for Oathplate helm/chest/legs — strong melee armour set.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Attack': 80, 'Defence': 75},
    priority: 4,
    rewards: 'Oathplate helm, Oathplate chest, Oathplate legs',
    wikiPath: 'Yama',
  ),
  OsrsGoal(
    id: 'gear_late_primordial',
    title: 'Obtain Avernic Treads (Max) via Cerberus',
    description:
        'Kill Cerberus for crystals to upgrade Avernic treads to (max) — BiS boots.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 91, 'Defence': 70},
    priority: 4,
    rewards: 'Avernic treads (max)',
    wikiPath: 'Cerberus',
  ),
  OsrsGoal(
    id: 'gear_late_noxious',
    title: 'Obtain Noxious Halberd + Amulet of Rancour',
    description:
        'Kill Araxxor for Noxious halberd and Amulet of rancour — powerful melee upgrades.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Attack': 80, 'Strength': 80},
    priority: 5,
    rewards: 'Noxious halberd, Amulet of rancour',
    wikiPath: 'Araxxor',
  ),
  OsrsGoal(
    id: 'gear_late_ferocious',
    title: 'Obtain Ferocious Gloves',
    description:
        'Kill Alchemical Hydra for Hydra leather → Ferocious gloves — BiS melee gloves.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Slayer': 95},
    priority: 5,
    rewards: 'Ferocious gloves',
    wikiPath: 'Ferocious_gloves',
  ),
  OsrsGoal(
    id: 'gear_late_dizana',
    title: 'Obtain Dizana\'s Quiver',
    description:
        'Complete Fortis Colosseum for Dizana\'s quiver — BiS Ranged cape/quiver.',
    category: GoalCategory.gearProgression,
    subcategory: 'Late Game',
    skillRequirements: {'Ranged': 85, 'Defence': 70, 'Prayer': 77},
    priority: 5,
    rewards: 'Dizana\'s quiver',
    wikiPath: 'Dizana%27s_quiver',
  ),

  // ── 4. END GAME ────────────────────────────────────────
  OsrsGoal(
    id: 'gear_end_elite_kourend',
    title: 'Elite Kourend Diary',
    description: 'Complete Elite Kourend Diary for Rada\'s blessing 4.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    priority: 3,
    rewards: 'Rada\'s blessing 4',
    wikiPath: 'Kourend_%26_Kebos_Diary',
  ),
  OsrsGoal(
    id: 'gear_end_blowpipe',
    title: 'Obtain Toxic Blowpipe',
    description:
        'Complete Zulrah grind for Toxic blowpipe — fast-hitting ranged weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Ranged': 75, 'Magic': 75},
    priority: 4,
    rewards: 'Toxic blowpipe',
    wikiPath: 'Toxic_blowpipe',
  ),
  OsrsGoal(
    id: 'gear_end_fang',
    title: 'Obtain Osmumten\'s Fang',
    description:
        'Complete Tombs of Amascut for Osmumten\'s fang — BiS stab weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {
      'Attack': 82,
      'Strength': 82,
      'Defence': 80,
      'Ranged': 80,
      'Magic': 80,
      'Prayer': 77
    },
    priority: 5,
    rewards: 'Osmumten\'s fang',
    wikiPath: 'Osmumten%27s_fang',
  ),
  OsrsGoal(
    id: 'gear_end_masori',
    title: 'Obtain Masori Armour',
    description:
        'Complete Tombs of Amascut for Masori mask/body/chaps — BiS Ranged armour.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Ranged': 80, 'Defence': 80},
    priority: 5,
    rewards: 'Masori mask, Masori body, Masori chaps',
    wikiPath: 'Masori_armour',
  ),
  OsrsGoal(
    id: 'gear_end_elidinis',
    title: 'Obtain Elidinis\' Ward',
    description:
        'Complete Tombs of Amascut for Elidinis\' ward — BiS Magic shield.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Magic': 80, 'Defence': 80, 'Prayer': 80},
    priority: 4,
    rewards: 'Elidinis\' ward',
    wikiPath: 'Elidinis%27_ward',
  ),
  OsrsGoal(
    id: 'gear_end_dt2_rings',
    title: 'Obtain Forgotten Four Rings',
    description:
        'Kill DT2 bosses for Ultor ring (melee), Venator ring (ranged), Magus ring (mage).',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {
      'Magic': 75,
      'Firemaking': 75,
      'Thieving': 62,
      'Herblore': 62,
      'Runecraft': 60,
      'Construction': 60,
    },
    priority: 5,
    rewards: 'Ultor ring, Venator ring, Magus ring',
    wikiPath: 'Desert_Treasure_II_-_The_Fallen_Empire',
  ),
  OsrsGoal(
    id: 'gear_end_ancestral',
    title: 'Obtain Ancestral Robes',
    description:
        'Complete Chambers of Xeric for Ancestral hat/robe top/robe bottom — BiS Magic armour.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Magic': 75, 'Defence': 75},
    priority: 5,
    rewards: 'Ancestral hat, Ancestral robe top, Ancestral robe bottom',
    wikiPath: 'Chambers_of_Xeric',
  ),
  OsrsGoal(
    id: 'gear_end_torva',
    title: 'Obtain Torva Armour',
    description:
        'Kill Nex for Torva full helm/platebody/platelegs — BiS melee armour.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {
      'Attack': 80,
      'Defence': 80,
      'Hitpoints': 85,
      'Ranged': 80
    },
    priority: 5,
    rewards: 'Torva full helm, Torva platebody, Torva platelegs',
    wikiPath: 'Nex',
  ),
  OsrsGoal(
    id: 'gear_end_zaryte',
    title: 'Obtain Zaryte Crossbow + Vambraces',
    description:
        'Kill Nex for Zaryte crossbow and Zaryte vambraces — strong ranged upgrades.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Ranged': 80, 'Defence': 80},
    priority: 4,
    rewards: 'Zaryte crossbow, Zaryte vambraces',
    wikiPath: 'Nex',
  ),
  OsrsGoal(
    id: 'gear_end_avernic_def',
    title: 'Obtain Avernic Defender',
    description:
        'Complete Theatre of Blood for Avernic defender hilt → Avernic defender — BiS melee offhand.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Attack': 70, 'Defence': 70},
    priority: 5,
    rewards: 'Avernic defender',
    wikiPath: 'Avernic_defender',
  ),
  OsrsGoal(
    id: 'gear_end_scythe',
    title: 'Obtain Scythe of Vitur',
    description:
        'Theatre of Blood megarare — Scythe of vitur — BiS melee weapon for multi-tile monsters.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Attack': 75, 'Strength': 75},
    priority: 5,
    rewards: 'Scythe of vitur',
    wikiPath: 'Scythe_of_vitur',
  ),
  OsrsGoal(
    id: 'gear_end_tbow',
    title: 'Obtain Twisted Bow',
    description:
        'Chambers of Xeric megarare — Twisted bow — BiS ranged weapon against high Magic targets.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Ranged': 85},
    priority: 5,
    rewards: 'Twisted bow',
    wikiPath: 'Twisted_bow',
  ),
  OsrsGoal(
    id: 'gear_end_shadow',
    title: 'Obtain Tumeken\'s Shadow',
    description:
        'Tombs of Amascut megarare — Tumeken\'s shadow — BiS Magic weapon.',
    category: GoalCategory.gearProgression,
    subcategory: 'End Game',
    skillRequirements: {'Magic': 85},
    priority: 5,
    rewards: 'Tumeken\'s shadow',
    wikiPath: 'Tumeken%27s_shadow',
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  GOAL CASCADE MAP
//  When a parent goal is marked complete, all children are also
//  marked complete. Reverse: unchecking a parent unchecks children.
//  Transitive: Quest Cape → quest_tier_* → individual quests.
// ═══════════════════════════════════════════════════════════════════

const Map<String, List<String>> goalCascadeMap = {
  // ── Diary tier aggregates → individual diaries ────────────
  'diary_all_easy': [
    'diary_ardy_easy',
    'diary_varrock_easy',
    'diary_lumbridge_easy',
    'gear_early_diaries', // "Easy Diaries (Ardougne, Kourend, Lumbridge)"
  ],
  'diary_all_medium': [
    'diary_ardy_medium',
    'diary_varrock_medium',
    'gear_mid_med_kourend', // "Medium Kourend Diary"
  ],
  'diary_all_hard': [
    'diary_ardy_hard',
    'diary_varrock_hard',
    'diary_lumbridge_hard',
    'diary_morytania_hard',
    'diary_western_hard',
    'diary_kandarin_hard',
    'gear_late_hard_kourend', // "Hard Kourend Diary" in gear progression
  ],
  // diary_all_elite has no individual elite diary goals in the data

  // ── Quest tier aggregates → individual quests ─────────────
  'quest_tier_novice': [
    'quest_priest_in_peril',
    'gear_early_climbing_boots', // Death Plateau
  ],
  'quest_tier_intermediate': [
    'quest_bone_voyage',
    'quest_animal_magnetism',
    'gear_early_feud', // The Feud
    'gear_early_dorgeshuun_cbow', // The Lost Tribe
    'gear_early_avas', // Animal Magnetism (gear duplicate)
  ],
  'quest_tier_experienced': [
    'quest_regicide',
    'quest_lost_city',
    'gear_early_ibans', // Underground Pass
    'gear_early_neitiznot', // The Fremennik Isles
    'gear_early_rune_armour', // Dragon Slayer I
    'gear_early_dragon_slayer1_start', // Dragon Slayer I (start)
    'gear_mid_warped_sceptre', // Path of Glouphrie
  ],
  'quest_tier_master': [
    'quest_rfd',
    'quest_sins_of_father',
    'quest_beneath_cursed_sands',
    'gear_early_dragon_scim', // Monkey Madness I
    'gear_early_bgloves', // Recipe for Disaster (gear duplicate)
  ],
  'quest_tier_grandmaster': [
    'quest_ds2',
    'quest_sote',
    'quest_mm2',
    'quest_dt2',
  ],

  // ── Quest Cape → all quest tiers (transitive) ─────────────
  'quest_quest_cape': [
    'quest_tier_novice',
    'quest_tier_intermediate',
    'quest_tier_experienced',
    'quest_tier_master',
    'quest_tier_grandmaster',
  ],
};

/// Recursively collect all goal IDs that should be cascaded from [parentId].
Set<String> expandCascade(String parentId) {
  final result = <String>{};
  final directChildren = goalCascadeMap[parentId];
  if (directChildren == null) return result;
  for (final childId in directChildren) {
    result.add(childId);
    result.addAll(expandCascade(childId));
  }
  return result;
}

/// Reverse lookup: given a child goal ID, find all parent goals that include it.
Set<String> findParentGoals(String childId) {
  final result = <String>{};
  for (final entry in goalCascadeMap.entries) {
    final allChildren = expandCascade(entry.key);
    if (allChildren.contains(childId)) {
      result.add(entry.key);
    }
  }
  return result;
}
