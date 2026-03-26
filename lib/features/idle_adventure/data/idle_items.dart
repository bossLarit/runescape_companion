import '../domain/idle_models.dart';

// ─── Equipment Catalog ──────────────────────────────────────────
// OSRS-accurate equipment items with stat bonuses and requirements.

const equipmentDefs = <EquipmentItemDef>[
  // ── Weapons ────────────────────────────────────────────────────
  // Bronze → Rune melee weapons
  EquipmentItemDef(
      id: 'bronze_scimitar',
      name: 'Bronze Scimitar',
      icon: '🗡️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 7,
      meleeStrength: 6,
      buyPrice: 32),
  EquipmentItemDef(
      id: 'iron_scimitar',
      name: 'Iron Scimitar',
      icon: '🗡️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 10,
      meleeStrength: 9,
      attackReq: 1,
      buyPrice: 112),
  EquipmentItemDef(
      id: 'steel_scimitar',
      name: 'Steel Scimitar',
      icon: '🗡️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 15,
      meleeStrength: 14,
      attackReq: 5,
      buyPrice: 400),
  EquipmentItemDef(
      id: 'mithril_scimitar',
      name: 'Mithril Scimitar',
      icon: '🗡️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 21,
      meleeStrength: 20,
      attackReq: 20,
      buyPrice: 1040),
  EquipmentItemDef(
      id: 'adamant_scimitar',
      name: 'Adamant Scimitar',
      icon: '🗡️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 29,
      meleeStrength: 28,
      attackReq: 30,
      buyPrice: 2560),
  EquipmentItemDef(
      id: 'rune_scimitar',
      name: 'Rune Scimitar',
      icon: '🗡️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 45,
      meleeStrength: 44,
      attackReq: 40),
  // Dragon+
  EquipmentItemDef(
      id: 'dragon_scimitar',
      name: 'Dragon Scimitar',
      icon: '🐉',
      slot: EquipmentSlot.weapon,
      meleeAttack: 67,
      meleeStrength: 66,
      attackReq: 60),
  EquipmentItemDef(
      id: 'abyssal_whip_eq',
      name: 'Abyssal Whip',
      icon: '🪢',
      slot: EquipmentSlot.weapon,
      meleeAttack: 82,
      meleeStrength: 82,
      attackReq: 70),
  EquipmentItemDef(
      id: 'tentacle_whip',
      name: 'Abyssal Tentacle',
      icon: '🐙',
      slot: EquipmentSlot.weapon,
      meleeAttack: 90,
      meleeStrength: 86,
      attackReq: 75),
  EquipmentItemDef(
      id: 'ghrazi_rapier',
      name: 'Ghrazi Rapier',
      icon: '⚔️',
      slot: EquipmentSlot.weapon,
      meleeAttack: 94,
      meleeStrength: 89,
      attackReq: 75),
  // Ranged weapons
  EquipmentItemDef(
      id: 'shortbow',
      name: 'Shortbow',
      icon: '🏹',
      slot: EquipmentSlot.weapon,
      rangedAttack: 8,
      buyPrice: 50),
  EquipmentItemDef(
      id: 'maple_shortbow',
      name: 'Maple Shortbow',
      icon: '🏹',
      slot: EquipmentSlot.weapon,
      rangedAttack: 29,
      rangedReq: 30,
      buyPrice: 400),
  EquipmentItemDef(
      id: 'magic_shortbow',
      name: 'Magic Shortbow',
      icon: '🏹',
      slot: EquipmentSlot.weapon,
      rangedAttack: 69,
      rangedReq: 50),
  EquipmentItemDef(
      id: 'rune_crossbow',
      name: 'Rune Crossbow',
      icon: '🏹',
      slot: EquipmentSlot.weapon,
      rangedAttack: 90,
      rangedReq: 61),
  EquipmentItemDef(
      id: 'armadyl_crossbow',
      name: 'Armadyl Crossbow',
      icon: '🦅',
      slot: EquipmentSlot.weapon,
      rangedAttack: 100,
      rangedReq: 70,
      prayerBonus: 1),
  EquipmentItemDef(
      id: 'twisted_bow',
      name: 'Twisted Bow',
      icon: '🎯',
      slot: EquipmentSlot.weapon,
      rangedAttack: 70,
      rangedStrength: 20,
      rangedReq: 75,
      prayerBonus: 4),
  // Magic weapons
  EquipmentItemDef(
      id: 'staff_of_fire',
      name: 'Staff of Fire',
      icon: '🔥',
      slot: EquipmentSlot.weapon,
      magicAttack: 10,
      buyPrice: 200),
  EquipmentItemDef(
      id: 'mystic_fire_staff',
      name: 'Mystic Fire Staff',
      icon: '🔥',
      slot: EquipmentSlot.weapon,
      magicAttack: 10,
      magicReq: 40,
      attackReq: 40,
      buyPrice: 1500),
  EquipmentItemDef(
      id: 'ancient_staff',
      name: 'Ancient Staff',
      icon: '🔮',
      slot: EquipmentSlot.weapon,
      magicAttack: 15,
      magicStrength: 5,
      magicReq: 50),
  EquipmentItemDef(
      id: 'trident_of_the_seas',
      name: 'Trident of the Seas',
      icon: '🔱',
      slot: EquipmentSlot.weapon,
      magicAttack: 25,
      magicStrength: 15,
      magicReq: 75),
  EquipmentItemDef(
      id: 'sanguinesti_staff',
      name: 'Sanguinesti Staff',
      icon: '🩸',
      slot: EquipmentSlot.weapon,
      magicAttack: 25,
      magicStrength: 20,
      magicReq: 75),

  // ── Head ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'bronze_full_helm',
      name: 'Bronze Full Helm',
      icon: '⛑️',
      slot: EquipmentSlot.head,
      meleeDefence: 4,
      buyPrice: 44),
  EquipmentItemDef(
      id: 'iron_full_helm',
      name: 'Iron Full Helm',
      icon: '⛑️',
      slot: EquipmentSlot.head,
      meleeDefence: 7,
      defenceReq: 1,
      buyPrice: 154),
  EquipmentItemDef(
      id: 'steel_full_helm',
      name: 'Steel Full Helm',
      icon: '⛑️',
      slot: EquipmentSlot.head,
      meleeDefence: 12,
      defenceReq: 5,
      buyPrice: 550),
  EquipmentItemDef(
      id: 'mithril_full_helm',
      name: 'Mithril Full Helm',
      icon: '⛑️',
      slot: EquipmentSlot.head,
      meleeDefence: 17,
      defenceReq: 20,
      buyPrice: 1430),
  EquipmentItemDef(
      id: 'adamant_full_helm',
      name: 'Adamant Full Helm',
      icon: '⛑️',
      slot: EquipmentSlot.head,
      meleeDefence: 24,
      defenceReq: 30,
      buyPrice: 3520),
  EquipmentItemDef(
      id: 'rune_full_helm',
      name: 'Rune Full Helm',
      icon: '⛑️',
      slot: EquipmentSlot.head,
      meleeDefence: 33,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'helm_of_neitiznot',
      name: 'Helm of Neitiznot',
      icon: '🪖',
      slot: EquipmentSlot.head,
      meleeDefence: 31,
      meleeStrength: 3,
      prayerBonus: 3,
      defenceReq: 55),
  EquipmentItemDef(
      id: 'serpentine_helm',
      name: 'Serpentine Helm',
      icon: '🐍',
      slot: EquipmentSlot.head,
      meleeDefence: 52,
      meleeStrength: 5,
      defenceReq: 75),
  EquipmentItemDef(
      id: 'torva_full_helm',
      name: 'Torva Full Helm',
      icon: '👑',
      slot: EquipmentSlot.head,
      meleeDefence: 59,
      meleeStrength: 8,
      prayerBonus: 1,
      defenceReq: 80),

  // ── Body ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'bronze_platebody',
      name: 'Bronze Platebody',
      icon: '🛡️',
      slot: EquipmentSlot.body,
      meleeDefence: 15,
      buyPrice: 160),
  EquipmentItemDef(
      id: 'iron_platebody',
      name: 'Iron Platebody',
      icon: '🛡️',
      slot: EquipmentSlot.body,
      meleeDefence: 21,
      defenceReq: 1,
      buyPrice: 560),
  EquipmentItemDef(
      id: 'steel_platebody',
      name: 'Steel Platebody',
      icon: '🛡️',
      slot: EquipmentSlot.body,
      meleeDefence: 32,
      defenceReq: 5,
      buyPrice: 2000),
  EquipmentItemDef(
      id: 'mithril_platebody',
      name: 'Mithril Platebody',
      icon: '🛡️',
      slot: EquipmentSlot.body,
      meleeDefence: 46,
      defenceReq: 20,
      buyPrice: 5200),
  EquipmentItemDef(
      id: 'adamant_platebody',
      name: 'Adamant Platebody',
      icon: '🛡️',
      slot: EquipmentSlot.body,
      meleeDefence: 65,
      defenceReq: 30,
      buyPrice: 12800),
  EquipmentItemDef(
      id: 'rune_platebody',
      name: 'Rune Platebody',
      icon: '🛡️',
      slot: EquipmentSlot.body,
      meleeDefence: 82,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'fighter_torso',
      name: 'Fighter Torso',
      icon: '💪',
      slot: EquipmentSlot.body,
      meleeDefence: 40,
      meleeStrength: 4,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'bandos_chestplate',
      name: 'Bandos Chestplate',
      icon: '⚔️',
      slot: EquipmentSlot.body,
      meleeDefence: 98,
      meleeStrength: 4,
      defenceReq: 65),
  EquipmentItemDef(
      id: 'torva_platebody',
      name: 'Torva Platebody',
      icon: '👑',
      slot: EquipmentSlot.body,
      meleeDefence: 106,
      meleeStrength: 6,
      prayerBonus: 1,
      defenceReq: 80),
  // Ranged body
  EquipmentItemDef(
      id: 'leather_body',
      name: 'Leather Body',
      icon: '🧥',
      slot: EquipmentSlot.body,
      rangedAttack: 2,
      meleeDefence: 7,
      buyPrice: 21),
  EquipmentItemDef(
      id: 'green_dhide_body_eq',
      name: 'Green D\'hide Body',
      icon: '🟩',
      slot: EquipmentSlot.body,
      rangedAttack: 15,
      meleeDefence: 40,
      rangedReq: 40,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'black_dhide_body_eq',
      name: 'Black D\'hide Body',
      icon: '⬛',
      slot: EquipmentSlot.body,
      rangedAttack: 30,
      meleeDefence: 55,
      rangedReq: 70,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'armadyl_chestplate',
      name: 'Armadyl Chestplate',
      icon: '🦅',
      slot: EquipmentSlot.body,
      rangedAttack: 33,
      meleeDefence: 56,
      prayerBonus: 1,
      rangedReq: 70,
      defenceReq: 70),
  // Magic body
  EquipmentItemDef(
      id: 'wizard_robe_top',
      name: 'Wizard Robe Top',
      icon: '🧙',
      slot: EquipmentSlot.body,
      magicAttack: 3,
      buyPrice: 15),
  EquipmentItemDef(
      id: 'mystic_robe_top',
      name: 'Mystic Robe Top',
      icon: '🔮',
      slot: EquipmentSlot.body,
      magicAttack: 20,
      magicReq: 40,
      defenceReq: 20),
  EquipmentItemDef(
      id: 'ahrims_robetop',
      name: 'Ahrim\'s Robetop',
      icon: '⚰️',
      slot: EquipmentSlot.body,
      magicAttack: 25,
      meleeDefence: 52,
      magicReq: 70,
      defenceReq: 70),
  EquipmentItemDef(
      id: 'ancestral_robe_top',
      name: 'Ancestral Robe Top',
      icon: '📜',
      slot: EquipmentSlot.body,
      magicAttack: 35,
      magicStrength: 2,
      magicReq: 75,
      defenceReq: 65),

  // ── Legs ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'bronze_platelegs',
      name: 'Bronze Platelegs',
      icon: '🦿',
      slot: EquipmentSlot.legs,
      meleeDefence: 7,
      buyPrice: 80),
  EquipmentItemDef(
      id: 'iron_platelegs',
      name: 'Iron Platelegs',
      icon: '🦿',
      slot: EquipmentSlot.legs,
      meleeDefence: 10,
      defenceReq: 1,
      buyPrice: 280),
  EquipmentItemDef(
      id: 'steel_platelegs',
      name: 'Steel Platelegs',
      icon: '🦿',
      slot: EquipmentSlot.legs,
      meleeDefence: 16,
      defenceReq: 5,
      buyPrice: 1000),
  EquipmentItemDef(
      id: 'mithril_platelegs',
      name: 'Mithril Platelegs',
      icon: '🦿',
      slot: EquipmentSlot.legs,
      meleeDefence: 22,
      defenceReq: 20,
      buyPrice: 2600),
  EquipmentItemDef(
      id: 'adamant_platelegs',
      name: 'Adamant Platelegs',
      icon: '🦿',
      slot: EquipmentSlot.legs,
      meleeDefence: 33,
      defenceReq: 30,
      buyPrice: 6400),
  EquipmentItemDef(
      id: 'rune_platelegs',
      name: 'Rune Platelegs',
      icon: '🦿',
      slot: EquipmentSlot.legs,
      meleeDefence: 51,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'bandos_tassets',
      name: 'Bandos Tassets',
      icon: '⚔️',
      slot: EquipmentSlot.legs,
      meleeDefence: 71,
      meleeStrength: 2,
      prayerBonus: 1,
      defenceReq: 65),
  EquipmentItemDef(
      id: 'torva_platelegs',
      name: 'Torva Platelegs',
      icon: '👑',
      slot: EquipmentSlot.legs,
      meleeDefence: 75,
      meleeStrength: 4,
      prayerBonus: 1,
      defenceReq: 80),

  // ── Shield ─────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'bronze_kiteshield',
      name: 'Bronze Kiteshield',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 8,
      buyPrice: 68),
  EquipmentItemDef(
      id: 'iron_kiteshield',
      name: 'Iron Kiteshield',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 12,
      defenceReq: 1,
      buyPrice: 238),
  EquipmentItemDef(
      id: 'steel_kiteshield',
      name: 'Steel Kiteshield',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 19,
      defenceReq: 5,
      buyPrice: 850),
  EquipmentItemDef(
      id: 'mithril_kiteshield',
      name: 'Mithril Kiteshield',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 24,
      defenceReq: 20,
      buyPrice: 2210),
  EquipmentItemDef(
      id: 'adamant_kiteshield',
      name: 'Adamant Kiteshield',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 33,
      defenceReq: 30,
      buyPrice: 5440),
  EquipmentItemDef(
      id: 'rune_kiteshield',
      name: 'Rune Kiteshield',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 44,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'dragon_defender',
      name: 'Dragon Defender',
      icon: '🐲',
      slot: EquipmentSlot.shield,
      meleeDefence: 25,
      meleeAttack: 25,
      meleeStrength: 6,
      defenceReq: 60),
  EquipmentItemDef(
      id: 'avernic_defender',
      name: 'Avernic Defender',
      icon: '💀',
      slot: EquipmentSlot.shield,
      meleeDefence: 29,
      meleeAttack: 30,
      meleeStrength: 8,
      defenceReq: 70),

  // ── Cape ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'obsidian_cape_eq',
      name: 'Obsidian Cape',
      icon: '🧥',
      slot: EquipmentSlot.cape,
      meleeDefence: 9,
      buyPrice: 5000),
  EquipmentItemDef(
      id: 'fire_cape_eq',
      name: 'Fire Cape',
      icon: '🔥',
      slot: EquipmentSlot.cape,
      meleeDefence: 11,
      meleeStrength: 4,
      prayerBonus: 2),
  EquipmentItemDef(
      id: 'infernal_cape',
      name: 'Infernal Cape',
      icon: '🌋',
      slot: EquipmentSlot.cape,
      meleeDefence: 12,
      meleeStrength: 8,
      prayerBonus: 2),
  EquipmentItemDef(
      id: 'avas_accumulator',
      name: 'Ava\'s Accumulator',
      icon: '🧲',
      slot: EquipmentSlot.cape,
      rangedAttack: 4,
      rangedReq: 50),
  EquipmentItemDef(
      id: 'avas_assembler',
      name: 'Ava\'s Assembler',
      icon: '🧲',
      slot: EquipmentSlot.cape,
      rangedAttack: 8,
      rangedStrength: 2,
      rangedReq: 70),

  // ── Neck ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'amulet_of_strength',
      name: 'Amulet of Strength',
      icon: '📿',
      slot: EquipmentSlot.neck,
      meleeStrength: 10,
      buyPrice: 2000),
  EquipmentItemDef(
      id: 'amulet_of_glory',
      name: 'Amulet of Glory',
      icon: '📿',
      slot: EquipmentSlot.neck,
      meleeAttack: 10,
      meleeStrength: 6,
      meleeDefence: 3,
      rangedAttack: 3,
      magicAttack: 3,
      buyPrice: 5000),
  EquipmentItemDef(
      id: 'amulet_of_fury',
      name: 'Amulet of Fury',
      icon: '📿',
      slot: EquipmentSlot.neck,
      meleeAttack: 10,
      meleeStrength: 8,
      meleeDefence: 15,
      rangedAttack: 10,
      magicAttack: 10,
      prayerBonus: 5),
  EquipmentItemDef(
      id: 'amulet_of_torture',
      name: 'Amulet of Torture',
      icon: '⛓️',
      slot: EquipmentSlot.neck,
      meleeAttack: 15,
      meleeStrength: 10,
      meleeDefence: 0),
  EquipmentItemDef(
      id: 'necklace_of_anguish',
      name: 'Necklace of Anguish',
      icon: '🔗',
      slot: EquipmentSlot.neck,
      rangedAttack: 15,
      rangedStrength: 5,
      prayerBonus: 2),
  EquipmentItemDef(
      id: 'occult_necklace',
      name: 'Occult Necklace',
      icon: '🔮',
      slot: EquipmentSlot.neck,
      magicAttack: 12,
      magicStrength: 10),

  // ── Ring ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'ring_of_wealth',
      name: 'Ring of Wealth',
      icon: '💍',
      slot: EquipmentSlot.ring,
      buyPrice: 3000),
  EquipmentItemDef(
      id: 'berserker_ring',
      name: 'Berserker Ring',
      icon: '💍',
      slot: EquipmentSlot.ring,
      meleeAttack: 4,
      meleeStrength: 4),
  EquipmentItemDef(
      id: 'berserker_ring_i',
      name: 'Berserker Ring (i)',
      icon: '💍',
      slot: EquipmentSlot.ring,
      meleeAttack: 8,
      meleeStrength: 8),
  EquipmentItemDef(
      id: 'archers_ring',
      name: 'Archers Ring',
      icon: '💍',
      slot: EquipmentSlot.ring,
      rangedAttack: 4),
  EquipmentItemDef(
      id: 'archers_ring_i',
      name: 'Archers Ring (i)',
      icon: '💍',
      slot: EquipmentSlot.ring,
      rangedAttack: 8),
  EquipmentItemDef(
      id: 'seers_ring',
      name: 'Seers Ring',
      icon: '💍',
      slot: EquipmentSlot.ring,
      magicAttack: 4),
  EquipmentItemDef(
      id: 'seers_ring_i',
      name: 'Seers Ring (i)',
      icon: '💍',
      slot: EquipmentSlot.ring,
      magicAttack: 8),
  EquipmentItemDef(
      id: 'ultor_ring',
      name: 'Ultor Ring',
      icon: '💎',
      slot: EquipmentSlot.ring,
      meleeStrength: 12),

  // ── Hands ──────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'leather_gloves',
      name: 'Leather Gloves',
      icon: '🧤',
      slot: EquipmentSlot.hands,
      meleeDefence: 1,
      buyPrice: 6),
  EquipmentItemDef(
      id: 'combat_bracelet',
      name: 'Combat Bracelet',
      icon: '🧤',
      slot: EquipmentSlot.hands,
      meleeAttack: 5,
      meleeStrength: 5,
      meleeDefence: 5,
      buyPrice: 5000),
  EquipmentItemDef(
      id: 'barrows_gloves',
      name: 'Barrows Gloves',
      icon: '🧤',
      slot: EquipmentSlot.hands,
      meleeAttack: 12,
      meleeStrength: 12,
      meleeDefence: 12,
      rangedAttack: 12,
      magicAttack: 6,
      defenceReq: 40),
  EquipmentItemDef(
      id: 'ferocious_gloves',
      name: 'Ferocious Gloves',
      icon: '🧤',
      slot: EquipmentSlot.hands,
      meleeAttack: 16,
      meleeStrength: 14,
      meleeDefence: 0,
      attackReq: 80,
      defenceReq: 80),

  // ── Feet ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'leather_boots',
      name: 'Leather Boots',
      icon: '👢',
      slot: EquipmentSlot.feet,
      meleeDefence: 1,
      buyPrice: 6),
  EquipmentItemDef(
      id: 'climbing_boots',
      name: 'Climbing Boots',
      icon: '🥾',
      slot: EquipmentSlot.feet,
      meleeStrength: 2,
      meleeDefence: 2,
      buyPrice: 500),
  EquipmentItemDef(
      id: 'dragon_boots',
      name: 'Dragon Boots',
      icon: '🐉',
      slot: EquipmentSlot.feet,
      meleeStrength: 4,
      meleeDefence: 5,
      defenceReq: 60),
  EquipmentItemDef(
      id: 'primordial_boots',
      name: 'Primordial Boots',
      icon: '💎',
      slot: EquipmentSlot.feet,
      meleeAttack: 2,
      meleeStrength: 5,
      meleeDefence: 22,
      defenceReq: 75),

  // ── Ammo ───────────────────────────────────────────────────────
  EquipmentItemDef(
      id: 'iron_arrows',
      name: 'Iron Arrows',
      icon: '➡️',
      slot: EquipmentSlot.ammo,
      rangedStrength: 10,
      buyPrice: 20),
  EquipmentItemDef(
      id: 'mithril_arrows',
      name: 'Mithril Arrows',
      icon: '➡️',
      slot: EquipmentSlot.ammo,
      rangedStrength: 22,
      rangedReq: 1,
      buyPrice: 80),
  EquipmentItemDef(
      id: 'adamant_arrows',
      name: 'Adamant Arrows',
      icon: '➡️',
      slot: EquipmentSlot.ammo,
      rangedStrength: 31,
      rangedReq: 30,
      buyPrice: 200),
  EquipmentItemDef(
      id: 'rune_arrows',
      name: 'Rune Arrows',
      icon: '➡️',
      slot: EquipmentSlot.ammo,
      rangedStrength: 49,
      rangedReq: 40),
  EquipmentItemDef(
      id: 'dragon_arrows',
      name: 'Dragon Arrows',
      icon: '🐲',
      slot: EquipmentSlot.ammo,
      rangedStrength: 60,
      rangedReq: 60),
  EquipmentItemDef(
      id: 'ruby_bolts_e',
      name: 'Ruby Bolts (e)',
      icon: '🔴',
      slot: EquipmentSlot.ammo,
      rangedStrength: 103,
      rangedReq: 63),
  EquipmentItemDef(
      id: 'diamond_bolts_e',
      name: 'Diamond Bolts (e)',
      icon: '💎',
      slot: EquipmentSlot.ammo,
      rangedStrength: 105,
      rangedReq: 65),

  // ── Chambers of Xeric Uniques ─────────────────────────────────
  EquipmentItemDef(
      id: 'dragon_claws',
      name: 'Dragon Claws',
      icon: '🐉',
      slot: EquipmentSlot.weapon,
      meleeAttack: 57,
      meleeStrength: 56,
      attackReq: 60),
  EquipmentItemDef(
      id: 'elder_maul',
      name: 'Elder Maul',
      icon: '🔨',
      slot: EquipmentSlot.weapon,
      meleeAttack: 135,
      meleeStrength: 147,
      attackReq: 75,
      defenceReq: 0),
  EquipmentItemDef(
      id: 'kodai_wand',
      name: 'Kodai Wand',
      icon: '🪄',
      slot: EquipmentSlot.weapon,
      magicAttack: 28,
      magicStrength: 15,
      magicReq: 75),
  EquipmentItemDef(
      id: 'dragon_hunter_crossbow',
      name: 'Dragon Hunter Crossbow',
      icon: '🏹',
      slot: EquipmentSlot.weapon,
      rangedAttack: 95,
      rangedReq: 65),
  EquipmentItemDef(
      id: 'twisted_buckler',
      name: 'Twisted Buckler',
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      rangedAttack: 10,
      rangedStrength: 2,
      meleeDefence: 38,
      rangedReq: 75,
      defenceReq: 75),
  EquipmentItemDef(
      id: 'dinhs_bulwark',
      name: "Dinh's Bulwark",
      icon: '🛡️',
      slot: EquipmentSlot.shield,
      meleeDefence: 103,
      defenceReq: 75),
  EquipmentItemDef(
      id: 'ancestral_hat',
      name: 'Ancestral Hat',
      icon: '📜',
      slot: EquipmentSlot.head,
      magicAttack: 8,
      magicStrength: 2,
      magicReq: 75,
      defenceReq: 65),
  EquipmentItemDef(
      id: 'ancestral_robe_bottom',
      name: 'Ancestral Robe Bottom',
      icon: '📜',
      slot: EquipmentSlot.legs,
      magicAttack: 26,
      magicStrength: 2,
      magicReq: 75,
      defenceReq: 65),
];

/// Maps LootItem IDs to their corresponding equipment def IDs.
const _equipAliases = <String, String>{
  'fire_cape': 'fire_cape_eq',
  'obsidian_cape': 'obsidian_cape_eq',
  'abyssal_whip': 'abyssal_whip_eq',
  'green_dhide_body': 'green_dhide_body_eq',
  'black_dhide_body': 'black_dhide_body_eq',
};

/// Find equipment def by id (also checks LootItem → equipment aliases).
EquipmentItemDef? getEquipmentDefById(String id) {
  for (final e in equipmentDefs) {
    if (e.id == id) return e;
  }
  final alias = _equipAliases[id];
  if (alias != null) {
    for (final e in equipmentDefs) {
      if (e.id == alias) return e;
    }
  }
  return null;
}

/// Get all buyable equipment (buyPrice > 0).
List<EquipmentItemDef> get shopEquipment =>
    equipmentDefs.where((e) => e.buyPrice > 0).toList();

// ─── Item Catalog ───────────────────────────────────────────────
// Every item that can exist in the bank.

const allItems = <LootItem>[
  // ── Bones ────────────────────────────────────────────────────
  LootItem(id: 'bones', name: 'Bones', icon: '🦴', category: 'bone'),
  LootItem(id: 'big_bones', name: 'Big Bones', icon: '🦴', category: 'bone'),
  LootItem(
      id: 'dragon_bones', name: 'Dragon Bones', icon: '🦴', category: 'bone'),

  // ── Raw Fish ─────────────────────────────────────────────────
  LootItem(
      id: 'raw_shrimp', name: 'Raw Shrimps', icon: '🦐', category: 'fish_raw'),
  LootItem(
      id: 'raw_trout', name: 'Raw Trout', icon: '🐟', category: 'fish_raw'),
  LootItem(
      id: 'raw_lobster', name: 'Raw Lobster', icon: '🦞', category: 'fish_raw'),
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
      id: 'raw_chicken', name: 'Raw Chicken', icon: '🍗', category: 'fish_raw'),
  LootItem(id: 'raw_beef', name: 'Raw Beef', icon: '🥩', category: 'fish_raw'),

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
  LootItem(id: 'mithril_ore', name: 'Mithril Ore', icon: '🔵', category: 'ore'),
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
  LootItem(id: 'mithril_bar', name: 'Mithril Bar', icon: '💙', category: 'bar'),
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
  LootItem(id: 'willow_logs', name: 'Willow Logs', icon: '🪵', category: 'log'),
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
      id: 'black_dhide', name: 'Black Dragonhide', icon: '⬛', category: 'hide'),

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
  LootItem(id: 'chaos_rune', name: 'Chaos Rune', icon: '🟣', category: 'rune'),
  LootItem(
      id: 'rune_essence', name: 'Rune Essence', icon: '⚪', category: 'rune'),

  // ── Misc Drops ───────────────────────────────────────────────
  LootItem(id: 'feathers', name: 'Feathers', icon: '🪶', category: 'misc'),
  LootItem(
      id: 'goblin_mail', name: 'Goblin Mail', icon: '📮', category: 'misc'),
  LootItem(
      id: 'bronze_spear', name: 'Bronze Spear', icon: '🔱', category: 'misc'),
  LootItem(
      id: 'limpwurt_root', name: 'Limpwurt Root', icon: '🌱', category: 'misc'),
  LootItem(id: 'tokkul', name: 'Tokkul', icon: '🪙', category: 'misc'),
  LootItem(
      id: 'obsidian_cape', name: 'Obsidian Cape', icon: '🧥', category: 'misc'),
  LootItem(id: 'fire_cape', name: 'Fire Cape', icon: '🔥', category: 'misc'),

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

  // ── Boss Unique Drops ───────────────────────────────────────
  LootItem(id: 'bolt_rack', name: 'Bolt Rack', icon: '➡️', category: 'misc'),
  LootItem(
      id: 'dragon_chainbody',
      name: 'Dragon Chainbody',
      icon: '🐉',
      category: 'misc'),
  LootItem(
      id: 'dragon_med_helm',
      name: 'Dragon Med Helm',
      icon: '🐉',
      category: 'misc'),
  LootItem(
      id: 'dragon_spear', name: 'Dragon Spear', icon: '🐉', category: 'misc'),
  LootItem(
      id: 'shield_left_half',
      name: 'Shield Left Half',
      icon: '🛡️',
      category: 'misc'),
  LootItem(
      id: 'staff_of_the_dead',
      name: 'Staff of the Dead',
      icon: '💀',
      category: 'misc'),
  LootItem(
      id: 'zamorakian_spear',
      name: 'Zamorakian Spear',
      icon: '😈',
      category: 'misc'),
  LootItem(
      id: 'steam_battlestaff',
      name: 'Steam Battlestaff',
      icon: '💨',
      category: 'misc'),
  LootItem(
      id: 'mud_battlestaff',
      name: 'Mud Battlestaff',
      icon: '🌊',
      category: 'misc'),

  // ── Slayer Unique Drops ──────────────────────────────────────
  LootItem(
      id: 'dust_battlestaff',
      name: 'Dust Battlestaff',
      icon: '🌪️',
      category: 'misc'),
  LootItem(
      id: 'granite_legs', name: 'Granite Legs', icon: '🦿', category: 'misc'),
  LootItem(
      id: 'abyssal_whip', name: 'Abyssal Whip', icon: '🪢', category: 'misc'),
  LootItem(
      id: 'primordial_crystal',
      name: 'Primordial Crystal',
      icon: '💎',
      category: 'misc'),
  LootItem(
      id: 'hydra_leather', name: 'Hydra Leather', icon: '🐲', category: 'misc'),

  // ── CoX Unique Drops (non-equipment) ─────────────────────────
  LootItem(
      id: 'dexterous_prayer_scroll',
      name: 'Dexterous Prayer Scroll',
      icon: '📜',
      category: 'misc'),
  LootItem(
      id: 'arcane_prayer_scroll',
      name: 'Arcane Prayer Scroll',
      icon: '📜',
      category: 'misc'),
  LootItem(
      id: 'kodai_insignia',
      name: 'Kodai Insignia',
      icon: '🪄',
      category: 'misc'),

  // ── Tools (purchasable for skilling) ─────────────────────────
  LootItem(id: 'axe', name: 'Axe', icon: '🪓', category: 'tool', buyPrice: 50),
  LootItem(
      id: 'pickaxe',
      name: 'Pickaxe',
      icon: '⛏️',
      category: 'tool',
      buyPrice: 50),
  LootItem(
      id: 'fishing_rod',
      name: 'Fishing Rod',
      icon: '🎣',
      category: 'tool',
      buyPrice: 50),
  LootItem(
      id: 'harpoon',
      name: 'Harpoon',
      icon: '🔱',
      category: 'tool',
      buyPrice: 100),
  LootItem(
      id: 'hammer', name: 'Hammer', icon: '🔨', category: 'tool', buyPrice: 20),
  LootItem(
      id: 'needle', name: 'Needle', icon: '🪡', category: 'tool', buyPrice: 10),
  LootItem(
      id: 'chisel', name: 'Chisel', icon: '🔧', category: 'tool', buyPrice: 10),
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
    DropEntry(itemId: 'rune_full_helm', chance: 0.0078),
  ],
  'lesser_demon': [
    DropEntry(itemId: 'fire_rune', chance: 0.6, minQty: 15, maxQty: 60),
    DropEntry(itemId: 'gold_ore', chance: 0.3),
    DropEntry(itemId: 'coal', chance: 0.5, minQty: 5, maxQty: 10),
    DropEntry(itemId: 'rune_essence', chance: 0.4, minQty: 5, maxQty: 15),
    DropEntry(itemId: 'rune_scimitar', chance: 0.0078),
  ],
  'fire_giant': [
    DropEntry(itemId: 'rune_scimitar', chance: 0.0078),
    DropEntry(itemId: 'fire_rune', chance: 0.6, minQty: 30, maxQty: 75),
    DropEntry(itemId: 'big_bones', chance: 1.0),
  ],
  'greater_demon': [
    DropEntry(itemId: 'chaos_rune', chance: 0.6, minQty: 10, maxQty: 20),
    DropEntry(itemId: 'adamantite_ore', chance: 0.25),
    DropEntry(itemId: 'raw_lobster', chance: 0.4, minQty: 2, maxQty: 5),
    DropEntry(itemId: 'black_dhide', chance: 0.15),
    DropEntry(itemId: 'rune_platelegs', chance: 0.0078),
    DropEntry(itemId: 'rune_kiteshield', chance: 0.0078),
  ],
  'blue_dragon': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0),
    DropEntry(itemId: 'helm_of_neitiznot', chance: 0.005),
  ],
  'ankou': [
    DropEntry(itemId: 'amulet_of_strength', chance: 0.015),
    DropEntry(itemId: 'adamant_arrows', chance: 0.3, minQty: 10, maxQty: 30),
    DropEntry(itemId: 'big_bones', chance: 1.0),
  ],
  'black_dragon': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0),
    DropEntry(itemId: 'black_dhide', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'adamantite_ore', chance: 0.4, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'runite_ore', chance: 0.1),
    DropEntry(itemId: 'rune_platebody', chance: 0.0078),
    DropEntry(itemId: 'dragon_scimitar', chance: 0.005),
  ],
  'tztok_jad': [
    DropEntry(itemId: 'tokkul', chance: 1.0, minQty: 1000, maxQty: 5000),
    DropEntry(itemId: 'fire_cape_eq', chance: 0.15),
    DropEntry(itemId: 'obsidian_cape_eq', chance: 0.3),
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
    DropEntry(itemId: 'abyssal_whip_eq', chance: 0.002),
    DropEntry(itemId: 'chaos_rune', chance: 0.5, minQty: 15, maxQty: 40),
    DropEntry(itemId: 'runite_ore', chance: 0.1),
    DropEntry(itemId: 'black_dhide', chance: 0.2, minQty: 1, maxQty: 3),
  ],
  'cerberus': [
    DropEntry(itemId: 'primordial_boots', chance: 0.004),
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

  // ── Boss equipment drops ───────────────────────────────────────
  'king_black_dragon': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'dragon_boots', chance: 0.0078),
    DropEntry(itemId: 'amulet_of_fury', chance: 0.005),
    DropEntry(itemId: 'black_dhide', chance: 0.5, minQty: 3, maxQty: 6),
    DropEntry(itemId: 'runite_ore', chance: 0.3, minQty: 2, maxQty: 5),
  ],
  'dagannoth_rex': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0),
    DropEntry(itemId: 'berserker_ring', chance: 0.0078),
    DropEntry(itemId: 'archers_ring', chance: 0.0078),
    DropEntry(itemId: 'seers_ring', chance: 0.0078),
    DropEntry(itemId: 'dragon_scimitar', chance: 0.01),
  ],
  'dagannoth_supreme': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0),
    DropEntry(itemId: 'archers_ring', chance: 0.0078),
    DropEntry(itemId: 'seers_ring', chance: 0.0078),
    DropEntry(itemId: 'dragon_med_helm', chance: 0.01),
    DropEntry(itemId: 'adamantite_ore', chance: 0.4, minQty: 3, maxQty: 6),
    DropEntry(itemId: 'runite_ore', chance: 0.15, minQty: 1, maxQty: 3),
  ],
  'dagannoth_prime': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0),
    DropEntry(itemId: 'seers_ring', chance: 0.0078),
    DropEntry(itemId: 'mud_battlestaff', chance: 0.0078),
    DropEntry(itemId: 'dragon_spear', chance: 0.01),
    DropEntry(itemId: 'runite_ore', chance: 0.2, minQty: 2, maxQty: 5),
    DropEntry(itemId: 'raw_shark', chance: 0.5, minQty: 3, maxQty: 8),
  ],
  'barrows': [
    DropEntry(itemId: 'bolt_rack', chance: 0.8, minQty: 20, maxQty: 50),
    DropEntry(itemId: 'chaos_rune', chance: 0.8, minQty: 50, maxQty: 150),
    DropEntry(itemId: 'ahrims_robetop', chance: 0.018),
    DropEntry(itemId: 'barrows_gloves', chance: 0.018),
    DropEntry(itemId: 'dragon_med_helm', chance: 0.02),
    DropEntry(itemId: 'runite_ore', chance: 0.3, minQty: 2, maxQty: 5),
  ],
  'kalphite_queen': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'dragon_chainbody', chance: 0.0078),
    DropEntry(itemId: 'dragon_med_helm', chance: 0.01),
    DropEntry(itemId: 'shield_left_half', chance: 0.005),
    DropEntry(itemId: 'runite_ore', chance: 0.4, minQty: 3, maxQty: 7),
    DropEntry(itemId: 'adamantite_ore', chance: 0.5, minQty: 5, maxQty: 10),
  ],
  'kril_tsutsaroth': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'staff_of_the_dead', chance: 0.0078),
    DropEntry(itemId: 'zamorakian_spear', chance: 0.0078),
    DropEntry(itemId: 'steam_battlestaff', chance: 0.01),
    DropEntry(itemId: 'runite_ore', chance: 0.5, minQty: 3, maxQty: 8),
    DropEntry(itemId: 'raw_shark', chance: 0.4, minQty: 5, maxQty: 10),
  ],
  'general_graardor': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'bandos_chestplate', chance: 0.0078),
    DropEntry(itemId: 'bandos_tassets', chance: 0.0078),
    DropEntry(itemId: 'dragon_boots', chance: 0.02),
    DropEntry(itemId: 'runite_ore', chance: 0.5, minQty: 3, maxQty: 8),
  ],
  'kreearra': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'armadyl_chestplate', chance: 0.0078),
    DropEntry(itemId: 'armadyl_crossbow', chance: 0.0078),
    DropEntry(itemId: 'avas_assembler', chance: 0.01),
    DropEntry(itemId: 'runite_ore', chance: 0.4, minQty: 2, maxQty: 6),
  ],
  'commander_zilyana': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 2, maxQty: 4),
    DropEntry(itemId: 'amulet_of_fury', chance: 0.01),
    DropEntry(itemId: 'magic_shortbow', chance: 0.02),
    DropEntry(itemId: 'runite_ore', chance: 0.4, minQty: 2, maxQty: 6),
  ],
  'corporeal_beast': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 3, maxQty: 6),
    DropEntry(itemId: 'avernic_defender', chance: 0.004),
    DropEntry(itemId: 'occult_necklace', chance: 0.005),
    DropEntry(itemId: 'runite_ore', chance: 0.5, minQty: 5, maxQty: 10),
  ],
  'nex': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 4, maxQty: 8),
    DropEntry(itemId: 'torva_full_helm', chance: 0.004),
    DropEntry(itemId: 'torva_platebody', chance: 0.004),
    DropEntry(itemId: 'torva_platelegs', chance: 0.004),
    DropEntry(itemId: 'runite_ore', chance: 0.6, minQty: 5, maxQty: 12),
  ],
  'verzik_vitur': [
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 4, maxQty: 8),
    DropEntry(itemId: 'ghrazi_rapier', chance: 0.004),
    DropEntry(itemId: 'avernic_defender', chance: 0.004),
    DropEntry(itemId: 'ferocious_gloves', chance: 0.005),
    DropEntry(itemId: 'runite_ore', chance: 0.6, minQty: 5, maxQty: 12),
  ],
  'zuk': [
    DropEntry(itemId: 'tokkul', chance: 1.0, minQty: 3000, maxQty: 10000),
    DropEntry(itemId: 'infernal_cape', chance: 0.10),
    DropEntry(itemId: 'dragon_bones', chance: 1.0, minQty: 5, maxQty: 10),
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
    requiredToolId: 'axe',
  ),
  SkillingResource(
    id: 'wc_oak',
    name: 'Oak Tree',
    icon: '🌳',
    skill: SkillType.woodcutting,
    levelRequired: 15,
    xpPerAction: 38,
    producesItemId: 'oak_logs',
    requiredToolId: 'axe',
  ),
  SkillingResource(
    id: 'wc_willow',
    name: 'Willow Tree',
    icon: '🌴',
    skill: SkillType.woodcutting,
    levelRequired: 30,
    xpPerAction: 68,
    producesItemId: 'willow_logs',
    requiredToolId: 'axe',
  ),
  SkillingResource(
    id: 'wc_maple',
    name: 'Maple Tree',
    icon: '🍁',
    skill: SkillType.woodcutting,
    levelRequired: 45,
    xpPerAction: 100,
    producesItemId: 'maple_logs',
    requiredToolId: 'axe',
  ),
  SkillingResource(
    id: 'wc_yew',
    name: 'Yew Tree',
    icon: '🎄',
    skill: SkillType.woodcutting,
    levelRequired: 60,
    xpPerAction: 175,
    producesItemId: 'yew_logs',
    requiredToolId: 'axe',
  ),
  SkillingResource(
    id: 'wc_magic',
    name: 'Magic Tree',
    icon: '✨',
    skill: SkillType.woodcutting,
    levelRequired: 75,
    xpPerAction: 250,
    producesItemId: 'magic_logs',
    requiredToolId: 'axe',
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
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_tin',
    name: 'Tin Rock',
    icon: '⚪',
    skill: SkillType.mining,
    levelRequired: 1,
    xpPerAction: 18,
    producesItemId: 'tin_ore',
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_iron',
    name: 'Iron Rock',
    icon: '🔘',
    skill: SkillType.mining,
    levelRequired: 15,
    xpPerAction: 35,
    producesItemId: 'iron_ore',
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_coal',
    name: 'Coal Rock',
    icon: '⬛',
    skill: SkillType.mining,
    levelRequired: 30,
    xpPerAction: 50,
    producesItemId: 'coal',
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_gold',
    name: 'Gold Rock',
    icon: '🟡',
    skill: SkillType.mining,
    levelRequired: 40,
    xpPerAction: 65,
    producesItemId: 'gold_ore',
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_mithril',
    name: 'Mithril Rock',
    icon: '🔵',
    skill: SkillType.mining,
    levelRequired: 55,
    xpPerAction: 80,
    producesItemId: 'mithril_ore',
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_adamantite',
    name: 'Adamantite Rock',
    icon: '🟢',
    skill: SkillType.mining,
    levelRequired: 70,
    xpPerAction: 95,
    producesItemId: 'adamantite_ore',
    requiredToolId: 'pickaxe',
  ),
  SkillingResource(
    id: 'mine_runite',
    name: 'Runite Rock',
    icon: '🔷',
    skill: SkillType.mining,
    levelRequired: 85,
    xpPerAction: 125,
    producesItemId: 'runite_ore',
    requiredToolId: 'pickaxe',
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
    requiredToolId: 'fishing_rod',
  ),
  SkillingResource(
    id: 'fish_trout',
    name: 'Trout',
    icon: '🐟',
    skill: SkillType.fishing,
    levelRequired: 20,
    xpPerAction: 50,
    producesItemId: 'raw_trout',
    requiredToolId: 'fishing_rod',
  ),
  SkillingResource(
    id: 'fish_lobster',
    name: 'Lobster',
    icon: '🦞',
    skill: SkillType.fishing,
    levelRequired: 40,
    xpPerAction: 90,
    producesItemId: 'raw_lobster',
    requiredToolId: 'harpoon',
  ),
  SkillingResource(
    id: 'fish_swordfish',
    name: 'Swordfish',
    icon: '🐡',
    skill: SkillType.fishing,
    levelRequired: 50,
    xpPerAction: 100,
    producesItemId: 'raw_swordfish',
    requiredToolId: 'harpoon',
  ),
  SkillingResource(
    id: 'fish_shark',
    name: 'Shark',
    icon: '🦈',
    skill: SkillType.fishing,
    levelRequired: 76,
    xpPerAction: 110,
    producesItemId: 'raw_shark',
    requiredToolId: 'harpoon',
  ),
  SkillingResource(
    id: 'fish_anglerfish',
    name: 'Anglerfish',
    icon: '🎣',
    skill: SkillType.fishing,
    levelRequired: 82,
    xpPerAction: 120,
    producesItemId: 'raw_anglerfish',
    requiredToolId: 'harpoon',
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
    requiredToolId: 'hammer',
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
    requiredToolId: 'hammer',
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
    requiredToolId: 'hammer',
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
    requiredToolId: 'hammer',
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
    requiredToolId: 'hammer',
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
    requiredToolId: 'hammer',
  ),

  // ── Crafting ───────────────────────────────────────────────────
  SkillingResource(
    id: 'craft_leather',
    name: 'Tan Leather',
    icon: '�',
    skill: SkillType.crafting,
    levelRequired: 1,
    xpPerAction: 14,
    producesItemId: 'leather',
    consumesItems: {'cowhide': 1},
    requiredToolId: 'needle',
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
    requiredToolId: 'needle',
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
    requiredToolId: 'needle',
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
