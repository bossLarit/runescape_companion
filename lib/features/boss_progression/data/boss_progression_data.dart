// Boss Progression data sourced from the OSRS Wiki Bossing Ladder guide.
// https://oldschool.runescape.wiki/w/Guide:Bossing_Ladder

enum BossTier {
  easy,
  medium,
  hard,
  elite,
  master,
  grandmaster;

  String get label {
    switch (this) {
      case BossTier.easy:
        return 'Easy';
      case BossTier.medium:
        return 'Medium';
      case BossTier.hard:
        return 'Hard';
      case BossTier.elite:
        return 'Elite';
      case BossTier.master:
        return 'Master';
      case BossTier.grandmaster:
        return 'Grandmaster';
    }
  }

  String get description {
    switch (this) {
      case BossTier.easy:
        return 'Low requirements. Overhead prayers trivialize most encounters.';
      case BossTier.medium:
        return 'Multiple mechanics to learn without being too punishing.';
      case BossTier.hard:
        return 'Solid execution of multiple mechanics required. 70+ stats recommended.';
      case BossTier.elite:
        return 'High combat levels, strong equipment. Failing mechanics = death.';
      case BossTier.master:
        return 'Long, punishing encounters. 90+ stats and powerful gear recommended.';
      case BossTier.grandmaster:
        return 'Aspirational challenges. Max combat and BiS gear expected.';
    }
  }

  int get suggestedCombat {
    switch (this) {
      case BossTier.easy:
        return 50;
      case BossTier.medium:
        return 70;
      case BossTier.hard:
        return 80;
      case BossTier.elite:
        return 90;
      case BossTier.master:
        return 100;
      case BossTier.grandmaster:
        return 126;
    }
  }
}

class BossEntry {
  final String name;
  final BossTier tier;
  final String description;
  final Map<String, int> combatReqs; // skill -> level
  final int? slayerReq;
  final String? questReq;
  final List<String> keyDrops;
  final String wikiPath;
  final bool isWilderness;
  final bool isSkillingBoss;
  final String? groupSize; // null = solo, or "Solo/Duo", "Team"

  const BossEntry({
    required this.name,
    required this.tier,
    required this.description,
    this.combatReqs = const {},
    this.slayerReq,
    this.questReq,
    this.keyDrops = const [],
    required this.wikiPath,
    this.isWilderness = false,
    this.isSkillingBoss = false,
    this.groupSize,
  });

  /// Check if a player meets the combat requirements.
  bool meetsRequirements(Map<String, int> playerLevels) {
    for (final entry in combatReqs.entries) {
      final playerLevel = playerLevels[entry.key] ?? 1;
      if (playerLevel < entry.value) return false;
    }
    if (slayerReq != null) {
      final slayer = playerLevels['Slayer'] ?? 1;
      if (slayer < slayerReq!) return false;
    }
    return true;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ALL BOSSES — ordered by tier, then roughly by difficulty within tier
// ═══════════════════════════════════════════════════════════════════

const List<BossEntry> allBosses = [
  // ─── EASY TIER ───────────────────────────────────────────
  BossEntry(
    name: 'Wintertodt',
    tier: BossTier.easy,
    description:
        'Skilling boss — uses Firemaking. Best done at low HP for less damage.',
    combatReqs: {'Firemaking': 50},
    keyDrops: ['Tome of fire', 'Warm gloves', 'Pyromancer outfit'],
    wikiPath: 'Wintertodt',
    isSkillingBoss: true,
  ),
  BossEntry(
    name: 'Tempoross',
    tier: BossTier.easy,
    description:
        'Skilling boss — uses Fishing. Safe minigame with useful rewards.',
    combatReqs: {'Fishing': 35},
    keyDrops: ['Tome of water', 'Fish barrel', 'Tackle box'],
    wikiPath: 'Tempoross',
    isSkillingBoss: true,
  ),
  BossEntry(
    name: 'Obor',
    tier: BossTier.easy,
    description:
        'F2P hill giant boss. Requires a Giant key drop from hill giants.',
    keyDrops: ['Hill giant club', 'Rune equipment'],
    wikiPath: 'Obor',
  ),
  BossEntry(
    name: 'Bryophyta',
    tier: BossTier.easy,
    description: 'F2P moss giant boss. Requires a Mossy key.',
    keyDrops: ["Bryophyta's essence"],
    wikiPath: 'Bryophyta',
  ),
  BossEntry(
    name: 'Scurrius',
    tier: BossTier.easy,
    description:
        'Low-level combat boss under Varrock. Good intro to PvM mechanics.',
    keyDrops: ["Scurrius' spine", 'Runes'],
    wikiPath: 'Scurrius',
  ),
  BossEntry(
    name: 'Giant Mole',
    tier: BossTier.easy,
    description:
        'Simple boss in Falador Park. Bring a Dharok set or ranged for easy kills.',
    combatReqs: {'Attack': 40, 'Prayer': 43},
    keyDrops: ['Mole skin', 'Mole claw'],
    wikiPath: 'Giant_Mole',
  ),
  BossEntry(
    name: 'Deranged Archaeologist',
    tier: BossTier.easy,
    description: 'Fossil Island ranged boss. Easy to safespot.',
    questReq: 'Bone Voyage',
    keyDrops: ['Steel ring', 'Crystal key'],
    wikiPath: 'Deranged_archaeologist',
  ),
  BossEntry(
    name: 'Barrows',
    tier: BossTier.easy,
    description:
        'Six brothers in crypts. Use Magic to kill efficiently. Great early GP.',
    combatReqs: {'Magic': 50, 'Prayer': 43},
    questReq: 'Priest in Peril',
    keyDrops: ['Barrows equipment', 'Runes'],
    wikiPath: 'Barrows',
  ),

  // ─── MEDIUM TIER ─────────────────────────────────────────
  BossEntry(
    name: 'Hespori',
    tier: BossTier.medium,
    description:
        'Farming Guild boss. Grows from a Hespori seed, fight when ready.',
    combatReqs: {'Farming': 65},
    keyDrops: ['Anima seeds', 'Bottomless compost bucket'],
    wikiPath: 'Hespori',
    isSkillingBoss: true,
  ),
  BossEntry(
    name: 'Sarachnis',
    tier: BossTier.medium,
    description:
        'Spider boss in Forthos Dungeon. Good intro to prayer switching.',
    combatReqs: {'Attack': 65, 'Strength': 65},
    keyDrops: ['Sarachnis cudgel', 'Giant egg sac'],
    wikiPath: 'Sarachnis',
  ),
  BossEntry(
    name: 'King Black Dragon',
    tier: BossTier.medium,
    description:
        'Classic dragon boss in the Wilderness. Bring an anti-dragon shield.',
    combatReqs: {'Ranged': 61},
    keyDrops: ['KBD heads', 'Draconic visage', 'Dragon med helm'],
    wikiPath: 'King_Black_Dragon',
    isWilderness: true,
  ),
  BossEntry(
    name: 'Crazy Archaeologist',
    tier: BossTier.medium,
    description: 'Wilderness demi-boss. Easy to safe-spot with ranged.',
    keyDrops: ['Odium shard 1', 'Malediction shard 1'],
    wikiPath: 'Crazy_archaeologist',
    isWilderness: true,
  ),
  BossEntry(
    name: 'Chaos Fanatic',
    tier: BossTier.medium,
    description: 'Wilderness demi-boss. Easy to safe-spot.',
    keyDrops: ['Odium shard 2', 'Malediction shard 2'],
    wikiPath: 'Chaos_Fanatic',
    isWilderness: true,
  ),
  BossEntry(
    name: 'Amoxliatl',
    tier: BossTier.medium,
    description: 'Cam Torum boss. Accessible mid-game encounter.',
    keyDrops: ['Glacial temotli', 'Pendant of ates'],
    wikiPath: 'Amoxliatl',
  ),
  BossEntry(
    name: 'The Hueycoatl',
    tier: BossTier.medium,
    description: 'Cam Torum group boss. Multi-phase dragon fight.',
    questReq: 'Children of the Sun',
    keyDrops: ['Dragon hunter wand', 'Hueycoatl hide'],
    wikiPath: 'The_Hueycoatl',
    groupSize: 'Team',
  ),
  BossEntry(
    name: 'Kraken',
    tier: BossTier.medium,
    description:
        'Slayer boss — requires 87 Slayer on task. Easy mechanics, great drops.',
    slayerReq: 87,
    keyDrops: ['Trident of the seas', 'Kraken tentacle'],
    wikiPath: 'Kraken',
  ),
  BossEntry(
    name: 'Thermonuclear Smoke Devil',
    tier: BossTier.medium,
    description: 'Slayer boss — requires 93 Slayer. Simple mechanics.',
    slayerReq: 93,
    keyDrops: ['Occult necklace', 'Smoke battlestaff'],
    wikiPath: 'Thermonuclear_smoke_devil',
  ),
  BossEntry(
    name: 'Zalcano',
    tier: BossTier.medium,
    description:
        'Skilling boss in Prifddinas. Uses Mining, Smithing, and Runecraft.',
    combatReqs: {'Mining': 70, 'Smithing': 70},
    questReq: 'Song of the Elves',
    keyDrops: ['Crystal tool seed', 'Zalcano shard'],
    wikiPath: 'Zalcano',
    isSkillingBoss: true,
  ),
  BossEntry(
    name: 'Royal Titans',
    tier: BossTier.medium,
    description: 'Elemental boss encounter with prayer-based mechanics.',
    keyDrops: ['Twinflame staff', "Mage's book", 'Deadeye prayer scroll'],
    wikiPath: 'Royal_Titans',
  ),
  BossEntry(
    name: 'Moons of Peril',
    tier: BossTier.medium,
    description:
        'Three-moon boss fight. Drops Moon equipment for all combat styles.',
    questReq: 'Perilous Moons',
    keyDrops: ['Blood Moon armour', 'Eclipse Moon armour', 'Blue Moon armour'],
    wikiPath: 'Moons_of_Peril',
    groupSize: 'Solo/Duo',
  ),
  BossEntry(
    name: 'God Wars Dungeon (intro)',
    tier: BossTier.medium,
    description:
        'GWD minions and learning the dungeon. Full bosses are harder.',
    combatReqs: {'Hitpoints': 70, 'Agility': 70},
    keyDrops: ['Godsword shards', 'God equipment'],
    wikiPath: 'God_Wars_Dungeon',
    groupSize: 'Solo/Team',
  ),

  // ─── HARD TIER ───────────────────────────────────────────
  BossEntry(
    name: 'TzTok-Jad (Fight Caves)',
    tier: BossTier.hard,
    description:
        'Iconic wave-based challenge. Prayer switching is key. Reward: Fire cape.',
    combatReqs: {'Ranged': 70, 'Prayer': 43, 'Hitpoints': 70},
    keyDrops: ['Fire cape'],
    wikiPath: 'TzTok-Jad',
  ),
  BossEntry(
    name: 'Dagannoth Kings',
    tier: BossTier.hard,
    description: 'Tri-boss fight — each king uses a different combat style.',
    combatReqs: {'Attack': 70, 'Ranged': 70, 'Magic': 70},
    keyDrops: ['Berserker ring', 'Archers ring', 'Seers ring', 'Warrior ring'],
    wikiPath: 'Dagannoth_Kings',
  ),
  BossEntry(
    name: 'Grotesque Guardians',
    tier: BossTier.hard,
    description: 'Gargoyle slayer boss on the Slayer Tower roof.',
    slayerReq: 75,
    keyDrops: ['Granite dust', 'Granite hammer', 'Black tourmaline core'],
    wikiPath: 'Grotesque_Guardians',
  ),
  BossEntry(
    name: 'Skotizo',
    tier: BossTier.hard,
    description:
        'Catacombs boss — use Arclight. Requires a Dark totem to access.',
    combatReqs: {'Attack': 70},
    keyDrops: ['Ancient shard', 'Dark claw', 'Uncut onyx'],
    wikiPath: 'Skotizo',
  ),
  BossEntry(
    name: 'Scorpia',
    tier: BossTier.hard,
    description: 'Wilderness scorpion boss. Bring Protect from Melee.',
    keyDrops: ['Odium shard 3', 'Malediction shard 3'],
    wikiPath: 'Scorpia',
    isWilderness: true,
  ),
  BossEntry(
    name: 'Chaos Elemental',
    tier: BossTier.hard,
    description: 'Wilderness boss — unequips your gear. Tricky mechanics.',
    keyDrops: ['Dragon pickaxe', 'Dragon 2h sword'],
    wikiPath: 'Chaos_Elemental',
    isWilderness: true,
  ),
  BossEntry(
    name: "Vet'ion / Calvar'ion",
    tier: BossTier.hard,
    description:
        'Wilderness undead boss. Calvar\'ion is the singles-plus variant.',
    keyDrops: ['Voidwaker blade', 'Dragon pickaxe'],
    wikiPath: "Vet'ion",
    isWilderness: true,
  ),
  BossEntry(
    name: 'Venenatis / Spindel',
    tier: BossTier.hard,
    description: 'Wilderness spider boss. Spindel is the singles-plus variant.',
    keyDrops: ['Voidwaker gem', 'Dragon pickaxe'],
    wikiPath: 'Venenatis',
    isWilderness: true,
  ),
  BossEntry(
    name: 'Callisto / Artio',
    tier: BossTier.hard,
    description: 'Wilderness bear boss. Artio is the singles-plus variant.',
    keyDrops: ['Voidwaker hilt', 'Dragon pickaxe'],
    wikiPath: 'Callisto',
    isWilderness: true,
  ),
  BossEntry(
    name: 'The Gauntlet',
    tier: BossTier.hard,
    description:
        'Solo dungeon — gather resources and fight the Hunllef. No gear brought in.',
    questReq: 'Song of the Elves',
    keyDrops: ['Crystal shards', 'Crystal armour seed'],
    wikiPath: 'The_Gauntlet',
  ),
  BossEntry(
    name: 'Demonic Gorillas',
    tier: BossTier.hard,
    description: 'Prayer switching + overhead recognition. Drop zenyte shards.',
    questReq: 'Monkey Madness II',
    keyDrops: ['Zenyte shard', 'Ballista pieces'],
    wikiPath: 'Demonic_gorilla',
  ),
  BossEntry(
    name: 'Tormented Demons',
    tier: BossTier.hard,
    description: 'Multi-style combat. Requires While Guthix Sleeps.',
    questReq: 'While Guthix Sleeps',
    keyDrops: ['Tormented synapse', 'Burning claw', 'Scorching bow'],
    wikiPath: 'Tormented_Demon',
  ),
  BossEntry(
    name: 'Abyssal Sire',
    tier: BossTier.hard,
    description: 'Multi-phase Slayer boss. Drops Unsired for abyssal weapons.',
    slayerReq: 85,
    keyDrops: ['Unsired', 'Abyssal bludgeon', 'Abyssal dagger'],
    wikiPath: 'Abyssal_Sire',
  ),
  BossEntry(
    name: 'Cerberus',
    tier: BossTier.hard,
    description:
        'Hellhound Slayer boss. Drops crystals for best-in-slot boots.',
    slayerReq: 91,
    keyDrops: ['Primordial crystal', 'Pegasian crystal', 'Eternal crystal'],
    wikiPath: 'Cerberus',
  ),
  BossEntry(
    name: 'Araxxor',
    tier: BossTier.hard,
    description:
        'Spider boss with enrage mechanics. Drops noxious halberd components.',
    combatReqs: {'Attack': 80, 'Strength': 80},
    keyDrops: ['Araxyte fang', 'Noxious halberd', 'Amulet of rancour'],
    wikiPath: 'Araxxor',
  ),
  BossEntry(
    name: 'Alchemical Hydra',
    tier: BossTier.hard,
    description: 'Four-phase Slayer boss. Excellent GP and drops Hydra claw.',
    slayerReq: 95,
    keyDrops: ["Hydra's claw", 'Hydra leather', 'Hydra bones'],
    wikiPath: 'Alchemical_Hydra',
  ),
  BossEntry(
    name: 'Kalphite Queen',
    tier: BossTier.hard,
    description:
        'Two-phase boss — melee then ranged/magic. Drops dragon pickaxe.',
    combatReqs: {'Attack': 70, 'Defence': 70},
    keyDrops: ['KQ head', 'Dragon pickaxe', 'Dragon chain'],
    wikiPath: 'Kalphite_Queen',
  ),
  BossEntry(
    name: "K'ril Tsutsaroth",
    tier: BossTier.hard,
    description:
        'Zamorak GWD boss. Drops Staff of the dead and Zamorakian hasta.',
    combatReqs: {'Hitpoints': 70, 'Strength': 70},
    keyDrops: ['Zamorakian hasta', 'Staff of the dead', 'Zamorak hilt'],
    wikiPath: "K'ril_Tsutsaroth",
  ),
  BossEntry(
    name: 'Commander Zilyana',
    tier: BossTier.hard,
    description: 'Saradomin GWD boss. Fast-moving — kiting is essential.',
    combatReqs: {'Hitpoints': 70, 'Agility': 70},
    keyDrops: ['Armadyl crossbow', 'Saradomin hilt', 'Saradomin sword'],
    wikiPath: 'Commander_Zilyana',
  ),

  // ─── ELITE TIER ──────────────────────────────────────────
  BossEntry(
    name: 'Zulrah',
    tier: BossTier.elite,
    description:
        'Multi-phase snake boss. Learn rotations for consistent kills.',
    combatReqs: {'Ranged': 80, 'Magic': 80},
    questReq: 'Regicide',
    keyDrops: ['Tanzanite fang', 'Magic fang', 'Serpentine visage'],
    wikiPath: 'Zulrah',
  ),
  BossEntry(
    name: 'Vorkath',
    tier: BossTier.elite,
    description: 'Undead dragon — consistent GP. Requires Dragon Slayer II.',
    combatReqs: {'Ranged': 80, 'Defence': 70},
    questReq: 'Dragon Slayer II',
    keyDrops: [
      "Vorkath's head",
      'Superior dragon bones',
      'Dragonbone necklace'
    ],
    wikiPath: 'Vorkath',
  ),
  BossEntry(
    name: 'Phantom Muspah',
    tier: BossTier.elite,
    description:
        'Multi-phase boss — melee and ranged forms. Good for Ancient essence.',
    questReq: 'Secrets of the North',
    keyDrops: ['Ancient icon', 'Venator shard', 'Ancient essence'],
    wikiPath: 'Phantom_Muspah',
  ),
  BossEntry(
    name: "Kree'arra",
    tier: BossTier.elite,
    description: 'Armadyl GWD boss. Ranged-based fight with minions.',
    combatReqs: {'Ranged': 80, 'Defence': 70},
    keyDrops: ['Armadyl armour', 'Armadyl hilt'],
    wikiPath: "Kree'arra",
  ),
  BossEntry(
    name: 'General Graardor',
    tier: BossTier.elite,
    description: 'Bandos GWD boss. High damage output — bring good food.',
    combatReqs: {'Strength': 80, 'Defence': 70},
    keyDrops: ['Bandos chestplate', 'Bandos tassets', 'Bandos hilt'],
    wikiPath: 'General_Graardor',
  ),
  BossEntry(
    name: 'Duke Sucellus',
    tier: BossTier.elite,
    description: 'DT2 boss — magic-based fight. Drops Magus ring.',
    questReq: 'Desert Treasure II',
    keyDrops: ['Magus ring', 'Eye of the duke'],
    wikiPath: 'Duke_Sucellus',
  ),
  BossEntry(
    name: 'The Leviathan',
    tier: BossTier.elite,
    description: 'DT2 boss — ranged-based. Drops Venator ring.',
    questReq: 'Desert Treasure II',
    keyDrops: ['Venator ring', "Leviathan's lure"],
    wikiPath: 'The_Leviathan',
  ),
  BossEntry(
    name: 'The Whisperer',
    tier: BossTier.elite,
    description: 'DT2 boss — magic heavy. Drops Bellator ring.',
    questReq: 'Desert Treasure II',
    keyDrops: ['Bellator ring', "Siren's staff"],
    wikiPath: 'The_Whisperer',
  ),
  BossEntry(
    name: 'Vardorvis',
    tier: BossTier.elite,
    description: 'DT2 boss — melee. Drops Ultor ring.',
    questReq: 'Desert Treasure II',
    keyDrops: ['Ultor ring', "Executioner's axe head"],
    wikiPath: 'Vardorvis',
  ),
  BossEntry(
    name: 'Corrupted Gauntlet',
    tier: BossTier.elite,
    description:
        'Harder Gauntlet variant. Drops enhanced crystal weapon seed for Bowfa.',
    questReq: 'Song of the Elves',
    keyDrops: ['Enhanced crystal weapon seed', 'Crystal armour seed'],
    wikiPath: 'The_Gauntlet',
  ),
  BossEntry(
    name: 'Nex',
    tier: BossTier.elite,
    description: 'Ancient GWD boss — team fight. Drops Torva armour.',
    combatReqs: {'Ranged': 90, 'Defence': 85, 'Hitpoints': 90},
    questReq: 'The Frozen Door',
    keyDrops: ['Torva armour', 'Zaryte crossbow', 'Nihil horn'],
    wikiPath: 'Nex',
    groupSize: 'Team',
  ),
  BossEntry(
    name: 'Tombs of Amascut',
    tier: BossTier.elite,
    description:
        'Raid with scalable difficulty. Amazing loot at higher invocations.',
    combatReqs: {'Attack': 80, 'Ranged': 80, 'Magic': 80},
    questReq: 'Beneath Cursed Sands',
    keyDrops: [
      "Osmumten's fang",
      'Masori armour',
      "Tumeken's shadow",
      "Elidinis' ward"
    ],
    wikiPath: 'Tombs_of_Amascut',
    groupSize: 'Solo/Team',
  ),

  // ─── MASTER TIER ─────────────────────────────────────────
  BossEntry(
    name: 'Chambers of Xeric',
    tier: BossTier.master,
    description:
        'The original OSRS raid. Team-based with varied rooms and the Great Olm.',
    combatReqs: {'Attack': 85, 'Ranged': 85, 'Magic': 85},
    keyDrops: [
      'Twisted bow',
      'Ancestral robes',
      'Dragon claws',
      'Dexterous prayer scroll'
    ],
    wikiPath: 'Chambers_of_Xeric',
    groupSize: 'Solo/Team',
  ),
  BossEntry(
    name: 'The Nightmare / Phosani',
    tier: BossTier.master,
    description:
        'Positioning-heavy boss. Phosani is the solo variant — harder but better drops.',
    combatReqs: {'Attack': 85, 'Strength': 85, 'Hitpoints': 85},
    questReq: 'Priest in Peril',
    keyDrops: [
      "Inquisitor's armour",
      'Nightmare staff',
      'Eldritch/Harmonised/Volatile orb'
    ],
    wikiPath: "The_Nightmare",
    groupSize: 'Solo/Team',
  ),
  BossEntry(
    name: 'Yama',
    tier: BossTier.master,
    description: 'Kourend boss with complex mechanics. Drops Oathplate armour.',
    questReq: 'A Kingdom Divided',
    keyDrops: ['Oathplate armour', 'Soulflame horn'],
    wikiPath: 'Yama',
  ),
  BossEntry(
    name: 'Doom of Mokhaiotl',
    tier: BossTier.master,
    description:
        'Extended encounter with multiple phases. Drops Avernic treads.',
    questReq: 'The Final Dawn',
    keyDrops: ['Avernic treads', 'Eye of ayak', 'Mokhaiotl cloth'],
    wikiPath: 'Doom_of_Mokhaiotl',
  ),
  BossEntry(
    name: 'Theatre of Blood',
    tier: BossTier.master,
    description:
        'Raid with 5 bosses + Verzik Vitur. Requires strong team coordination.',
    combatReqs: {'Attack': 90, 'Ranged': 90, 'Magic': 90},
    keyDrops: [
      'Scythe of vitur',
      'Avernic defender hilt',
      'Ghrazi rapier',
      'Sanguinesti staff'
    ],
    wikiPath: 'Theatre_of_Blood',
    groupSize: 'Team',
  ),
  BossEntry(
    name: 'TzKal-Zuk (Inferno)',
    tier: BossTier.master,
    description:
        'The hardest solo PvM challenge. 69 waves ending in TzKal-Zuk. Reward: Infernal cape.',
    combatReqs: {'Ranged': 90, 'Prayer': 77, 'Defence': 70, 'Hitpoints': 85},
    keyDrops: ['Infernal cape'],
    wikiPath: 'TzKal-Zuk',
  ),
  BossEntry(
    name: 'Sol Heredit (Fortis Colosseum)',
    tier: BossTier.master,
    description:
        'Wave-based arena with modifiers. Final boss drops Dizana\'s quiver.',
    combatReqs: {'Ranged': 85, 'Defence': 70, 'Prayer': 77},
    questReq: 'Children of the Sun',
    keyDrops: ["Dizana's quiver", 'Sunfire fanatic armour', 'Echo crystal'],
    wikiPath: 'Sol_Heredit',
  ),

  // ─── GRANDMASTER TIER ────────────────────────────────────
  BossEntry(
    name: 'Challenge Mode Chambers of Xeric',
    tier: BossTier.grandmaster,
    description:
        'Harder CoX with cosmetic rewards. Requires mastery of all rooms.',
    combatReqs: {'Attack': 99, 'Ranged': 99, 'Magic': 99},
    keyDrops: ['Twisted ancestral colour kit', 'Metamorphic dust'],
    wikiPath: 'Chambers_of_Xeric/Challenge_Mode',
    groupSize: 'Team',
  ),
  BossEntry(
    name: 'Hard Mode Theatre of Blood',
    tier: BossTier.grandmaster,
    description: 'Harder ToB with enrage mechanics. Cosmetic ornament kits.',
    combatReqs: {'Attack': 99, 'Ranged': 99, 'Magic': 99},
    keyDrops: ['Holy ornament kit', 'Sanguine ornament kit', 'Sanguine dust'],
    wikiPath: 'Theatre_of_Blood/Hard_Mode',
    groupSize: 'Team',
  ),
  BossEntry(
    name: 'Tombs of Amascut (500+ invocation)',
    tier: BossTier.grandmaster,
    description: 'Expert-level ToA with extreme modifiers. Cosmetic rewards.',
    combatReqs: {'Attack': 99, 'Ranged': 99, 'Magic': 99},
    keyDrops: ['Cursed phalanx', "Tumeken's shadow"],
    wikiPath: 'Tombs_of_Amascut',
    groupSize: 'Solo/Team',
  ),
  BossEntry(
    name: "Yama's Contracts",
    tier: BossTier.grandmaster,
    description:
        'Challenge contracts for Yama boss. Drops radiant Oathplate recolor.',
    keyDrops: ['Radiant oathplate armour'],
    wikiPath: 'Yama',
  ),
  BossEntry(
    name: 'Awakened DT2 Bosses',
    tier: BossTier.grandmaster,
    description:
        'Harder variants of all four DT2 bosses with enrage mechanics.',
    questReq: 'Desert Treasure II',
    keyDrops: ['Sanguine torva armour'],
    wikiPath: "Awakener's_orb",
  ),
];
