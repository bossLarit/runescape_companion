// ═══════════════════════════════════════════════════════════════════
//  SLAYER BLOCK LIST DATA
//  Recommended block/skip lists per slayer master based on
//  OSRS Wiki task weights and community meta (efficiency + profit).
// ═══════════════════════════════════════════════════════════════════

class SlayerMaster {
  final String name;
  final int combatReq;
  final int slayerReq;
  final String location;
  final int pointsPer;
  final int points10th;
  final int points50th;
  final List<SlayerTaskWeight> tasks;
  final List<String> recommendedBlocks;
  final List<String> recommendedSkips;
  final String blockNotes;

  const SlayerMaster({
    required this.name,
    required this.combatReq,
    this.slayerReq = 0,
    required this.location,
    required this.pointsPer,
    required this.points10th,
    required this.points50th,
    required this.tasks,
    required this.recommendedBlocks,
    this.recommendedSkips = const [],
    this.blockNotes = '',
  });

  int get totalWeight => tasks.fold(0, (sum, t) => sum + t.weight);
}

class SlayerTaskWeight {
  final String task;
  final int weight;
  final int slayerReq;
  final bool unlockable;
  final String? quest;

  /// Community rating: 'block', 'skip', 'do', 'prefer', 'boss'
  final String rating;
  final String? ratingNote;

  const SlayerTaskWeight({
    required this.task,
    required this.weight,
    this.slayerReq = 1,
    this.unlockable = false,
    this.quest,
    this.rating = 'do',
    this.ratingNote,
  });

  double chancePercent(int totalWeight) =>
      totalWeight > 0 ? (weight / totalWeight * 100) : 0;
}

// ─── Slayer Masters ─────────────────────────────────────────────

const List<SlayerMaster> slayerMasters = [
  _duradel,
  _nieve,
  _chaeldar,
  _konar,
];

// ═══════════════════════════════════════════════════════════════════
//  DURADEL  (Shilo Village — highest-level master)
// ═══════════════════════════════════════════════════════════════════
const _duradel = SlayerMaster(
  name: 'Duradel',
  combatReq: 100,
  slayerReq: 50,
  location: 'Shilo Village',
  pointsPer: 15,
  points10th: 75,
  points50th: 375,
  blockNotes: 'Block the highest-weight tasks you dislike. With 6 block slots, '
      'focus on tasks that are slow, unprofitable, and cannot be done '
      'as a boss variant. Turael-skippable tasks are better skipped than blocked.',
  recommendedBlocks: [
    'Spiritual creatures',
    'Black demons',
    'Hellhounds',
    'Greater demons',
    'Fire giants',
    'Drakes',
  ],
  recommendedSkips: [
    'Elves',
    'Red dragons',
    'Mutated Zygomites',
    'Fossil Island Wyverns',
    'Waterfiends',
    'Metal dragons',
    'Blue dragons',
  ],
  tasks: [
    SlayerTaskWeight(
      task: 'Abyssal demons',
      weight: 12,
      slayerReq: 85,
      rating: 'prefer',
      ratingNote: 'Barrage in Catacombs — excellent XP. One of the best tasks.',
    ),
    SlayerTaskWeight(
      task: 'Dark beasts',
      weight: 11,
      slayerReq: 90,
      rating: 'do',
      ratingNote: 'Good XP, can barrage. Decent task.',
    ),
    SlayerTaskWeight(
      task: 'Hellhounds',
      weight: 10,
      rating: 'block',
      ratingNote: 'No drops, slow melee. Only do if Cerberus (91 Slayer).',
    ),
    SlayerTaskWeight(
      task: 'Araxytes',
      weight: 10,
      slayerReq: 92,
      rating: 'prefer',
      ratingNote: 'Great drops from Araxxor boss variant.',
    ),
    SlayerTaskWeight(
      task: 'Lizardmen',
      weight: 10,
      unlockable: true,
      rating: 'do',
      ratingNote: 'Dragon warhammer from shamans — very profitable.',
    ),
    SlayerTaskWeight(
      task: 'TzHaar',
      weight: 10,
      unlockable: true,
      rating: 'prefer',
      ratingNote: 'Jad/Inferno tasks — huge XP bonus on completion.',
    ),
    SlayerTaskWeight(
      task: 'Black dragons',
      weight: 9,
      quest: 'Dragon Slayer I',
      rating: 'do',
      ratingNote: 'Do Vorkath for great profit. Skip if no DS2.',
    ),
    SlayerTaskWeight(
      task: 'Cave kraken',
      weight: 9,
      slayerReq: 87,
      rating: 'prefer',
      ratingNote: 'Very profitable and AFK. Great task.',
    ),
    SlayerTaskWeight(
      task: 'Dagannoth',
      weight: 9,
      rating: 'do',
      ratingNote: 'DK kings for rings, or cannon at lighthouse.',
    ),
    SlayerTaskWeight(
      task: 'Greater demons',
      weight: 9,
      rating: 'block',
      ratingNote: 'Slow unless doing K\'ril. Keep unblocked if bossing.',
    ),
    SlayerTaskWeight(
      task: 'Kalphite',
      weight: 9,
      rating: 'do',
      ratingNote: 'Fast cannon task. KQ for boss variant.',
    ),
    SlayerTaskWeight(
      task: 'Nechryael',
      weight: 9,
      slayerReq: 80,
      rating: 'prefer',
      ratingNote: 'Barrage in Catacombs — one of the best barrage tasks.',
    ),
    SlayerTaskWeight(
      task: 'Smoke devils',
      weight: 9,
      slayerReq: 93,
      rating: 'prefer',
      ratingNote: 'Barrage for excellent XP. Thermy for boss pet.',
    ),
    SlayerTaskWeight(
      task: 'Aviansie',
      weight: 8,
      unlockable: true,
      rating: 'do',
      ratingNote: 'Kree\'arra boss variant for Armadyl gear.',
    ),
    SlayerTaskWeight(
      task: 'Black demons',
      weight: 8,
      rating: 'block',
      ratingNote: 'Block unless doing Demonic gorillas for zenyte.',
    ),
    SlayerTaskWeight(
      task: 'Bloodveld',
      weight: 8,
      slayerReq: 50,
      rating: 'do',
      ratingNote: 'Fast in Catacombs. Can barrage or prayer-AFK.',
    ),
    SlayerTaskWeight(
      task: 'Custodian stalkers',
      weight: 8,
      slayerReq: 54,
      rating: 'do',
      ratingNote: 'New content — barrage or ranged. Good drops.',
    ),
    SlayerTaskWeight(
      task: 'Drakes',
      weight: 8,
      slayerReq: 84,
      rating: 'block',
      ratingNote: 'Slow, boring, mediocre drops. High weight — worth blocking.',
    ),
    SlayerTaskWeight(
      task: 'Gargoyles',
      weight: 8,
      slayerReq: 75,
      rating: 'do',
      ratingNote: 'Very profitable AFK task. Keep for money.',
    ),
    SlayerTaskWeight(
      task: 'Red dragons',
      weight: 8,
      unlockable: true,
      rating: 'skip',
      ratingNote: 'Low XP. Kill baby reds for fast completion.',
    ),
    SlayerTaskWeight(
      task: 'Suqah',
      weight: 8,
      rating: 'do',
      ratingNote: 'Fast cannon task on Lunar Isle.',
    ),
    SlayerTaskWeight(
      task: 'Vampyres',
      weight: 8,
      unlockable: true,
      rating: 'do',
      ratingNote: 'Vyrewatch Sentinels for blood shard — profitable.',
    ),
    SlayerTaskWeight(
      task: 'Wyrms',
      weight: 8,
      slayerReq: 62,
      rating: 'do',
      ratingNote: 'Decent drops (dragon items). AFK-able.',
    ),
    SlayerTaskWeight(
      task: 'Boss',
      weight: 8,
      unlockable: true,
      rating: 'prefer',
      ratingNote: 'Boss tasks are always worth doing for big drops.',
    ),
    SlayerTaskWeight(
      task: 'Aberrant spectres',
      weight: 7,
      slayerReq: 60,
      rating: 'do',
      ratingNote: 'Barrage in Catacombs for decent XP and herb drops.',
    ),
    SlayerTaskWeight(
      task: 'Basilisks',
      weight: 7,
      unlockable: true,
      rating: 'do',
      ratingNote: 'Basilisk jaw is valuable. Keep if you need it.',
    ),
    SlayerTaskWeight(
      task: 'Fire giants',
      weight: 7,
      rating: 'block',
      ratingNote: 'Slow, low XP, poor drops. High weight — block.',
    ),
    SlayerTaskWeight(
      task: 'Fossil Island Wyverns',
      weight: 7,
      slayerReq: 66,
      rating: 'skip',
      ratingNote: 'Slow, annoying. Skip or block if out of slots.',
    ),
    SlayerTaskWeight(
      task: 'Skeletal Wyverns',
      weight: 7,
      slayerReq: 72,
      rating: 'skip',
      ratingNote: 'Slow ranged task. Skip unless you enjoy them.',
    ),
    SlayerTaskWeight(
      task: 'Spiritual creatures',
      weight: 7,
      slayerReq: 63,
      rating: 'block',
      ratingNote: 'Boring GWD task. High weight — always block.',
    ),
    SlayerTaskWeight(
      task: 'Trolls',
      weight: 6,
      rating: 'do',
      ratingNote: 'Fast cannon task (ice trolls on Jatizso).',
    ),
    SlayerTaskWeight(
      task: 'Ankou',
      weight: 5,
      rating: 'do',
      ratingNote: 'Decent in Catacombs with prayer.',
    ),
    SlayerTaskWeight(
      task: 'Dust devils',
      weight: 5,
      slayerReq: 65,
      rating: 'prefer',
      ratingNote: 'Barrage in Catacombs — one of the best XP tasks.',
    ),
    SlayerTaskWeight(
      task: 'Frost dragons',
      weight: 5,
      rating: 'do',
      ratingNote: 'Requires Sailing. Good profit if accessible.',
    ),
    SlayerTaskWeight(
      task: 'Gryphons',
      weight: 5,
      rating: 'do',
      ratingNote: 'New content from Troubled Tortugans.',
    ),
    SlayerTaskWeight(
      task: 'Warped creatures',
      weight: 5,
      unlockable: true,
      slayerReq: 56,
      rating: 'do',
      ratingNote: 'Warped sceptre is a decent drop.',
    ),
    SlayerTaskWeight(
      task: 'Blue dragons',
      weight: 4,
      rating: 'skip',
      ratingNote: 'Slow unless doing Vorkath. Skip if no DS2.',
    ),
    SlayerTaskWeight(
      task: 'Cave horrors',
      weight: 4,
      slayerReq: 58,
      rating: 'do',
      ratingNote: 'Black mask drop. Decent task.',
    ),
    SlayerTaskWeight(
      task: 'Elves',
      weight: 4,
      rating: 'skip',
      ratingNote: 'Long task. Skip unless crystal shard farming.',
    ),
    SlayerTaskWeight(
      task: 'Kurask',
      weight: 4,
      slayerReq: 70,
      rating: 'do',
      ratingNote: 'Decent AFK task with leaf-bladed battleaxe.',
    ),
    SlayerTaskWeight(
      task: 'Metal dragons',
      weight: 4,
      rating: 'skip',
      ratingNote: 'Slow without DHCB. Skip.',
    ),
    SlayerTaskWeight(
      task: 'Aquanites',
      weight: 2,
      slayerReq: 78,
      unlockable: true,
      rating: 'do',
      ratingNote: 'New task. Low weight.',
    ),
    SlayerTaskWeight(
      task: 'Mutated Zygomites',
      weight: 2,
      slayerReq: 57,
      rating: 'skip',
      ratingNote: 'Annoying fungicide mechanic. Skip.',
    ),
    SlayerTaskWeight(
      task: 'Waterfiends',
      weight: 2,
      rating: 'skip',
      ratingNote: 'Low weight, low drops. Skip.',
    ),
  ],
);

// ═══════════════════════════════════════════════════════════════════
//  NIEVE / STEVE  (Tree Gnome Stronghold)
// ═══════════════════════════════════════════════════════════════════
const _nieve = SlayerMaster(
  name: 'Nieve / Steve',
  combatReq: 85,
  location: 'Tree Gnome Stronghold',
  pointsPer: 12,
  points10th: 60,
  points50th: 300,
  blockNotes: 'Similar blocks to Duradel but lower weights. '
      'Nieve has more low-level filler tasks. '
      'Block high-weight tasks you dislike and turael-skip the rest.',
  recommendedBlocks: [
    'Spiritual creatures',
    'Fire giants',
    'Hellhounds',
    'Greater demons',
    'Black demons',
    'Drakes',
  ],
  recommendedSkips: [
    'Elves',
    'Metal dragons',
    'Blue dragons',
    'Fossil Island Wyverns',
    'Mutated Zygomites',
  ],
  tasks: [
    SlayerTaskWeight(
        task: 'Abyssal demons',
        weight: 12,
        slayerReq: 85,
        rating: 'prefer',
        ratingNote: 'Barrage in Catacombs — best XP task.'),
    SlayerTaskWeight(
        task: 'Cave kraken',
        weight: 9,
        slayerReq: 87,
        rating: 'prefer',
        ratingNote: 'Very profitable and AFK.'),
    SlayerTaskWeight(
        task: 'Hellhounds',
        weight: 8,
        rating: 'block',
        ratingNote: 'No drops, slow. Only do for Cerberus.'),
    SlayerTaskWeight(
        task: 'Black demons',
        weight: 8,
        rating: 'block',
        ratingNote: 'Block unless gorillas for zenyte.'),
    SlayerTaskWeight(
        task: 'Greater demons',
        weight: 7,
        rating: 'block',
        ratingNote: 'Slow unless bossing K\'ril.'),
    SlayerTaskWeight(
        task: 'Bloodveld',
        weight: 8,
        slayerReq: 50,
        rating: 'do',
        ratingNote: 'Good in Catacombs with prayer.'),
    SlayerTaskWeight(
        task: 'Dagannoth',
        weight: 8,
        rating: 'do',
        ratingNote: 'DKs or cannon at lighthouse.'),
    SlayerTaskWeight(
        task: 'Fire giants',
        weight: 7,
        rating: 'block',
        ratingNote: 'Slow, low XP. Block.'),
    SlayerTaskWeight(
        task: 'Gargoyles',
        weight: 7,
        slayerReq: 75,
        rating: 'do',
        ratingNote: 'Profitable AFK. Keep for money.'),
    SlayerTaskWeight(
        task: 'Kalphite',
        weight: 9,
        rating: 'do',
        ratingNote: 'Fast cannon task.'),
    SlayerTaskWeight(
        task: 'Trolls',
        weight: 6,
        rating: 'do',
        ratingNote: 'Fast cannon task.'),
    SlayerTaskWeight(
        task: 'Nechryael',
        weight: 7,
        slayerReq: 80,
        rating: 'prefer',
        ratingNote: 'Barrage in Catacombs.'),
    SlayerTaskWeight(
        task: 'Spiritual creatures',
        weight: 6,
        slayerReq: 63,
        rating: 'block',
        ratingNote: 'Boring GWD task. Block.'),
    SlayerTaskWeight(
        task: 'Dust devils',
        weight: 6,
        slayerReq: 65,
        rating: 'prefer',
        ratingNote: 'Barrage in Catacombs.'),
    SlayerTaskWeight(
        task: 'Aberrant spectres',
        weight: 6,
        slayerReq: 60,
        rating: 'do',
        ratingNote: 'Barrage or melee. Decent.'),
    SlayerTaskWeight(
        task: 'Suqah',
        weight: 8,
        rating: 'do',
        ratingNote: 'Fast cannon task.'),
    SlayerTaskWeight(
        task: 'Ankou',
        weight: 5,
        rating: 'do',
        ratingNote: 'Decent in Catacombs.'),
    SlayerTaskWeight(
        task: 'Black dragons',
        weight: 6,
        rating: 'do',
        ratingNote: 'Vorkath or baby blacks.'),
    SlayerTaskWeight(
        task: 'Drakes',
        weight: 7,
        slayerReq: 84,
        rating: 'block',
        ratingNote: 'Slow and boring. Block.'),
    SlayerTaskWeight(
        task: 'Wyrms',
        weight: 7,
        slayerReq: 62,
        rating: 'do',
        ratingNote: 'Decent AFK melee.'),
    SlayerTaskWeight(
        task: 'Cave horrors',
        weight: 5,
        slayerReq: 58,
        rating: 'do',
        ratingNote: 'Black mask drop.'),
    SlayerTaskWeight(
        task: 'Kurask',
        weight: 3,
        slayerReq: 70,
        rating: 'do',
        ratingNote: 'Decent AFK.'),
    SlayerTaskWeight(
        task: 'Blue dragons',
        weight: 4,
        rating: 'skip',
        ratingNote: 'Slow unless Vorkath.'),
    SlayerTaskWeight(
        task: 'Elves', weight: 4, rating: 'skip', ratingNote: 'Long task.'),
    SlayerTaskWeight(
        task: 'Metal dragons',
        weight: 4,
        rating: 'skip',
        ratingNote: 'Slow without DHCB.'),
    SlayerTaskWeight(
        task: 'Fossil Island Wyverns',
        weight: 5,
        slayerReq: 66,
        rating: 'skip',
        ratingNote: 'Slow.'),
    SlayerTaskWeight(
        task: 'Mutated Zygomites',
        weight: 2,
        slayerReq: 57,
        rating: 'skip',
        ratingNote: 'Fungicide mechanic. Skip.'),
  ],
);

// ═══════════════════════════════════════════════════════════════════
//  KONAR  (Mount Karuulm — location-locked tasks)
// ═══════════════════════════════════════════════════════════════════
const _konar = SlayerMaster(
  name: 'Konar',
  combatReq: 75,
  location: 'Mount Karuulm',
  pointsPer: 18,
  points10th: 90,
  points50th: 450,
  blockNotes: 'Konar assigns location-specific tasks with Brimstone key drops. '
      'Higher points than Duradel. Good for point boosting on milestone tasks. '
      'Block high-weight tasks sent to bad locations. '
      'Tasks here are less skippable due to location locks.',
  recommendedBlocks: [
    'Spiritual creatures',
    'Black demons',
    'Fire giants',
    'Drakes',
    'Hellhounds',
    'Greater demons',
  ],
  recommendedSkips: [
    'Metal dragons',
    'Blue dragons',
    'Fossil Island Wyverns',
    'Red dragons',
  ],
  tasks: [
    SlayerTaskWeight(
        task: 'Abyssal demons',
        weight: 9,
        slayerReq: 85,
        rating: 'prefer',
        ratingNote: 'Barrage wherever assigned.'),
    SlayerTaskWeight(
        task: 'Hellhounds',
        weight: 8,
        rating: 'block',
        ratingNote: 'Location lock makes it worse.'),
    SlayerTaskWeight(
        task: 'Black demons',
        weight: 8,
        rating: 'block',
        ratingNote: 'Location lock often bad.'),
    SlayerTaskWeight(
        task: 'Dagannoth',
        weight: 8,
        rating: 'do',
        ratingNote: 'DKs if sent to Waterbirth.'),
    SlayerTaskWeight(
        task: 'Greater demons',
        weight: 8,
        rating: 'block',
        ratingNote: 'Location lock often bad.'),
    SlayerTaskWeight(
        task: 'Bloodveld',
        weight: 7,
        slayerReq: 50,
        rating: 'do',
        ratingNote: 'Good wherever.'),
    SlayerTaskWeight(
        task: 'Drakes',
        weight: 8,
        slayerReq: 84,
        rating: 'block',
        ratingNote: 'Slow task.'),
    SlayerTaskWeight(
        task: 'Fire giants', weight: 7, rating: 'block', ratingNote: 'Slow.'),
    SlayerTaskWeight(
        task: 'Gargoyles',
        weight: 6,
        slayerReq: 75,
        rating: 'do',
        ratingNote: 'Profitable.'),
    SlayerTaskWeight(
        task: 'Nechryael',
        weight: 7,
        slayerReq: 80,
        rating: 'prefer',
        ratingNote: 'Barrage wherever sent.'),
    SlayerTaskWeight(
        task: 'Dust devils',
        weight: 6,
        slayerReq: 65,
        rating: 'prefer',
        ratingNote: 'Barrage wherever sent.'),
    SlayerTaskWeight(
        task: 'Wyrms',
        weight: 8,
        slayerReq: 62,
        rating: 'do',
        ratingNote: 'Brimstone key drops help.'),
    SlayerTaskWeight(
        task: 'Spiritual creatures',
        weight: 6,
        slayerReq: 63,
        rating: 'block',
        ratingNote: 'Boring. Block.'),
    SlayerTaskWeight(
        task: 'Trolls',
        weight: 6,
        rating: 'do',
        ratingNote: 'Fast if good location.'),
    SlayerTaskWeight(
        task: 'Kalphite', weight: 6, rating: 'do', ratingNote: 'OK task.'),
    SlayerTaskWeight(
        task: 'Blue dragons', weight: 4, rating: 'skip', ratingNote: 'Slow.'),
    SlayerTaskWeight(
        task: 'Metal dragons', weight: 4, rating: 'skip', ratingNote: 'Slow.'),
    SlayerTaskWeight(
        task: 'Red dragons', weight: 5, rating: 'skip', ratingNote: 'Low XP.'),
    SlayerTaskWeight(
        task: 'Fossil Island Wyverns',
        weight: 5,
        slayerReq: 66,
        rating: 'skip',
        ratingNote: 'Slow.'),
  ],
);

// ═══════════════════════════════════════════════════════════════════
//  CHAELDAR  (Zanaris — mid-level master)
// ═══════════════════════════════════════════════════════════════════
const _chaeldar = SlayerMaster(
  name: 'Chaeldar',
  combatReq: 70,
  location: 'Zanaris',
  pointsPer: 10,
  points10th: 50,
  points50th: 250,
  blockNotes: 'Mid-level master with many filler tasks. '
      'Block the worst high-weight tasks. '
      'Upgrade to Nieve/Duradel as soon as possible for better tasks and points.',
  recommendedBlocks: [
    'Spiritual creatures',
    'Fire giants',
    'Black demons',
    'Blue dragons',
    'Hellhounds',
    'Kalphite',
  ],
  recommendedSkips: [
    'Metal dragons',
    'Elves',
    'Fossil Island Wyverns',
  ],
  tasks: [
    SlayerTaskWeight(
        task: 'Aberrant spectres',
        weight: 8,
        slayerReq: 60,
        rating: 'do',
        ratingNote: 'Good herb drops.'),
    SlayerTaskWeight(
        task: 'Bloodveld',
        weight: 8,
        slayerReq: 50,
        rating: 'do',
        ratingNote: 'OK in Catacombs.'),
    SlayerTaskWeight(
        task: 'Cave kraken',
        weight: 12,
        slayerReq: 87,
        rating: 'prefer',
        ratingNote: 'Very profitable.'),
    SlayerTaskWeight(
        task: 'Dagannoth',
        weight: 8,
        rating: 'do',
        ratingNote: 'Cannon at lighthouse.'),
    SlayerTaskWeight(
        task: 'Fire giants',
        weight: 12,
        rating: 'block',
        ratingNote: 'Very high weight, slow. Block.'),
    SlayerTaskWeight(
        task: 'Gargoyles',
        weight: 10,
        slayerReq: 75,
        rating: 'do',
        ratingNote: 'Profitable.'),
    SlayerTaskWeight(
        task: 'Hellhounds',
        weight: 8,
        rating: 'block',
        ratingNote: 'No drops.'),
    SlayerTaskWeight(
        task: 'Kalphite',
        weight: 11,
        rating: 'block',
        ratingNote: 'High weight, can be annoying.'),
    SlayerTaskWeight(
        task: 'Black demons',
        weight: 8,
        rating: 'block',
        ratingNote: 'Slow task.'),
    SlayerTaskWeight(
        task: 'Blue dragons', weight: 8, rating: 'block', ratingNote: 'Slow.'),
    SlayerTaskWeight(
        task: 'Spiritual creatures',
        weight: 6,
        slayerReq: 63,
        rating: 'block',
        ratingNote: 'Block.'),
    SlayerTaskWeight(
        task: 'Metal dragons', weight: 2, rating: 'skip', ratingNote: 'Slow.'),
  ],
);
