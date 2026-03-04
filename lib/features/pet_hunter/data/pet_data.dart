import 'dart:math';

// ═══════════════════════════════════════════════════════════════════
//  OSRS Pet Data — drop rates, sources, estimated kills/hr
// ═══════════════════════════════════════════════════════════════════

enum PetSource { boss, skilling, minigame, other }

class PetInfo {
  final String name;
  final String source;
  final PetSource type;
  final int dropRateDenominator;
  final int dropRateNumerator;
  final double killsPerHour;
  final Map<String, int> requirements;
  final String? questReq;
  final String notes;
  final List<String> alsoTrains;

  const PetInfo({
    required this.name,
    required this.source,
    required this.type,
    required this.dropRateDenominator,
    this.dropRateNumerator = 1,
    required this.killsPerHour,
    this.requirements = const {},
    this.questReq,
    this.notes = '',
    this.alsoTrains = const [],
  });

  double get dropChance => dropRateNumerator / dropRateDenominator;
  String get rateStr => '$dropRateNumerator/$dropRateDenominator';

  /// Expected kills to reach 50% chance of getting pet
  int get killsFor50 => (log(0.5) / log(1 - dropChance)).ceil();

  /// Expected kills to reach 90% chance
  int get killsFor90 => (log(0.1) / log(1 - dropChance)).ceil();

  /// Estimated hours at 50% chance
  double get hoursFor50 =>
      killsPerHour > 0 ? killsFor50 / killsPerHour : double.infinity;

  /// Estimated hours at 90% chance
  double get hoursFor90 =>
      killsPerHour > 0 ? killsFor90 / killsPerHour : double.infinity;

  /// Probability of getting pet after N kills
  double probAfterKills(int kills) => 1 - pow(1 - dropChance, kills).toDouble();

  /// "Efficiency score" — hours per 50% chance, lower = more efficient to hunt
  double get efficiencyScore => hoursFor50;

  /// Check if player meets requirements
  bool meetsRequirements(Map<String, int> playerLevels) {
    for (final entry in requirements.entries) {
      if ((playerLevels[entry.key] ?? 1) < entry.value) return false;
    }
    return true;
  }
}

// ─── Boss Pets ───────────────────────────────────────────────────

const List<PetInfo> allPets = [
  // ── Boss Pets — Easy ──
  PetInfo(
    name: 'Baby mole',
    source: 'Giant Mole',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 35,
    requirements: {'Attack': 40, 'Prayer': 43},
    notes: 'Very AFK with Dharok. Falador diary ring helps track.',
    alsoTrains: ['Hitpoints'],
  ),
  PetInfo(
    name: 'Kalphite Princess',
    source: 'Kalphite Queen',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 18,
    requirements: {'Attack': 70, 'Defence': 70},
    notes: 'Two-phase boss. Need both melee and ranged/magic.',
    alsoTrains: ['Attack', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Prince black dragon',
    source: 'King Black Dragon',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 30,
    notes: 'Wilderness — bank loot frequently.',
    alsoTrains: ['Ranged', 'Hitpoints'],
  ),

  // ── Boss Pets — Medium ──
  PetInfo(
    name: 'Kraken pet',
    source: 'Kraken',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 90,
    requirements: {'Slayer': 87},
    notes:
        'Slayer boss — very AFK, on task only. One of the fastest boss pets.',
    alsoTrains: ['Slayer', 'Magic'],
  ),
  PetInfo(
    name: 'Thermy',
    source: 'Thermonuclear Smoke Devil',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 110,
    requirements: {'Slayer': 93},
    notes: 'Fastest boss pet hunt in game. AFK Slayer boss.',
    alsoTrains: ['Slayer', 'Magic'],
  ),
  PetInfo(
    name: 'Sraracha',
    source: 'Sarachnis',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 45,
    requirements: {'Attack': 65, 'Strength': 65},
    notes: 'Good intro boss. Cudgel is useful for ironmen.',
    alsoTrains: ['Attack', 'Hitpoints'],
  ),

  // ── Boss Pets — Hard ──
  PetInfo(
    name: 'Hellpuppy',
    source: 'Cerberus',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 32,
    requirements: {'Slayer': 91},
    notes: 'Also drops crystals for BiS boots. Very worthwhile grind.',
    alsoTrains: ['Slayer', 'Attack', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Abyssal orphan',
    source: 'Abyssal Sire',
    type: PetSource.boss,
    dropRateDenominator: 2560,
    killsPerHour: 22,
    requirements: {'Slayer': 85},
    notes: 'Drops unsired for Abyssal bludgeon/dagger.',
    alsoTrains: ['Slayer', 'Attack', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Noon/Midnight',
    source: 'Grotesque Guardians',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 28,
    requirements: {'Slayer': 75},
    notes: 'Rooftop gargoyle Slayer boss.',
    alsoTrains: ['Slayer', 'Attack'],
  ),
  PetInfo(
    name: 'Ikkle Hydra',
    source: 'Alchemical Hydra',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 28,
    requirements: {'Slayer': 95},
    notes: 'Excellent GP/hr + Hydra claw. One of the best grinds in the game.',
    alsoTrains: ['Slayer', 'Ranged', 'Hitpoints'],
  ),

  // ── Boss Pets — Elite ──
  PetInfo(
    name: 'Snakeling',
    source: 'Zulrah',
    type: PetSource.boss,
    dropRateDenominator: 4000,
    killsPerHour: 30,
    requirements: {'Ranged': 80, 'Magic': 80},
    questReq: 'Regicide',
    notes: 'Great GP while hunting. Learn rotations.',
    alsoTrains: ['Ranged', 'Magic', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Vorki',
    source: 'Vorkath',
    type: PetSource.boss,
    dropRateDenominator: 3000,
    killsPerHour: 30,
    requirements: {'Ranged': 80, 'Defence': 70},
    questReq: 'Dragon Slayer II',
    notes: 'Consistent GP/hr. One of the best pet hunts.',
    alsoTrains: ['Ranged', 'Hitpoints'],
  ),
  PetInfo(
    name: 'General Graardor Jr.',
    source: 'General Graardor',
    type: PetSource.boss,
    dropRateDenominator: 5000,
    killsPerHour: 22,
    requirements: {'Strength': 80, 'Defence': 70},
    notes: 'Bandos — also good GP from tassets/BCP.',
    alsoTrains: ['Strength', 'Hitpoints'],
  ),
  PetInfo(
    name: "Kree'arra Jr.",
    source: "Kree'arra",
    type: PetSource.boss,
    dropRateDenominator: 5000,
    killsPerHour: 20,
    requirements: {'Ranged': 80, 'Defence': 70},
    notes: 'Armadyl — crossbow and armour drops.',
    alsoTrains: ['Ranged', 'Hitpoints'],
  ),
  PetInfo(
    name: "K'ril Jr.",
    source: "K'ril Tsutsaroth",
    type: PetSource.boss,
    dropRateDenominator: 5000,
    killsPerHour: 25,
    requirements: {'Hitpoints': 70, 'Strength': 70},
    notes: 'Zamorak GWD — hasta/SotD drops.',
    alsoTrains: ['Attack', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Zilyana Jr.',
    source: 'Commander Zilyana',
    type: PetSource.boss,
    dropRateDenominator: 5000,
    killsPerHour: 20,
    requirements: {'Hitpoints': 70, 'Agility': 70},
    notes: 'Saradomin GWD — ACB drops.',
    alsoTrains: ['Ranged', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Nexling',
    source: 'Nex',
    type: PetSource.boss,
    dropRateDenominator: 500,
    killsPerHour: 12,
    requirements: {'Ranged': 90, 'Defence': 85},
    notes: 'Team boss. Drop rate scales with team size. Torva drops.',
    alsoTrains: ['Ranged', 'Hitpoints'],
  ),

  // ── Boss Pets — Master ──
  PetInfo(
    name: 'Olmlet',
    source: 'Chambers of Xeric',
    type: PetSource.boss,
    dropRateDenominator: 53,
    dropRateNumerator: 1,
    killsPerHour: 2,
    requirements: {'Attack': 85, 'Ranged': 85, 'Magic': 85},
    notes: '1/53 per purple. ~31.5k points per raid. Team or solo.',
    alsoTrains: ['Attack', 'Ranged', 'Magic'],
  ),
  PetInfo(
    name: "Lil' Zik",
    source: 'Theatre of Blood',
    type: PetSource.boss,
    dropRateDenominator: 650,
    killsPerHour: 2,
    requirements: {'Attack': 90, 'Ranged': 90, 'Magic': 90},
    notes: 'Team raid. Hard mode has better pet chance.',
    alsoTrains: ['Attack', 'Ranged', 'Magic'],
  ),
  PetInfo(
    name: 'Tumeken\'s guardian',
    source: 'Tombs of Amascut',
    type: PetSource.boss,
    dropRateDenominator: 2000,
    killsPerHour: 2,
    requirements: {'Attack': 80, 'Ranged': 80, 'Magic': 80},
    questReq: 'Beneath Cursed Sands',
    notes: 'Scales with invocation level. 300+ invo recommended.',
    alsoTrains: ['Attack', 'Ranged', 'Magic'],
  ),
  PetInfo(
    name: 'Jal-nib-rek',
    source: 'TzKal-Zuk (Inferno)',
    type: PetSource.boss,
    dropRateDenominator: 100,
    killsPerHour: 0.5,
    requirements: {'Ranged': 90, 'Prayer': 77},
    notes: 'Hardest solo PvM challenge. ~2 hours per attempt.',
    alsoTrains: ['Ranged', 'Prayer'],
  ),
  PetInfo(
    name: 'TzRek-Jad',
    source: 'TzTok-Jad (Fight Caves)',
    type: PetSource.boss,
    dropRateDenominator: 200,
    killsPerHour: 1,
    requirements: {'Ranged': 70, 'Prayer': 43},
    notes: 'Also from gambles (1/200). ~1 hour per run.',
    alsoTrains: ['Ranged', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Smolcano',
    source: 'Zalcano',
    type: PetSource.boss,
    dropRateDenominator: 2250,
    killsPerHour: 20,
    requirements: {'Mining': 70, 'Smithing': 70},
    questReq: 'Song of the Elves',
    notes: 'Skilling boss — no combat needed. Good GP.',
    alsoTrains: ['Mining', 'Smithing', 'Runecraft'],
  ),
  PetInfo(
    name: 'Corporeal Critter',
    source: 'Corporeal Beast',
    type: PetSource.boss,
    dropRateDenominator: 5000,
    killsPerHour: 8,
    requirements: {'Attack': 80, 'Strength': 80},
    notes: 'Solo is slow. Team speeds it up. Sigil drops.',
    alsoTrains: ['Attack', 'Hitpoints'],
  ),

  // ── Skilling Pets ──
  PetInfo(
    name: 'Heron',
    source: 'Fishing',
    type: PetSource.skilling,
    dropRateDenominator: 426954,
    killsPerHour: 900,
    requirements: {'Fishing': 82},
    notes:
        'Rate varies by fish type. Anglerfish ~1/78.6k, Monkfish ~1/138k. Scales with level.',
    alsoTrains: ['Fishing'],
  ),
  PetInfo(
    name: 'Rock Golem',
    source: 'Mining',
    type: PetSource.skilling,
    dropRateDenominator: 244725,
    killsPerHour: 1200,
    requirements: {'Mining': 72},
    notes:
        'Rate varies by ore. MLM ~1/247k per pay-dirt. Shooting Stars, Gem rocks also roll.',
    alsoTrains: ['Mining'],
  ),
  PetInfo(
    name: 'Beaver',
    source: 'Woodcutting',
    type: PetSource.skilling,
    dropRateDenominator: 317647,
    killsPerHour: 1500,
    requirements: {'Woodcutting': 60},
    notes: 'Rate varies by tree. Teaks ~1/317k. Fastest with 2-tick teaks.',
    alsoTrains: ['Woodcutting'],
  ),
  PetInfo(
    name: 'Tangleroot',
    source: 'Farming',
    type: PetSource.skilling,
    dropRateDenominator: 7500,
    killsPerHour: 8,
    requirements: {'Farming': 55},
    notes:
        'Rolled per harvest. Tree patches give best chance. Do all patches every run. ~1/7.5k per tree check.',
    alsoTrains: ['Farming'],
  ),
  PetInfo(
    name: 'Giant squirrel',
    source: 'Agility',
    type: PetSource.skilling,
    dropRateDenominator: 36842,
    killsPerHour: 50,
    requirements: {'Agility': 60},
    notes:
        'Rate varies by course. Seers\' ~1/35k, Ardougne ~1/36k. Scales with course.',
    alsoTrains: ['Agility'],
  ),
  PetInfo(
    name: 'Rocky',
    source: 'Thieving',
    type: PetSource.skilling,
    dropRateDenominator: 36490,
    killsPerHour: 1500,
    requirements: {'Thieving': 55},
    notes:
        'Rate varies by target. Ardy knights ~1/257k per pickpocket. Fastest with Elves.',
    alsoTrains: ['Thieving'],
  ),
  PetInfo(
    name: 'Rift Guardian',
    source: 'Runecraft',
    type: PetSource.skilling,
    dropRateDenominator: 1795758,
    killsPerHour: 2000,
    requirements: {'Runecraft': 44},
    notes:
        'Rate varies by rune type. GOTR also rolls. Bloods ~1/1.5M per essence. Extremely rare.',
    alsoTrains: ['Runecraft'],
  ),
  PetInfo(
    name: 'Phoenix',
    source: 'Wintertodt',
    type: PetSource.skilling,
    dropRateDenominator: 5000,
    killsPerHour: 5,
    requirements: {'Firemaking': 50},
    notes: 'From supply crates. One of the easier skilling pets. ~5 games/hr.',
    alsoTrains: ['Firemaking', 'Woodcutting', 'Fletching', 'Construction'],
  ),
  PetInfo(
    name: 'Tiny Tempor',
    source: 'Tempoross',
    type: PetSource.skilling,
    dropRateDenominator: 8000,
    killsPerHour: 5,
    requirements: {'Fishing': 35},
    notes: 'From reward pool. Also gives Fish barrel, Tackle box.',
    alsoTrains: ['Fishing', 'Cooking'],
  ),

  // ── Minigame Pets ──
  PetInfo(
    name: 'Youngllef',
    source: 'Corrupted Gauntlet',
    type: PetSource.minigame,
    dropRateDenominator: 400,
    killsPerHour: 4,
    questReq: 'Song of the Elves',
    notes:
        '1/400 in Corrupted, 1/2000 in Regular. Also drops enhanced crystal weapon seed.',
    alsoTrains: ['Attack', 'Ranged', 'Magic', 'Hitpoints'],
  ),
  PetInfo(
    name: 'Herbi',
    source: 'Herbiboar',
    type: PetSource.skilling,
    dropRateDenominator: 6500,
    killsPerHour: 55,
    requirements: {'Hunter': 80, 'Herblore': 31},
    questReq: 'Bone Voyage',
    notes: 'Fossil Island herbiboar tracking. AFK-ish. Also gives herbs.',
    alsoTrains: ['Hunter', 'Herblore'],
  ),
  PetInfo(
    name: 'Abyssal protector',
    source: 'Guardians of the Rift',
    type: PetSource.minigame,
    dropRateDenominator: 4000,
    killsPerHour: 5,
    requirements: {'Runecraft': 27},
    notes:
        'GOTR pet. Also gives essential rune supply. Great ironman activity.',
    alsoTrains: ['Runecraft'],
  ),
  PetInfo(
    name: 'Lil\' creator',
    source: 'Soul Wars',
    type: PetSource.minigame,
    dropRateDenominator: 2500,
    killsPerHour: 4,
    notes: 'From spoils of war crate. Also gives XP lamps.',
    alsoTrains: [],
  ),
];

// ─── Engine ──────────────────────────────────────────────────────

class PetHuntingEngine {
  /// Rank all pets by efficiency (hours to 50% chance, ascending)
  static List<PetInfo> rankByEfficiency({
    Map<String, int>? playerLevels,
    bool onlyEligible = false,
  }) {
    var pets = List<PetInfo>.from(allPets);

    if (onlyEligible && playerLevels != null) {
      pets = pets.where((p) => p.meetsRequirements(playerLevels)).toList();
    }

    pets.sort((a, b) => a.efficiencyScore.compareTo(b.efficiencyScore));
    return pets;
  }

  /// Get pets that train a specific skill while hunting
  static List<PetInfo> petsThatTrain(String skill) {
    return allPets
        .where((p) =>
            p.alsoTrains.contains(skill) ||
            p.source.toLowerCase() == skill.toLowerCase())
        .toList()
      ..sort((a, b) => a.efficiencyScore.compareTo(b.efficiencyScore));
  }

  /// Get pets by source type
  static List<PetInfo> petsByType(PetSource type) {
    return allPets.where((p) => p.type == type).toList()
      ..sort((a, b) => a.efficiencyScore.compareTo(b.efficiencyScore));
  }

  /// Calculate probability of getting a pet given KC
  static double probability(PetInfo pet, int kc) {
    return pet.probAfterKills(kc);
  }

  /// Format hours nicely
  static String formatHours(double hours) {
    if (hours == double.infinity) return '???';
    if (hours < 1) return '${(hours * 60).round()} min';
    if (hours < 24) return '${hours.toStringAsFixed(1)} hrs';
    final days = hours / 24;
    if (days < 7) return '${days.toStringAsFixed(1)} days';
    return '${(days / 7).toStringAsFixed(1)} weeks';
  }
}
