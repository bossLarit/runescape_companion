import '../../../core/services/osrs_api_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  SLAYER TASK DATA
//  Comprehensive slayer monster database with recommended gear per
//  slot, based on OSRS Wiki Slayer training guide & meta setups.
// ═══════════════════════════════════════════════════════════════════

/// How to kill this monster.
enum SlayerStyle { melee, ranged, magic, barrage, hybrid, prayer }

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

  /// Fairy ring code to get close to this monster (e.g. 'CKS').
  final String? fairyRing;

  /// How to get there — teleports, routes, etc.
  final List<String> travelTips;

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
    this.fairyRing,
    this.travelTips = const [],
  });

  /// Get the recommended gear for a slot. Uses override if present,
  /// otherwise falls back to the base template for this monster's style.
  List<String> gearForSlot(String slot) {
    if (gearOverrides.containsKey(slot)) return gearOverrides[slot]!;
    final base = _baseGear[style] ?? _baseGear[SlayerStyle.melee]!;
    return base[slot] ?? [];
  }

  /// Get gear for a slot using a specific [overrideStyle] instead of the
  /// monster's default. Gear overrides are only used when [overrideStyle]
  /// matches the monster's own style.
  List<String> gearForSlotWithStyle(String slot, SlayerStyle overrideStyle) {
    if (overrideStyle == style && gearOverrides.containsKey(slot)) {
      return gearOverrides[slot]!;
    }
    final base = _baseGear[overrideStyle] ?? _baseGear[SlayerStyle.melee]!;
    return base[slot] ?? [];
  }

  /// All equipment slots relevant for this monster's loadout.
  List<String> get relevantSlots {
    final base = _baseGear[style] ?? _baseGear[SlayerStyle.melee]!;
    final allSlots = {...base.keys, ...gearOverrides.keys};
    // Return in canonical order
    return equipmentSlots.where((s) => allSlots.contains(s)).toList();
  }

  /// Relevant slots for a given style.
  List<String> relevantSlotsForStyle(SlayerStyle overrideStyle) {
    final base = _baseGear[overrideStyle] ?? _baseGear[SlayerStyle.melee]!;
    final keys = overrideStyle == style
        ? {...base.keys, ...gearOverrides.keys}
        : base.keys;
    return equipmentSlots.where((s) => keys.contains(s)).toList();
  }

  /// Find the best item the player owns for a given slot.
  String? bestOwnedForSlot(String slot, Set<String> bankItems) {
    final gear = gearForSlot(slot);
    for (final item in gear) {
      if (bankItems.contains(item.toLowerCase())) return item;
    }
    return null;
  }

  /// Find the best item the player owns for a given slot using a specific style.
  String? bestOwnedForSlotWithStyle(
      String slot, Set<String> bankItems, SlayerStyle overrideStyle) {
    final gear = gearForSlotWithStyle(slot, overrideStyle);
    for (final item in gear) {
      if (bankItems.contains(item.toLowerCase())) return item;
    }
    return null;
  }

  CombatStyle get combatStyle {
    switch (style) {
      case SlayerStyle.melee:
      case SlayerStyle.hybrid:
      case SlayerStyle.prayer:
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
  SlayerStyle.prayer: _proselyteBase,
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

/// Prayer-focused melee template (Proselyte armour).
/// Used for tasks where you camp protection prayers for AFK/extended trips.
const _proselyteBase = <String, List<String>>{
  'head': [
    'Slayer helmet (i)',
    'Slayer helmet',
    'Black mask (i)',
    'Black mask',
  ],
  'cape': [
    'Infernal cape',
    'Fire cape',
    'Ardougne cloak 4',
    'Ardougne cloak 3',
  ],
  'neck': [
    'Dragonbone necklace',
    'Amulet of torture',
    'Amulet of fury',
    'Amulet of glory',
  ],
  'body': [
    'Proselyte hauberk',
  ],
  'legs': [
    'Proselyte cuisse',
  ],
  'weapon': [
    'Soulreaper axe',
    'Ghrazi rapier',
    'Blade of saeldor',
    'Abyssal tentacle',
    'Abyssal whip',
    'Dragon scimitar',
  ],
  'shield': [
    'Avernic defender',
    'Dragon defender',
    'Falador shield 4',
  ],
  'hands': [
    'Ferocious gloves',
    'Barrows gloves',
    'Dragon gloves',
    'Combat bracelet',
  ],
  'feet': [
    'Devout boots',
    'Holy sandals',
    'Dragon boots',
    'Climbing boots',
  ],
  'ring': [
    'Ring of the gods (i)',
    'Ring of the gods',
    'Berserker ring (i)',
    'Berserker ring',
    'Ring of wealth',
  ],
  'ammo': [
    'Holy blessing',
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
    fairyRing: 'CKS',
    travelTips: [
      'Slayer Tower: Fairy ring CKS → run west, or Slayer ring teleport',
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart, enter statue',
    ],
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
    fairyRing: 'CKS',
    travelTips: [
      'Slayer Tower: Fairy ring CKS → run west, or Slayer ring teleport',
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart, enter statue',
    ],
  ),
  SlayerMonster(
    name: 'Adamant dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Lithkren Vault',
    travelTips: ['Digsite pendant → Lithkren'],
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
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Stronghold: Skull sceptre teleport, or Varrock teleport → run south',
    ],
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
    notes:
        'Undead — Salve amulet(ei) is better than Slayer helm (they do NOT stack — use Salve instead).',
    wikiPath: 'Ankou',
  ),
  SlayerMonster(
    name: 'Ankou (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    gearOverrides: {
      'neck': [
        'Salve amulet(ei)',
        'Salve amulet (e)',
        'Salve amulet (i)',
        'Salve amulet',
        'Dragonbone necklace',
      ],
    },
    notableDrops: ['Blood rune', 'Death rune', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee in Catacombs. Salve amulet(ei) is better than Slayer helm (they do NOT stack — use Salve instead). Very AFK with prayer gear.',
    wikiPath: 'Ankou',
  ),
  SlayerMonster(
    name: 'Araxytes',
    slayerLevel: 92,
    style: SlayerStyle.melee,
    location: 'Araxyte Cave',
    fairyRing: 'CKS',
    travelTips: [
      'Fairy ring CKS → run east to Morytania Spider Cave',
      'Drakan\'s medallion → Ver Sinhaza → run north'
    ],
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
    travelTips: [
      'Ghommal\'s hilt teleport (Combat Achievements)',
      'Trollheim teleport → run north to GWD entrance'
    ],
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
    travelTips: [
      'Fremennik sea boots 4 teleport',
      'Rellekka teleport → boat to Island of Stone'
    ],
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
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Taverley: POH Taverley portal, or Falador teleport → run west',
    ],
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
    name: 'Black demons (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Abyssal whip',
        'Dragon scimitar',
      ],
    },
    notableDrops: ['Rune chainbody', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee with Arclight in Catacombs. Very AFK — aggressive monsters replenish prayer with bone drops.',
    wikiPath: 'Black_demon',
  ),
  SlayerMonster(
    name: 'Black dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Taverley Dungeon / Evil Chicken\'s Lair',
    travelTips: [
      'Taverley: POH Taverley portal, or Falador teleport → run west',
      'Evil Chicken: Fairy ring BKQ → Zanaris → chicken shrine',
    ],
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
    fairyRing: 'CKS',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Slayer Tower: Fairy ring CKS → run west, or Slayer ring teleport',
    ],
    notableDrops: ['Blood rune', 'Rune med helm'],
    notes:
        'Mutated bloodvelds in Catacombs are aggressive — good AFK with protect from melee. Can also barrage.',
    wikiPath: 'Bloodveld',
  ),
  SlayerMonster(
    name: 'Bloodveld (prayer)',
    slayerLevel: 50,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    notableDrops: [
      'Blood rune',
      'Rune med helm',
      'Totem pieces',
      'Ancient shard'
    ],
    notes:
        'Proselyte + Protect from Melee in Catacombs. Mutated bloodvelds are aggressive — fully AFK with prayer. One of the best prayer-afk tasks.',
    wikiPath: 'Bloodveld',
  ),
  SlayerMonster(
    name: 'Blue dragons',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    location: 'Taverley Dungeon / Myths\' Guild',
    travelTips: [
      'Taverley: POH Taverley portal, or Falador teleport → run west',
      'Myths\' Guild: Mythical cape teleport',
    ],
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
    travelTips: [
      'Ectophial → charter ship to Mos Le\'Harmless',
      'POH Mos Le\'Harmless portal'
    ],
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
    fairyRing: 'AKQ',
    travelTips: [
      'Fairy ring AKQ → run south-east to cave entrance',
      'Piscarilius house teleport → run south'
    ],
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
    travelTips: [
      'Key Master teleport (dropped by Cerberus)',
      'POH Taverley portal → run through dungeon'
    ],
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

  SlayerMonster(
    name: 'Custodian stalkers',
    slayerLevel: 54,
    style: SlayerStyle.ranged,
    canCannon: true,
    location: 'Stalker Den (Auburnvale)',
    travelTips: ['Auburnvale teleport scroll'],
    gearOverrides: {
      'head': [
        'Slayer helmet (i)',
        'Masori mask (f)',
        'Masori mask',
      ],
      'neck': [
        'Necklace of anguish',
        'Amulet of fury',
        'Bonecrusher necklace',
        'Dragonbone necklace',
      ],
      'cape': [
        "Dizana's quiver",
        "Ava's assembler",
        "Ava's accumulator",
        'Ranging cape(t)',
      ],
      'body': [
        'Masori body (f)',
        'Masori body',
        'Hueycoatl hide body',
      ],
      'legs': [
        'Masori chaps (f)',
        'Masori chaps',
        'Hueycoatl hide chaps',
      ],
      'weapon': [
        'Venator bow',
        'Black chinchompa',
        'Red chinchompa',
      ],
      'shield': [
        'Twisted buckler',
        'Dragonfire ward',
        'Odium ward',
        'Antler guard',
        'Book of law',
      ],
      'ammo': [
        'Amethyst arrow',
        "Rada's blessing 4",
        'Rune arrow',
        "Rada's blessing 3",
      ],
      'hands': [
        'Bracelet of slaughter',
        'Zaryte vambraces',
        'Barrows gloves',
        'Regen bracelet',
      ],
      'feet': [
        'Devout boots',
        'Echo boots',
        "Blessed d'hide boots",
      ],
      'ring': [
        'Venator ring',
        'Lightbearer',
        'Ring of the gods (i)',
        'Ring of suffering (i)',
        'Ring of wealth',
      ],
    },
    alternatives: [
      'Juvenile custodian stalker',
      'Mature custodian stalker',
      'Elder custodian stalker',
    ],
    notableDrops: ['Antler guard', 'Broken antlers', 'Atlatl dart tips'],
    notes:
        'Requires Shadows of Custodia quest. Use Protect from Melee; switch to Protect from Magic at low HP for bleed. '
        'Venator bow is BiS for auto-aggro. Cannon in multicombat SW area. '
        'Elder stalkers (76 Slayer) can spawn the Ancient Custodian superior.',
    wikiPath: 'Custodian_stalker',
  ),
  SlayerMonster(
    name: 'Custodian stalkers (barrage)',
    slayerLevel: 54,
    style: SlayerStyle.barrage,
    canBarrage: true,
    canCannon: true,
    location: 'Stalker Den (Auburnvale)',
    travelTips: ['Auburnvale teleport scroll'],
    gearOverrides: {
      'head': [
        'Slayer helmet (i)',
        'Virtus mask',
        'Ancestral hat',
        "Ahrim's hood",
      ],
      'neck': [
        'Occult necklace',
        'Amulet of fury',
        'Bonecrusher necklace',
        'Dragonbone necklace',
      ],
      'cape': [
        'Imbued saradomin cape',
        'Imbued guthix cape',
        'Imbued zamorak cape',
        'Ardougne cloak 4',
        'Soul cape',
      ],
      'body': [
        'Virtus robe top',
        'Ancestral robe top',
        "Ahrim's robetop",
        'Mystic robe top',
      ],
      'legs': [
        'Virtus robe bottom',
        'Ancestral robe bottom',
        "Ahrim's robeskirt",
        'Mystic robe bottom',
      ],
      'weapon': [
        'Kodai wand',
        'Nightmare staff',
        'Ancient sceptre',
        "Ahrim's staff",
        'Master wand',
        'Ancient staff',
      ],
      'shield': [
        "Elidinis' ward (f)",
        'Arcane spirit shield',
        "Elidinis' ward",
        "Mage's book",
        'Book of darkness',
        'Antler guard',
      ],
      'ammo': [
        "Rada's blessing 4",
        'God blessing',
        "Rada's blessing 3",
      ],
      'hands': [
        'Bracelet of slaughter',
        'Confliction gauntlets',
        'Tormented bracelet',
        'Barrows gloves',
      ],
      'feet': [
        'Eternal boots',
        'Devout boots',
        'Holy sandals',
        'Mystic boots',
      ],
      'ring': [
        'Magus ring',
        'Lightbearer',
        'Seers ring (i)',
        'Ring of the gods (i)',
        'Brimstone ring',
        'Ring of wealth',
      ],
    },
    alternatives: [
      'Juvenile custodian stalker',
      'Mature custodian stalker',
      'Elder custodian stalker',
    ],
    notableDrops: ['Antler guard', 'Broken antlers', 'Atlatl dart tips'],
    notes:
        'Requires Shadows of Custodia quest. Barrage in multicombat SW area. '
        'Use Protect from Melee; Blood Barrage can sustain HP vs bleeds. '
        'Bring Crystal/Dragon halberd spec for stacked enemies.',
    wikiPath: 'Custodian_stalker',
  ),

  // ── D ──
  SlayerMonster(
    name: 'Dagannoth',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Lighthouse / Catacombs of Kourend',
    fairyRing: 'ALP',
    travelTips: [
      'Lighthouse: Fairy ring ALP → run north',
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'DKs: Waterbirth Island → Fairy ring DKS',
    ],
    alternatives: ['Dagannoth Kings'],
    notableDrops: ['Dagannoth bones'],
    notes:
        'Cannon at Lighthouse for fast task. Can do DKs for berserker/archers/seers rings.',
    wikiPath: 'Dagannoth',
  ),
  SlayerMonster(
    name: 'Dagannoth (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    notableDrops: ['Dagannoth bones', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee in Catacombs. Aggressive dagannoth — very AFK with prayer bonus gear.',
    wikiPath: 'Dagannoth',
  ),
  SlayerMonster(
    name: 'Dark beasts',
    slayerLevel: 90,
    style: SlayerStyle.melee,
    canBarrage: true,
    location: 'Mourner Tunnels / Catacombs of Kourend',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Iorwerth Dungeon: Teleport crystal → Prifddinas',
    ],
    notableDrops: ['Dark bow'],
    notes:
        'Can melee or barrage. Mourner Tunnels after Song of the Elves, or Catacombs.',
    wikiPath: 'Dark_beast',
  ),
  SlayerMonster(
    name: 'Dark beasts (prayer)',
    slayerLevel: 90,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    notableDrops: ['Dark bow', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee in Catacombs. AFK — dark beasts are aggressive. Good prayer-extending setup.',
    wikiPath: 'Dark_beast',
  ),
  SlayerMonster(
    name: 'Demonic gorillas',
    slayerLevel: 1,
    style: SlayerStyle.hybrid,
    location: 'Crash Site Cavern',
    travelTips: [
      'Royal seed pod → Grand Tree → Gnome Glider to Crash Site',
      'Spirit tree → Tree Gnome Stronghold → run east'
    ],
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
    fairyRing: 'CIR',
    travelTips: [
      'Fairy ring CIR → climb Mount Karuulm',
      'Skills necklace → Farming Guild → run north',
      'Rada\'s blessing 3/4 → Mount Karuulm teleport',
    ],
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
    fairyRing: 'DLQ',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Smoke Dungeon: Fairy ring DLQ → run south-east, or Desert amulet → Pollnivneach',
    ],
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
    travelTips: ['Teleport crystal → Prifddinas → Iorwerth Dungeon entrance'],
    notableDrops: [
      'Crystal armour seed',
      'Crystal weapon seed',
      'Enhanced crystal key'
    ],
    notes:
        'Requires Song of the Elves. Kill Iorwerth warriors in the dungeon. Good for crystal shards.',
    wikiPath: 'Slayer_task/Elves',
  ),
  SlayerMonster(
    name: 'Elves (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Iorwerth Dungeon (Prifddinas)',
    travelTips: ['Teleport crystal → Prifddinas → Iorwerth Dungeon entrance'],
    notableDrops: [
      'Crystal armour seed',
      'Crystal weapon seed',
      'Enhanced crystal key',
    ],
    notes:
        'Proselyte + Protect from Melee in Iorwerth Dungeon. Warriors are aggressive — AFK with prayer. Good crystal shard source.',
    wikiPath: 'Slayer_task/Elves',
  ),

  // ── F ──
  SlayerMonster(
    name: 'Fire giants',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Waterfall Dungeon',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Waterfall: Games necklace → Barbarian Assault → run south',
    ],
    notableDrops: ['Rune scimitar'],
    notes: 'Good cannon task in Waterfall Dungeon or melee in Catacombs.',
    wikiPath: 'Fire_giant',
  ),
  SlayerMonster(
    name: 'Fire giants (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    notableDrops: ['Rune scimitar', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee in Catacombs. Aggressive — fully AFK with prayer gear. Good for totem/shard farming.',
    wikiPath: 'Fire_giant',
  ),
  SlayerMonster(
    name: 'Fossil Island Wyverns',
    slayerLevel: 66,
    style: SlayerStyle.melee,
    location: 'Fossil Island Wyvern Cave',
    travelTips: ['Digsite pendant → Fossil Island → run to Wyvern Cave'],
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
    travelTips: ['Sailing → Icy seas voyage'],
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
    fairyRing: 'CKS',
    travelTips: [
      'Fairy ring CKS → run west',
      'Slayer ring teleport → Slayer Tower'
    ],
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
    name: 'Gargoyles (prayer)',
    slayerLevel: 75,
    style: SlayerStyle.prayer,
    location: 'Slayer Tower (rooftop)',
    fairyRing: 'CKS',
    travelTips: [
      'Fairy ring CKS → run west',
      'Slayer ring teleport → Slayer Tower'
    ],
    specialItems: ['Rock hammer (or Granite hammer)'],
    notableDrops: [
      'Granite maul',
      'Mystic robe top (dark)',
      'Gold bar (noted)',
    ],
    notes:
        'Proselyte + Protect from Melee on Slayer Tower rooftop. Very AFK and profitable — extends trips significantly with prayer gear.',
    wikiPath: 'Gargoyle',
  ),
  SlayerMonster(
    name: 'Greater demons',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Catacombs of Kourend / Chasm of Fire',
    fairyRing: 'DJR',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Chasm of Fire: Fairy ring DJR',
    ],
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
    name: 'Greater demons (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    gearOverrides: {
      'weapon': [
        'Arclight',
        'Abyssal whip',
        'Dragon scimitar',
      ],
    },
    notableDrops: ['Rune full helm', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee with Arclight in Catacombs. Aggressive — very AFK. Good for totem/shard farming.',
    wikiPath: 'Greater_demon',
  ),
  SlayerMonster(
    name: 'Grotesque Guardians',
    slayerLevel: 75,
    style: SlayerStyle.melee,
    location: 'Slayer Tower (rooftop)',
    fairyRing: 'CKS',
    travelTips: [
      'Fairy ring CKS → run west',
      'Slayer ring teleport → Slayer Tower'
    ],
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
    travelTips: ['Depends on location — check Troubled Tortugans quest areas'],
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
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Taverley: POH Taverley portal, or Falador teleport → run west',
    ],
    alternatives: ['Cerberus'],
    notableDrops: ['Hard clue scroll', 'Smouldering stone (Cerberus)'],
    notes:
        'Great cannon task. At 91 Slayer, do Cerberus instead for crystal drops. Catacombs for prayer drops.',
    wikiPath: 'Hellhound',
  ),
  SlayerMonster(
    name: 'Hellhounds (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Catacombs of Kourend',
    travelTips: ['Xeric\'s talisman → Xeric\'s Heart, enter statue'],
    notableDrops: ['Hard clue scroll', 'Totem pieces', 'Ancient shard'],
    notes:
        'Proselyte + Protect from Melee in Catacombs. Classic AFK prayer task — hellhounds only drop clues. Aggressive for zero-effort kills.',
    wikiPath: 'Hellhound',
  ),
  SlayerMonster(
    name: 'Hydra',
    slayerLevel: 95,
    style: SlayerStyle.ranged,
    location: 'Karuulm Slayer Dungeon (lower level)',
    fairyRing: 'CIR',
    travelTips: [
      'Fairy ring CIR → climb Mount Karuulm',
      'Rada\'s blessing 3/4 → Mount Karuulm teleport',
      'Skills necklace → Farming Guild → run north',
    ],
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
    fairyRing: 'BIQ',
    travelTips: [
      'Fairy ring BIQ → run west to Kalphite Lair',
      'Desert amulet 4 → Kalphite cave teleport',
      'Shantay Pass → magic carpet to Pollnivneach → run south',
    ],
    alternatives: ['Kalphite Queen'],
    notableDrops: ['Dragon chainbody (KQ)', 'Dragon 2h sword (KQ)'],
    notes:
        'Cannon kalphite soldiers/workers for fast task. Can do KQ for boss KC.',
    wikiPath: 'Kalphite',
  ),
  SlayerMonster(
    name: 'Kraken',
    slayerLevel: 87,
    style: SlayerStyle.magic,
    location: 'Kraken Cove',
    fairyRing: 'AKQ',
    travelTips: [
      'Fairy ring AKQ → run south-east to cave entrance',
      'Piscarilius house teleport → run south'
    ],
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
    fairyRing: 'AJR',
    travelTips: [
      'Fairy ring AJR → Fremennik Slayer Dungeon',
      'Slayer ring teleport'
    ],
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
    travelTips: [
      'Xeric\'s talisman → Xeric\'s Glade → run south to canyon',
      'Fairy ring DJR → run north-east'
    ],
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
    fairyRing: 'CKR',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Brimhaven: Fairy ring CKR → run east, or POH Brimhaven portal',
    ],
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
    fairyRing: 'BJQ',
    travelTips: ['Fairy ring BJQ → under Baxtorian Falls (Ancient Cavern)'],
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
    notes:
        'Bring extended antifire + protect from magic. Dragon hunter crossbow recommended.',
    wikiPath: 'Mithril_dragon',
  ),
  SlayerMonster(
    name: 'Mutated Zygomites',
    slayerLevel: 57,
    style: SlayerStyle.melee,
    location: 'Fossil Island / Zanaris',
    travelTips: [
      'Enchanted Valley: Fairy ring BKQ (Zygomites spawn here)',
      'Zanaris: Enter shed in Lumbridge Swamp with Dramen/Lunar staff',
      'Fossil Island: Digsite pendant → Fossil Island'
    ],
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
    fairyRing: 'CKS',
    travelTips: [
      'Catacombs: Xeric\'s talisman → Xeric\'s Heart',
      'Slayer Tower: Fairy ring CKS → run west, or Slayer ring teleport',
    ],
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
    fairyRing: 'CKR',
    travelTips: [
      'Brimhaven: Fairy ring CKR → run east, or POH Brimhaven portal',
      'Forthos Dungeon: Xeric\'s talisman → Xeric\'s Glade'
    ],
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
    travelTips: ['Digsite pendant → Lithkren'],
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
    fairyRing: 'AIQ',
    travelTips: [
      'Fairy ring AIQ → Asgarnian Ice Dungeon entrance',
      'POH Rimmington portal → run south'
    ],
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
    fairyRing: 'DLQ',
    travelTips: ['Fairy ring DLQ → run east to Smoke Devil Dungeon entrance'],
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
    travelTips: [
      'Ghommal\'s hilt teleport (Combat Achievements)',
      'Trollheim teleport → run north to GWD entrance'
    ],
    notableDrops: ['Dragon boots (spiritual mages)'],
    notes:
        'Spiritual mages (83 Slayer) drop Dragon boots. Wear God items to avoid aggression.',
    wikiPath: 'Spiritual_creature',
  ),
  SlayerMonster(
    name: 'Spiritual creatures (prayer)',
    slayerLevel: 63,
    style: SlayerStyle.prayer,
    location: 'God Wars Dungeon',
    travelTips: [
      'Ghommal\'s hilt teleport (Combat Achievements)',
      'Trollheim teleport → run north to GWD entrance'
    ],
    specialItems: ['God items for protection'],
    notableDrops: ['Dragon boots (spiritual mages)'],
    notes:
        'Proselyte + protection prayers in GWD. Prayer gear is essential here as you need to pray anyway. Wear a God item to avoid aggression from other factions.',
    wikiPath: 'Spiritual_creature',
  ),
  SlayerMonster(
    name: 'Suqah',
    slayerLevel: 1,
    style: SlayerStyle.melee,
    canCannon: true,
    location: 'Lunar Isle',
    travelTips: [
      'Lunar spellbook: Moonclan Teleport',
      'Seal of passage + boat from Rellekka'
    ],
    notableDrops: ['Suqah tooth', 'Suqah hide'],
    notes: 'Cannon + melee with protect from magic for fast task.',
    wikiPath: 'Suqah',
  ),
  SlayerMonster(
    name: 'Suqah (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    canCannon: true,
    location: 'Lunar Isle',
    travelTips: [
      'Lunar spellbook: Moonclan Teleport',
      'Seal of passage + boat from Rellekka'
    ],
    notableDrops: ['Suqah tooth', 'Suqah hide'],
    notes:
        'Proselyte + Protect from Magic with cannon. Prayer gear extends trips since you pray the entire task. Cannon speeds it up.',
    wikiPath: 'Suqah',
  ),

  // ── T ──
  SlayerMonster(
    name: 'Tormented Demons',
    slayerLevel: 1,
    style: SlayerStyle.hybrid,
    location: 'Tormented Demon Dungeon',
    travelTips: ['Lassar Undercity teleport via Ancient spellbook'],
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
    travelTips: [
      'Trollheim teleport → run to troll area',
      'Jatizso: Fremennik sea boots / Enchanted lyre → boat to Jatizso'
    ],
    notableDrops: ['Granite shield'],
    notes:
        'Cannon ice trolls on Jatizso for fast task + good prayer XP from bones.',
    wikiPath: 'Troll',
  ),
  SlayerMonster(
    name: 'Turoth',
    slayerLevel: 55,
    style: SlayerStyle.melee,
    location: 'Fremennik Slayer Dungeon',
    fairyRing: 'AJR',
    travelTips: [
      'Fairy ring AJR → Fremennik Slayer Dungeon',
      'Slayer ring teleport'
    ],
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
    travelTips: [
      'Fairy ring BLP → TzHaar City entrance',
      'Glory teleport → Karamja → run to volcano entrance'
    ],
    fairyRing: 'BLP',
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
    travelTips: ['Drakan\'s medallion → Darkmeyer'],
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
  SlayerMonster(
    name: 'Vampyres (prayer)',
    slayerLevel: 1,
    style: SlayerStyle.prayer,
    location: 'Darkmeyer',
    travelTips: ['Drakan\'s medallion → Darkmeyer'],
    specialItems: ['Blisterwood flail or Ivandis flail'],
    gearOverrides: {
      'weapon': [
        'Blisterwood flail',
        'Ivandis flail',
      ],
    },
    notableDrops: ['Blood shard'],
    notes:
        'Proselyte + Protect from Melee in Darkmeyer. Vyrewatch Sentinels are aggressive — very AFK with prayer gear. Blood shard is ~10M.',
    wikiPath: 'Vyrewatch_Sentinel',
  ),

  // ── W ──
  SlayerMonster(
    name: 'Warped creatures',
    slayerLevel: 56,
    style: SlayerStyle.melee,
    location: 'Warped area (Tree Gnome Stronghold)',
    travelTips: ['Spirit tree → Tree Gnome Stronghold → run to Warped area'],
    notableDrops: ['Warped sceptre'],
    notes: 'Requires completion of The Path of Glouphrie.',
    wikiPath: 'Slayer_task/Warped_creature',
  ),
  SlayerMonster(
    name: 'Waterfiends',
    slayerLevel: 1,
    style: SlayerStyle.ranged,
    canCannon: true,
    location: 'Ancient Cavern',
    fairyRing: 'BJQ',
    travelTips: [
      'Ancient Cavern: Fairy ring BJQ → under Baxtorian Falls',
    ],
    notableDrops: ['Water orb', 'Mist battlestaff'],
    notes: 'Ranged + cannon for fast task. Weak to ranged attacks.',
    wikiPath: 'Waterfiend',
  ),
  SlayerMonster(
    name: 'Wyrms',
    slayerLevel: 62,
    style: SlayerStyle.melee,
    location: 'Karuulm Slayer Dungeon',
    fairyRing: 'CIR',
    travelTips: [
      'Fairy ring CIR → climb Mount Karuulm',
      'Rada\'s blessing 3/4 → Mount Karuulm teleport',
      'Skills necklace → Farming Guild → run north',
    ],
    specialItems: ['Boots of stone/brimstone'],
    notableDrops: ['Dragon harpoon', 'Dragon sword', 'Dragon knife'],
    notes:
        'Need boots of stone/brimstone for the dungeon. Decent melee task, AFK-able.',
    wikiPath: 'Wyrm',
  ),
];
