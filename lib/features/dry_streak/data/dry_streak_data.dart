import 'dart:math';

// ═══════════════════════════════════════════════════════════════════
//  Dry Streak Tracker — Boss drop rates, KC tracking, statistics
// ═══════════════════════════════════════════════════════════════════

class TrackedDrop {
  final String boss;
  final String item;
  final int rateNumerator;
  final int rateDenominator;
  final String category; // 'weapon', 'armour', 'pet', 'unique', 'rare'

  const TrackedDrop({
    required this.boss,
    required this.item,
    required this.rateNumerator,
    required this.rateDenominator,
    this.category = 'unique',
  });

  double get dropChance => rateNumerator / rateDenominator;
  String get rateStr => '$rateNumerator/$rateDenominator';
}

class BossDropLog {
  final String boss;
  int kc;
  final Map<String, int> dropsReceived; // item name -> count

  BossDropLog({
    required this.boss,
    this.kc = 0,
    Map<String, int>? dropsReceived,
  }) : dropsReceived = dropsReceived ?? {};

  Map<String, dynamic> toJson() => {
        'boss': boss,
        'kc': kc,
        'drops': dropsReceived,
      };

  factory BossDropLog.fromJson(Map<String, dynamic> json) => BossDropLog(
        boss: json['boss'] as String,
        kc: json['kc'] as int? ?? 0,
        dropsReceived: (json['drops'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
      );
}

class DryStreakResult {
  final TrackedDrop drop;
  final int kc;
  final int dropsReceived;
  final double expectedDrops;
  final double probAtLeastOne;
  final double dryPercentile; // what % of players would have it by now
  final String verdict;
  final int
      severity; // 0=lucky, 1=average, 2=slightly dry, 3=dry, 4=very dry, 5=astronomically dry

  const DryStreakResult({
    required this.drop,
    required this.kc,
    required this.dropsReceived,
    required this.expectedDrops,
    required this.probAtLeastOne,
    required this.dryPercentile,
    required this.verdict,
    required this.severity,
  });
}

class DryStreakEngine {
  /// Analyze dryness for a specific drop at a given KC
  static DryStreakResult analyze({
    required TrackedDrop drop,
    required int kc,
    int dropsReceived = 0,
  }) {
    final p = drop.dropChance;
    final expected = kc * p;
    final probAtLeastOne = 1 - pow(1 - p, kc).toDouble();
    final dryPct = probAtLeastOne * 100;

    String verdict;
    int severity;

    if (dropsReceived > 0) {
      final ratio = dropsReceived / (expected == 0 ? 1 : expected);
      if (ratio >= 2.0) {
        verdict = 'Very spooned! ${ratio.toStringAsFixed(1)}x expected drops.';
        severity = 0;
      } else if (ratio >= 1.2) {
        verdict = 'Lucky — ${ratio.toStringAsFixed(1)}x expected.';
        severity = 0;
      } else if (ratio >= 0.8) {
        verdict = 'About average.';
        severity = 1;
      } else if (ratio >= 0.5) {
        verdict =
            'Slightly dry — ${ratio.toStringAsFixed(2)}x expected. This happens to ~${((1 - ratio) * 50).toStringAsFixed(0)}% of players.';
        severity = 2;
      } else {
        verdict =
            'Very dry — only ${ratio.toStringAsFixed(2)}x expected. Unluckier than ~${(dryPct).toStringAsFixed(0)}% of players.';
        severity = 4;
      }
    } else if (kc > 0) {
      if (dryPct < 50) {
        verdict =
            'Not dry yet — ${dryPct.toStringAsFixed(0)}% of players would have it.';
        severity = 0;
      } else if (dryPct < 75) {
        verdict =
            'Getting unlucky — ${dryPct.toStringAsFixed(0)}% of players would have it by now.';
        severity = 2;
      } else if (dryPct < 90) {
        verdict =
            'Pretty dry! Only ${(100 - dryPct).toStringAsFixed(0)}% of players go this long without it.';
        severity = 3;
      } else if (dryPct < 95) {
        verdict =
            'Very dry! You\'re in the top ${(100 - dryPct).toStringAsFixed(1)}% unluckiest players.';
        severity = 4;
      } else if (dryPct < 99) {
        verdict =
            'Extremely dry!! Top ${(100 - dryPct).toStringAsFixed(2)}% unluckiest.';
        severity = 5;
      } else {
        verdict =
            'Astronomically dry!!! Top ${(100 - dryPct).toStringAsFixed(3)}% unluckiest. This is insane.';
        severity = 5;
      }
    } else {
      verdict = 'Enter your KC to see how dry you are.';
      severity = 1;
    }

    return DryStreakResult(
      drop: drop,
      kc: kc,
      dropsReceived: dropsReceived,
      expectedDrops: expected,
      probAtLeastOne: probAtLeastOne,
      dryPercentile: dryPct,
      verdict: verdict,
      severity: severity,
    );
  }

  /// Kills needed for a given probability
  static int killsForProb(double dropChance, double targetProb) {
    if (dropChance <= 0) return 0;
    return (log(1 - targetProb) / log(1 - dropChance)).ceil();
  }

  /// Format KC nicely
  static String fmtKc(int kc) {
    if (kc >= 1000000) return '${(kc / 1000000).toStringAsFixed(1)}M';
    if (kc >= 1000) return '${(kc / 1000).toStringAsFixed(1)}k';
    return '$kc';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Boss Drop Rate Database
// ═══════════════════════════════════════════════════════════════════

const List<TrackedDrop> allTrackedDrops = [
  // ── Cerberus ──
  TrackedDrop(
      boss: 'Cerberus',
      item: 'Primordial crystal',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'unique'),
  TrackedDrop(
      boss: 'Cerberus',
      item: 'Pegasian crystal',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'unique'),
  TrackedDrop(
      boss: 'Cerberus',
      item: 'Eternal crystal',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'unique'),
  TrackedDrop(
      boss: 'Cerberus',
      item: 'Smouldering stone',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'unique'),
  TrackedDrop(
      boss: 'Cerberus',
      item: 'Hellpuppy',
      rateNumerator: 1,
      rateDenominator: 3000,
      category: 'pet'),
  TrackedDrop(
      boss: 'Cerberus',
      item: 'Any crystal',
      rateNumerator: 3,
      rateDenominator: 512,
      category: 'unique'),

  // ── Alchemical Hydra ──
  TrackedDrop(
      boss: 'Alchemical Hydra',
      item: "Hydra's claw",
      rateNumerator: 1,
      rateDenominator: 1001,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Alchemical Hydra',
      item: 'Hydra leather',
      rateNumerator: 1,
      rateDenominator: 514,
      category: 'unique'),
  TrackedDrop(
      boss: 'Alchemical Hydra',
      item: 'Hydra tail',
      rateNumerator: 1,
      rateDenominator: 514,
      category: 'unique'),
  TrackedDrop(
      boss: 'Alchemical Hydra',
      item: 'Ikkle Hydra',
      rateNumerator: 1,
      rateDenominator: 3000,
      category: 'pet'),

  // ── Zulrah ──
  TrackedDrop(
      boss: 'Zulrah',
      item: 'Tanzanite fang',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Zulrah',
      item: 'Magic fang',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Zulrah',
      item: 'Serpentine visage',
      rateNumerator: 1,
      rateDenominator: 512,
      category: 'armour'),
  TrackedDrop(
      boss: 'Zulrah',
      item: 'Any unique',
      rateNumerator: 1,
      rateDenominator: 128,
      category: 'unique'),
  TrackedDrop(
      boss: 'Zulrah',
      item: 'Snakeling',
      rateNumerator: 1,
      rateDenominator: 4000,
      category: 'pet'),

  // ── Vorkath ──
  TrackedDrop(
      boss: 'Vorkath',
      item: 'Skeletal visage',
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'unique'),
  TrackedDrop(
      boss: 'Vorkath',
      item: 'Draconic visage',
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'unique'),
  TrackedDrop(
      boss: 'Vorkath',
      item: "Vorkath's head (50 KC)",
      rateNumerator: 1,
      rateDenominator: 50,
      category: 'unique'),
  TrackedDrop(
      boss: 'Vorkath',
      item: 'Vorki',
      rateNumerator: 1,
      rateDenominator: 3000,
      category: 'pet'),

  // ── General Graardor (Bandos) ──
  TrackedDrop(
      boss: 'General Graardor',
      item: 'Bandos chestplate',
      rateNumerator: 1,
      rateDenominator: 381,
      category: 'armour'),
  TrackedDrop(
      boss: 'General Graardor',
      item: 'Bandos tassets',
      rateNumerator: 1,
      rateDenominator: 381,
      category: 'armour'),
  TrackedDrop(
      boss: 'General Graardor',
      item: 'Bandos boots',
      rateNumerator: 1,
      rateDenominator: 381,
      category: 'armour'),
  TrackedDrop(
      boss: 'General Graardor',
      item: 'Bandos hilt',
      rateNumerator: 1,
      rateDenominator: 508,
      category: 'weapon'),
  TrackedDrop(
      boss: 'General Graardor',
      item: 'Graardor Jr.',
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'pet'),

  // ── Kree'arra (Armadyl) ──
  TrackedDrop(
      boss: "Kree'arra",
      item: 'Armadyl helmet',
      rateNumerator: 1,
      rateDenominator: 381,
      category: 'armour'),
  TrackedDrop(
      boss: "Kree'arra",
      item: 'Armadyl chestplate',
      rateNumerator: 1,
      rateDenominator: 381,
      category: 'armour'),
  TrackedDrop(
      boss: "Kree'arra",
      item: 'Armadyl chainskirt',
      rateNumerator: 1,
      rateDenominator: 381,
      category: 'armour'),
  TrackedDrop(
      boss: "Kree'arra",
      item: 'Armadyl hilt',
      rateNumerator: 1,
      rateDenominator: 508,
      category: 'weapon'),
  TrackedDrop(
      boss: "Kree'arra",
      item: "Kree'arra Jr.",
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'pet'),

  // ── K'ril Tsutsaroth (Zamorak) ──
  TrackedDrop(
      boss: "K'ril Tsutsaroth",
      item: 'Staff of the dead',
      rateNumerator: 1,
      rateDenominator: 508,
      category: 'weapon'),
  TrackedDrop(
      boss: "K'ril Tsutsaroth",
      item: 'Zamorakian spear',
      rateNumerator: 1,
      rateDenominator: 128,
      category: 'weapon'),
  TrackedDrop(
      boss: "K'ril Tsutsaroth",
      item: 'Zamorak hilt',
      rateNumerator: 1,
      rateDenominator: 508,
      category: 'weapon'),
  TrackedDrop(
      boss: "K'ril Tsutsaroth",
      item: "K'ril Jr.",
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'pet'),

  // ── Commander Zilyana (Saradomin) ──
  TrackedDrop(
      boss: 'Commander Zilyana',
      item: 'Armadyl crossbow',
      rateNumerator: 1,
      rateDenominator: 508,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Commander Zilyana',
      item: 'Saradomin sword',
      rateNumerator: 1,
      rateDenominator: 127,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Commander Zilyana',
      item: 'Saradomin hilt',
      rateNumerator: 1,
      rateDenominator: 508,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Commander Zilyana',
      item: 'Zilyana Jr.',
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'pet'),

  // ── Corporeal Beast ──
  TrackedDrop(
      boss: 'Corporeal Beast',
      item: 'Spectral sigil',
      rateNumerator: 1,
      rateDenominator: 1365,
      category: 'unique'),
  TrackedDrop(
      boss: 'Corporeal Beast',
      item: 'Arcane sigil',
      rateNumerator: 1,
      rateDenominator: 1365,
      category: 'unique'),
  TrackedDrop(
      boss: 'Corporeal Beast',
      item: 'Elysian sigil',
      rateNumerator: 1,
      rateDenominator: 4095,
      category: 'rare'),
  TrackedDrop(
      boss: 'Corporeal Beast',
      item: 'Any sigil',
      rateNumerator: 1,
      rateDenominator: 585,
      category: 'unique'),
  TrackedDrop(
      boss: 'Corporeal Beast',
      item: 'Corp pet',
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'pet'),

  // ── Corrupted Gauntlet ──
  TrackedDrop(
      boss: 'Corrupted Gauntlet',
      item: 'Enhanced crystal weapon seed',
      rateNumerator: 1,
      rateDenominator: 400,
      category: 'rare'),
  TrackedDrop(
      boss: 'Corrupted Gauntlet',
      item: 'Crystal armour seed',
      rateNumerator: 1,
      rateDenominator: 50,
      category: 'unique'),
  TrackedDrop(
      boss: 'Corrupted Gauntlet',
      item: 'Youngllef',
      rateNumerator: 1,
      rateDenominator: 400,
      category: 'pet'),

  // ── Chambers of Xeric ──
  TrackedDrop(
      boss: 'Chambers of Xeric',
      item: 'Twisted bow',
      rateNumerator: 1,
      rateDenominator: 345,
      category: 'rare'),
  TrackedDrop(
      boss: 'Chambers of Xeric',
      item: 'Dragon claws',
      rateNumerator: 1,
      rateDenominator: 230,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Chambers of Xeric',
      item: 'Any purple',
      rateNumerator: 1,
      rateDenominator: 30,
      category: 'unique'),
  TrackedDrop(
      boss: 'Chambers of Xeric',
      item: 'Olmlet',
      rateNumerator: 1,
      rateDenominator: 53,
      category: 'pet'),

  // ── Theatre of Blood ──
  TrackedDrop(
      boss: 'Theatre of Blood',
      item: 'Scythe of vitur',
      rateNumerator: 1,
      rateDenominator: 172,
      category: 'rare'),
  TrackedDrop(
      boss: 'Theatre of Blood',
      item: 'Ghrazi rapier',
      rateNumerator: 1,
      rateDenominator: 86,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Theatre of Blood',
      item: 'Avernic defender hilt',
      rateNumerator: 1,
      rateDenominator: 86,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Theatre of Blood',
      item: "Lil' Zik",
      rateNumerator: 1,
      rateDenominator: 650,
      category: 'pet'),

  // ── Tombs of Amascut ──
  TrackedDrop(
      boss: 'Tombs of Amascut',
      item: "Osmumten's fang",
      rateNumerator: 1,
      rateDenominator: 72,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Tombs of Amascut',
      item: "Tumeken's shadow",
      rateNumerator: 1,
      rateDenominator: 216,
      category: 'rare'),
  TrackedDrop(
      boss: 'Tombs of Amascut',
      item: 'Masori mask',
      rateNumerator: 1,
      rateDenominator: 216,
      category: 'armour'),
  TrackedDrop(
      boss: 'Tombs of Amascut',
      item: "Tumeken's guardian",
      rateNumerator: 1,
      rateDenominator: 2000,
      category: 'pet'),

  // ── DT2 Bosses ──
  TrackedDrop(
      boss: 'Duke Sucellus',
      item: 'Magus ring',
      rateNumerator: 1,
      rateDenominator: 180,
      category: 'unique'),
  TrackedDrop(
      boss: 'Duke Sucellus',
      item: 'Eye of the duke',
      rateNumerator: 1,
      rateDenominator: 360,
      category: 'unique'),
  TrackedDrop(
      boss: 'The Leviathan',
      item: 'Venator ring',
      rateNumerator: 1,
      rateDenominator: 180,
      category: 'unique'),
  TrackedDrop(
      boss: 'The Whisperer',
      item: 'Bellator ring',
      rateNumerator: 1,
      rateDenominator: 180,
      category: 'unique'),
  TrackedDrop(
      boss: 'Vardorvis',
      item: 'Ultor ring',
      rateNumerator: 1,
      rateDenominator: 180,
      category: 'unique'),

  // ── Nightmare ──
  TrackedDrop(
      boss: "Phosani's Nightmare",
      item: "Inquisitor's mace",
      rateNumerator: 1,
      rateDenominator: 500,
      category: 'weapon'),
  TrackedDrop(
      boss: "Phosani's Nightmare",
      item: 'Nightmare staff',
      rateNumerator: 1,
      rateDenominator: 200,
      category: 'weapon'),
  TrackedDrop(
      boss: "Phosani's Nightmare",
      item: 'Harmonised orb',
      rateNumerator: 1,
      rateDenominator: 1600,
      category: 'rare'),

  // ── Demonic Gorillas ──
  TrackedDrop(
      boss: 'Demonic Gorillas',
      item: 'Zenyte shard',
      rateNumerator: 1,
      rateDenominator: 300,
      category: 'unique'),

  // ── Shamans ──
  TrackedDrop(
      boss: 'Lizardman Shamans',
      item: 'Dragon warhammer',
      rateNumerator: 1,
      rateDenominator: 5000,
      category: 'rare'),

  // ── Dagannoth Kings ──
  TrackedDrop(
      boss: 'Dagannoth Rex',
      item: 'Berserker ring',
      rateNumerator: 1,
      rateDenominator: 128,
      category: 'unique'),
  TrackedDrop(
      boss: 'Dagannoth Supreme',
      item: 'Archers ring',
      rateNumerator: 1,
      rateDenominator: 128,
      category: 'unique'),
  TrackedDrop(
      boss: 'Dagannoth Prime',
      item: 'Seers ring',
      rateNumerator: 1,
      rateDenominator: 128,
      category: 'unique'),

  // ── Giant Mole ──
  TrackedDrop(
      boss: 'Giant Mole',
      item: 'Baby mole',
      rateNumerator: 1,
      rateDenominator: 3000,
      category: 'pet'),

  // ── Kalphite Queen ──
  TrackedDrop(
      boss: 'Kalphite Queen',
      item: 'KQ head',
      rateNumerator: 1,
      rateDenominator: 128,
      category: 'unique'),
  TrackedDrop(
      boss: 'Kalphite Queen',
      item: 'Kalphite Princess',
      rateNumerator: 1,
      rateDenominator: 3000,
      category: 'pet'),

  // ── Araxxor ──
  TrackedDrop(
      boss: 'Araxxor',
      item: 'Araxyte fang',
      rateNumerator: 1,
      rateDenominator: 200,
      category: 'weapon'),
  TrackedDrop(
      boss: 'Araxxor',
      item: 'Noxious halberd',
      rateNumerator: 1,
      rateDenominator: 200,
      category: 'weapon'),
];

/// Get unique boss names
List<String> get allBossNames =>
    allTrackedDrops.map((d) => d.boss).toSet().toList()..sort();

/// Get drops for a specific boss
List<TrackedDrop> dropsForBoss(String boss) =>
    allTrackedDrops.where((d) => d.boss == boss).toList();
