// ═══════════════════════════════════════════════════════════════════
//  GEAR UPGRADE PRIORITY DATA
//  Curated upgrade paths per slot with DPS improvement estimates
//  and approximate GP costs. Sourced from OSRS Wiki + community DPS calcs.
// ═══════════════════════════════════════════════════════════════════

enum UpgradeStyle { melee, ranged, magic, general }

class GearUpgradePath {
  final String slot;
  final UpgradeStyle style;

  /// Items from worst to best — player works up this ladder.
  final List<GearTier> tiers;

  const GearUpgradePath({
    required this.slot,
    required this.style,
    required this.tiers,
  });
}

class GearTier {
  final String item;

  /// Approximate GE price in GP. 0 = quest reward / free.
  final int gpCost;

  /// Approximate DPS increase % over previous tier.
  final double dpsIncrease;

  /// Any requirement or note.
  final String? note;

  const GearTier({
    required this.item,
    required this.gpCost,
    this.dpsIncrease = 0,
    this.note,
  });
}

class GearUpgradeRecommendation {
  final String slot;
  final UpgradeStyle style;
  final String currentItem;
  final String upgradeItem;
  final int gpCost;
  final double dpsIncrease;

  /// GP per 1% DPS increase — lower is better value.
  final double gpPerPercent;
  final String? note;

  const GearUpgradeRecommendation({
    required this.slot,
    required this.style,
    required this.currentItem,
    required this.upgradeItem,
    required this.gpCost,
    required this.dpsIncrease,
    required this.gpPerPercent,
    this.note,
  });
}

/// Calculate recommended upgrades based on player's bank.
List<GearUpgradeRecommendation> calculateUpgrades(Set<String> bankItems) {
  final recommendations = <GearUpgradeRecommendation>[];

  for (final path in gearUpgradePaths) {
    // Find the player's current best item in this path
    int currentTierIdx = -1;
    for (int i = path.tiers.length - 1; i >= 0; i--) {
      if (_bankContains(bankItems, path.tiers[i].item)) {
        currentTierIdx = i;
        break;
      }
    }

    // Suggest the next tier(s) they don't own
    final startIdx = currentTierIdx + 1;
    if (startIdx >= path.tiers.length) continue; // already BiS

    final nextTier = path.tiers[startIdx];
    final currentName =
        currentTierIdx >= 0 ? path.tiers[currentTierIdx].item : 'Nothing';

    // Sum DPS increase from current to next
    double totalDps = 0;
    for (int i = startIdx; i <= startIdx; i++) {
      totalDps += path.tiers[i].dpsIncrease;
    }

    final gpPerPct =
        totalDps > 0 ? nextTier.gpCost / totalDps : double.infinity;

    recommendations.add(GearUpgradeRecommendation(
      slot: path.slot,
      style: path.style,
      currentItem: currentName,
      upgradeItem: nextTier.item,
      gpCost: nextTier.gpCost,
      dpsIncrease: totalDps,
      gpPerPercent: gpPerPct,
      note: nextTier.note,
    ));
  }

  // Sort by GP/% — best value first
  recommendations.sort((a, b) {
    // Prioritize: free upgrades first, then by gpPerPercent
    if (a.gpCost == 0 && b.gpCost > 0) return -1;
    if (b.gpCost == 0 && a.gpCost > 0) return 1;
    return a.gpPerPercent.compareTo(b.gpPerPercent);
  });

  return recommendations;
}

bool _bankContains(Set<String> bank, String item) {
  final lower = item.toLowerCase();
  return bank.any((b) => b == lower || b.contains(lower) || lower.contains(b));
}

String formatGp(int gp) {
  if (gp == 0) return 'Free';
  if (gp >= 1000000000) return '${(gp / 1000000000).toStringAsFixed(1)}B';
  if (gp >= 1000000) return '${(gp / 1000000).toStringAsFixed(1)}M';
  if (gp >= 1000) return '${(gp / 1000).toStringAsFixed(0)}K';
  return '$gp';
}

String styleLabel(UpgradeStyle s) {
  switch (s) {
    case UpgradeStyle.melee:
      return 'Melee';
    case UpgradeStyle.ranged:
      return 'Ranged';
    case UpgradeStyle.magic:
      return 'Magic';
    case UpgradeStyle.general:
      return 'General';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  UPGRADE PATHS — curated per slot per style
// ═══════════════════════════════════════════════════════════════════

const List<GearUpgradePath> gearUpgradePaths = [
  // ── MELEE WEAPON ──
  GearUpgradePath(slot: 'Weapon', style: UpgradeStyle.melee, tiers: [
    GearTier(
        item: 'Dragon scimitar',
        gpCost: 60000,
        dpsIncrease: 0,
        note: 'Requires Monkey Madness I'),
    GearTier(
        item: 'Abyssal whip',
        gpCost: 1500000,
        dpsIncrease: 8,
        note: '70 Attack'),
    GearTier(item: 'Abyssal tentacle', gpCost: 3500000, dpsIncrease: 3),
    GearTier(
        item: 'Ghrazi rapier',
        gpCost: 95000000,
        dpsIncrease: 3,
        note: 'Theatre of Blood'),
    GearTier(
        item: 'Blade of saeldor',
        gpCost: 120000000,
        dpsIncrease: 0,
        note: 'Equal to rapier, corrupted form'),
    GearTier(
        item: 'Soulreaper axe',
        gpCost: 150000000,
        dpsIncrease: 5,
        note: 'BiS melee — stacking buff'),
  ]),

  // ── MELEE HELM ──
  GearUpgradePath(slot: 'Head', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Berserker helm', gpCost: 50000, dpsIncrease: 0),
    GearTier(
        item: 'Fighter hat',
        gpCost: 0,
        dpsIncrease: 1,
        note: 'Barbarian Assault'),
    GearTier(
        item: 'Helm of neitiznot',
        gpCost: 0,
        dpsIncrease: 2,
        note: 'Fremennik Isles quest'),
    GearTier(
        item: 'Neitiznot faceguard',
        gpCost: 8000000,
        dpsIncrease: 4,
        note: 'Basilisk jaw upgrade'),
    GearTier(item: 'Torva full helm', gpCost: 75000000, dpsIncrease: 2),
  ]),

  // ── MELEE BODY ──
  GearUpgradePath(slot: 'Body', style: UpgradeStyle.melee, tiers: [
    GearTier(
        item: 'Fighter torso',
        gpCost: 0,
        dpsIncrease: 0,
        note: 'Barbarian Assault — free str bonus'),
    GearTier(
        item: 'Bandos chestplate',
        gpCost: 15000000,
        dpsIncrease: 2,
        note: 'Def + prayer bonus'),
    GearTier(
        item: 'Torva platebody',
        gpCost: 150000000,
        dpsIncrease: 3,
        note: 'BiS melee body — HP boost'),
  ]),

  // ── MELEE LEGS ──
  GearUpgradePath(slot: 'Legs', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Dragon platelegs', gpCost: 160000, dpsIncrease: 0),
    GearTier(item: 'Obsidian platelegs', gpCost: 900000, dpsIncrease: 1),
    GearTier(
        item: 'Bandos tassets',
        gpCost: 24000000,
        dpsIncrease: 3,
        note: 'Str bonus + prayer'),
    GearTier(
        item: 'Torva platelegs',
        gpCost: 100000000,
        dpsIncrease: 2,
        note: 'BiS melee legs — HP boost'),
  ]),

  // ── MELEE CAPE ──
  GearUpgradePath(slot: 'Cape', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Obsidian cape', gpCost: 300000, dpsIncrease: 0),
    GearTier(
        item: 'Fire cape',
        gpCost: 0,
        dpsIncrease: 4,
        note: 'Fight Cave — essential upgrade'),
    GearTier(
        item: 'Infernal cape',
        gpCost: 0,
        dpsIncrease: 4,
        note: 'Inferno — BiS melee cape'),
  ]),

  // ── MELEE NECK ──
  GearUpgradePath(slot: 'Neck', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Amulet of glory', gpCost: 10000, dpsIncrease: 0),
    GearTier(item: 'Amulet of fury', gpCost: 2500000, dpsIncrease: 3),
    GearTier(
        item: 'Amulet of torture',
        gpCost: 10000000,
        dpsIncrease: 5,
        note: 'Zenyte — big str boost'),
  ]),

  // ── MELEE HANDS ──
  GearUpgradePath(slot: 'Hands', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Combat bracelet', gpCost: 12000, dpsIncrease: 0),
    GearTier(
        item: 'Dragon gloves',
        gpCost: 0,
        dpsIncrease: 1,
        note: 'Recipe for Disaster'),
    GearTier(
        item: 'Barrows gloves',
        gpCost: 0,
        dpsIncrease: 4,
        note: 'RFD complete — huge upgrade'),
    GearTier(
        item: 'Ferocious gloves',
        gpCost: 5000000,
        dpsIncrease: 3,
        note: 'Hydra leather — melee BiS'),
  ]),

  // ── MELEE FEET ──
  GearUpgradePath(slot: 'Feet', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Climbing boots', gpCost: 700, dpsIncrease: 0),
    GearTier(item: 'Dragon boots', gpCost: 300000, dpsIncrease: 2),
    GearTier(
        item: 'Primordial boots',
        gpCost: 25000000,
        dpsIncrease: 2,
        note: 'Cerberus crystal'),
  ]),

  // ── MELEE RING ──
  GearUpgradePath(slot: 'Ring', style: UpgradeStyle.melee, tiers: [
    GearTier(item: 'Ring of wealth', gpCost: 25000, dpsIncrease: 0),
    GearTier(item: 'Berserker ring', gpCost: 3000000, dpsIncrease: 3),
    GearTier(
        item: 'Berserker ring (i)',
        gpCost: 3500000,
        dpsIncrease: 3,
        note: 'Imbue at NMZ/Soul Wars'),
    GearTier(
        item: 'Ultor ring',
        gpCost: 100000000,
        dpsIncrease: 3,
        note: 'BiS melee ring'),
  ]),

  // ── MELEE SHIELD ──
  GearUpgradePath(slot: 'Shield', style: UpgradeStyle.melee, tiers: [
    GearTier(
        item: 'Rune defender',
        gpCost: 0,
        dpsIncrease: 0,
        note: 'Warriors Guild'),
    GearTier(
        item: 'Dragon defender',
        gpCost: 0,
        dpsIncrease: 3,
        note: 'Warriors Guild basement'),
    GearTier(
        item: 'Avernic defender',
        gpCost: 85000000,
        dpsIncrease: 2,
        note: 'Theatre of Blood'),
  ]),

  // ── RANGED WEAPON ──
  GearUpgradePath(slot: 'Weapon', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: 'Magic shortbow (i)', gpCost: 100000, dpsIncrease: 0),
    GearTier(
        item: 'Rune crossbow',
        gpCost: 10000,
        dpsIncrease: 2,
        note: 'Uses bolts — good with shield'),
    GearTier(item: 'Armadyl crossbow', gpCost: 30000000, dpsIncrease: 3),
    GearTier(
        item: 'Dragon hunter crossbow',
        gpCost: 65000000,
        dpsIncrease: 3,
        note: 'BiS vs dragons'),
    GearTier(
        item: 'Bow of faerdhinen',
        gpCost: 150000000,
        dpsIncrease: 5,
        note: 'No ammo cost — crystal'),
    GearTier(
        item: 'Twisted bow',
        gpCost: 1100000000,
        dpsIncrease: 8,
        note: 'BiS vs high-magic bosses'),
  ]),

  // ── RANGED HEAD ──
  GearUpgradePath(slot: 'Head', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: "Karil's coif", gpCost: 100000, dpsIncrease: 0),
    GearTier(
        item: 'Blessed coif',
        gpCost: 200000,
        dpsIncrease: 1,
        note: 'Any god blessed'),
    GearTier(item: 'Armadyl helmet', gpCost: 6000000, dpsIncrease: 3),
    GearTier(item: 'Masori mask', gpCost: 35000000, dpsIncrease: 2),
    GearTier(
        item: 'Masori mask (f)',
        gpCost: 45000000,
        dpsIncrease: 2,
        note: 'Fortified — BiS ranged'),
  ]),

  // ── RANGED BODY ──
  GearUpgradePath(slot: 'Body', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: "Black d'hide body", gpCost: 8000, dpsIncrease: 0),
    GearTier(
        item: 'Blessed body',
        gpCost: 500000,
        dpsIncrease: 1,
        note: 'Prayer bonus'),
    GearTier(item: "Karil's leathertop", gpCost: 1000000, dpsIncrease: 1),
    GearTier(item: 'Armadyl chestplate', gpCost: 30000000, dpsIncrease: 3),
    GearTier(
        item: 'Masori body (f)',
        gpCost: 120000000,
        dpsIncrease: 3,
        note: 'BiS ranged body'),
  ]),

  // ── RANGED LEGS ──
  GearUpgradePath(slot: 'Legs', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: "Black d'hide chaps", gpCost: 5000, dpsIncrease: 0),
    GearTier(item: 'Blessed chaps', gpCost: 400000, dpsIncrease: 1),
    GearTier(item: 'Armadyl chainskirt', gpCost: 28000000, dpsIncrease: 3),
    GearTier(
        item: 'Masori chaps (f)',
        gpCost: 90000000,
        dpsIncrease: 3,
        note: 'BiS ranged legs'),
  ]),

  // ── RANGED NECK ──
  GearUpgradePath(slot: 'Neck', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: 'Amulet of glory', gpCost: 10000, dpsIncrease: 0),
    GearTier(item: 'Amulet of fury', gpCost: 2500000, dpsIncrease: 2),
    GearTier(
        item: 'Necklace of anguish',
        gpCost: 12000000,
        dpsIncrease: 5,
        note: 'Zenyte — BiS ranged neck'),
  ]),

  // ── RANGED HANDS ──
  GearUpgradePath(slot: 'Hands', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: "Black d'hide vambraces", gpCost: 5000, dpsIncrease: 0),
    GearTier(
        item: 'Barrows gloves',
        gpCost: 0,
        dpsIncrease: 4,
        note: 'RFD complete'),
    GearTier(
        item: 'Zaryte vambraces',
        gpCost: 40000000,
        dpsIncrease: 3,
        note: 'Nex — BiS ranged gloves'),
  ]),

  // ── RANGED FEET ──
  GearUpgradePath(slot: 'Feet', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: "Blessed d'hide boots", gpCost: 100000, dpsIncrease: 0),
    GearTier(
        item: 'Pegasian boots',
        gpCost: 32000000,
        dpsIncrease: 2,
        note: 'Cerberus crystal'),
  ]),

  // ── RANGED RING ──
  GearUpgradePath(slot: 'Ring', style: UpgradeStyle.ranged, tiers: [
    GearTier(item: 'Ring of wealth', gpCost: 25000, dpsIncrease: 0),
    GearTier(item: 'Archers ring', gpCost: 5000000, dpsIncrease: 2),
    GearTier(
        item: 'Archers ring (i)',
        gpCost: 5500000,
        dpsIncrease: 2,
        note: 'Imbue at NMZ'),
    GearTier(
        item: 'Venator ring',
        gpCost: 50000000,
        dpsIncrease: 3,
        note: 'BiS ranged ring'),
  ]),

  // ── RANGED CAPE ──
  GearUpgradePath(slot: 'Cape', style: UpgradeStyle.ranged, tiers: [
    GearTier(
        item: "Ava's accumulator",
        gpCost: 0,
        dpsIncrease: 0,
        note: 'Animal Magnetism quest'),
    GearTier(
        item: "Ava's assembler",
        gpCost: 0,
        dpsIncrease: 3,
        note: 'DS2 quest — essential'),
    GearTier(
        item: 'Dizana\'s quiver',
        gpCost: 80000000,
        dpsIncrease: 3,
        note: 'BiS ranged cape'),
  ]),

  // ── MAGIC WEAPON ──
  GearUpgradePath(slot: 'Weapon', style: UpgradeStyle.magic, tiers: [
    GearTier(
        item: 'Iban\'s staff',
        gpCost: 0,
        dpsIncrease: 0,
        note: 'Underground Pass quest'),
    GearTier(
        item: 'Trident of the seas',
        gpCost: 500000,
        dpsIncrease: 5,
        note: '75 Magic'),
    GearTier(item: 'Trident of the swamp', gpCost: 3000000, dpsIncrease: 3),
    GearTier(
        item: 'Sanguinesti staff',
        gpCost: 55000000,
        dpsIncrease: 3,
        note: 'Theatre of Blood'),
    GearTier(
        item: 'Tumeken\'s shadow',
        gpCost: 900000000,
        dpsIncrease: 15,
        note: 'ToA — massive DPS increase'),
  ]),

  // ── MAGIC HEAD ──
  GearUpgradePath(slot: 'Head', style: UpgradeStyle.magic, tiers: [
    GearTier(item: "Ahrim's hood", gpCost: 100000, dpsIncrease: 0),
    GearTier(item: 'Ancestral hat', gpCost: 15000000, dpsIncrease: 3),
    GearTier(
        item: 'Virtus mask',
        gpCost: 50000000,
        dpsIncrease: 2,
        note: 'Nex — BiS magic helm'),
  ]),

  // ── MAGIC BODY ──
  GearUpgradePath(slot: 'Body', style: UpgradeStyle.magic, tiers: [
    GearTier(item: "Ahrim's robetop", gpCost: 1000000, dpsIncrease: 0),
    GearTier(item: 'Ancestral robe top', gpCost: 55000000, dpsIncrease: 4),
    GearTier(
        item: 'Virtus robe top',
        gpCost: 90000000,
        dpsIncrease: 2,
        note: 'BiS magic body'),
  ]),

  // ── MAGIC LEGS ──
  GearUpgradePath(slot: 'Legs', style: UpgradeStyle.magic, tiers: [
    GearTier(item: "Ahrim's robeskirt", gpCost: 700000, dpsIncrease: 0),
    GearTier(item: 'Ancestral robe bottom', gpCost: 45000000, dpsIncrease: 4),
    GearTier(
        item: 'Virtus robe bottom',
        gpCost: 65000000,
        dpsIncrease: 2,
        note: 'BiS magic legs'),
  ]),

  // ── MAGIC NECK ──
  GearUpgradePath(slot: 'Neck', style: UpgradeStyle.magic, tiers: [
    GearTier(item: 'Amulet of glory', gpCost: 10000, dpsIncrease: 0),
    GearTier(item: 'Amulet of fury', gpCost: 2500000, dpsIncrease: 2),
    GearTier(
        item: 'Occult necklace',
        gpCost: 500000,
        dpsIncrease: 8,
        note: 'BiS magic neck — 10% damage'),
  ]),

  // ── MAGIC CAPE ──
  GearUpgradePath(slot: 'Cape', style: UpgradeStyle.magic, tiers: [
    GearTier(item: 'God cape', gpCost: 0, dpsIncrease: 0, note: 'Mage Arena'),
    GearTier(
        item: 'Imbued god cape',
        gpCost: 0,
        dpsIncrease: 3,
        note: 'Mage Arena II — free 2% magic dmg'),
  ]),

  // ── MAGIC RING ──
  GearUpgradePath(slot: 'Ring', style: UpgradeStyle.magic, tiers: [
    GearTier(item: 'Ring of wealth', gpCost: 25000, dpsIncrease: 0),
    GearTier(item: 'Seers ring', gpCost: 800000, dpsIncrease: 2),
    GearTier(
        item: 'Seers ring (i)',
        gpCost: 1300000,
        dpsIncrease: 2,
        note: 'Imbue at NMZ'),
    GearTier(
        item: 'Magus ring',
        gpCost: 60000000,
        dpsIncrease: 3,
        note: 'BiS magic ring'),
  ]),

  // ── MAGIC FEET ──
  GearUpgradePath(slot: 'Feet', style: UpgradeStyle.magic, tiers: [
    GearTier(item: 'Mystic boots', gpCost: 10000, dpsIncrease: 0),
    GearTier(
        item: 'Eternal boots',
        gpCost: 5000000,
        dpsIncrease: 1,
        note: 'Cerberus crystal'),
  ]),

  // ── GENERAL: PRAYER ──
  GearUpgradePath(slot: 'Prayer', style: UpgradeStyle.general, tiers: [
    GearTier(item: 'Monk robes', gpCost: 0, dpsIncrease: 0),
    GearTier(
        item: 'Proselyte armour',
        gpCost: 0,
        dpsIncrease: 0,
        note: 'Slug Menace quest — best prayer bonus'),
    GearTier(
        item: 'Dragonbone necklace',
        gpCost: 10000000,
        dpsIncrease: 0,
        note: 'Restores prayer from bone drops'),
    GearTier(
        item: 'Ring of the gods (i)',
        gpCost: 8000000,
        dpsIncrease: 0,
        note: '+8 prayer — BiS prayer ring'),
  ]),
];
