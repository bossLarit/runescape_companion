import '../domain/idle_models.dart';

// ─── Item Catalog ───────────────────────────────────────────────
// Every item that can exist in the bank.

const allItems = <LootItem>[
  // ── Bones ────────────────────────────────────────────────────
  LootItem(id: 'bones', name: 'Bones', icon: '🦴', category: 'bone'),
  LootItem(id: 'big_bones', name: 'Big Bones', icon: '🦴', category: 'bone'),
  LootItem(
      id: 'dragon_bones',
      name: 'Dragon Bones',
      icon: '🦴',
      category: 'bone'),

  // ── Raw Fish ─────────────────────────────────────────────────
  LootItem(
      id: 'raw_shrimp', name: 'Raw Shrimps', icon: '🦐', category: 'fish_raw'),
  LootItem(
      id: 'raw_trout', name: 'Raw Trout', icon: '🐟', category: 'fish_raw'),
  LootItem(
      id: 'raw_lobster',
      name: 'Raw Lobster',
      icon: '🦞',
      category: 'fish_raw'),
  LootItem(
      id: 'raw_swordfish',
      name: 'Raw Swordfish',
      icon: '🐡',
      category: 'fish_raw'),
  LootItem(
      id: 'raw_shark', name: 'Raw Shark', icon: '🦈', category: 'fish_raw'),
  LootItem(
      id: 'raw_anglerfish',
      name: 'Raw Anglerfish',
      icon: '🎣',
      category: 'fish_raw'),
  LootItem(
      id: 'raw_chicken',
      name: 'Raw Chicken',
      icon: '🍗',
      category: 'fish_raw'),
  LootItem(
      id: 'raw_beef', name: 'Raw Beef', icon: '🥩', category: 'fish_raw'),

  // ── Cooked Food ──────────────────────────────────────────────
  LootItem(
      id: 'cooked_shrimp',
      name: 'Shrimps',
      icon: '🦐',
      category: 'fish_cooked'),
  LootItem(
      id: 'cooked_trout', name: 'Trout', icon: '🐟', category: 'fish_cooked'),
  LootItem(
      id: 'cooked_chicken',
      name: 'Cooked Chicken',
      icon: '🍗',
      category: 'fish_cooked'),
  LootItem(
      id: 'cooked_beef',
      name: 'Cooked Beef',
      icon: '🥩',
      category: 'fish_cooked'),
  LootItem(
      id: 'cooked_lobster',
      name: 'Lobster',
      icon: '🦞',
      category: 'fish_cooked'),
  LootItem(
      id: 'cooked_swordfish',
      name: 'Swordfish',
      icon: '🐡',
      category: 'fish_cooked'),
  LootItem(
      id: 'cooked_shark', name: 'Shark', icon: '🦈', category: 'fish_cooked'),
  LootItem(
      id: 'cooked_anglerfish',
      name: 'Anglerfish',
      icon: '🎣',
      category: 'fish_cooked'),

  // ── Ores ─────────────────────────────────────────────────────
  LootItem(id: 'copper_ore', name: 'Copper Ore', icon: '🟤', category: 'ore'),
  LootItem(id: 'tin_ore', name: 'Tin Ore', icon: '⚪', category: 'ore'),
  LootItem(id: 'iron_ore', name: 'Iron Ore', icon: '🔘', category: 'ore'),
  LootItem(id: 'coal', name: 'Coal', icon: '⬛', category: 'ore'),
  LootItem(
      id: 'mithril_ore', name: 'Mithril Ore', icon: '🔵', category: 'ore'),
  LootItem(
      id: 'adamantite_ore',
      name: 'Adamantite Ore',
      icon: '🟢',
      category: 'ore'),
  LootItem(id: 'runite_ore', name: 'Runite Ore', icon: '🔷', category: 'ore'),
  LootItem(id: 'gold_ore', name: 'Gold Ore', icon: '🟡', category: 'ore'),

  // ── Bars ─────────────────────────────────────────────────────
  LootItem(id: 'bronze_bar', name: 'Bronze Bar', icon: '🟫', category: 'bar'),
  LootItem(id: 'iron_bar', name: 'Iron Bar', icon: '⬜', category: 'bar'),
  LootItem(id: 'steel_bar', name: 'Steel Bar', icon: '🩶', category: 'bar'),
  LootItem(
      id: 'mithril_bar', name: 'Mithril Bar', icon: '💙', category: 'bar'),
  LootItem(
      id: 'adamantite_bar',
      name: 'Adamantite Bar',
      icon: '💚',
      category: 'bar'),
  LootItem(id: 'rune_bar', name: 'Rune Bar', icon: '💎', category: 'bar'),
  LootItem(id: 'gold_bar', name: 'Gold Bar', icon: '🥇', category: 'bar'),

  // ── Logs ─────────────────────────────────────────────────────
  LootItem(id: 'logs', name: 'Logs', icon: '🪵', category: 'log'),
  LootItem(id: 'oak_logs', name: 'Oak Logs', icon: '🪵', category: 'log'),
  LootItem(
      id: 'willow_logs', name: 'Willow Logs', icon: '🪵', category: 'log'),
  LootItem(id: 'maple_logs', name: 'Maple Logs', icon: '🪵', category: 'log'),
  LootItem(id: 'yew_logs', name: 'Yew Logs', icon: '🪵', category: 'log'),
  LootItem(id: 'magic_logs', name: 'Magic Logs', icon: '🪵', category: 'log'),

  // ── Hides ────────────────────────────────────────────────────
  LootItem(id: 'cowhide', name: 'Cowhide', icon: '🐮', category: 'hide'),
  LootItem(
      id: 'green_dhide',
      name: 'Green Dragonhide',
      icon: '🟩',
      category: 'hide'),
  LootItem(
      id: 'black_dhide',
      name: 'Black Dragonhide',
      icon: '⬛',
      category: 'hide'),

  // ── Leather (crafting output) ────────────────────────────────
  LootItem(id: 'leather', name: 'Leather', icon: '🟫', category: 'misc'),
  LootItem(
      id: 'green_dhide_body',
      name: 'Green D\'hide Body',
      icon: '🟩',
      category: 'misc'),
  LootItem(
      id: 'black_dhide_body',
      name: 'Black D\'hide Body',
      icon: '⬛',
      category: 'misc'),

  // ── Runes ────────────────────────────────────────────────────
  LootItem(
      id: 'nature_rune', name: 'Nature Rune', icon: '🟢', category: 'rune'),
  LootItem(id: 'fire_rune', name: 'Fire Rune', icon: '🔴', category: 'rune'),
  LootItem(
      id: 'chaos_rune', name: 'Chaos Rune', icon: '🟣', category: 'rune'),
  LootItem(
      id: 'rune_essence',
      name: 'Rune Essence',
      icon: '⚪',
      category: 'rune'),

  // ── Misc Drops ───────────────────────────────────────────────
  LootItem(id: 'feathers', name: 'Feathers', icon: '🪶', category: 'misc'),
  LootItem(
      id: 'goblin_mail', name: 'Goblin Mail', icon: '📮', category: 'misc'),
  LootItem(
      id: 'bronze_spear',
      name: 'Bronze Spear',
      icon: '🔱',
      category: 'misc'),
  LootItem(
      id: 'limpwurt_root',
      name: 'Limpwurt Root',
      icon: '🌱',
      category: 'misc'),
  LootItem(id: 'tokkul', name: 'Tokkul', icon: '🪙', category: 'misc'),
  LootItem(
      id: 'obsidian_cape',
      name: 'Obsidian Cape',
      icon: '🧥',
      category: 'misc'),
  LootItem(
      id: 'fire_cape', name: 'Fire Cape', icon: '🔥', category: 'misc'),

  // ── Smithing Output ──────────────────────────────────────────
  LootItem(
      id: 'bronze_platebody',
      name: 'Bronze Platebody',
      icon: '🛡️',
      category: 'misc'),
  LootItem(
      id: 'iron_platebody',
      name: 'Iron Platebody',
      icon: '🛡️',
      category: 'misc'),
  LootItem(
      id: 'steel_platebody',
      name: 'Steel Platebody',
      icon: '🛡️',
      category: 'misc'),
  LootItem(
      id: 'mithril_platebody',
      name: 'Mithril Platebody',
      icon: '🛡️',
      category: 'misc'),
  LootItem(
      id: 'adamant_platebody',
      name: 'Adamant Platebody',
      icon: '🛡️',
      category: 'misc'),
  LootItem(
      id: 'rune_platebody',
      name: 'Rune Platebody',
      icon: '🛡️',
      category: 'misc'),

  // ── Slayer Unique Drops ──────────────────────────────────────
  LootItem(
      id: 'dust_battlestaff',
      name: 'Dust Battlestaff',
      icon: '🌪️',
      category: 'misc'),
  LootItem(
      id: 'granite_legs',
      name: 'Granite Legs',
      icon: '🦿',
      category: 'misc'),
  LootItem(
      id: 'abyssal_whip',
      name: 'Abyssal Whip',
      icon: '🪢',
      category: 'misc'),
  LootItem(
      id: 'primordial_crystal',
      name: 'Primordial Crystal',
      icon: '💎',
      category: 'misc'),
  LootItem(
      id: 'hydra_leather',
      name: 'Hydra Leather',
      icon: '🐲',
      category: 'misc'),
];

LootItem? getItemById(String id) {
  for (final item in allItems) {
    if (item.id == id) return item;
  }
  return null;
}

// ─── Monster Drop Tables ────────────────────────────────────────

const monsterDropTables = <String, List<DropEntry>>{
  'chicken': [
    DropEntry(itemId: 'feathers', chance: 1.0, minQty: 5, maxQty: 15),
    DropEntry(itemId: 'raw_chicken', chance: 1.0),
    DropEntry(itemId: 'bones', chance: 1.0),
  ],
  'cow': [
    DropEntry(itemId: 'cowhide', chance: 1.0),
    DropEntry(itemId: 'raw_beef', chance: 1.0),
    DropEntry(itemId: 'bones', chance: 1.0),
  ],
  'goblin': [
    DropEntry(itemId: 'goblin_mail', chance: 0.5),
    DropEntry(itemId: 'bronze_spear', chance: 0.3),
    DropEntry(itemId: 'bones', chance: 1.0),
  ],
  'guard': [
    DropEntry(itemId: 'iron_ore', chance: 0.6, minQty: 1, maxQty: 3),
    DropEntry(itemId: 'bones', chance: 1.0),
  ],
  'hill_giant': [
    DropEntry(itemId: 'big_bones', chance: 1.0),
    DropEntry(itemId: 'limpwurt_root', chance: 0.5),
    DropEntry(itemId: 'nature_rune', chance: 0.4, minQty: 3, maxQty: 7),
    DropEntry(itemId: 'iron_ore', chance: 0.3, minQty: 2, maxQty: 5),
  ],
  'moss_giant': [
    DropEntry(itemId: 'big_bones', chance: 1.0),
    DropEntry(itemId: 'nature_rune', chance: 0.5, minQty: 5, maxQty: 12),
    DropEntry(itemId: 'mithril_ore', chance: 0.3, minQty: 1, maxQty: 3),
    DropEntry(itemId: 'maple_logs', chance: 0.4, minQty: 1, maxQty: 3),
  ],
  'lesser_demon': [
    DropEntry(itemId: 'fire_rune', chance: 0.6, minQty: 15, maxQty: 60),
    DropEntry(itemId: 'gold_ore', chance: 0.3),
    DropEntry(itemId: 'coal', chance: 0.5, minQty: 5, maxQty: 10),
    DropEntry(itemId: 'rune_essence', chance: 0.4, minQty: 5, maxQty: 15),
  ],
  'greater_demon': [
    DropEntry(itemId: 'chaos_rune', chance: 0.6, minQty: 10, maxQty: 20),
    DropEntry(itemId: 'adamantite_ore', chance: 0.25),
    DropEntry(itemId: 'raw_lobster', chance: 0.4, minQty: 2, maxQty: 5),
    DropEntry(itemId: 'black_dhide', chance: 0.15),
  ],
  'black_dragon': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0),
    DropEntry(itemId: 'black_dhide', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'adamantite_ore', chance: 0.4, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'runite_ore', chance: 0.1),
  ],
  'tztok_jad': [
    DropEntry(itemId: 'tokkul', chance: 1.0, minQty: 1000, maxQty: 5000),
    DropEntry(itemId: 'fire_cape', chance: 0.15),
    DropEntry(itemId: 'obsidian_cape', chance: 0.3),
    DropEntry(itemId: 'raw_shark', chance: 0.8, minQty: 5, maxQty: 10),
  ],
  // Slayer monsters
  'dust_devil': [
    DropEntry(itemId: 'dust_battlestaff', chance: 0.05),
    DropEntry(itemId: 'chaos_rune', chance: 0.6, minQty: 10, maxQty: 30),
    DropEntry(itemId: 'fire_rune', chance: 0.5, minQty: 20, maxQty: 50),
    DropEntry(itemId: 'mithril_ore', chance: 0.3, minQty: 2, maxQty: 5),
  ],
  'wyvern': [
    DropEntry(itemId: 'granite_legs', chance: 0.04),
    DropEntry(itemId: 'adamantite_ore', chance: 0.4, minQty: 2, maxQty: 5),
    DropEntry(itemId: 'coal', chance: 0.5, minQty: 10, maxQty: 25),
    DropEntry(itemId: 'raw_lobster', chance: 0.4, minQty: 3, maxQty: 8),
  ],
  'abyssal_demon': [
    DropEntry(itemId: 'abyssal_whip', chance: 0.02),
    DropEntry(itemId: 'chaos_rune', chance: 0.5, minQty: 15, maxQty: 40),
    DropEntry(itemId: 'runite_ore', chance: 0.1),
    DropEntry(itemId: 'black_dhide', chance: 0.2, minQty: 1, maxQty: 3),
  ],
  'cerberus': [
    DropEntry(itemId: 'primordial_crystal', chance: 0.03),
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'runite_ore', chance: 0.2, minQty: 1, maxQty: 3),
    DropEntry(itemId: 'raw_shark', chance: 0.5, minQty: 5, maxQty: 12),
  ],
  'hydra': [
    DropEntry(itemId: 'hydra_leather', chance: 0.02),
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 3, maxQty: 6),
    DropEntry(itemId: 'runite_ore', chance: 0.3, minQty: 2, maxQty: 5),
    DropEntry(itemId: 'black_dhide', chance: 0.4, minQty: 3, maxQty: 6),
  ],
};

// ─── Cooked Food → FoodItem mapping ─────────────────────────────
// Maps a cooked item id to its heal amount for combat food inventory.

const cookedFoodHealAmounts = <String, int>{
  'cooked_chicken': 3,
  'cooked_beef': 3,
  'cooked_shrimp': 3,
  'cooked_trout': 7,
  'cooked_lobster': 12,
  'cooked_swordfish': 14,
  'cooked_shark': 20,
  'cooked_anglerfish': 22,
};

// ─── Skilling Resource Definitions ──────────────────────────────

const skillingResources = <SkillingResource>[
  // ── Woodcutting ────────────────────────────────────────────────
  SkillingResource(
    id: 'wc_normal',
    name: 'Normal Tree',
    icon: '🌲',
    skill: SkillType.woodcutting,
    levelRequired: 1,
    xpPerAction: 25,
    producesItemId: 'logs',
  ),
  SkillingResource(
    id: 'wc_oak',
    name: 'Oak Tree',
    icon: '🌳',
    skill: SkillType.woodcutting,
    levelRequired: 15,
    xpPerAction: 38,
    producesItemId: 'oak_logs',
  ),
  SkillingResource(
    id: 'wc_willow',
    name: 'Willow Tree',
    icon: '🌴',
    skill: SkillType.woodcutting,
    levelRequired: 30,
    xpPerAction: 68,
    producesItemId: 'willow_logs',
  ),
  SkillingResource(
    id: 'wc_maple',
    name: 'Maple Tree',
    icon: '🍁',
    skill: SkillType.woodcutting,
    levelRequired: 45,
    xpPerAction: 100,
    producesItemId: 'maple_logs',
  ),
  SkillingResource(
    id: 'wc_yew',
    name: 'Yew Tree',
    icon: '🎄',
    skill: SkillType.woodcutting,
    levelRequired: 60,
    xpPerAction: 175,
    producesItemId: 'yew_logs',
  ),
  SkillingResource(
    id: 'wc_magic',
    name: 'Magic Tree',
    icon: '✨',
    skill: SkillType.woodcutting,
    levelRequired: 75,
    xpPerAction: 250,
    producesItemId: 'magic_logs',
  ),

  // ── Mining ─────────────────────────────────────────────────────
  SkillingResource(
    id: 'mine_copper',
    name: 'Copper Rock',
    icon: '🟤',
    skill: SkillType.mining,
    levelRequired: 1,
    xpPerAction: 18,
    producesItemId: 'copper_ore',
  ),
  SkillingResource(
    id: 'mine_tin',
    name: 'Tin Rock',
    icon: '⚪',
    skill: SkillType.mining,
    levelRequired: 1,
    xpPerAction: 18,
    producesItemId: 'tin_ore',
  ),
  SkillingResource(
    id: 'mine_iron',
    name: 'Iron Rock',
    icon: '🔘',
    skill: SkillType.mining,
    levelRequired: 15,
    xpPerAction: 35,
    producesItemId: 'iron_ore',
  ),
  SkillingResource(
    id: 'mine_coal',
    name: 'Coal Rock',
    icon: '⬛',
    skill: SkillType.mining,
    levelRequired: 30,
    xpPerAction: 50,
    producesItemId: 'coal',
  ),
  SkillingResource(
    id: 'mine_gold',
    name: 'Gold Rock',
    icon: '🟡',
    skill: SkillType.mining,
    levelRequired: 40,
    xpPerAction: 65,
    producesItemId: 'gold_ore',
  ),
  SkillingResource(
    id: 'mine_mithril',
    name: 'Mithril Rock',
    icon: '🔵',
    skill: SkillType.mining,
    levelRequired: 55,
    xpPerAction: 80,
    producesItemId: 'mithril_ore',
  ),
  SkillingResource(
    id: 'mine_adamantite',
    name: 'Adamantite Rock',
    icon: '🟢',
    skill: SkillType.mining,
    levelRequired: 70,
    xpPerAction: 95,
    producesItemId: 'adamantite_ore',
  ),
  SkillingResource(
    id: 'mine_runite',
    name: 'Runite Rock',
    icon: '🔷',
    skill: SkillType.mining,
    levelRequired: 85,
    xpPerAction: 125,
    producesItemId: 'runite_ore',
  ),

  // ── Fishing ────────────────────────────────────────────────────
  SkillingResource(
    id: 'fish_shrimp',
    name: 'Shrimps',
    icon: '🦐',
    skill: SkillType.fishing,
    levelRequired: 1,
    xpPerAction: 10,
    producesItemId: 'raw_shrimp',
  ),
  SkillingResource(
    id: 'fish_trout',
    name: 'Trout',
    icon: '🐟',
    skill: SkillType.fishing,
    levelRequired: 20,
    xpPerAction: 50,
    producesItemId: 'raw_trout',
  ),
  SkillingResource(
    id: 'fish_lobster',
    name: 'Lobster',
    icon: '🦞',
    skill: SkillType.fishing,
    levelRequired: 40,
    xpPerAction: 90,
    producesItemId: 'raw_lobster',
  ),
  SkillingResource(
    id: 'fish_swordfish',
    name: 'Swordfish',
    icon: '🐡',
    skill: SkillType.fishing,
    levelRequired: 50,
    xpPerAction: 100,
    producesItemId: 'raw_swordfish',
  ),
  SkillingResource(
    id: 'fish_shark',
    name: 'Shark',
    icon: '🦈',
    skill: SkillType.fishing,
    levelRequired: 76,
    xpPerAction: 110,
    producesItemId: 'raw_shark',
  ),
  SkillingResource(
    id: 'fish_anglerfish',
    name: 'Anglerfish',
    icon: '🎣',
    skill: SkillType.fishing,
    levelRequired: 82,
    xpPerAction: 120,
    producesItemId: 'raw_anglerfish',
  ),

  // ── Cooking ────────────────────────────────────────────────────
  SkillingResource(
    id: 'cook_chicken',
    name: 'Cook Chicken',
    icon: '🍗',
    skill: SkillType.cooking,
    levelRequired: 1,
    xpPerAction: 30,
    producesItemId: 'cooked_chicken',
    consumesItems: {'raw_chicken': 1},
    successRate: 0.7,
  ),
  SkillingResource(
    id: 'cook_beef',
    name: 'Cook Beef',
    icon: '🥩',
    skill: SkillType.cooking,
    levelRequired: 1,
    xpPerAction: 30,
    producesItemId: 'cooked_beef',
    consumesItems: {'raw_beef': 1},
    successRate: 0.7,
  ),
  SkillingResource(
    id: 'cook_shrimp',
    name: 'Cook Shrimps',
    icon: '🦐',
    skill: SkillType.cooking,
    levelRequired: 1,
    xpPerAction: 30,
    producesItemId: 'cooked_shrimp',
    consumesItems: {'raw_shrimp': 1},
    successRate: 0.7,
  ),
  SkillingResource(
    id: 'cook_trout',
    name: 'Cook Trout',
    icon: '🐟',
    skill: SkillType.cooking,
    levelRequired: 15,
    xpPerAction: 70,
    producesItemId: 'cooked_trout',
    consumesItems: {'raw_trout': 1},
    successRate: 0.65,
  ),
  SkillingResource(
    id: 'cook_lobster',
    name: 'Cook Lobster',
    icon: '🦞',
    skill: SkillType.cooking,
    levelRequired: 40,
    xpPerAction: 120,
    producesItemId: 'cooked_lobster',
    consumesItems: {'raw_lobster': 1},
    successRate: 0.6,
  ),
  SkillingResource(
    id: 'cook_swordfish',
    name: 'Cook Swordfish',
    icon: '🐡',
    skill: SkillType.cooking,
    levelRequired: 45,
    xpPerAction: 140,
    producesItemId: 'cooked_swordfish',
    consumesItems: {'raw_swordfish': 1},
    successRate: 0.55,
  ),
  SkillingResource(
    id: 'cook_shark',
    name: 'Cook Shark',
    icon: '🦈',
    skill: SkillType.cooking,
    levelRequired: 80,
    xpPerAction: 210,
    producesItemId: 'cooked_shark',
    consumesItems: {'raw_shark': 1},
    successRate: 0.5,
  ),
  SkillingResource(
    id: 'cook_anglerfish',
    name: 'Cook Anglerfish',
    icon: '🎣',
    skill: SkillType.cooking,
    levelRequired: 84,
    xpPerAction: 230,
    producesItemId: 'cooked_anglerfish',
    consumesItems: {'raw_anglerfish': 1},
    successRate: 0.45,
  ),

  // ── Smithing — Smelting ────────────────────────────────────────
  SkillingResource(
    id: 'smelt_bronze',
    name: 'Smelt Bronze',
    icon: '🟫',
    skill: SkillType.smithing,
    levelRequired: 1,
    xpPerAction: 6,
    producesItemId: 'bronze_bar',
    consumesItems: {'copper_ore': 1, 'tin_ore': 1},
  ),
  SkillingResource(
    id: 'smelt_iron',
    name: 'Smelt Iron',
    icon: '⬜',
    skill: SkillType.smithing,
    levelRequired: 15,
    xpPerAction: 13,
    producesItemId: 'iron_bar',
    consumesItems: {'iron_ore': 1},
    successRate: 0.5,
  ),
  SkillingResource(
    id: 'smelt_steel',
    name: 'Smelt Steel',
    icon: '🩶',
    skill: SkillType.smithing,
    levelRequired: 30,
    xpPerAction: 18,
    producesItemId: 'steel_bar',
    consumesItems: {'iron_ore': 1, 'coal': 2},
  ),
  SkillingResource(
    id: 'smelt_gold',
    name: 'Smelt Gold',
    icon: '🥇',
    skill: SkillType.smithing,
    levelRequired: 40,
    xpPerAction: 22,
    producesItemId: 'gold_bar',
    consumesItems: {'gold_ore': 1},
  ),
  SkillingResource(
    id: 'smelt_mithril',
    name: 'Smelt Mithril',
    icon: '💙',
    skill: SkillType.smithing,
    levelRequired: 50,
    xpPerAction: 30,
    producesItemId: 'mithril_bar',
    consumesItems: {'mithril_ore': 1, 'coal': 4},
  ),
  SkillingResource(
    id: 'smelt_adamantite',
    name: 'Smelt Adamantite',
    icon: '💚',
    skill: SkillType.smithing,
    levelRequired: 70,
    xpPerAction: 38,
    producesItemId: 'adamantite_bar',
    consumesItems: {'adamantite_ore': 1, 'coal': 6},
  ),
  SkillingResource(
    id: 'smelt_rune',
    name: 'Smelt Rune',
    icon: '💎',
    skill: SkillType.smithing,
    levelRequired: 85,
    xpPerAction: 50,
    producesItemId: 'rune_bar',
    consumesItems: {'runite_ore': 1, 'coal': 8},
  ),

  // ── Smithing — Forging ─────────────────────────────────────────
  SkillingResource(
    id: 'smith_bronze_plate',
    name: 'Bronze Platebody',
    icon: '🛡️',
    skill: SkillType.smithing,
    levelRequired: 18,
    xpPerAction: 63,
    producesItemId: 'bronze_platebody',
    consumesItems: {'bronze_bar': 5},
  ),
  SkillingResource(
    id: 'smith_iron_plate',
    name: 'Iron Platebody',
    icon: '🛡️',
    skill: SkillType.smithing,
    levelRequired: 33,
    xpPerAction: 125,
    producesItemId: 'iron_platebody',
    consumesItems: {'iron_bar': 5},
  ),
  SkillingResource(
    id: 'smith_steel_plate',
    name: 'Steel Platebody',
    icon: '🛡️',
    skill: SkillType.smithing,
    levelRequired: 48,
    xpPerAction: 188,
    producesItemId: 'steel_platebody',
    consumesItems: {'steel_bar': 5},
  ),
  SkillingResource(
    id: 'smith_mithril_plate',
    name: 'Mithril Platebody',
    icon: '🛡️',
    skill: SkillType.smithing,
    levelRequired: 68,
    xpPerAction: 250,
    producesItemId: 'mithril_platebody',
    consumesItems: {'mithril_bar': 5},
  ),
  SkillingResource(
    id: 'smith_adamant_plate',
    name: 'Adamant Platebody',
    icon: '🛡️',
    skill: SkillType.smithing,
    levelRequired: 88,
    xpPerAction: 313,
    producesItemId: 'adamant_platebody',
    consumesItems: {'adamantite_bar': 5},
  ),
  SkillingResource(
    id: 'smith_rune_plate',
    name: 'Rune Platebody',
    icon: '🛡️',
    skill: SkillType.smithing,
    levelRequired: 99,
    xpPerAction: 375,
    producesItemId: 'rune_platebody',
    consumesItems: {'rune_bar': 5},
  ),

  // ── Crafting ───────────────────────────────────────────────────
  SkillingResource(
    id: 'craft_leather',
    name: 'Tan Leather',
    icon: '🟫',
    skill: SkillType.crafting,
    levelRequired: 1,
    xpPerAction: 14,
    producesItemId: 'leather',
    consumesItems: {'cowhide': 1},
  ),
  SkillingResource(
    id: 'craft_green_dhide',
    name: 'Green D\'hide Body',
    icon: '🟩',
    skill: SkillType.crafting,
    levelRequired: 63,
    xpPerAction: 186,
    producesItemId: 'green_dhide_body',
    consumesItems: {'green_dhide': 3},
  ),
  SkillingResource(
    id: 'craft_black_dhide',
    name: 'Black D\'hide Body',
    icon: '⬛',
    skill: SkillType.crafting,
    levelRequired: 84,
    xpPerAction: 258,
    producesItemId: 'black_dhide_body',
    consumesItems: {'black_dhide': 3},
  ),
];

SkillingResource? getSkillingResourceById(String id) {
  for (final r in skillingResources) {
    if (r.id == id) return r;
  }
  return null;
}

List<SkillingResource> getResourcesForSkill(SkillType skill) {
  return skillingResources.where((r) => r.skill == skill).toList();
}
