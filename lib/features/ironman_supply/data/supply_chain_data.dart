// ═══════════════════════════════════════════════════════════════════
//  Ironman Supply Chain — Skill dependencies, bottleneck analysis
// ═══════════════════════════════════════════════════════════════════

class SupplyLink {
  final String fromSkill;
  final String toSkill;
  final String resource;
  final String description;
  final int fromLevelNeeded;
  final int toLevelNeeded;
  final int importance; // 1-5, higher = more critical

  const SupplyLink({
    required this.fromSkill,
    required this.toSkill,
    required this.resource,
    required this.description,
    this.fromLevelNeeded = 1,
    this.toLevelNeeded = 1,
    this.importance = 3,
  });
}

class Bottleneck {
  final String skill;
  final int currentLevel;
  final int neededLevel;
  final String reason;
  final List<String> blockedSkills;
  final String suggestion;
  final int severity; // 1-5

  const Bottleneck({
    required this.skill,
    required this.currentLevel,
    required this.neededLevel,
    required this.reason,
    required this.blockedSkills,
    required this.suggestion,
    required this.severity,
  });
}

class SupplyChainEngine {
  /// All ironman skill supply chain links
  static const List<SupplyLink> allLinks = [
    // ── Farming → Herblore ──
    SupplyLink(
      fromSkill: 'Farming',
      toSkill: 'Herblore',
      resource: 'Herb seeds → Grimy herbs',
      description:
          'Farm herbs for potions. Ranarr (32), Snapdragon (62), Torstol (85) are key milestones.',
      fromLevelNeeded: 32,
      toLevelNeeded: 38,
      importance: 5,
    ),

    // ── Thieving → Farming ──
    SupplyLink(
      fromSkill: 'Thieving',
      toSkill: 'Farming',
      resource: 'Herb seeds from Master Farmer',
      description:
          'Master Farmer pickpocketing is the primary herb seed source. Rogue\'s outfit doubles loot.',
      fromLevelNeeded: 38,
      toLevelNeeded: 32,
      importance: 5,
    ),

    // ── Herblore → Slayer ──
    SupplyLink(
      fromSkill: 'Herblore',
      toSkill: 'Slayer',
      resource: 'Prayer potions, Super restores',
      description:
          'Prayer potions (38) and Super restores (63) enable efficient Slayer with Protect prayers.',
      fromLevelNeeded: 38,
      toLevelNeeded: 40,
      importance: 5,
    ),

    // ── Herblore → Combat ──
    SupplyLink(
      fromSkill: 'Herblore',
      toSkill: 'Attack',
      resource: 'Super combat potions',
      description:
          'Super combats (90) or Super sets (45+) boost DPS significantly for bossing.',
      fromLevelNeeded: 45,
      toLevelNeeded: 60,
      importance: 4,
    ),
    SupplyLink(
      fromSkill: 'Herblore',
      toSkill: 'Ranged',
      resource: 'Ranging potions',
      description: 'Ranging potions (72) boost Ranged accuracy and damage.',
      fromLevelNeeded: 72,
      toLevelNeeded: 70,
      importance: 4,
    ),

    // ── Slayer → Crafting (gems) ──
    SupplyLink(
      fromSkill: 'Slayer',
      toSkill: 'Crafting',
      resource: 'Gems, gold bars, dragon bones',
      description:
          'Slayer drops supply gems for Crafting and bones for Prayer.',
      fromLevelNeeded: 40,
      toLevelNeeded: 20,
      importance: 3,
    ),

    // ── Mining → Smithing ──
    SupplyLink(
      fromSkill: 'Mining',
      toSkill: 'Smithing',
      resource: 'Ores → Bars',
      description:
          'Mine ores (iron, coal, gold, mithril, adamant) for Blast Furnace smelting.',
      fromLevelNeeded: 15,
      toLevelNeeded: 15,
      importance: 4,
    ),

    // ── Mining → Crafting (sandstone) ──
    SupplyLink(
      fromSkill: 'Mining',
      toSkill: 'Crafting',
      resource: 'Sandstone → Buckets of sand',
      description:
          'Mine sandstone at quarry, grind at Grinder for Superglass Make.',
      fromLevelNeeded: 35,
      toLevelNeeded: 61,
      importance: 5,
    ),

    // ── Farming → Crafting (seaweed) ──
    SupplyLink(
      fromSkill: 'Farming',
      toSkill: 'Crafting',
      resource: 'Giant seaweed',
      description:
          'Plant seaweed spores underwater (Fossil Island). Essential for Superglass Make.',
      fromLevelNeeded: 23,
      toLevelNeeded: 61,
      importance: 5,
    ),

    // ── Smithing → Ranged (cannonballs) ──
    SupplyLink(
      fromSkill: 'Smithing',
      toSkill: 'Ranged',
      resource: 'Cannonballs',
      description:
          'Smith steel bars into cannonballs. Essential for cannon Slayer tasks.',
      fromLevelNeeded: 35,
      toLevelNeeded: 40,
      importance: 4,
    ),

    // ── Smithing → Slayer (cannonballs) ──
    SupplyLink(
      fromSkill: 'Smithing',
      toSkill: 'Slayer',
      resource: 'Cannonballs for task efficiency',
      description: 'Cannon speeds up multi-combat Slayer tasks significantly.',
      fromLevelNeeded: 35,
      toLevelNeeded: 40,
      importance: 4,
    ),

    // ── Fletching → Ranged ──
    SupplyLink(
      fromSkill: 'Fletching',
      toSkill: 'Ranged',
      resource: 'Arrows, bolts, darts',
      description:
          'Fletch broad arrows (Slayer pts), amethyst darts/arrows for endgame.',
      fromLevelNeeded: 52,
      toLevelNeeded: 55,
      importance: 3,
    ),

    // ── Runecraft → Magic ──
    SupplyLink(
      fromSkill: 'Runecraft',
      toSkill: 'Magic',
      resource: 'Nature, death, blood runes',
      description:
          'GOTR and crafting supply runes for alching, bursting, and barraging Slayer tasks.',
      fromLevelNeeded: 27,
      toLevelNeeded: 55,
      importance: 5,
    ),

    // ── Woodcutting → Construction ──
    SupplyLink(
      fromSkill: 'Woodcutting',
      toSkill: 'Construction',
      resource: 'Teak/Mahogany logs → Planks',
      description:
          'Cut teaks/mahogany at Fossil Island. Use Plank Make or sawmill for Construction planks.',
      fromLevelNeeded: 35,
      toLevelNeeded: 47,
      importance: 4,
    ),

    // ── Construction → Slayer/PvM QoL ──
    SupplyLink(
      fromSkill: 'Construction',
      toSkill: 'Slayer',
      resource: 'POH pool, jewellery box, fairy ring',
      description:
          'Ornate rejuvenation pool (82), Jewellery box (83), Fairy ring + Spirit tree (95). Huge QoL for Slayer and bossing.',
      fromLevelNeeded: 82,
      toLevelNeeded: 1,
      importance: 4,
    ),

    // ── Crafting → Magic (jewellery) ──
    SupplyLink(
      fromSkill: 'Crafting',
      toSkill: 'Magic',
      resource: 'Jewellery for teleports + alching',
      description:
          'Craft gold bracelets/necklaces for alching. Make zenyte jewellery at 89.',
      fromLevelNeeded: 7,
      toLevelNeeded: 55,
      importance: 3,
    ),

    // ── Hunter → Ranged (chins) ──
    SupplyLink(
      fromSkill: 'Hunter',
      toSkill: 'Ranged',
      resource: 'Red/Black chinchompas',
      description:
          'Catch chins for chinning MM1/MM2 tunnels. Primary ironman Ranged training.',
      fromLevelNeeded: 63,
      toLevelNeeded: 50,
      importance: 5,
    ),

    // ── Fishing → Cooking ──
    SupplyLink(
      fromSkill: 'Fishing',
      toSkill: 'Cooking',
      resource: 'Raw fish for cooking',
      description:
          'Catch fish to cook. Karambwan (65), sharks (76) for PvM food.',
      fromLevelNeeded: 35,
      toLevelNeeded: 30,
      importance: 3,
    ),

    // ── Cooking → All PvM ──
    SupplyLink(
      fromSkill: 'Cooking',
      toSkill: 'Hitpoints',
      resource: 'Cooked food for PvM',
      description:
          'Karambwan + sharks for PvM. Cooking is the food supply pipeline.',
      fromLevelNeeded: 65,
      toLevelNeeded: 1,
      importance: 4,
    ),

    // ── Agility → Everything (run energy) ──
    SupplyLink(
      fromSkill: 'Agility',
      toSkill: 'Hitpoints',
      resource: 'Run energy + shortcuts',
      description:
          'Higher Agility = faster run restore. Unlocks critical shortcuts for Slayer and bossing.',
      fromLevelNeeded: 50,
      toLevelNeeded: 1,
      importance: 3,
    ),

    // ── Prayer → All Combat ──
    SupplyLink(
      fromSkill: 'Prayer',
      toSkill: 'Attack',
      resource: 'Protection prayers, Piety, Rigour, Augury',
      description:
          'Piety (70), Rigour (74), Augury (77). Massive DPS boosts. Trained from Slayer bones.',
      fromLevelNeeded: 70,
      toLevelNeeded: 70,
      importance: 5,
    ),

    // ── Slayer → Prayer ──
    SupplyLink(
      fromSkill: 'Slayer',
      toSkill: 'Prayer',
      resource: 'Dragon bones, ensouled heads',
      description:
          'Slayer drops supply bones and ensouled heads for Prayer training.',
      fromLevelNeeded: 40,
      toLevelNeeded: 43,
      importance: 4,
    ),

    // ── Farming → Herblore (Kingdom) ──
    SupplyLink(
      fromSkill: 'Farming',
      toSkill: 'Herblore',
      resource: 'Kingdom of Miscellania herbs',
      description:
          'Passive herb supply from Managing Miscellania (Throne of Miscellania quest).',
      fromLevelNeeded: 10,
      toLevelNeeded: 3,
      importance: 3,
    ),
  ];

  /// Analyze bottlenecks given player levels
  static List<Bottleneck> findBottlenecks(Map<String, int> playerLevels) {
    final bottlenecks = <Bottleneck>[];
    final seen = <String>{};

    for (final link in allLinks) {
      final fromLevel = playerLevels[link.fromSkill] ?? 1;

      // Bottleneck: from skill is too low to supply the to skill
      if (fromLevel < link.fromLevelNeeded && link.importance >= 4) {
        final key = '${link.fromSkill}_${link.toSkill}';
        if (seen.contains(key)) continue;
        seen.add(key);

        final blocked = allLinks
            .where((l) => l.fromSkill == link.fromSkill && l.importance >= 3)
            .map((l) => l.toSkill)
            .toSet()
            .toList();

        bottlenecks.add(Bottleneck(
          skill: link.fromSkill,
          currentLevel: fromLevel,
          neededLevel: link.fromLevelNeeded,
          reason: link.description,
          blockedSkills: blocked,
          suggestion:
              'Train ${link.fromSkill} to ${link.fromLevelNeeded} to unlock ${link.resource} for ${link.toSkill}.',
          severity: link.importance,
        ));
      }
    }

    // Sort by severity descending
    bottlenecks.sort((a, b) => b.severity.compareTo(a.severity));
    return bottlenecks;
  }

  /// Get all links feeding INTO a skill
  static List<SupplyLink> linksInto(String skill) =>
      allLinks.where((l) => l.toSkill == skill).toList()
        ..sort((a, b) => b.importance.compareTo(a.importance));

  /// Get all links coming FROM a skill
  static List<SupplyLink> linksFrom(String skill) =>
      allLinks.where((l) => l.fromSkill == skill).toList()
        ..sort((a, b) => b.importance.compareTo(a.importance));

  /// Get unique skill names involved in the supply chain
  static List<String> get allSkills {
    final skills = <String>{};
    for (final l in allLinks) {
      skills.add(l.fromSkill);
      skills.add(l.toSkill);
    }
    return skills.toList()..sort();
  }

  /// Priority order: which skills to train first for maximum unblocking
  static List<String> trainingPriority(Map<String, int> playerLevels) {
    final scores = <String, double>{};
    for (final link in allLinks) {
      final fromLevel = playerLevels[link.fromSkill] ?? 1;
      if (fromLevel < link.fromLevelNeeded) {
        scores[link.fromSkill] =
            (scores[link.fromSkill] ?? 0) + link.importance;
      }
    }
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
}
