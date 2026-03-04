// Training methods per skill — XP rates sourced from OSRS Wiki training guides.
// Covers Members, Ironman, and Ultimate Ironman methods.

enum AccountMode { any, mainOnly, ironmanOnly }

enum Intensity { active, afk, either }

class TrainingMethod {
  final int minLevel;
  final int maxLevel;
  final String method;
  final int xpPerHour;
  final String notes;
  final AccountMode accountMode;
  final Intensity intensity;
  final String? sessionUnit;
  final int? sessionAmount;
  final int? xpPerAction;

  /// Item keywords that must exist in the player's bank for this method.
  /// If empty, the method has no bank requirements (e.g. gathering, combat).
  /// Matching is case-insensitive substring: if the bank contains an item
  /// whose name includes any keyword, the method is considered bank-viable.
  final List<String> requiredItems;

  const TrainingMethod({
    required this.minLevel,
    required this.maxLevel,
    required this.method,
    required this.xpPerHour,
    this.notes = '',
    this.accountMode = AccountMode.any,
    this.intensity = Intensity.active,
    this.sessionUnit,
    this.sessionAmount,
    this.xpPerAction,
    this.requiredItems = const [],
  });

  bool fitsAccount(bool isIronman) {
    if (accountMode == AccountMode.any) return true;
    if (isIronman) return accountMode != AccountMode.mainOnly;
    return accountMode != AccountMode.ironmanOnly;
  }

  bool fitsIntensity(Intensity pref) {
    if (pref == Intensity.either) return true;
    if (intensity == Intensity.either) return true;
    return intensity == pref;
  }

  /// Whether this method requires specific bank items.
  bool get needsBankItems => requiredItems.isNotEmpty;

  /// Check if the player's bank satisfies this method's requirements.
  /// [bankItems] is a set of lowercase item names.
  bool bankViable(Set<String> bankItems) {
    if (requiredItems.isEmpty) return true;
    for (final keyword in requiredItems) {
      final kw = keyword.toLowerCase();
      if (bankItems.any((item) => item.contains(kw))) return true;
    }
    return false;
  }

  /// Sum the total quantity of matching items in bank.
  /// [bankItemQuantities] is a map of lowercase name to quantity.
  int bankQuantityAvailable(Map<String, int> bankItemQuantities) {
    if (requiredItems.isEmpty) return 0;
    int total = 0;
    for (final keyword in requiredItems) {
      final kw = keyword.toLowerCase();
      for (final entry in bankItemQuantities.entries) {
        if (entry.key.contains(kw)) total += entry.value;
      }
    }
    return total;
  }

  /// How many items are needed to gain [xpNeeded] XP with this method.
  /// Returns null if xpPerAction is not set.
  int? itemsNeededForXp(int xpNeeded) {
    if (xpPerAction == null || xpPerAction! <= 0) return null;
    return (xpNeeded / xpPerAction!).ceil();
  }

  /// Check if the bank has enough items for the given XP target.
  /// Returns null if quantity checking is not possible (no xpPerAction).
  /// Returns true if enough, false if not enough.
  bool? bankHasEnough(Map<String, int> bankItemQuantities, int xpNeeded) {
    if (requiredItems.isEmpty) return null;
    if (xpPerAction == null || xpPerAction! <= 0) return null;
    final needed = itemsNeededForXp(xpNeeded);
    if (needed == null) return null;
    final available = bankQuantityAvailable(bankItemQuantities);
    return available >= needed;
  }
}

class SkillMilestone {
  final int level;
  final String unlock;
  const SkillMilestone(this.level, this.unlock);
}

class SkillTrainingInfo {
  final String skill;
  final List<TrainingMethod> methods;
  final List<SkillMilestone> milestones;

  const SkillTrainingInfo({
    required this.skill,
    required this.methods,
    this.milestones = const [],
  });

  TrainingMethod? bestMethodAt(int level,
      {bool isIronman = false,
      Intensity pref = Intensity.either,
      Set<String>? bankItems}) {
    TrainingMethod? best;
    TrainingMethod? bestFallback; // best ignoring bank
    for (final m in methods) {
      if (level >= m.minLevel &&
          level <= m.maxLevel &&
          m.fitsAccount(isIronman) &&
          m.fitsIntensity(pref)) {
        if (bestFallback == null || m.xpPerHour > bestFallback.xpPerHour) {
          bestFallback = m;
        }
        if (bankItems != null && !m.bankViable(bankItems)) continue;
        if (best == null || m.xpPerHour > best.xpPerHour) {
          best = m;
        }
      }
    }
    // If bank data was provided but no method is bank-viable, fall back
    return best ?? bestFallback;
  }

  List<TrainingMethod> allMethodsAt(int level,
      {bool isIronman = false,
      Intensity pref = Intensity.either,
      Set<String>? bankItems}) {
    final eligible = methods
        .where((m) =>
            level >= m.minLevel &&
            level <= m.maxLevel &&
            m.fitsAccount(isIronman) &&
            m.fitsIntensity(pref))
        .toList();
    if (bankItems != null) {
      // Sort: bank-viable first, then by xp/hr
      eligible.sort((a, b) {
        final aViable = a.bankViable(bankItems);
        final bViable = b.bankViable(bankItems);
        if (aViable != bViable) return bViable ? 1 : -1;
        return b.xpPerHour.compareTo(a.xpPerHour);
      });
    } else {
      eligible.sort((a, b) => b.xpPerHour.compareTo(a.xpPerHour));
    }
    return eligible;
  }

  int? nextMilestoneAfter(int level) {
    for (final m in milestones) {
      if (m.level > level) return m.level;
    }
    final next5 = ((level ~/ 5) + 1) * 5;
    final next10 = ((level ~/ 10) + 1) * 10;
    if (next5 <= 99 && next5 - level <= 7) return next5;
    if (next10 <= 99) return next10;
    if (level < 99) return 99;
    return null;
  }

  String? milestoneUnlock(int level) {
    for (final m in milestones) {
      if (m.level == level) return m.unlock;
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TRAINING DATA — sourced from oldschool.runescape.wiki guides
// ═══════════════════════════════════════════════════════════════════
const Map<String, SkillTrainingInfo> trainingData = {
  // ─── ATTACK ────────────────────────────────────────────
  'Attack': SkillTrainingInfo(skill: 'Attack', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 29,
        method: 'Quests (Waterfall Quest)',
        xpPerHour: 0,
        notes: 'Instant 30 Attack + 30 Strength'),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 39,
        method: 'Ammonite Crabs',
        xpPerHour: 30000,
        intensity: Intensity.afk,
        sessionUnit: 'kills',
        sessionAmount: 200,
        xpPerAction: 160),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 59,
        method: 'Ammonite Crabs (Rune Scim)',
        xpPerHour: 45000,
        intensity: Intensity.afk,
        sessionUnit: 'kills',
        sessionAmount: 200,
        xpPerAction: 240),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'Slayer (Nieve/Duradel)',
        xpPerHour: 40000,
        notes: 'Best long-term — trains Slayer + GP',
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 10000),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'NMZ (Hard Rumble)',
        xpPerHour: 100000,
        intensity: Intensity.afk,
        accountMode: AccountMode.mainOnly,
        notes: 'Dharok/Obsidian — fastest pure melee XP'),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'NMZ Obsidian set',
        xpPerHour: 75000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Obsidian helm/body/legs + Berserker necklace + Obby sword. Craft own absorption potions. Very AFK once set up.'),
  ], milestones: [
    SkillMilestone(20, 'Mithril equipment'),
    SkillMilestone(30, 'Adamant equipment'),
    SkillMilestone(40, 'Rune equipment'),
    SkillMilestone(50, 'Granite Maul, Leaf-bladed sword'),
    SkillMilestone(60, 'Dragon Scimitar (after MM1)'),
    SkillMilestone(70, 'Abyssal Whip — huge upgrade'),
    SkillMilestone(75, 'Godswords, Abyssal Bludgeon'),
    SkillMilestone(99, 'Attack Cape'),
  ]),

  // ─── STRENGTH ──────────────────────────────────────────
  'Strength': SkillTrainingInfo(skill: 'Strength', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 29,
        method: 'Quests (Waterfall Quest)',
        xpPerHour: 0,
        notes: 'Instant 30 Attack + 30 Strength'),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 39,
        method: 'Ammonite Crabs',
        xpPerHour: 30000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 59,
        method: 'Ammonite Crabs (Aggressive)',
        xpPerHour: 45000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'Slayer (Duradel)',
        xpPerHour: 40000,
        notes: 'Bludgeon/Sara Sword — trains Slayer + GP'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'NMZ (Hard Rumble) Dharok',
        xpPerHour: 105000,
        intensity: Intensity.afk,
        accountMode: AccountMode.mainOnly),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'NMZ Obsidian (Aggressive)',
        xpPerHour: 80000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Obsidian set + Berserker necklace + Obby sword on Aggressive. Craft own absorptions. Best AFK Strength XP for ironmen.'),
  ], milestones: [
    SkillMilestone(40, 'Rune effective'),
    SkillMilestone(50, 'Granite Maul spec'),
    SkillMilestone(60, 'Dragon weapons on Aggressive'),
    SkillMilestone(70, 'Saradomin Sword, Bludgeon'),
    SkillMilestone(85, 'Max hit milestones'),
    SkillMilestone(99, 'Strength Cape'),
  ]),

  // ─── DEFENCE ───────────────────────────────────────────
  'Defence': SkillTrainingInfo(skill: 'Defence', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 39,
        method: 'Quests (Nature Spirit, Holy Grail)',
        xpPerHour: 0,
        notes: 'Use quest rewards for early Defence'),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 69,
        method: 'Ammonite Crabs (Defensive)',
        xpPerHour: 30000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'Slayer on Defensive',
        xpPerHour: 30000),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Defensive Casting (Burst/Barrage)',
        xpPerHour: 80000,
        notes: 'Train Magic + Defence simultaneously'),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'NMZ Obsidian (Defensive)',
        xpPerHour: 55000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Obsidian set on Defensive. Slower than Attack/Str but very AFK. Good if you need Defence levels for PvM gear.'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Defensive Burst/Barrage Slayer',
        xpPerHour: 60000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Cast on defensive — trains Magic + Defence + Slayer. Conserve runes with burst over barrage.'),
  ], milestones: [
    SkillMilestone(20, 'Mithril armour'),
    SkillMilestone(40, 'Rune armour, Green d\'hide'),
    SkillMilestone(45, 'Warrior\'s Guild (with Attack)'),
    SkillMilestone(60, 'Dragon armour, Obsidian'),
    SkillMilestone(70, 'Barrows, God d\'hide, Piety'),
    SkillMilestone(75, 'Bandos, Crystal, DFS'),
    SkillMilestone(99, 'Defence Cape'),
  ]),

  // ─── RANGED ────────────────────────────────────────────
  'Ranged': SkillTrainingInfo(skill: 'Ranged', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 19,
        method: 'Dorgeshuun C\'bow / Quests',
        xpPerHour: 15000),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 49,
        method: 'Ammonite Crabs (Bone C\'bow)',
        xpPerHour: 30000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 69,
        method: 'Ammonite Crabs MSB (i)',
        xpPerHour: 50000,
        intensity: Intensity.afk,
        notes: 'Broad arrows from Slayer'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 69,
        method: 'Cannon Slayer tasks',
        xpPerHour: 70000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['cannonball'],
        notes: 'Buy cannonballs from GE'),
    TrainingMethod(
        minLevel: 50,
        maxLevel: 69,
        method: 'Chinning MM1 tunnels (bought)',
        xpPerHour: 200000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['chinchompa'],
        notes: 'Buy red/grey chins from GE',
        xpPerAction: 350),
    TrainingMethod(
        minLevel: 50,
        maxLevel: 69,
        method: 'Chinning MM1 (self-caught)',
        xpPerHour: 80000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['chinchompa'],
        notes: 'Catch red chins first',
        sessionUnit: 'chins',
        sessionAmount: 500,
        xpPerAction: 300),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Chinning MM2 tunnels (bought)',
        xpPerHour: 500000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['chinchompa'],
        notes: 'Black chins — fastest Ranged XP in game',
        xpPerAction: 500),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Chinning MM2 (self-caught)',
        xpPerHour: 250000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['chinchompa'],
        notes: 'Catch red/black chins, then chin',
        sessionUnit: 'chins',
        sessionAmount: 1000,
        xpPerAction: 400),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Slayer with Bowfa/Blowpipe',
        xpPerHour: 35000,
        intensity: Intensity.afk,
        notes: 'Slower but profitable + Slayer XP'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'Slayer with broad bolts (Rune C\'bow)',
        xpPerHour: 20000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Broad bolts from Slayer points. Train Ranged passively through Slayer tasks.'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 69,
        method: 'Cannon Slayer (self-made cballs)',
        xpPerHour: 50000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Smith steel bars → cannonballs at BF. Slower supply than mains but still fast XP.',
        requiredItems: ['cannonball']),
  ], milestones: [
    SkillMilestone(30, 'Snakeskin, Ava\'s Accumulator'),
    SkillMilestone(40, 'Green d\'hide, Bone Crossbow'),
    SkillMilestone(50, 'Magic Shortbow (i), Broad bolts'),
    SkillMilestone(61, 'Rune Crossbow'),
    SkillMilestone(70, 'Crystal Bow, Black d\'hide, ACB'),
    SkillMilestone(75, 'Toxic Blowpipe — massive upgrade'),
    SkillMilestone(80, 'Bow of Faerdhinen'),
    SkillMilestone(99, 'Ranged Cape — Ava\'s effect'),
  ]),

  // ─── PRAYER ────────────────────────────────────────────
  'Prayer': SkillTrainingInfo(skill: 'Prayer', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 42,
        method: 'Quests (Holy Grail, His Faithful Servants etc.)',
        xpPerHour: 0,
        notes: 'Can reach 42 from quests alone'),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 99,
        method: 'Dragon Bones at Chaos Altar',
        xpPerHour: 600000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['dragon bones'],
        notes: 'Buy bones — Wilderness, 700% XP avg',
        xpPerAction: 252),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 99,
        method: 'Superior Dragon Bones Chaos Altar',
        xpPerHour: 1000000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['superior dragon bones'],
        notes: 'Expensive — fastest Prayer XP',
        xpPerAction: 525),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 99,
        method: 'Own bones at Chaos Altar',
        xpPerHour: 500000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: [
          'dragon bones',
          'superior dragon bones',
          'wyvern bones',
          'lava dragon bones',
          'dagannoth bones'
        ],
        notes: 'Kill dragons, use Chaos Altar (700% avg XP)',
        sessionUnit: 'bones',
        sessionAmount: 100,
        xpPerAction: 252),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 99,
        method: 'Ensouled Heads',
        xpPerHour: 50000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['ensouled'],
        notes: 'Collect from Slayer — slow but safe',
        sessionUnit: 'heads',
        sessionAmount: 50,
        xpPerAction: 650),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 99,
        method: 'Ectofuntus',
        xpPerHour: 80000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['dragon bones', 'dagannoth bones', 'wyvern bones'],
        notes: '4x XP per bone — safe for HCIM',
        xpPerAction: 288),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 99,
        method: 'Libation Bowl (blessed shards)',
        xpPerHour: 300000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['blessed bone shards'],
        notes: 'Up to 5-6x base XP — requires bone crushing',
        xpPerAction: 5),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Demonic/Sinister Offering (Slayer)',
        xpPerHour: 0,
        accountMode: AccountMode.ironmanOnly,
        notes: '3x ashes/bones during Slayer — passive, needs wrath runes'),
  ], milestones: [
    SkillMilestone(13, 'Superhuman Strength'),
    SkillMilestone(25, 'Protect Item'),
    SkillMilestone(31, 'Protect from Melee'),
    SkillMilestone(43, 'All protection prayers'),
    SkillMilestone(44, 'Eagle Eye, Mystic Might'),
    SkillMilestone(60, 'Chivalry (King\'s Ransom)'),
    SkillMilestone(70, 'Piety — +25% melee'),
    SkillMilestone(74, 'Rigour — best Ranged prayer'),
    SkillMilestone(77, 'Augury — best Magic prayer'),
    SkillMilestone(99, 'Prayer Cape'),
  ]),

  // ─── MAGIC ─────────────────────────────────────────────
  'Magic': SkillTrainingInfo(skill: 'Magic', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 32,
        method: 'Quests (Witch\'s House etc.)',
        xpPerHour: 0,
        notes: 'Skip early levels'),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 54,
        method: 'Strike/Bolt spells on crabs',
        xpPerHour: 20000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 33,
        maxLevel: 54,
        method: 'Teleport spells',
        xpPerHour: 65000),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'High Level Alchemy',
        xpPerHour: 78000,
        intensity: Intensity.afk,
        notes: 'Alch profitable items',
        sessionUnit: 'alchs',
        sessionAmount: 1000,
        xpPerAction: 65),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'Stun-Alch (Camelot Tele)',
        xpPerHour: 180000,
        notes: 'Click-intensive — fastest pre-barrage'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'Alching Slayer drops',
        xpPerHour: 65000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Alch battlestaffs/alchables from Slayer'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Ice Burst/Barrage Slayer (Dust Devils, Nechs)',
        xpPerHour: 250000,
        notes: 'Best combined Magic+Slayer XP',
        sessionUnit: 'tasks',
        sessionAmount: 3,
        xpPerAction: 40000),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Ice Burst Slayer (conserve runes)',
        xpPerHour: 150000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Use burst to save runes'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Surge spells in NMZ',
        xpPerHour: 200000,
        intensity: Intensity.afk,
        accountMode: AccountMode.mainOnly),
  ], milestones: [
    SkillMilestone(13, 'Fire Strike'),
    SkillMilestone(21, 'Teleports (Varrock etc.)'),
    SkillMilestone(43, 'Superheat Item'),
    SkillMilestone(55, 'High Level Alchemy'),
    SkillMilestone(65, 'Lunar spellbook'),
    SkillMilestone(70, 'Ice Burst — Slayer barraging'),
    SkillMilestone(75, 'Trident of the Seas'),
    SkillMilestone(94, 'Ice Barrage'),
    SkillMilestone(99, 'Magic Cape — spellbook swap'),
  ]),

  // ─── HITPOINTS ─────────────────────────────────────────
  'Hitpoints': SkillTrainingInfo(skill: 'Hitpoints', methods: [
    TrainingMethod(
        minLevel: 10,
        maxLevel: 99,
        method: 'Passive through combat',
        xpPerHour: 15000,
        intensity: Intensity.either,
        notes: '1/3 of combat XP — trained automatically'),
  ], milestones: [
    SkillMilestone(50, 'PvM survivability'),
    SkillMilestone(70, 'Fire Cape attempts viable'),
    SkillMilestone(80, 'Comfortable bossing'),
    SkillMilestone(90, 'Raid-ready HP'),
    SkillMilestone(99, 'Hitpoints Cape — 2x regen'),
  ]),

  // ─── MINING ────────────────────────────────────────────
  'Mining': SkillTrainingInfo(skill: 'Mining', methods: [
    TrainingMethod(
        minLevel: 1, maxLevel: 14, method: 'Copper/Tin', xpPerHour: 10000),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 37,
        method: 'Quests (Dwarven Mines, Plague City etc.)',
        xpPerHour: 0,
        notes: 'Can reach 37 from quests'),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 44,
        method: 'Iron power-mining (3-tick)',
        xpPerHour: 57000,
        notes: '3-tick manipulation',
        sessionUnit: 'inventories',
        sessionAmount: 20,
        xpPerAction: 980),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 44,
        method: 'Iron power-mining (normal)',
        xpPerHour: 40000,
        notes: 'Drop iron as you mine'),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 99,
        method: 'Motherlode Mine',
        xpPerHour: 30000,
        intensity: Intensity.afk,
        notes: 'AFK + nuggets for Prospector set'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 99,
        method: 'Granite (3-tick)',
        xpPerHour: 75000,
        notes: 'Fastest Mining XP — desert, very click-intensive'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 99,
        method: 'Granite (normal)',
        xpPerHour: 50000),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Volcanic Mine',
        xpPerHour: 90000,
        notes: 'Team minigame — best balanced XP'),
    TrainingMethod(
        minLevel: 72,
        maxLevel: 99,
        method: 'Motherlode Mine (upper)',
        xpPerHour: 45000,
        intensity: Intensity.afk,
        notes: 'Upper level — better ores, AFK'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Zalcano (no resources)',
        xpPerHour: 63500,
        notes: 'Skilling boss — toggle off resources for ~63.5k Mining XP/hr'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Zalcano (with resources)',
        xpPerHour: 13500,
        notes:
            'Skilling boss — ~13.5k Mining + GP/uniques, Song of the Elves req'),
    TrainingMethod(
        minLevel: 92,
        maxLevel: 99,
        method: 'Amethyst mining',
        xpPerHour: 20000,
        intensity: Intensity.afk,
        notes: 'Very AFK, amethyst for arrows/darts'),
    TrainingMethod(
        minLevel: 10,
        maxLevel: 99,
        method: 'Shooting Stars',
        xpPerHour: 25000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Passive — scout stars between tasks. Stardust → soft clay packs + gems. Great for ironmen.'),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 99,
        method: 'Gem rocks (Shilo Village)',
        xpPerHour: 35000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Gems for Crafting (cut → jewellery). Karamja gloves 3 for double gems.'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Sandstone mining (Quarry)',
        xpPerHour: 60000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Grind sandstone → buckets of sand for Superglass Make. Essential Crafting supply.'),
  ], milestones: [
    SkillMilestone(15, 'Iron ore'),
    SkillMilestone(30, 'Motherlode Mine, Coal'),
    SkillMilestone(40, 'Gold ore, Gem rocks'),
    SkillMilestone(45, 'Granite quarry'),
    SkillMilestone(55, 'Blast Mine'),
    SkillMilestone(70, 'Volcanic Mine, Zalcano (Song of the Elves)'),
    SkillMilestone(72, 'Motherlode upper level'),
    SkillMilestone(85, 'Runite ore'),
    SkillMilestone(92, 'Amethyst'),
    SkillMilestone(99, 'Mining Cape'),
  ]),

  // ─── WOODCUTTING ───────────────────────────────────────
  'Woodcutting': SkillTrainingInfo(skill: 'Woodcutting', methods: [
    TrainingMethod(
        minLevel: 1, maxLevel: 14, method: 'Regular trees', xpPerHour: 10000),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 34,
        method: 'Oak trees',
        xpPerHour: 25000,
        intensity: Intensity.afk,
        sessionUnit: 'logs',
        sessionAmount: 200,
        xpPerAction: 38),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 34,
        method: 'Willow trees',
        xpPerHour: 35000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 35,
        maxLevel: 59,
        method: 'Teak trees (2-tick)',
        xpPerHour: 95000,
        notes: 'Ape Atoll or Fossil Island — click-intensive'),
    TrainingMethod(
        minLevel: 35,
        maxLevel: 59,
        method: 'Willow trees',
        xpPerHour: 40000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 89,
        method: 'Teak trees (1.5-tick)',
        xpPerHour: 170000,
        notes: 'Fastest WC XP — very click-intensive'),
    TrainingMethod(
        minLevel: 65,
        maxLevel: 89,
        method: 'Sulliuscep mushrooms',
        xpPerHour: 80000,
        notes: 'Good XP + Fossils + Numulite, ironman-useful'),
    TrainingMethod(
        minLevel: 65,
        maxLevel: 89,
        method: 'Blisterwood trees',
        xpPerHour: 55000,
        intensity: Intensity.afk,
        notes: 'After Sins of the Father'),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: 'Redwood trees',
        xpPerHour: 65000,
        intensity: Intensity.afk,
        notes: 'Very AFK'),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: '2-tick/1.5-tick Teaks',
        xpPerHour: 170000,
        notes: 'Fastest in game'),
    TrainingMethod(
        minLevel: 35,
        maxLevel: 99,
        method: 'Teak trees (bank for planks)',
        xpPerHour: 80000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Bank teaks at Fossil Island or Ape Atoll for Construction planks. Use Plank Make spell or sawmill.'),
    TrainingMethod(
        minLevel: 50,
        maxLevel: 99,
        method: 'Mahogany trees (bank for planks)',
        xpPerHour: 40000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Bank mahogany logs for Construction. Fossil Island or Hardwood patches. Kingdom of Miscellania also supplies logs.'),
  ], milestones: [
    SkillMilestone(15, 'Oak trees'),
    SkillMilestone(30, 'Willow trees'),
    SkillMilestone(35, 'Teak trees — fast XP'),
    SkillMilestone(50, 'Mahogany trees'),
    SkillMilestone(60, 'Yew trees, Dragon axe'),
    SkillMilestone(65, 'Blisterwood trees (SotF)'),
    SkillMilestone(75, 'Magic trees'),
    SkillMilestone(90, 'Redwood trees'),
    SkillMilestone(99, 'Woodcutting Cape'),
  ]),

  // ─── FISHING ───────────────────────────────────────────
  'Fishing': SkillTrainingInfo(skill: 'Fishing', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 19,
        method: 'Shrimp/Anchovies',
        xpPerHour: 10000),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 47,
        method: 'Fly fishing (Trout/Salmon)',
        xpPerHour: 40000,
        sessionUnit: 'fish',
        sessionAmount: 200,
        xpPerAction: 60),
    TrainingMethod(
        minLevel: 35,
        maxLevel: 81,
        method: 'Tempoross',
        xpPerHour: 60000,
        intensity: Intensity.afk,
        notes: 'Minigame — fish + supplies + unique rewards'),
    TrainingMethod(
        minLevel: 48,
        maxLevel: 70,
        method: 'Barbarian Fishing',
        xpPerHour: 50000,
        notes: '+Agility +Strength XP',
        sessionUnit: 'fish',
        sessionAmount: 200,
        xpPerAction: 50),
    TrainingMethod(
        minLevel: 62,
        maxLevel: 99,
        method: 'Monkfish',
        xpPerHour: 35000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['monkfish'],
        notes: 'AFK food source for ironmen',
        xpPerAction: 120),
    TrainingMethod(
        minLevel: 71,
        maxLevel: 81,
        method: 'Barbarian Fishing (Sturgeon)',
        xpPerHour: 65000,
        sessionUnit: 'fish',
        sessionAmount: 200,
        xpPerAction: 80),
    TrainingMethod(
        minLevel: 82,
        maxLevel: 99,
        method: 'Barbarian Fishing (3-tick)',
        xpPerHour: 110000,
        notes: 'Fastest Fishing XP — click-intensive'),
    TrainingMethod(
        minLevel: 82,
        maxLevel: 99,
        method: 'Tempoross',
        xpPerHour: 65000,
        intensity: Intensity.afk,
        notes: 'Decent AFK XP + fish rewards'),
    TrainingMethod(
        minLevel: 82,
        maxLevel: 99,
        method: 'Anglerfish',
        xpPerHour: 18000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['raw anglerfish'],
        notes: 'AFK food for PvM',
        xpPerAction: 120),
    TrainingMethod(
        minLevel: 65,
        maxLevel: 99,
        method: 'Karambwan fishing',
        xpPerHour: 30000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['raw karambwan'],
        notes: 'Combo food for PvM',
        xpPerAction: 50),
  ], milestones: [
    SkillMilestone(20, 'Fly fishing'),
    SkillMilestone(35, 'Tempoross'),
    SkillMilestone(40, 'Lobsters'),
    SkillMilestone(48, 'Barbarian Fishing'),
    SkillMilestone(62, 'Monkfish (Swan Song)'),
    SkillMilestone(76, 'Sharks'),
    SkillMilestone(82, 'Anglerfish, Minnows'),
    SkillMilestone(99, 'Fishing Cape'),
  ]),

  // ─── HUNTER ────────────────────────────────────────────
  'Hunter': SkillTrainingInfo(skill: 'Hunter', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 8,
        method: 'Varrock Museum quiz',
        xpPerHour: 0,
        notes: 'Free level 9 Hunter'),
    TrainingMethod(
        minLevel: 9,
        maxLevel: 19,
        method: 'Birdhouse runs',
        xpPerHour: 30000,
        intensity: Intensity.afk,
        notes: 'Passive — every 50 min'),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 59,
        method: 'Birdhouse runs + Falconry',
        xpPerHour: 50000),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 72,
        method: 'Red Chinchompas',
        xpPerHour: 100000,
        sessionUnit: 'chins',
        sessionAmount: 500,
        xpPerAction: 198),
    TrainingMethod(
        minLevel: 63,
        maxLevel: 79,
        method: 'Red Chinchompas (bank for Ranged)',
        xpPerHour: 100000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Bank chins for Ranged training',
        sessionUnit: 'chins',
        sessionAmount: 1000,
        xpPerAction: 198),
    TrainingMethod(
        minLevel: 73,
        maxLevel: 99,
        method: 'Black Chinchompas',
        xpPerHour: 170000,
        notes: 'Wilderness — PKer risk, best XP'),
    TrainingMethod(
        minLevel: 80,
        maxLevel: 99,
        method: 'Herbiboar',
        xpPerHour: 150000,
        intensity: Intensity.afk,
        notes: 'Safe + herbs for Herblore'),
  ], milestones: [
    SkillMilestone(9, 'Birdhouse runs'),
    SkillMilestone(43, 'Chinchompas'),
    SkillMilestone(63, 'Red Chinchompas'),
    SkillMilestone(73, 'Black Chinchompas'),
    SkillMilestone(80, 'Herbiboar — XP + herbs'),
    SkillMilestone(99, 'Hunter Cape'),
  ]),

  // ─── COOKING ───────────────────────────────────────────
  'Cooking': SkillTrainingInfo(skill: 'Cooking', methods: [
    TrainingMethod(
        minLevel: 1, maxLevel: 14, method: 'Shrimp/Meat', xpPerHour: 30000),
    TrainingMethod(
        minLevel: 15, maxLevel: 29, method: 'Trout/Salmon', xpPerHour: 40000),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 64,
        method: 'Wines',
        xpPerHour: 480000,
        accountMode: AccountMode.mainOnly,
        notes: 'Buy grapes from GE — fastest cooking XP',
        requiredItems: ['grapes', 'jug of water'],
        xpPerAction: 200),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 64,
        method: 'Tuna/Lobster at Hosidius',
        xpPerHour: 130000,
        notes: 'Hosidius range = lower burn',
        sessionUnit: 'inventories',
        sessionAmount: 10,
        xpPerAction: 3360),
    TrainingMethod(
        minLevel: 65,
        maxLevel: 79,
        method: 'Karambwans',
        xpPerHour: 250000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Cook your karambwan catch — combo food',
        requiredItems: ['raw karambwan'],
        sessionUnit: 'inventories',
        sessionAmount: 10,
        xpPerAction: 190),
    TrainingMethod(
        minLevel: 65,
        maxLevel: 79,
        method: 'Sharks at Hosidius',
        xpPerHour: 180000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 80,
        maxLevel: 99,
        method: '1-tick Karambwans',
        xpPerHour: 490000,
        notes: 'Fastest cooking method',
        requiredItems: ['raw karambwan'],
        xpPerAction: 190),
    TrainingMethod(
        minLevel: 80,
        maxLevel: 99,
        method: 'Sharks at Hosidius',
        xpPerHour: 200000,
        intensity: Intensity.afk),
  ], milestones: [
    SkillMilestone(30, 'Cooking Guild'),
    SkillMilestone(43, 'Lobsters'),
    SkillMilestone(62, 'Monkfish'),
    SkillMilestone(65, 'Karambwans (Tai Bwo Wannai Trio)'),
    SkillMilestone(76, 'Sharks'),
    SkillMilestone(80, '1-tick Karambwans'),
    SkillMilestone(84, 'Anglerfish'),
    SkillMilestone(99, 'Cooking Cape — never burn'),
  ]),

  // ─── FIREMAKING ────────────────────────────────────────
  'Firemaking': SkillTrainingInfo(skill: 'Firemaking', methods: [
    TrainingMethod(
        minLevel: 1, maxLevel: 14, method: 'Normal logs', xpPerHour: 20000),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 29,
        method: 'Oak logs',
        xpPerHour: 100000,
        requiredItems: ['oak logs'],
        sessionUnit: 'logs',
        sessionAmount: 100,
        xpPerAction: 60),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 44,
        method: 'Willow logs',
        xpPerHour: 133000,
        requiredItems: ['willow logs'],
        sessionUnit: 'logs',
        sessionAmount: 100,
        xpPerAction: 90),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 49,
        method: 'Maple logs',
        xpPerHour: 175000,
        requiredItems: ['maple logs'],
        xpPerAction: 135),
    TrainingMethod(
        minLevel: 50,
        maxLevel: 99,
        method: 'Wintertodt',
        xpPerHour: 290000,
        intensity: Intensity.either,
        notes: 'Best at low HP — ironman essential for supplies',
        sessionUnit: 'games',
        sessionAmount: 10,
        xpPerAction: 25000),
    TrainingMethod(
        minLevel: 50,
        maxLevel: 99,
        method: 'Yew/Magic log burning',
        xpPerHour: 300000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['yew logs', 'magic logs'],
        notes: 'Buy logs from GE — fast line-burning',
        xpPerAction: 202),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: 'Redwood logs',
        xpPerHour: 490000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['redwood logs'],
        notes: 'Fastest FM XP — expensive',
        xpPerAction: 350),
  ], milestones: [
    SkillMilestone(30, 'Willow logs'),
    SkillMilestone(45, 'Maple logs'),
    SkillMilestone(50, 'Wintertodt — best FM training'),
    SkillMilestone(60, 'Yew logs'),
    SkillMilestone(75, 'Magic logs'),
    SkillMilestone(90, 'Redwood logs'),
    SkillMilestone(99, 'Firemaking Cape'),
  ]),

  // ─── SMITHING ──────────────────────────────────────────
  'Smithing': SkillTrainingInfo(skill: 'Smithing', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 28,
        method: 'Quests (Knight\'s Sword)',
        xpPerHour: 0,
        notes: 'Instant 29 Smithing'),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 39,
        method: 'Smelting at Blast Furnace',
        xpPerHour: 60000,
        sessionUnit: 'bars',
        sessionAmount: 200,
        xpPerAction: 18),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 99,
        method: 'Gold bars at Blast Furnace',
        xpPerHour: 380000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['gold ore'],
        notes: 'Buy gold ore from GE + Goldsmith gauntlets',
        xpPerAction: 56),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 99,
        method: 'Gold bars at BF (own ore)',
        xpPerHour: 230000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['gold ore'],
        notes: 'Buy from Ordan + Goldsmith gauntlets — 230k/hr',
        sessionUnit: 'bars',
        sessionAmount: 500,
        xpPerAction: 56),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 99,
        method: 'Steel/Mithril bars at BF',
        xpPerHour: 80000,
        accountMode: AccountMode.ironmanOnly,
        intensity: Intensity.afk,
        requiredItems: ['iron ore', 'coal'],
        notes: 'Useful bars — cannonballs, dart tips',
        xpPerAction: 18),
    TrainingMethod(
        minLevel: 85,
        maxLevel: 99,
        method: 'Rune bars at Blast Furnace',
        xpPerHour: 80000,
        intensity: Intensity.afk,
        requiredItems: ['runite ore', 'coal'],
        notes: 'Good GP',
        xpPerAction: 50),
    TrainingMethod(
        minLevel: 88,
        maxLevel: 99,
        method: 'Adamant platebodies',
        xpPerHour: 220000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['adamantite bar'],
        notes: 'Buy bars from GE',
        xpPerAction: 313),
  ], milestones: [
    SkillMilestone(29, 'After Knight\'s Sword'),
    SkillMilestone(30, 'Steel bars'),
    SkillMilestone(40, 'Gold bars at BF — Goldsmith gauntlets'),
    SkillMilestone(50, 'Mithril bars'),
    SkillMilestone(70, 'Adamant bars'),
    SkillMilestone(85, 'Rune bars — profit'),
    SkillMilestone(88, 'Dragon Sq Shield'),
    SkillMilestone(99, 'Smithing Cape'),
  ]),

  // ─── CRAFTING ──────────────────────────────────────────
  'Crafting': SkillTrainingInfo(skill: 'Crafting', methods: [
    TrainingMethod(
        minLevel: 1, maxLevel: 19, method: 'Leather bodies', xpPerHour: 30000),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 45,
        method: 'Cut gems / Jewellery',
        xpPerHour: 60000,
        requiredItems: [
          'sapphire',
          'emerald',
          'ruby',
          'diamond',
          'dragonstone',
          'opal',
          'jade',
          'topaz'
        ],
        sessionUnit: 'gems',
        sessionAmount: 100,
        xpPerAction: 67),
    TrainingMethod(
        minLevel: 46,
        maxLevel: 76,
        method: 'D\'hide bodies (GE hides)',
        xpPerHour: 140000,
        accountMode: AccountMode.mainOnly,
        requiredItems: [
          'dragon leather',
          'green dragon',
          'blue dragon',
          'red dragon',
          'black dragon',
          'd\'hide'
        ],
        notes: 'Buy hides from GE'),
    TrainingMethod(
        minLevel: 35,
        maxLevel: 60,
        method: 'Glassblowing (charter ships)',
        xpPerHour: 50000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Buy sand+soda ash from charter ships'),
    TrainingMethod(
        minLevel: 61,
        maxLevel: 99,
        method: 'Superglass Make + blow',
        xpPerHour: 85000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['giant seaweed', 'bucket of sand', 'sandstone'],
        notes: 'Giant seaweed from Fossil Island + sandstone',
        sessionUnit: 'inventories',
        sessionAmount: 20,
        xpPerAction: 2340),
    TrainingMethod(
        minLevel: 77,
        maxLevel: 99,
        method: 'Black d\'hide bodies',
        xpPerHour: 170000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['black dragon leather', 'black d\'hide']),
    TrainingMethod(
        minLevel: 61,
        maxLevel: 99,
        method: 'Cutting gems',
        xpPerHour: 90000,
        intensity: Intensity.afk,
        requiredItems: [
          'sapphire',
          'emerald',
          'ruby',
          'diamond',
          'dragonstone',
          'onyx',
          'zenyte'
        ]),
    TrainingMethod(
        minLevel: 87,
        maxLevel: 99,
        method: 'Dorgesh-Kaan goblin lamps',
        xpPerHour: 140000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'No supply cost — requires 52 Firemaking'),
  ], milestones: [
    SkillMilestone(20, 'Cut sapphires'),
    SkillMilestone(31, 'Holy symbol'),
    SkillMilestone(40, 'Gold amulets'),
    SkillMilestone(55, 'Crafting Guild'),
    SkillMilestone(63, 'Black d\'hide bodies'),
    SkillMilestone(66, 'Air battlestaff'),
    SkillMilestone(75, 'Slayer rings'),
    SkillMilestone(84, 'Fury / Zenyte (with boost)'),
    SkillMilestone(89, 'Zenyte jewellery'),
    SkillMilestone(99, 'Crafting Cape — bank teleport'),
  ]),

  // ─── FLETCHING ─────────────────────────────────────────
  'Fletching': SkillTrainingInfo(skill: 'Fletching', methods: [
    TrainingMethod(
        minLevel: 1, maxLevel: 9, method: 'Arrow shafts', xpPerHour: 15000),
    TrainingMethod(
        minLevel: 10, maxLevel: 24, method: 'Longbows (u)', xpPerHour: 30000),
    TrainingMethod(
        minLevel: 25,
        maxLevel: 51,
        method: 'Oak/Willow longbows (u)',
        xpPerHour: 100000),
    TrainingMethod(
        minLevel: 52,
        maxLevel: 99,
        method: 'Broad arrows (GE heads)',
        xpPerHour: 300000,
        accountMode: AccountMode.mainOnly,
        notes: 'Buy broad arrowheads from GE — AFK',
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 52,
        maxLevel: 99,
        method: 'Broad arrows (Slayer pts)',
        xpPerHour: 150000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Buy heads with Slayer points'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'Maple longbows (u)',
        xpPerHour: 120000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Cut own logs'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Yew/Magic longbows (u)',
        xpPerHour: 150000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Cut own logs — AFK'),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 49,
        method: 'Vale Totems (oak/willow)',
        xpPerHour: 100000,
        requiredItems: ['oak logs', 'willow logs'],
        notes: 'Fletching minigame — ~450 logs/hr, great XP per log',
        xpPerAction: 222),
    TrainingMethod(
        minLevel: 50,
        maxLevel: 64,
        method: 'Vale Totems (maple)',
        xpPerHour: 180000,
        requiredItems: ['maple logs'],
        notes: 'Fletching minigame — ~450 logs/hr',
        xpPerAction: 400),
    TrainingMethod(
        minLevel: 65,
        maxLevel: 79,
        method: 'Vale Totems (yew)',
        xpPerHour: 250000,
        requiredItems: ['yew logs'],
        notes: 'Fletching minigame — ~450 logs/hr',
        xpPerAction: 556),
    TrainingMethod(
        minLevel: 80,
        maxLevel: 89,
        method: 'Vale Totems (magic)',
        xpPerHour: 300000,
        requiredItems: ['magic logs'],
        notes: 'Fletching minigame — ~450 logs/hr',
        xpPerAction: 667),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: 'Vale Totems (redwood)',
        xpPerHour: 350000,
        requiredItems: ['redwood logs'],
        notes: 'Fletching minigame — ~450 logs/hr, best non-dart method',
        xpPerAction: 778),
    TrainingMethod(
        minLevel: 81,
        maxLevel: 99,
        method: 'Dragon darts',
        xpPerHour: 1100000,
        accountMode: AccountMode.mainOnly,
        notes: 'Extremely expensive — fastest in game'),
    TrainingMethod(
        minLevel: 67,
        maxLevel: 99,
        method: 'Rune darts',
        xpPerHour: 700000,
        accountMode: AccountMode.mainOnly,
        notes: 'Expensive'),
  ], milestones: [
    SkillMilestone(10, 'Longbows'),
    SkillMilestone(20, 'Vale Totems (oak)'),
    SkillMilestone(25, 'Oak shortbow/longbow'),
    SkillMilestone(35, 'Vale Totems (willow)'),
    SkillMilestone(40, 'Willow longbow'),
    SkillMilestone(50, 'Vale Totems (maple)'),
    SkillMilestone(52, 'Broad arrows'),
    SkillMilestone(55, 'Maple longbow (u)'),
    SkillMilestone(65, 'Vale Totems (yew)'),
    SkillMilestone(70, 'Yew longbow (u)'),
    SkillMilestone(80, 'Vale Totems (magic)'),
    SkillMilestone(85, 'Magic longbow (u)'),
    SkillMilestone(90, 'Vale Totems (redwood) — best non-dart'),
    SkillMilestone(99, 'Fletching Cape'),
  ]),

  // ─── HERBLORE ──────────────────────────────────────────
  'Herblore': SkillTrainingInfo(skill: 'Herblore', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 2,
        method: 'Druidic Ritual quest',
        xpPerHour: 0,
        notes: 'Required to start Herblore'),
    TrainingMethod(
        minLevel: 3,
        maxLevel: 37,
        method: 'Attack/Energy potions',
        xpPerHour: 60000,
        accountMode: AccountMode.mainOnly,
        requiredItems: [
          'guam leaf',
          'harralander',
          'eye of newt',
          'chocolate dust'
        ]),
    TrainingMethod(
        minLevel: 3,
        maxLevel: 37,
        method: 'Quests + Kingdom herbs',
        xpPerHour: 20000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['guam leaf', 'marrentill', 'tarromin', 'harralander'],
        notes: 'Herbs from Farming/Kingdom'),
    TrainingMethod(
        minLevel: 38,
        maxLevel: 54,
        method: 'Prayer potions',
        xpPerHour: 120000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['ranarr', 'snape grass']),
    TrainingMethod(
        minLevel: 38,
        maxLevel: 54,
        method: 'Prayer pots (own ranarrs)',
        xpPerHour: 35000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['ranarr', 'snape grass'],
        notes: 'Farm ranarrs — limited by herb supply'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 77,
        method: 'Super restores',
        xpPerHour: 200000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['snapdragon', 'red spiders']),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 77,
        method: 'Super restores (own herbs)',
        xpPerHour: 50000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['snapdragon', 'red spiders'],
        notes: 'Farm snapegrass + snapdragon'),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 99,
        method: 'Mastering Mixology',
        xpPerHour: 120000,
        notes: 'Minigame — no herb cost, unique rewards'),
    TrainingMethod(
        minLevel: 78,
        maxLevel: 99,
        method: 'Saradomin Brews / Super combats',
        xpPerHour: 350000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['toadflax', 'torstol', 'crushed nest']),
    TrainingMethod(
        minLevel: 78,
        maxLevel: 99,
        method: 'Whatever herbs available',
        xpPerHour: 60000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: [
          'toadflax',
          'snapdragon',
          'torstol',
          'ranarr',
          'kwuarm',
          'cadantine',
          'lantadyme',
          'dwarf weed'
        ],
        notes: 'Limited by herb supply from Farming/Slayer'),
  ], milestones: [
    SkillMilestone(5, 'Attack potions'),
    SkillMilestone(25, 'Energy potions'),
    SkillMilestone(38, 'Prayer potions'),
    SkillMilestone(45, 'Super attack potions'),
    SkillMilestone(55, 'Super restores'),
    SkillMilestone(63, 'Super defence'),
    SkillMilestone(69, 'Antifire potions'),
    SkillMilestone(72, 'Ranging potion'),
    SkillMilestone(78, 'Super Combat — essential PvM'),
    SkillMilestone(81, 'Stamina potions'),
    SkillMilestone(90, 'NMZ Overloads'),
    SkillMilestone(99, 'Herblore Cape'),
  ]),

  // ─── AGILITY ───────────────────────────────────────────
  'Agility': SkillTrainingInfo(skill: 'Agility', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 32,
        method: 'Quests (Tourist Trap etc.)',
        xpPerHour: 0,
        notes: 'Tourist Trap alone → 26; all quests → 33'),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 9,
        method: 'Gnome Stronghold course',
        xpPerHour: 8000,
        sessionUnit: 'laps',
        sessionAmount: 50,
        xpPerAction: 86),
    TrainingMethod(
        minLevel: 10,
        maxLevel: 19,
        method: 'Draynor Village rooftop',
        xpPerHour: 9000,
        sessionUnit: 'laps',
        sessionAmount: 50,
        xpPerAction: 120),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 46,
        method: 'Brimhaven Agility Arena',
        xpPerHour: 45000,
        notes: 'Floor spikes + pillar tagging — fastest pre-Wilderness'),
    TrainingMethod(
        minLevel: 20,
        maxLevel: 29,
        method: 'Al Kharid rooftop',
        xpPerHour: 10000,
        intensity: Intensity.afk,
        sessionUnit: 'laps',
        sessionAmount: 50,
        xpPerAction: 180),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 39,
        method: 'Varrock rooftop',
        xpPerHour: 13000,
        sessionUnit: 'laps',
        sessionAmount: 50,
        xpPerAction: 238),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 47,
        method: 'Canifis rooftop',
        xpPerHour: 19000,
        notes: 'Farm Marks of Grace for Graceful',
        sessionUnit: 'laps',
        sessionAmount: 100,
        xpPerAction: 240),
    TrainingMethod(
        minLevel: 52,
        maxLevel: 61,
        method: 'Wilderness Agility Course',
        xpPerHour: 55000,
        notes: 'Fastest 52-62 — Wilderness risk'),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 79,
        method: 'Seers\' Village rooftop',
        xpPerHour: 45000,
        intensity: Intensity.afk,
        notes: 'With Kandarin Hard diary teleport',
        sessionUnit: 'laps',
        sessionAmount: 100,
        xpPerAction: 570),
    TrainingMethod(
        minLevel: 62,
        maxLevel: 79,
        method: 'Colossal Wyrm (advanced)',
        xpPerHour: 41000,
        intensity: Intensity.afk,
        notes: 'Very low-click — 6 clicks/lap, bonus marks'),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 79,
        method: 'Werewolf Agility Course',
        xpPerHour: 55000,
        notes: 'Decent XP + marks of grace'),
    TrainingMethod(
        minLevel: 62,
        maxLevel: 99,
        method: 'Hallowed Sepulchre',
        xpPerHour: 70000,
        notes: 'Fastest from 62 — scales to 105k/hr at 92+'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 89,
        method: 'Pollnivneach rooftop',
        xpPerHour: 50000,
        intensity: Intensity.afk,
        sessionUnit: 'laps',
        sessionAmount: 100,
        xpPerAction: 890),
    TrainingMethod(
        minLevel: 75,
        maxLevel: 99,
        method: 'Prifddinas Agility Course',
        xpPerHour: 62000,
        intensity: Intensity.afk,
        notes: 'Song of the Elves req — crystal shards'),
    TrainingMethod(
        minLevel: 80,
        maxLevel: 99,
        method: 'Rellekka rooftop',
        xpPerHour: 52000,
        intensity: Intensity.afk,
        sessionUnit: 'laps',
        sessionAmount: 100,
        xpPerAction: 780),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: 'Ardougne rooftop',
        xpPerHour: 60000,
        intensity: Intensity.afk,
        sessionUnit: 'laps',
        sessionAmount: 100,
        xpPerAction: 793),
    TrainingMethod(
        minLevel: 92,
        maxLevel: 99,
        method: 'Hallowed Sepulchre (floor 5)',
        xpPerHour: 105000,
        notes: 'Best Agility XP + Ring of Endurance + GP'),
  ], milestones: [
    SkillMilestone(10, 'Draynor Village rooftop'),
    SkillMilestone(20, 'Al Kharid rooftop'),
    SkillMilestone(30, 'Varrock rooftop'),
    SkillMilestone(40, 'Canifis rooftop — farm Graceful'),
    SkillMilestone(52, 'Hallowed Sepulchre access'),
    SkillMilestone(60, 'Seers\' Village rooftop, Full Graceful'),
    SkillMilestone(62, 'Hallowed Sepulchre — fastest from here'),
    SkillMilestone(70, 'Pollnivneach rooftop'),
    SkillMilestone(75, 'Prifddinas course'),
    SkillMilestone(80, 'Rellekka rooftop'),
    SkillMilestone(90, 'Ardougne rooftop'),
    SkillMilestone(92, 'Hallowed Sepulchre floor 5 — 105k/hr'),
    SkillMilestone(99, 'Agility Cape — stamina restore'),
  ]),

  // ─── THIEVING ──────────────────────────────────────────
  'Thieving': SkillTrainingInfo(skill: 'Thieving', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 4,
        method: 'Pickpocket Men/Women',
        xpPerHour: 5000),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 42,
        method: 'Quests',
        xpPerHour: 0,
        notes: 'Can reach 42 from quests'),
    TrainingMethod(
        minLevel: 5,
        maxLevel: 24,
        method: 'Cake stalls',
        xpPerHour: 15000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 25,
        maxLevel: 44,
        method: 'Fruit stalls (Hosidius)',
        xpPerHour: 40000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 36,
        maxLevel: 49,
        method: 'Aldarin Villa chests',
        xpPerHour: 80000,
        notes: 'Fast early Thieving'),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 37,
        method: 'HAM members',
        xpPerHour: 15000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Easy clue scrolls + jewellery for teleports. Wear full HAM robes to reduce kick rate. Early ironman essential.'),
    TrainingMethod(
        minLevel: 38,
        maxLevel: 54,
        method: 'Master Farmer',
        xpPerHour: 50000,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Herb seeds for Farming — essential',
        sessionUnit: 'pickpockets',
        sessionAmount: 200,
        xpPerAction: 43),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 93,
        method: 'Master Farmer (with Rogue\'s outfit)',
        xpPerHour: 65000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Double loot with Rogue\'s outfit. Ranarr/Snapdragon seeds are huge. Do between Slayer tasks.'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 64,
        method: 'Blackjacking',
        xpPerHour: 180000,
        notes: 'Very click-intensive — fastest mid-level'),
    TrainingMethod(
        minLevel: 49,
        maxLevel: 84,
        method: 'Stealing Artefacts',
        xpPerHour: 210000,
        notes: 'Port Piscarilius — fastest 49-84'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 99,
        method: 'Knights of Ardougne',
        xpPerHour: 230000,
        intensity: Intensity.afk,
        notes: 'Splashing knight method — very AFK'),
    TrainingMethod(
        minLevel: 82,
        maxLevel: 90,
        method: 'Vyre pickpocketing',
        xpPerHour: 150000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Blood shards + good XP'),
    TrainingMethod(
        minLevel: 84,
        maxLevel: 99,
        method: 'Rogues\' Castle chests',
        xpPerHour: 290000,
        notes: 'Wilderness — fastest 84+ with Rogue\'s outfit'),
    TrainingMethod(
        minLevel: 91,
        maxLevel: 99,
        method: 'Pyramid Plunder',
        xpPerHour: 270000,
        notes: 'Good at 91+ for pharaoh\'s sceptre'),
    TrainingMethod(
        minLevel: 91,
        maxLevel: 99,
        method: 'Pickpocket Elves (Prif)',
        xpPerHour: 250000,
        intensity: Intensity.afk,
        notes: 'Song of the Elves req — great GP + shards',
        sessionUnit: 'pickpockets',
        sessionAmount: 500,
        xpPerAction: 353),
  ], milestones: [
    SkillMilestone(5, 'Cake stalls'),
    SkillMilestone(25, 'Fruit stalls (Hosidius)'),
    SkillMilestone(38, 'Master Farmer — herb seeds'),
    SkillMilestone(45, 'Blackjacking'),
    SkillMilestone(49, 'Stealing Artefacts'),
    SkillMilestone(55, 'Knights of Ardougne + Rogues\' Outfit'),
    SkillMilestone(65, 'Stealing Valuables'),
    SkillMilestone(82, 'Vyre pickpocketing'),
    SkillMilestone(84, 'Rogues\' Castle chests'),
    SkillMilestone(91, 'Elf pickpocketing / Pyramid Plunder'),
    SkillMilestone(99, 'Thieving Cape'),
  ]),

  // ─── SLAYER ────────────────────────────────────────────
  'Slayer': SkillTrainingInfo(skill: 'Slayer', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 9,
        method: 'Turael tasks',
        xpPerHour: 5000,
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 1000),
    TrainingMethod(
        minLevel: 10,
        maxLevel: 39,
        method: 'Turael/Mazchna tasks',
        xpPerHour: 10000,
        notes: 'Slow — build Slayer points',
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 3000),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 54,
        method: 'Vannaka tasks',
        xpPerHour: 18000,
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 5000),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 54,
        method: 'Vannaka + cannon',
        xpPerHour: 30000,
        accountMode: AccountMode.mainOnly,
        notes: 'Buy cannonballs from GE'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'Nieve tasks',
        xpPerHour: 25000,
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 8000),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 69,
        method: 'Nieve + cannon + burst',
        xpPerHour: 40000,
        accountMode: AccountMode.mainOnly),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 84,
        method: 'Duradel tasks (burst/barrage)',
        xpPerHour: 35000,
        notes: 'Barrage Dust Devils, Nechs',
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 12000),
    TrainingMethod(
        minLevel: 85,
        maxLevel: 99,
        method: 'Duradel efficient (skip bad tasks)',
        xpPerHour: 50000,
        notes: 'Block bad tasks, burst/barrage burst tasks',
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 15000),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 69,
        method: 'Point boosting (9 Turael + 10th Nieve)',
        xpPerHour: 12000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Do 9 quick tasks at Turael, then 10th at Nieve/Duradel for bonus Slayer points. Essential for unlocking Slayer helm, blocks, extends.',
        sessionUnit: 'rotations',
        sessionAmount: 3,
        xpPerAction: 8000),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 69,
        method: 'Vannaka + self-made cannonballs',
        xpPerHour: 22000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Smith steel bars into cannonballs at Blast Furnace. Cannon Kalphites, Dagannoths. Slower supply than mains.'),
    TrainingMethod(
        minLevel: 70,
        maxLevel: 99,
        method: 'Duradel (ironman efficient)',
        xpPerHour: 35000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Burst over barrage to conserve runes. Self-made cannonballs for cannon tasks. Block/skip bad tasks. Prioritise Nechs, Dust Devils, Abby Demons.',
        sessionUnit: 'tasks',
        sessionAmount: 5,
        xpPerAction: 12000),
  ], milestones: [
    SkillMilestone(5, 'Crawling Hands'),
    SkillMilestone(15, 'Banshees'),
    SkillMilestone(35, 'Pyrefiends'),
    SkillMilestone(40, 'Bloodveld'),
    SkillMilestone(50, 'Broad arrows/bolts'),
    SkillMilestone(55, 'Slayer Helm'),
    SkillMilestone(58, 'Cave Horrors (Black mask)'),
    SkillMilestone(65, 'Dust Devils — burst/barrage'),
    SkillMilestone(70, 'Kurask'),
    SkillMilestone(72, 'Skeletal Wyverns'),
    SkillMilestone(75, 'Gargoyles — great GP'),
    SkillMilestone(80, 'Nechryaels — burst profit'),
    SkillMilestone(85, 'Abyssal Demons'),
    SkillMilestone(87, 'Kraken boss'),
    SkillMilestone(91, 'Cerberus — Primordial boots'),
    SkillMilestone(93, 'Thermonuclear Smoke Devil'),
    SkillMilestone(95, 'Alchemical Hydra — 3-4M/hr'),
    SkillMilestone(99, 'Slayer Cape'),
  ]),

  // ─── FARMING ───────────────────────────────────────────
  'Farming': SkillTrainingInfo(skill: 'Farming', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 14,
        method: 'Quests (Fairy Tale I)',
        xpPerHour: 0,
        notes: 'Quest XP skips early levels'),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 31,
        method: 'Tree + Allotment runs',
        xpPerHour: 30000,
        intensity: Intensity.afk,
        notes: 'Do runs every few hours'),
    TrainingMethod(
        minLevel: 32,
        maxLevel: 44,
        method: 'Tree + Fruit tree runs',
        xpPerHour: 60000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 32,
        maxLevel: 99,
        method: 'Herb runs',
        xpPerHour: 15000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Essential ironman GP + Herblore supplies'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 59,
        method: 'Maple + Papaya runs',
        xpPerHour: 100000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 60,
        maxLevel: 74,
        method: 'Yew + Palm tree runs',
        xpPerHour: 150000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 75,
        maxLevel: 84,
        method: 'Magic + Dragonfruit runs',
        xpPerHour: 200000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 85,
        maxLevel: 99,
        method: 'Tree + Fruit + Special runs',
        xpPerHour: 300000,
        intensity: Intensity.afk,
        notes: 'Calquat, Celastrus, Redwood, Mahogany'),
    TrainingMethod(
        minLevel: 34,
        maxLevel: 99,
        method: 'Tithe Farm',
        xpPerHour: 90000,
        notes: 'Minigame — useful for seed box, auto-weed, Farmer outfit'),
    TrainingMethod(
        minLevel: 45,
        maxLevel: 99,
        method: 'Farming contracts',
        xpPerHour: 50000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Farming Guild contracts — essential seed source for ironmen. Do every run. Scales with level to give tree/herb seeds.'),
    TrainingMethod(
        minLevel: 23,
        maxLevel: 99,
        method: 'Giant seaweed runs',
        xpPerHour: 5000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Plant seaweed spores underwater (Fossil Island). Essential for Superglass Make → Crafting. Do alongside herb runs.'),
    TrainingMethod(
        minLevel: 35,
        maxLevel: 99,
        method: 'Hardwood tree patches',
        xpPerHour: 20000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Plant teak/mahogany in Fossil Island hardwood patches. Passive XP + Construction plank supply via Kingdom.'),
  ], milestones: [
    SkillMilestone(15, 'Trees plantable'),
    SkillMilestone(27, 'Fruit trees'),
    SkillMilestone(32, 'Ranarr herbs — ironman essential'),
    SkillMilestone(38, 'Toadflax herbs'),
    SkillMilestone(45, 'Maple + Papaya trees'),
    SkillMilestone(55, 'Mahogany trees'),
    SkillMilestone(60, 'Yew + Palm trees'),
    SkillMilestone(62, 'Snapdragon herbs'),
    SkillMilestone(72, 'Calquat tree'),
    SkillMilestone(75, 'Magic + Dragonfruit'),
    SkillMilestone(85, 'Celastrus, Farming Guild'),
    SkillMilestone(90, 'Redwood tree'),
    SkillMilestone(99, 'Farming Cape — teleport to Farming Guild'),
  ]),

  // ─── RUNECRAFT ─────────────────────────────────────────
  'Runecraft': SkillTrainingInfo(skill: 'Runecraft', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 22,
        method: 'Quests (Abyss miniquest)',
        xpPerHour: 0,
        notes: 'Skip early levels'),
    TrainingMethod(
        minLevel: 23,
        maxLevel: 76,
        method: 'Lava runes (Binding Neck)',
        xpPerHour: 62000,
        notes: 'Fastest RC — click-intensive, needs Magic Imbue at 82'),
    TrainingMethod(
        minLevel: 23,
        maxLevel: 49,
        method: 'Earth runes via Abyss',
        xpPerHour: 18000,
        intensity: Intensity.afk),
    TrainingMethod(
        minLevel: 27,
        maxLevel: 99,
        method: 'Guardians of the Rift',
        xpPerHour: 55000,
        notes: 'Minigame — good XP + runes + Raiments of the Eye'),
    TrainingMethod(
        minLevel: 44,
        maxLevel: 76,
        method: 'Ourania Altar (ZMI)',
        xpPerHour: 38000,
        intensity: Intensity.afk,
        notes: 'Good XP + random runes'),
    TrainingMethod(
        minLevel: 77,
        maxLevel: 89,
        method: 'Blood runes (Arceuus)',
        xpPerHour: 38000,
        intensity: Intensity.afk,
        notes: 'Very AFK + 400-500k GP/hr'),
    TrainingMethod(
        minLevel: 77,
        maxLevel: 99,
        method: 'Blood runes (Arceuus)',
        xpPerHour: 38000,
        intensity: Intensity.afk,
        accountMode: AccountMode.ironmanOnly,
        notes: 'Essential rune supply for ironman'),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: 'Soul runes (Arceuus)',
        xpPerHour: 46000,
        intensity: Intensity.afk,
        notes: 'AFK + decent GP'),
    TrainingMethod(
        minLevel: 90,
        maxLevel: 99,
        method: 'Aether runes',
        xpPerHour: 60000,
        notes: 'New — fastest non-lava method'),
    TrainingMethod(
        minLevel: 77,
        maxLevel: 99,
        method: 'Lava runes (with runners)',
        xpPerHour: 240000,
        accountMode: AccountMode.mainOnly,
        notes: 'Paid runners — extremely fast but costly'),
    TrainingMethod(
        minLevel: 27,
        maxLevel: 99,
        method: 'Guardians of the Rift (ironman)',
        xpPerHour: 50000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Essential rune supply: death, blood, law, nature runes. Raiments of the Eye set boosts rune yield 60%. Do this regularly.'),
    TrainingMethod(
        minLevel: 44,
        maxLevel: 76,
        method: 'Nature runes via Abyss',
        xpPerHour: 22000,
        accountMode: AccountMode.ironmanOnly,
        notes:
            'Craft nature runes for High Alchemy. Slow XP but essential supply for ironmen.'),
  ], milestones: [
    SkillMilestone(14, 'Cosmic runes'),
    SkillMilestone(23, 'Lava runes — fastest RC'),
    SkillMilestone(27, 'Guardians of the Rift'),
    SkillMilestone(35, 'Chaos runes'),
    SkillMilestone(44, 'Nature runes, ZMI altar'),
    SkillMilestone(54, 'Law runes'),
    SkillMilestone(59, 'Double cosmic runes'),
    SkillMilestone(65, 'Death runes'),
    SkillMilestone(77, 'Blood runes — AFK + GP'),
    SkillMilestone(82, 'GOTR efficient'),
    SkillMilestone(90, 'Soul runes, Aether runes'),
    SkillMilestone(95, 'Wrath runes'),
    SkillMilestone(99, 'Runecraft Cape'),
  ]),

  // ─── CONSTRUCTION ──────────────────────────────────────
  'Construction': SkillTrainingInfo(skill: 'Construction', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 18,
        method: 'Planks (Regular)',
        xpPerHour: 30000),
    TrainingMethod(
        minLevel: 19,
        maxLevel: 32,
        method: 'Oak furniture',
        xpPerHour: 200000,
        requiredItems: ['oak plank'],
        sessionUnit: 'planks',
        sessionAmount: 500,
        xpPerAction: 60),
    TrainingMethod(
        minLevel: 33,
        maxLevel: 51,
        method: 'Oak Larders',
        xpPerHour: 280000,
        requiredItems: ['oak plank'],
        sessionUnit: 'planks',
        sessionAmount: 500,
        xpPerAction: 60),
    TrainingMethod(
        minLevel: 52,
        maxLevel: 99,
        method: 'Mahogany Tables (GE planks)',
        xpPerHour: 600000,
        accountMode: AccountMode.mainOnly,
        requiredItems: ['mahogany plank'],
        notes: 'Buy planks from GE — fastest Construction',
        xpPerAction: 140),
    TrainingMethod(
        minLevel: 47,
        maxLevel: 99,
        method: 'Mounted Mythical Capes (teak)',
        xpPerHour: 400000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['teak plank'],
        notes: 'Teak planks from Kingdom/Plank Make',
        xpPerAction: 123),
    TrainingMethod(
        minLevel: 52,
        maxLevel: 99,
        method: 'Oak Dungeon Doors',
        xpPerHour: 350000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['oak plank'],
        notes: 'Oak planks — cheaper than mahogany',
        xpPerAction: 60),
    TrainingMethod(
        minLevel: 52,
        maxLevel: 99,
        method: 'Mahogany Tables (own planks)',
        xpPerHour: 350000,
        accountMode: AccountMode.ironmanOnly,
        requiredItems: ['mahogany plank'],
        notes: 'Plank Make spell + Kingdom mahogany',
        xpPerAction: 140),
    TrainingMethod(
        minLevel: 1,
        maxLevel: 99,
        method: 'Mahogany Homes',
        xpPerHour: 150000,
        intensity: Intensity.afk,
        notes: 'Contracts — slower but cheaper + GP'),
  ], milestones: [
    SkillMilestone(20, 'Workshop, Study room'),
    SkillMilestone(30, 'Oak Larder'),
    SkillMilestone(47, 'Mounted Mythical Cape'),
    SkillMilestone(50, 'Portal rooms, Quest hall'),
    SkillMilestone(52, 'Mahogany tables'),
    SkillMilestone(65, 'Mounted Glory'),
    SkillMilestone(75, 'Gilded Altar, Rejuvenation pool (boost)'),
    SkillMilestone(80, 'Ornate Rejuvenation Pool (boost)'),
    SkillMilestone(82, 'Fairy ring in POH'),
    SkillMilestone(83, 'Ornate Jewellery Box (boost)'),
    SkillMilestone(84, 'Spirit tree in POH'),
    SkillMilestone(90, 'Occult Altar'),
    SkillMilestone(99, 'Construction Cape — POH teleport'),
  ]),

  // ─── SAILING ────────────────────────────────────────
  'Sailing': SkillTrainingInfo(skill: 'Sailing', methods: [
    TrainingMethod(
        minLevel: 1,
        maxLevel: 11,
        method: 'Pandemonium quest + Courier tasks',
        xpPerHour: 10000,
        notes:
            'Complete Pandemonium quest, then courier tasks Port Sarim ↔ Pandemonium'),
    TrainingMethod(
        minLevel: 12,
        maxLevel: 29,
        method: 'Sea charting',
        xpPerHour: 10000,
        notes:
            'Explore oceans with spyglass + current duck — one-off XP rewards'),
    TrainingMethod(
        minLevel: 15,
        maxLevel: 41,
        method: 'Shipwreck salvaging',
        xpPerHour: 15000,
        intensity: Intensity.afk,
        notes: 'Low-intensity gathering — salvaging hooks on shipwrecks'),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 54,
        method: 'Barracuda Trials (Tempor Tantrum)',
        xpPerHour: 60000,
        notes: 'Obstacle course at sea — fastest from level 30'),
    TrainingMethod(
        minLevel: 30,
        maxLevel: 54,
        method: 'Bounty tasks',
        xpPerHour: 50000,
        notes: 'Kill sea monsters for bounty items — mid-tier XP'),
    TrainingMethod(
        minLevel: 42,
        maxLevel: 99,
        method: 'Shipwreck salvaging (with station)',
        xpPerHour: 40000,
        intensity: Intensity.afk,
        notes:
            'Salvaging station schematic from Chinchompa Island — much faster'),
    TrainingMethod(
        minLevel: 46,
        maxLevel: 54,
        method: 'Courier tasks (Summer Shore)',
        xpPerHour: 30000,
        notes: 'Deliver cargo to The Summer Shore — ~9 trips/hr'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 71,
        method: 'Barracuda Trials (Jubbly Jive)',
        xpPerHour: 100000,
        notes: 'Second trial — faster XP than Tempor Tantrum'),
    TrainingMethod(
        minLevel: 55,
        maxLevel: 71,
        method: 'Bounty tasks (optimised)',
        xpPerHour: 130000,
        notes: 'Focus on bird + ray tasks from Prifddinas/Rellekka'),
    TrainingMethod(
        minLevel: 62,
        maxLevel: 71,
        method: 'Courier tasks (Rellekka)',
        xpPerHour: 70000,
        notes: 'Aldarin/Sunset Coast → Rellekka — up to 90k/hr at 65+'),
    TrainingMethod(
        minLevel: 40,
        maxLevel: 99,
        method: 'Deep sea trawling',
        xpPerHour: 25000,
        intensity: Intensity.afk,
        notes: 'Hybrid Fishing + Sailing — trawl shoals with nets'),
    TrainingMethod(
        minLevel: 72,
        maxLevel: 92,
        method: 'Barracuda Trials (Gwenith Glide)',
        xpPerHour: 160000,
        notes: 'Third trial — best XP, requires Song of the Elves area'),
    TrainingMethod(
        minLevel: 67,
        maxLevel: 99,
        method: 'Bounty tasks (Deepfin Point)',
        xpPerHour: 200000,
        notes: 'Birds, rays, low-level sharks — up to 200k/hr BiS ship'),
    TrainingMethod(
        minLevel: 93,
        maxLevel: 99,
        method: 'Barracuda Trials (Gwenith Glide + Rosewood)',
        xpPerHour: 200000,
        notes:
            'Rosewood hull (93 Sailing, 84 Con) — 200k+/hr with crystal extractor'),
  ], milestones: [
    SkillMilestone(1, 'Pandemonium quest — get a raft'),
    SkillMilestone(12, 'Prying Times — crowbar for sea charting'),
    SkillMilestone(15, 'Skiff + Shipwreck salvaging'),
    SkillMilestone(22, 'Current Affairs — current duck for charting'),
    SkillMilestone(30, 'Barracuda Trials (Tempor Tantrum) + Bounty tasks'),
    SkillMilestone(31, 'Teak hull — faster boat'),
    SkillMilestone(38, 'Mermaid guide tasks'),
    SkillMilestone(42, 'Salvaging station schematic'),
    SkillMilestone(45, 'Troubled Tortugans quest'),
    SkillMilestone(55, 'Jubbly Jive trial + Teleport focus'),
    SkillMilestone(60, 'Sloop — larger boat with more facilities'),
    SkillMilestone(67, 'Deepfin Point bounties — best bounty XP'),
    SkillMilestone(72, 'Gwenith Glide trial — fastest Sailing XP'),
    SkillMilestone(73, 'Crystal extractor — passive 10-15k XP/hr'),
    SkillMilestone(93, 'Rosewood hull — 200k+/hr Gwenith Glide'),
    SkillMilestone(99, 'Sailing Cape'),
  ]),
};
