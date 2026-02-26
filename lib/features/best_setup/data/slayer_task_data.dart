import '../../../core/services/osrs_api_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  SLAYER TASK DATA
//  Comprehensive slayer monster database with recommended gear per
//  slot, based on OSRS Wiki Slayer training guide & meta setups.
// ═══════════════════════════════════════════════════════════════════

/// How to kill this monster.
enum SlayerStyle { melee, ranged, magic, barrage, hybrid }

class SlayerMonster {
  final String name;
  final int slayerLevel;
  final SlayerStyle style;
  final bool canCannon;
  final bool canBarrage;
  final String location;
  final List<String> specialItems;
  final Map<String, List<String>> gearOverrides;
  final List<String> alternatives;
  final List<String> notableDrops;
  final String? notes;
  final String wikiPath;

  const SlayerMonster({
    required this.name,
    required this.slayerLevel,
    required this.style,
    this.canCannon = false,
    this.canBarrage = false,
    required this.location,
    this.specialItems = const [],
    this.gearOverrides = const {},
    this.alternatives = const [],
    this.notableDrops = const [],
    this.notes,
    required this.wikiPath,
  });

  /// Get the recommended gear for a slot. Uses override if present,
  /// otherwise falls back to the base template for this monster's style.
  List<String> gearForSlot(String slot) {
    if (gearOverrides.containsKey(slot)) return gearOverrides[slot]!;
    final base = _baseGear[style] ?? _baseGear[SlayerStyle.melee]!;
    return base[slot] ?? [];
  }

  /// All equipment slots relevant for this monster's loadout.
  List<String> get relevantSlots {
    final base = _baseGear[style] ?? _baseGear[SlayerStyle.melee]!;
    final allSlots = {...base.keys, ...gearOverrides.keys};
    // Return in canonical order
    return equipmentSlots.where((s) => allSlots.contains(s)).toList();
  }

  /// Find the best item the player owns for a given slot.
  String? bestOwnedForSlot(String slot, Set<String> bankItems) {
    final gear = gearForSlot(slot);
    for (final item in gear) {
      if (bankItems.contains(item.toLowerCase())) return item;
    }
    return null;
  }

  CombatStyle get combatStyle {
    switch (style) {
      case SlayerStyle.melee:
      case SlayerStyle.hybrid:
        return CombatStyle.melee;
      case SlayerStyle.ranged:
        return CombatStyle.ranged;
      case SlayerStyle.magic:
      case SlayerStyle.barrage:
        return CombatStyle.magic;
    }
  }
}

// ─── Base gear templates ─────────────────────────────────────────

const Map<SlayerStyle, Map<String, List<String>>> _baseGear = {
  SlayerStyle.melee: _meleeBase,
  SlayerStyle.ranged: _rangedBase,
  SlayerStyle.magic: _magicBase,
  SlayerStyle.barrage: _barrageBase,
  SlayerStyle.hybrid: _meleeBase,
};

const _meleeBase = <String, List<String>>{
  'head': [
    'Slayer helmet (i)',
    'Slayer helmet',
    'Black mask (i)',
    'Black mask',
    'Neitiznot faceguard',
    'Helm of neitiznot',
  ],
  'cape': [
    'Infernal cape',
    'Fire cape',
    'Mythical cape',
    'Ardougne cloak 4',
  ],
  'neck': [
    'Amulet of rancour',
    'Amulet of torture',
    'Amulet of fury',
    'Amulet of glory',
    'Amulet of strength',
  ],
  'body': [
    'Torva platebody',
    'Bandos chestplate',
    'Blood moon chestplate',
    'Fighter torso',
    'Proselyte hauberk',
    'Rune platebody',
  ],
  'legs': [
    'Torva platelegs',
    'Bandos tassets',
    'Blood moon tassets',
    'Obsidian platelegs',
    'Proselyte cuisse',
    'Rune platelegs',
  ],
  'weapon': [
    'Soulreaper axe',
    'Scythe of vitur',
    'Ghrazi rapier',
    'Blade of saeldor',
    'Abyssal tentacle',
    'Abyssal whip',
    'Dragon scimitar',
  ],
  'shield': [
    'Avernic defender',
    'Dragon defender',
    'Toktz-ket-xil',
  ],
  'hands': [
    'Ferocious gloves',
    'Barrows gloves',
    'Dragon gloves',
    'Regen bracelet',
    'Combat bracelet',
  ],
  'feet': [
    'Primordial boots',
    'Dragon boots',
    'Aranea boots',
    'Guardian boots',
    'Rune boots',
    'Climbing boots',
  ],
  'ring': [
    'Ultor ring',
    'Berserker ring (i)',
    'Berserker ring',
    'Brimstone ring',
    'Ring of wealth',
  ],
  'ammo': [
    "Rada's blessing 4",
    "Rada's blessing 3",
    'Holy blessing',
  ],
};

const _rangedBase = <String, List<String>>{
  'head': [
    'Slayer helmet (i)',
    'Slayer helmet',
    'Black mask (i)',
    'Black mask',
    'Masori mask (f)',
    'Masori mask',
    'Armadyl helmet',
  ],
  'cape': [
    "Ava's assembler",
    "Ava's accumulator",
    "Ava's attractor",
  ],
  'neck': [
    'Necklace of anguish',
    'Amulet of fury',
    'Amulet of glory',
  ],
  'body': [
    'Masori body (f)',
    'Masori body',
    'Armadyl chestplate',
    "Black d'hide body",
    "Red d'hide body",
  ],
  'legs': [
    'Masori chaps (f)',
    'Masori chaps',
    'Armadyl chainskirt',
    "Black d'hide chaps",
    "Red d'hide chaps",
  ],
  'weapon': [
    'Twisted bow',
    'Bow of faerdhinen',
    'Armadyl crossbow',
    'Dragon crossbow',
    'Rune crossbow',
    'Magic shortbow (i)',
  ],
  'shield': [
    'Twisted buckler',
    'Dragonfire ward',
    'Book of law',
    'Odium ward',
  ],
  'hands': [
    'Zaryte vambraces',
    'Barrows gloves',
    "Black d'hide vambraces",
  ],
  'feet': [
    'Pegasian boots',
    "Blessed d'hide boots",
    'Ranger boots',
    'Snakeskin boots',
  ],
  'ring': [
    'Venator ring',
    'Archers ring (i)',
    'Archers ring',
    'Brimstone ring',
    'Ring of wealth',
  ],
  'ammo': [
    'Ruby dragon bolts (e)',
    'Diamond dragon bolts (e)',
    'Broad bolts',
    'Amethyst arrows',
    'Rune arrows',
  ],
};

const _magicBase = <String, List<String>>{
  'head': [
    'Slayer helmet (i)',
    'Slayer helmet',
    'Black mask (i)',
    'Ancestral hat',
    'Ahrim\'s hood',
  ],
  'cape': [
    'Imbued saradomin cape',
    'Imbued guthix cape',
    'Imbued zamorak cape',
    'God cape',
  ],
  'neck': [
    'Occult necklace',
    'Amulet of fury',
    'Amulet of glory',
  ],
  'body': [
    'Ancestral robe top',
    'Ahrim\'s robetop',
    'Mystic robe top',
  ],
  'legs': [
    'Ancestral robe bottom',
    'Ahrim\'s robeskirt',
    'Mystic robe bottom',
  ],
  'weapon': [
    'Sanguinesti staff',
    'Trident of the swamp',
    'Trident of the seas',
    'Iban\'s staff',
  ],
  'shield': [
    'Arcane spirit shield',
    'Elidinis\' ward (f)',
    'Book of darkness',
    'Mage\'s book',
  ],
  'hands': [
    'Tormented bracelet',
    'Barrows gloves',
  ],
  'feet': [
    'Eternal boots',
    'Infinity boots',
    'Mystic boots',
  ],
  'ring': [
    'Magus ring',
    'Seers ring (i)',
    'Seers ring',
    'Brimstone ring',
  ],
  'ammo': [
    "Rada's blessing 4",
    "Rada's blessing 3",
  ],
};

const _barrageBase = <String, List<String>>{
  'head': [
    'Slayer helmet (i)',
    'Slayer helmet',
    'Black mask (i)',
    'Ancestral hat',
  ],
  'cape': [
    'Imbued saradomin cape',
    'Imbued guthix cape',
    'Imbued zamorak cape',
    'God cape',
  ],
  'neck': [
    'Occult necklace',
    'Amulet of fury',
  ],
  'body': [
    'Ancestral robe top',
    'Ahrim\'s robetop',
    'Mystic robe top',
    'Proselyte hauberk',
  ],
  'legs': [
    'Ancestral robe bottom',
    'Ahrim\'s robeskirt',
    'Mystic robe bottom',
    'Proselyte cuisse',
  ],
  'weapon': [
    'Kodai wand',
    'Master wand',
    'Ancient staff',
  ],
  'shield': [
    'Arcane spirit shield',
    'Elidinis\' ward (f)',
    'Book of darkness',
    'Mage\'s book',
    'Tome of fire',
  ],
  'hands': [
    'Tormented bracelet',
    'Barrows gloves',
  ],
  'feet': [
    'Eternal boots',
    'Infinity boots',
    'Mystic boots',
  ],
  'ring': [
    'Magus ring',
    'Seers ring (i)',
    'Brimstone ring',
  ],
  'ammo': [
    "Rada's blessing 4",
    "Rada's blessing 3",
  ],
};

// ─── Slayer monster database ────────────────────────────────────

const List<SlayerMonster> slayerMonsters = [
  // ── A ──
  SlayerMonster(
    name: 'Aberrant spectres',
    slayerLevel: 60,
    style: SlayerStyle.barrage,
    canBarrage: true,
    location: 'Catacombs of Kourend / Slayer Tower',
    specialItems: ['Nose peg (or Slayer helmet)'],
    notableDrops: ['Mystic robe top', 'Herb seeds'],
    notes:
        'Must wear nose peg or Slayer helmet for protection. Barrage in Catacombs for best XP. Can also melee in Slayer Tower.',
    wikiPath: 'Aberrant_spectre',
  ),
  SlayerMonster(
    name: 'Abyssal demons',
    slayerLevel: 85,
    style: SlayerStyle.barrage,
    canBarrage: true,
    location: 'Catacombs of Kourend / Slayer Tower',
    notableDrops: ['Abyssal whip', 'Abyssal dagger'],
    notes:
        'Barrage in Catacombs for fastest XP. Can melee in Slayer Tower rooftop with cannon for decent rates.',
    wikiPath: 'Abyssal_demon',
  ),
  SlayerMonster(
    name: 'Adamant dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Lithkren Vault',
    specialItems: ['Anti-dragon shield or Dragonfire ward'],
    gearOverrides: {
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
    },
    notableDrops: ['Dragon platelegs', 'Dragon plateskirt', 'Dragon limbs'],
    notes:
        'Dragon hunter crossbow is BiS here. Bring extended antifire + protect from magic.',
    wikiPath: 'Adamant_dragon',
  ),
  SlayerMonster(
    name: 'Ankou',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Stronghold of Security',
    gearOverrides: {
      'neck': [
        'Salve amulet(ei)',
        'Salve amulet (e)',
        'Salve amulet (i)',
        'Salve amulet',
        'Amulet of torture',
      ],
    },
    notableDrops: ['Blood rune', 'Death rune'],
    notes: 'Undead — Salve amulet works and stacks better than Slayer helm.',
    wikiPath: 'Ankou',
  ),
  SlayerMonster(
    name: 'Araxytes',
    slayerLevel: 92,
    style: SlayerStyle.melee,
    location: 'Araxyte Cave',
    notableDrops: ['Noxious halberd', 'Amulet of rancour (s)', 'Araxyte fang'],
    notes:
        'Kill Araxytes in the cave. Noxious halberd is a strong drop. Melee with best gear.',
    wikiPath: 'Araxyte',
  ),
  SlayerMonster(
    name: 'Aviansie',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'God Wars Dungeon / Armadyl area',
    alternatives: ["Kree'arra"],
    notableDrops: ['Adamantite bar', 'Noted limestones'],
    notes:
        'Must use Ranged or Magic — immune to Melee. Can do Kree\'arra as boss alternative.',
    wikiPath: 'Aviansie',
  ),

  // ── B ──
  SlayerMonster(
    name: 'Basilisk Knights',
    slayerLevel: 60,
    style: SlayerStyle.melee,
    location: 'Jormungand\'s Prison',
    specialItems: ["Mirror shield or V's shield"],
    gearOverrides: {
      'shield': [
        "V's shield",
        'Mirror shield',
      ],
    },
    notableDrops: ['Basilisk jaw'],
    notes:
        'Must wear mirror shield or V\'s shield. Basilisk jaw is valuable for Neitiznot faceguard. Requires Fremennik Exiles.',
    wikiPath: 'Basilisk_Knight',
  ),
  SlayerMonster(
    name: 'Black demons',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Taverley Dungeon',
    alternatives: ['Demonic gorillas', 'Skotizo'],
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Soulreaper axe',
        'Scythe of vitur',
        'Ghrazi rapier',
        'Abyssal whip',
      ],
    },
    notableDrops: ['Rune chainbody'],
    notes:
        'Arclight is BiS against demons. Most players do Demonic Gorillas instead for zenyte drops.',
    wikiPath: 'Black_demon',
  ),
  SlayerMonster(
    name: 'Black dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Taverley Dungeon / Evil Chicken\'s Lair',
    specialItems: ['Anti-dragon shield or Dragonfire ward'],
    gearOverrides: {
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
    },
    alternatives: ['King Black Dragon'],
    notableDrops: ['Draconic visage', 'Dragon platelegs'],
    notes:
        'Kill baby black dragons for fast tasks or KBD for boss KC. Anti-dragon shield required.',
    wikiPath: 'Black_dragon',
  ),
  SlayerMonster(
    name: 'Bloodveld',
    slayerLevel: 50,
    style: SlayerStyle.melee,
    canCannon: true,
    canBarrage: true,
    location: 'Catacombs of Kourend / Slayer Tower',
    notableDrops: ['Blood rune', 'Rune med helm'],
    notes:
        'Mutated bloodvelds in Catacombs are aggressive — good AFK with protect from melee. Can also barrage.',
    wikiPath: 'Bloodveld',
  ),
  SlayerMonster(
    name: 'Blue dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Taverley Dungeon / Myths\' Guild',
    specialItems: ['Anti-dragon shield or Dragonfire ward'],
    gearOverrides: {
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
    },
    alternatives: ['Vorkath'],
    notableDrops: ['Dragon bones', 'Blue dragonhide'],
    notes:
        'Most players do Vorkath instead if they have DS2 done. Otherwise kill baby blue dragons in Taverley.',
    wikiPath: 'Blue_dragon',
  ),

  // ── C ──
  SlayerMonster(
    name: 'Cave horrors',
    slayerLevel: 58,
    style: SlayerStyle.melee,
    location: 'Mos Le\'Harmless Cave',
    specialItems: ['Witchwood icon (or Slayer helmet)'],
    notableDrops: ['Black mask'],
    notes:
        'Witchwood icon or Slayer helmet required. Black mask is essential early drop for Slayer.',
    wikiPath: 'Cave_horror',
  ),
  SlayerMonster(
    name: 'Cave kraken',
    slayerLevel: 87,
    style: SlayerStyle.magic,
    location: 'Kraken Cove',
    alternatives: ['Kraken (boss)'],
    notableDrops: ['Trident of the seas'],
    notes:
        'Magic only — cannot be attacked with melee/ranged. Kill the Kraken boss variant for better drops.',
    wikiPath: 'Cave_kraken',
  ),
  SlayerMonster(
    name: 'Cerberus',
    slayerLevel: 91,
    style: SlayerStyle.melee,
    location: 'Cerberus\' Lair (Taverley Dungeon)',
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Soulreaper axe',
        'Ghrazi rapier',
        'Abyssal whip',
      ],
      'shield': [
        'Spectral spirit shield',
        'Avernic defender',
        'Dragon defender',
      ],
    },
    notableDrops: [
      'Primordial crystal',
      'Pegasian crystal',
      'Eternal crystal',
      'Smouldering stone',
    ],
    notes:
        'Arclight is BiS (demon). Spectral spirit shield reduces prayer drain from spectral attack. Requires 91 Slayer.',
    wikiPath: 'Cerberus',
  ),

  // ── D ──
  SlayerMonster(
    name: 'Dagannoth',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Lighthouse / Catacombs of Kourend',
    alternatives: ['Dagannoth Kings'],
    notableDrops: ['Dagannoth bones'],
    notes:
        'Cannon at Lighthouse for fast task. Can do DKs for berserker/archers/seers rings.',
    wikiPath: 'Dagannoth',
  ),
  SlayerMonster(
    name: 'Dark beasts',
    slayerLevel: 90,
    style: SlayerStyle.melee,
    canBarrage: true,
    location: 'Mourner Tunnels / Catacombs of Kourend',
    notableDrops: ['Dark bow'],
    notes:
        'Can melee or barrage. Mourner Tunnels after Song of the Elves, or Catacombs.',
    wikiPath: 'Dark_beast',
  ),
  SlayerMonster(
    name: 'Demonic gorillas',
    slayerLevel: 69,
    style: SlayerStyle.hybrid,
    location: 'Crash Site Cavern',
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Ghrazi rapier',
        'Abyssal tentacle',
        'Abyssal whip',
      ],
      'body': [
        'Karil\'s leathertop',
        'Black d\'hide body',
      ],
      'legs': [
        'Karil\'s leatherskirt',
        'Black d\'hide chaps',
      ],
    },
    notableDrops: [
      'Zenyte shard',
      'Ballista limbs',
      'Ballista spring',
      'Light frame',
      'Heavy frame',
    ],
    notes:
        'Hybrid switching — bring melee + ranged gear. Arclight is BiS for melee phase (demon). Very profitable.',
    wikiPath: 'Demonic_gorilla',
  ),
  SlayerMonster(
    name: 'Drakes',
    slayerLevel: 84,
    style: SlayerStyle.melee,
    location: 'Karuulm Slayer Dungeon',
    specialItems: ['Boots of stone/brimstone (or Granite boots)'],
    notableDrops: ['Drake\'s tooth', 'Drake\'s claw'],
    notes:
        'Need boots of stone/brimstone for the dungeon floor. Slow task but decent drops.',
    wikiPath: 'Drake',
  ),
  SlayerMonster(
    name: 'Dust devils',
    slayerLevel: 65,
    style: SlayerStyle.barrage,
    canBarrage: true,
    location: 'Catacombs of Kourend / Smoke Dungeon',
    specialItems: ['Facemask (or Slayer helmet)'],
    notableDrops: ['Dragon chainbody', 'Dust battlestaff'],
    notes:
        'Best XP barraging in Catacombs. One of the best barrage tasks. Stack them in multi-combat area.',
    wikiPath: 'Dust_devil',
  ),

  // ── E ──
  SlayerMonster(
    name: 'Elves',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    location: 'Iorwerth Dungeon (Prifddinas)',
    notableDrops: ['Crystal armour seed', 'Crystal weapon seed', 'Enhanced crystal key'],
    notes:
        'Requires Song of the Elves. Kill Iorwerth warriors in the dungeon. Good for crystal shards.',
    wikiPath: 'Slayer_task/Elves',
  ),

  // ── F ──
  SlayerMonster(
    name: 'Fire giants',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Waterfall Dungeon',
    notableDrops: ['Rune scimitar'],
    notes: 'Good cannon task in Waterfall Dungeon or melee in Catacombs.',
    wikiPath: 'Fire_giant',
  ),
  SlayerMonster(
    name: 'Fossil Island Wyverns',
    slayerLevel: 66,
    style: SlayerStyle.melee,
    location: 'Fossil Island Wyvern Cave',
    specialItems: ['Elemental shield / Mind shield / Dragonfire shield'],
    gearOverrides: {
      'shield': [
        'Dragonfire shield',
        'Ancient wyvern shield',
        'Elemental shield',
        'Mind shield',
      ],
    },
    notableDrops: ['Wyvern visage'],
    notes: 'Must have an elemental/mind/dragonfire shield equipped.',
    wikiPath: 'Fossil_Island_Wyvern',
  ),
  SlayerMonster(
    name: 'Frost dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Icy seas (Sailing)',
    specialItems: ['Anti-dragon shield'],
    gearOverrides: {
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
    },
    notableDrops: ['Draconic visage', 'Frost dragon bones'],
    notes: 'Requires Sailing. Dragon hunter crossbow recommended.',
    wikiPath: 'Frost_dragon',
  ),

  // ── G ──
  SlayerMonster(
    name: 'Gargoyles',
    slayerLevel: 75,
    style: SlayerStyle.melee,
    location: 'Slayer Tower (rooftop)',
    specialItems: ['Rock hammer (or Granite hammer)'],
    alternatives: ['Grotesque Guardians'],
    notableDrops: [
      'Granite maul',
      'Mystic robe top (dark)',
      'Gold bar (noted)',
    ],
    notes:
        'Bring rock hammer to finish them off (auto with Gargoyle smasher unlock). Very profitable AFK task.',
    wikiPath: 'Gargoyle',
  ),
  SlayerMonster(
    name: 'Greater demons',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Chasm of Fire',
    alternatives: ["K'ril Tsutsaroth", 'Tormented Demons'],
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Soulreaper axe',
        'Scythe of vitur',
        'Ghrazi rapier',
        'Abyssal whip',
      ],
    },
    notableDrops: ['Rune full helm'],
    notes:
        'Arclight is BiS (demon). Can do K\'ril Tsutsaroth or Tormented Demons as alternatives.',
    wikiPath: 'Greater_demon',
  ),
  SlayerMonster(
    name: 'Grotesque Guardians',
    slayerLevel: 75,
    style: SlayerStyle.melee,
    location: 'Slayer Tower (rooftop)',
    specialItems: ['Brittle key'],
    notableDrops: [
      'Black tourmaline core',
      'Granite gloves',
      'Granite ring',
      'Granite hammer',
    ],
    notes:
        'Boss variant of Gargoyles. Need brittle key drop from gargoyles first. Bring ranged switch for Dawn phase.',
    wikiPath: 'Grotesque_Guardians',
  ),
  SlayerMonster(
    name: 'Gryphons',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Various',
    notableDrops: [],
    notes: 'Standard melee task.',
    wikiPath: 'Gryphon',
  ),

  // ── H ──
  SlayerMonster(
    name: 'Hellhounds',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Taverley Dungeon',
    alternatives: ['Cerberus'],
    notableDrops: ['Hard clue scroll', 'Smouldering stone (Cerberus)'],
    notes:
        'Great cannon task. At 91 Slayer, do Cerberus instead for crystal drops. Catacombs for prayer drops.',
    wikiPath: 'Hellhound',
  ),
  SlayerMonster(
    name: 'Hydra',
    slayerLevel: 95,
    style: SlayerStyle.ranged,
    location: 'Karuulm Slayer Dungeon (lower level)',
    specialItems: ['Boots of stone/brimstone'],
    gearOverrides: {
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Bow of faerdhinen',
        'Armadyl crossbow',
      ],
      'shield': [
        'Dragonfire ward',
        'Twisted buckler',
        'Book of law',
      ],
    },
    alternatives: ['Alchemical Hydra'],
    notableDrops: [
      'Hydra\'s claw',
      'Hydra leather',
      'Hydra tail',
      'Hydra\'s eye',
      'Hydra\'s fang',
      'Hydra\'s heart',
    ],
    notes:
        'Kill the Alchemical Hydra boss variant for much better drops. Dragon hunter crossbow is BiS. Very profitable.',
    wikiPath: 'Alchemical_Hydra',
  ),

  // ── K ──
  SlayerMonster(
    name: 'Kalphites',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Kalphite Lair',
    alternatives: ['Kalphite Queen'],
    notableDrops: ['Dragon chainbody (KQ)', 'Dragon 2h sword (KQ)'],
    notes: 'Cannon kalphite soldiers/workers for fast task. Can do KQ for boss KC.',
    wikiPath: 'Kalphite',
  ),
  SlayerMonster(
    name: 'Kraken',
    slayerLevel: 87,
    style: SlayerStyle.magic,
    location: 'Kraken Cove',
    gearOverrides: {
      'weapon': [
        'Sanguinesti staff',
        'Trident of the swamp',
        'Trident of the seas',
      ],
    },
    notableDrops: [
      'Kraken tentacle',
      'Trident of the seas (full)',
      'Jar of dirt',
      'Pet kraken',
    ],
    notes:
        'Magic only boss. Very profitable and AFK. Use Trident-class weapon. Bring 1 click prayer restore.',
    wikiPath: 'Kraken',
  ),
  SlayerMonster(
    name: 'Kurask',
    slayerLevel: 70,
    style: SlayerStyle.melee,
    location: 'Fremennik Slayer Dungeon',
    specialItems: ['Leaf-bladed weapon required'],
    gearOverrides: {
      'weapon': [
        'Leaf-bladed battleaxe',
        'Leaf-bladed sword',
        'Leaf-bladed spear',
      ],
    },
    notableDrops: ['Mystic robe top (light)', 'Leaf-bladed sword'],
    notes:
        'Must use leaf-bladed weapons, broad bolts/arrows, or Magic Dart. Leaf-bladed battleaxe is BiS.',
    wikiPath: 'Kurask',
  ),

  // ── L ──
  SlayerMonster(
    name: 'Lizardmen',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Lizardman Canyon / Lizardman Temple',
    alternatives: ['Lizardman shamans'],
    gearOverrides: {
      'shield': [
        'Dragonfire ward',
        'Twisted buckler',
        'Book of law',
      ],
    },
    notableDrops: ['Dragon warhammer (shamans)'],
    notes:
        'Do Lizardman Shamans for Dragon warhammer — one of the most valuable drops in game. Bring Shayzien armour T5 for shaman acid splash immunity.',
    wikiPath: 'Lizardman',
  ),

  // ── M ──
  SlayerMonster(
    name: 'Metal dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Brimhaven Dungeon / Catacombs of Kourend',
    specialItems: ['Extended antifire potion'],
    gearOverrides: {
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
    },
    notableDrops: ['Dragon platelegs', 'Dragon plateskirt', 'Draconic visage'],
    notes:
        'Includes Iron, Steel, Mithril, Adamant, and Rune dragons. Dragon hunter crossbow speeds up all variants.',
    wikiPath: 'Metal_dragons',
  ),
  SlayerMonster(
    name: 'Mithril dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Ancient Cavern',
    specialItems: ['Extended antifire potion'],
    gearOverrides: {
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
    },
    notableDrops: ['Dragon full helm', 'Draconic visage', 'Chewed bones'],
    notes: 'Bring extended antifire + protect from magic. Dragon hunter crossbow recommended.',
    wikiPath: 'Mithril_dragon',
  ),
  SlayerMonster(
    name: 'Mutated Zygomites',
    slayerLevel: 57,
    style: SlayerStyle.melee,
    location: 'Fossil Island / Zanaris',
    specialItems: ['Fungicide spray'],
    notableDrops: ['Mort myre fungus'],
    notes: 'Must use Fungicide spray to finish them off below 7 HP.',
    wikiPath: 'Zygomite',
  ),

  // ── N ──
  SlayerMonster(
    name: 'Nechryael',
    slayerLevel: 80,
    style: SlayerStyle.barrage,
    canBarrage: true,
    location: 'Catacombs of Kourend / Slayer Tower',
    notableDrops: ['Rune boots', 'Death rune'],
    notes:
        'Barrage greater nechryael in Catacombs for excellent XP. Stack spawns in corner. One of the best barrage tasks.',
    wikiPath: 'Nechryael',
  ),

  // ── R ──
  SlayerMonster(
    name: 'Red dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Brimhaven Dungeon / Forthos Dungeon',
    specialItems: ['Anti-dragon shield'],
    gearOverrides: {
      'weapon': [
        'Dragon hunter crossbow',
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
    },
    notableDrops: ['Dragon bones', 'Red dragonhide'],
    notes: 'Kill baby red dragons for fast task.',
    wikiPath: 'Red_dragon',
  ),
  SlayerMonster(
    name: 'Rune dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Lithkren Vault',
    specialItems: ['Extended super antifire potion'],
    gearOverrides: {
      'weapon': [
        'Dragon hunter crossbow',
        'Dragon hunter lance',
        'Twisted bow',
        'Armadyl crossbow',
      ],
      'shield': [
        'Dragonfire ward',
        'Anti-dragon shield',
        'Dragonfire shield',
      ],
      'neck': [
        'Necklace of anguish',
        'Amulet of fury',
      ],
    },
    notableDrops: ['Dragon limbs', 'Dragon metal lump', 'Draconic visage'],
    notes:
        'Very profitable. Extended super antifire so you can use two-hand weapons. Dragon hunter crossbow is BiS.',
    wikiPath: 'Rune_dragon',
  ),

  // ── S ──
  SlayerMonster(
    name: 'Skeletal Wyverns',
    slayerLevel: 72,
    style: SlayerStyle.ranged,
    location: 'Asgarnian Ice Dungeon',
    specialItems: ['Elemental shield / Mind shield / Dragonfire shield'],
    gearOverrides: {
      'shield': [
        'Ancient wyvern shield',
        'Dragonfire shield',
        'Elemental shield',
        'Mind shield',
      ],
      'weapon': [
        'Twisted bow',
        'Armadyl crossbow',
        'Rune crossbow',
      ],
    },
    notableDrops: ['Granite legs', 'Draconic visage'],
    notes:
        'Need elemental/mind/DFS equipped for icy breath protection. Fairly AFK ranged task.',
    wikiPath: 'Skeletal_Wyvern',
  ),
  SlayerMonster(
    name: 'Smoke devils',
    slayerLevel: 93,
    style: SlayerStyle.barrage,
    canBarrage: true,
    location: 'Smoke Devil Dungeon',
    specialItems: ['Facemask (or Slayer helmet)'],
    alternatives: ['Thermonuclear smoke devil'],
    notableDrops: [
      'Occult necklace',
      'Smoke battlestaff',
      'Dragon chainbody',
    ],
    notes:
        'Barrage for excellent XP. Can also kill Thermy boss for pet + occult necklace. Requires facemask or Slayer helm.',
    wikiPath: 'Smoke_devil',
  ),
  SlayerMonster(
    name: 'Spiritual creatures',
    slayerLevel: 63,
    style: SlayerStyle.melee,
    location: 'God Wars Dungeon',
    notableDrops: ['Dragon boots (spiritual mages)'],
    notes:
        'Spiritual mages (83 Slayer) drop Dragon boots. Wear God items to avoid aggression.',
    wikiPath: 'Spiritual_creature',
  ),
  SlayerMonster(
    name: 'Suqah',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Lunar Isle',
    notableDrops: ['Suqah tooth', 'Suqah hide'],
    notes: 'Cannon + melee with protect from magic for fast task.',
    wikiPath: 'Suqah',
  ),

  // ── T ──
  SlayerMonster(
    name: 'Tormented Demons',
    slayerLevel: 1,
    style: SlayerStyle.hybrid,
    location: 'Tormented Demon Dungeon',
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Ghrazi rapier',
        'Abyssal whip',
      ],
    },
    notableDrops: [
      'Emberlight',
      'Burning claws',
      'Scorching bow',
      'Purging staff',
    ],
    notes:
        'Hybrid combat required — switches between protection prayers. Arclight very effective (demon).',
    wikiPath: 'Tormented_Demon',
  ),
  SlayerMonster(
    name: 'Trolls',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Trollheim / Mount Quidamortem',
    notableDrops: ['Granite shield'],
    notes: 'Cannon ice trolls on Jatizso for fast task + good prayer XP from bones.',
    wikiPath: 'Troll',
  ),
  SlayerMonster(
    name: 'Turoth',
    slayerLevel: 55,
    style: SlayerStyle.melee,
    location: 'Fremennik Slayer Dungeon',
    specialItems: ['Leaf-bladed weapon required'],
    gearOverrides: {
      'weapon': [
        'Leaf-bladed battleaxe',
        'Leaf-bladed sword',
        'Leaf-bladed spear',
      ],
    },
    notableDrops: ['Leaf-bladed sword', 'Mystic robe bottom (light)'],
    notes:
        'Must use leaf-bladed weapons, broad bolts/arrows, or Magic Dart. Same mechanic as Kurask.',
    wikiPath: 'Turoth',
  ),
  SlayerMonster(
    name: 'TzHaar',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    location: 'TzHaar City / Fight Cave / Inferno',
    notableDrops: [
      'Fire cape (Jad)',
      'Infernal cape (Inferno)',
      'Obsidian armour',
    ],
    notes:
        'Can do Fight Cave for Fire cape or Inferno for Infernal cape. Completing a cave counts as the full task.',
    wikiPath: 'TzHaar',
  ),

  // ── V ──
  SlayerMonster(
    name: 'Vampyres',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    location: 'Darkmeyer',
    specialItems: ['Blisterwood flail or Ivandis flail'],
    gearOverrides: {
      'weapon': [
        'Blisterwood flail',
        'Ivandis flail',
      ],
    },
    notableDrops: ['Blood shard'],
    notes:
        'Kill Vyrewatch Sentinels in Darkmeyer for blood shard drops. Requires Sins of the Father. Blisterwood flail is BiS.',
    wikiPath: 'Vyrewatch_Sentinel',
  ),

  // ── W ──
  SlayerMonster(
    name: 'Warped creatures',
    slayerLevel: 56,
    style: SlayerStyle.melee,
    location: 'Warped area (Tree Gnome Stronghold)',
    notableDrops: ['Warped sceptre'],
    notes: 'Requires completion of The Path of Glouphrie.',
    wikiPath: 'Slayer_task/Warped_creature',
  ),
  SlayerMonster(
    name: 'Waterfiends',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    canCannon: true,
    location: 'Kraken Cove / Ancient Cavern',
    notableDrops: ['Water orb', 'Mist battlestaff'],
    notes: 'Ranged + cannon for fast task. Weak to ranged attacks.',
    wikiPath: 'Waterfiend',
  ),
  SlayerMonster(
    name: 'Wyrms',
    slayerLevel: 62,
    style: SlayerStyle.melee,
    location: 'Karuulm Slayer Dungeon',
    specialItems: ['Boots of stone/brimstone'],
    notableDrops: ['Dragon harpoon', 'Dragon sword', 'Dragon knife'],
    notes:
        'Need boots of stone/brimstone for the dungeon. Decent melee task, AFK-able.',
    wikiPath: 'Wyrm',
  ),
];
