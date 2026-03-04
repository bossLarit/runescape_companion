import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final osrsApiServiceProvider = Provider<OsrsApiService>((ref) {
  return OsrsApiService();
});

/// Skill names in the order returned by the OSRS Hiscores API
const hiscoreSkillOrder = [
  'Overall',
  'Attack',
  'Defence',
  'Strength',
  'Hitpoints',
  'Ranged',
  'Prayer',
  'Magic',
  'Cooking',
  'Woodcutting',
  'Fletching',
  'Fishing',
  'Firemaking',
  'Crafting',
  'Smithing',
  'Mining',
  'Herblore',
  'Agility',
  'Thieving',
  'Slayer',
  'Farming',
  'Runecraft',
  'Hunter',
  'Construction',
  'Sailing',
];

/// Activity/minigame names in the order returned by the OSRS Hiscores API
const hiscoreActivityOrder = [
  'League Points',
  'Deadman Points',
  'Bounty Hunter - Hunter',
  'Bounty Hunter - Rogue',
  'Bounty Hunter (Legacy) - Hunter',
  'Bounty Hunter (Legacy) - Rogue',
  'Clue Scrolls (all)',
  'Clue Scrolls (beginner)',
  'Clue Scrolls (easy)',
  'Clue Scrolls (medium)',
  'Clue Scrolls (hard)',
  'Clue Scrolls (elite)',
  'Clue Scrolls (master)',
  'LMS - Rank',
  'PvP Arena - Rank',
  'Soul Wars Zeal',
  'Rifts closed',
  'Colosseum Glory',
  'Abyssal Sire',
  'Alchemical Hydra',
  'Artio',
  'Barrows Chests',
  'Bryophyta',
  'Callisto',
  'Cal\'varion',
  'Cerberus',
  'Chambers of Xeric',
  'Chambers of Xeric: Challenge Mode',
  'Chaos Elemental',
  'Chaos Fanatic',
  'Commander Zilyana',
  'Corporeal Beast',
  'Crazy Archaeologist',
  'Dagannoth Prime',
  'Dagannoth Rex',
  'Dagannoth Supreme',
  'Deranged Archaeologist',
  'Duke Sucellus',
  'General Graardor',
  'Giant Mole',
  'Grotesque Guardians',
  'Hespori',
  'Kalphite Queen',
  'King Black Dragon',
  'Kraken',
  'Kree\'Arra',
  'K\'ril Tsutsaroth',
  'Lunar Chests',
  'Mimic',
  'Nex',
  'Nightmare',
  'Phosani\'s Nightmare',
  'Obor',
  'Phantom Muspah',
  'Royal Titans',
  'Sarachnis',
  'Scorpia',
  'Scurrius',
  'Skotizo',
  'Sol Heredit',
  'Spindel',
  'Tempoross',
  'The Gauntlet',
  'The Corrupted Gauntlet',
  'The Leviathan',
  'The Whisperer',
  'Theatre of Blood',
  'Theatre of Blood: Hard Mode',
  'Thermonuclear Smoke Devil',
  'Tombs of Amascut',
  'Tombs of Amascut: Expert Mode',
  'TzKal-Zuk',
  'TzTok-Jad',
  'Vardorvis',
  'Venenatis',
  'Vet\'ion',
  'Vorkath',
  'Wintertodt',
  'Zalcano',
  'Zulrah',
];

class HiscoreEntry {
  final int rank;
  final int level;
  final int xp;
  const HiscoreEntry({this.rank = -1, this.level = -1, this.xp = -1});
}

class ActivityEntry {
  final int rank;
  final int score;
  const ActivityEntry({this.rank = -1, this.score = -1});
}

class HiscoreResult {
  final Map<String, HiscoreEntry> skills;
  final Map<String, ActivityEntry> activities;
  final String playerName;

  const HiscoreResult({
    required this.playerName,
    this.skills = const {},
    this.activities = const {},
  });

  int? get totalLevel => skills['Overall']?.level;
  int? get totalXp => skills['Overall']?.xp;
  int? get combatLevel {
    final att = skills['Attack']?.level ?? 1;
    final str = skills['Strength']?.level ?? 1;
    final def = skills['Defence']?.level ?? 1;
    final hp = skills['Hitpoints']?.level ?? 10;
    final prayer = skills['Prayer']?.level ?? 1;
    final ranged = skills['Ranged']?.level ?? 1;
    final magic = skills['Magic']?.level ?? 1;

    final base = 0.25 * (def + hp + (prayer / 2).floor());
    final melee = 0.325 * (att + str);
    final range = 0.325 * ((ranged / 2).floor() + ranged);
    final mage = 0.325 * ((magic / 2).floor() + magic);
    final best = [melee, range, mage].reduce((a, b) => a > b ? a : b);
    return (base + best).floor();
  }
}

class GeItemPrice {
  final int high;
  final int? highTime;
  final int low;
  final int? lowTime;
  const GeItemPrice(
      {required this.high, this.highTime, required this.low, this.lowTime});

  int get avgPrice => ((high + low) / 2).round();
}

class GeItemMapping {
  final int id;
  final String name;
  final String examine;
  final bool members;
  final int? lowalch;
  final int? highalch;
  final int? limit;
  final String? icon;

  const GeItemMapping({
    required this.id,
    required this.name,
    this.examine = '',
    this.members = false,
    this.lowalch,
    this.highalch,
    this.limit,
    this.icon,
  });

  factory GeItemMapping.fromJson(Map<String, dynamic> json) {
    return GeItemMapping(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      examine: json['examine'] as String? ?? '',
      members: json['members'] as bool? ?? false,
      lowalch: json['lowalch'] as int?,
      highalch: json['highalch'] as int?,
      limit: json['limit'] as int?,
      icon: json['icon'] as String?,
    );
  }
}

class WikiSearchResult {
  final String title;
  final String snippet;
  final int pageId;
  const WikiSearchResult(
      {required this.title, required this.snippet, required this.pageId});
}

class OsrsApiService {
  static const _userAgent =
      'OSRS Companion Desktop App - github.com/osrs-companion';
  static const _hiscoreBase =
      'https://secure.runescape.com/m=hiscore_oldschool';
  static const _priceBase = 'https://prices.runescape.wiki/api/v1/osrs';
  static const _wikiApi = 'https://oldschool.runescape.wiki/api.php';

  List<GeItemMapping>? _itemMappingCache;

  /// Fetch hiscores for a player (normal, ironman, hardcore, ultimate)
  Future<HiscoreResult?> fetchHiscores(String playerName,
      {String mode = 'normal'}) async {
    final modeSegment = switch (mode) {
      'ironman' => '_ironman',
      'hardcore' => '_hardcore_ironman',
      'ultimate' => '_ultimate',
      _ => '',
    };
    final url =
        '$_hiscoreBase$modeSegment/index_lite.ws?player=${Uri.encodeComponent(playerName)}';

    try {
      final response =
          await http.get(Uri.parse(url), headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return null;

      final lines = response.body.trim().split('\n');
      final skills = <String, HiscoreEntry>{};
      final activities = <String, ActivityEntry>{};

      for (int i = 0; i < lines.length; i++) {
        final parts = lines[i].split(',');
        if (i < hiscoreSkillOrder.length && parts.length >= 3) {
          skills[hiscoreSkillOrder[i]] = HiscoreEntry(
            rank: int.tryParse(parts[0]) ?? -1,
            level: int.tryParse(parts[1]) ?? -1,
            xp: int.tryParse(parts[2]) ?? -1,
          );
        } else if (i >= hiscoreSkillOrder.length) {
          final actIdx = i - hiscoreSkillOrder.length;
          if (actIdx < hiscoreActivityOrder.length && parts.length >= 2) {
            activities[hiscoreActivityOrder[actIdx]] = ActivityEntry(
              rank: int.tryParse(parts[0]) ?? -1,
              score: int.tryParse(parts[1]) ?? -1,
            );
          }
        }
      }

      return HiscoreResult(
          playerName: playerName, skills: skills, activities: activities);
    } catch (e) {
      return null;
    }
  }

  /// Fetch latest GE prices for all items
  Future<Map<int, GeItemPrice>?> fetchLatestPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$_priceBase/latest'),
        headers: {'User-Agent': _userAgent},
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = data['data'] as Map<String, dynamic>? ?? {};
      final result = <int, GeItemPrice>{};

      for (final entry in dataMap.entries) {
        final id = int.tryParse(entry.key);
        if (id == null) continue;
        final v = entry.value as Map<String, dynamic>;
        result[id] = GeItemPrice(
          high: v['high'] as int? ?? 0,
          highTime: v['highTime'] as int?,
          low: v['low'] as int? ?? 0,
          lowTime: v['lowTime'] as int?,
        );
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Fetch item mapping (name, id, alch values, etc.)
  Future<List<GeItemMapping>> fetchItemMapping() async {
    if (_itemMappingCache != null) return _itemMappingCache!;
    try {
      final response = await http.get(
        Uri.parse('$_priceBase/mapping'),
        headers: {'User-Agent': _userAgent},
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as List<dynamic>;
      _itemMappingCache = data
          .map((e) => GeItemMapping.fromJson(e as Map<String, dynamic>))
          .toList();
      return _itemMappingCache!;
    } catch (e) {
      return [];
    }
  }

  /// Search the OSRS Wiki via MediaWiki API
  Future<List<WikiSearchResult>> searchWiki(String query,
      {int limit = 10}) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse(_wikiApi).replace(queryParameters: {
        'action': 'query',
        'list': 'search',
        'srsearch': query,
        'srlimit': '$limit',
        'format': 'json',
      });
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final searchList = (data['query']?['search'] as List<dynamic>?) ?? [];
      return searchList.map((e) {
        final m = e as Map<String, dynamic>;
        return WikiSearchResult(
          title: m['title'] as String? ?? '',
          snippet: (m['snippet'] as String? ?? '')
              .replaceAll(RegExp(r'<[^>]*>'), ''),
          pageId: m['pageid'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch a specific item price by ID
  Future<GeItemPrice?> fetchItemPrice(int itemId) async {
    try {
      final response = await http.get(
        Uri.parse('$_priceBase/latest?id=$itemId'),
        headers: {'User-Agent': _userAgent},
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = data['data'] as Map<String, dynamic>? ?? {};
      final item = dataMap['$itemId'] as Map<String, dynamic>?;
      if (item == null) return null;

      return GeItemPrice(
        high: item['high'] as int? ?? 0,
        highTime: item['highTime'] as int?,
        low: item['low'] as int? ?? 0,
        lowTime: item['lowTime'] as int?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch raw wikitext for a page by title.
  Future<String?> fetchWikiPageWikitext(String pageTitle) async {
    try {
      final uri = Uri.parse(_wikiApi).replace(queryParameters: {
        'action': 'parse',
        'page': pageTitle,
        'prop': 'wikitext',
        'format': 'json',
      });
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['parse']?['wikitext']?['*'] as String?) ?? '';
    } catch (e) {
      return null;
    }
  }

  /// Fetch rendered HTML for a wiki page section.
  Future<String?> fetchWikiPageHtml(String pageTitle) async {
    try {
      final uri = Uri.parse(_wikiApi).replace(queryParameters: {
        'action': 'parse',
        'page': pageTitle,
        'prop': 'text',
        'format': 'json',
      });
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['parse']?['text']?['*'] as String?) ?? '';
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Wise Old Man API v2  —  https://docs.wiseoldman.net/api
  // ─────────────────────────────────────────────────────────────────────
  static const _womBase = 'https://api.wiseoldman.net/v2';

  Map<String, String> get _womHeaders => {
        'Content-Type': 'application/json',
        'User-Agent': _userAgent,
      };

  /// Search players by partial username
  Future<List<WomPlayer>> womSearchPlayers(String username,
      {int limit = 10}) async {
    try {
      final uri = Uri.parse(
          '$_womBase/players/search?username=${Uri.encodeComponent(username)}&limit=$limit');
      final res = await http.get(uri, headers: _womHeaders);
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => WomPlayer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get full player details including latest snapshot
  Future<WomPlayerDetails?> womGetPlayer(String username) async {
    try {
      final uri =
          Uri.parse('$_womBase/players/${Uri.encodeComponent(username)}');
      final res = await http.get(uri, headers: _womHeaders);
      if (res.statusCode != 200) return null;
      return WomPlayerDetails.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Update (refresh) a player on WOM
  Future<bool> womUpdatePlayer(String username) async {
    try {
      final uri =
          Uri.parse('$_womBase/players/${Uri.encodeComponent(username)}');
      final res = await http.post(uri, headers: _womHeaders);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get player gains for a period (day, week, month, year)
  Future<WomGains?> womGetGains(String username,
      {String period = 'week'}) async {
    try {
      final uri = Uri.parse(
          '$_womBase/players/${Uri.encodeComponent(username)}/gained?period=$period');
      final res = await http.get(uri, headers: _womHeaders);
      if (res.statusCode != 200) return null;
      return WomGains.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Get player achievements
  Future<List<WomAchievement>> womGetAchievements(String username) async {
    try {
      final uri = Uri.parse(
          '$_womBase/players/${Uri.encodeComponent(username)}/achievements');
      final res = await http.get(uri, headers: _womHeaders);
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => WomAchievement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get player records
  Future<List<WomRecord>> womGetRecords(String username) async {
    try {
      final uri = Uri.parse(
          '$_womBase/players/${Uri.encodeComponent(username)}/records');
      final res = await http.get(uri, headers: _womHeaders);
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => WomRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WOM Data Models
// ─────────────────────────────────────────────────────────────────────────────

class WomPlayer {
  final int id;
  final String username;
  final String displayName;
  final String type;
  final String build;
  final String status;
  final int exp;
  final double ehp;
  final double ehb;
  final double ttm;
  final double tt200m;
  final String? updatedAt;

  WomPlayer({
    required this.id,
    required this.username,
    required this.displayName,
    required this.type,
    required this.build,
    required this.status,
    required this.exp,
    required this.ehp,
    required this.ehb,
    required this.ttm,
    required this.tt200m,
    this.updatedAt,
  });

  factory WomPlayer.fromJson(Map<String, dynamic> j) => WomPlayer(
        id: j['id'] as int? ?? 0,
        username: j['username'] as String? ?? '',
        displayName: j['displayName'] as String? ?? '',
        type: j['type'] as String? ?? 'unknown',
        build: j['build'] as String? ?? 'main',
        status: j['status'] as String? ?? 'active',
        exp: (j['exp'] as num?)?.toInt() ?? 0,
        ehp: (j['ehp'] as num?)?.toDouble() ?? 0,
        ehb: (j['ehb'] as num?)?.toDouble() ?? 0,
        ttm: (j['ttm'] as num?)?.toDouble() ?? 0,
        tt200m: (j['tt200m'] as num?)?.toDouble() ?? 0,
        updatedAt: j['updatedAt'] as String?,
      );
}

class WomSkillSnapshot {
  final String metric;
  final int experience;
  final int rank;
  final int level;
  final double ehp;

  WomSkillSnapshot(
      {required this.metric,
      required this.experience,
      required this.rank,
      required this.level,
      required this.ehp});

  factory WomSkillSnapshot.fromJson(Map<String, dynamic> j) => WomSkillSnapshot(
        metric: j['metric'] as String? ?? '',
        experience: (j['experience'] as num?)?.toInt() ?? 0,
        rank: (j['rank'] as num?)?.toInt() ?? -1,
        level: (j['level'] as num?)?.toInt() ?? 1,
        ehp: (j['ehp'] as num?)?.toDouble() ?? 0,
      );
}

class WomBossSnapshot {
  final String metric;
  final int kills;
  final int rank;
  final double ehb;

  WomBossSnapshot(
      {required this.metric,
      required this.kills,
      required this.rank,
      required this.ehb});

  factory WomBossSnapshot.fromJson(Map<String, dynamic> j) => WomBossSnapshot(
        metric: j['metric'] as String? ?? '',
        kills: (j['kills'] as num?)?.toInt() ?? -1,
        rank: (j['rank'] as num?)?.toInt() ?? -1,
        ehb: (j['ehb'] as num?)?.toDouble() ?? 0,
      );
}

class WomPlayerDetails {
  final WomPlayer player;
  final int combatLevel;
  final Map<String, WomSkillSnapshot> skills;
  final Map<String, WomBossSnapshot> bosses;

  WomPlayerDetails(
      {required this.player,
      required this.combatLevel,
      required this.skills,
      required this.bosses});

  factory WomPlayerDetails.fromJson(Map<String, dynamic> j) {
    final player = WomPlayer.fromJson(j);
    final combatLevel = (j['combatLevel'] as num?)?.toInt() ?? 3;
    final snapshot = j['latestSnapshot'] as Map<String, dynamic>? ?? {};
    final data = snapshot['data'] as Map<String, dynamic>? ?? {};
    final skillsRaw = data['skills'] as Map<String, dynamic>? ?? {};
    final bossesRaw = data['bosses'] as Map<String, dynamic>? ?? {};

    final skills = <String, WomSkillSnapshot>{};
    skillsRaw.forEach((k, v) {
      skills[k] = WomSkillSnapshot.fromJson(v as Map<String, dynamic>);
    });

    final bosses = <String, WomBossSnapshot>{};
    bossesRaw.forEach((k, v) {
      bosses[k] = WomBossSnapshot.fromJson(v as Map<String, dynamic>);
    });

    return WomPlayerDetails(
        player: player,
        combatLevel: combatLevel,
        skills: skills,
        bosses: bosses);
  }
}

class WomGainEntry {
  final int gained;
  final int start;
  final int end;
  WomGainEntry({required this.gained, required this.start, required this.end});
}

class WomSkillGain {
  final String metric;
  final WomGainEntry experience;
  final int levelGained;
  WomSkillGain(
      {required this.metric,
      required this.experience,
      required this.levelGained});
}

class WomBossGain {
  final String metric;
  final int killsGained;
  WomBossGain({required this.metric, required this.killsGained});
}

class WomGains {
  final String? startsAt;
  final String? endsAt;
  final Map<String, WomSkillGain> skills;
  final Map<String, WomBossGain> bosses;

  WomGains(
      {required this.startsAt,
      required this.endsAt,
      required this.skills,
      required this.bosses});

  factory WomGains.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>? ?? {};
    final skillsRaw = data['skills'] as Map<String, dynamic>? ?? {};
    final bossesRaw = data['bosses'] as Map<String, dynamic>? ?? {};

    final skills = <String, WomSkillGain>{};
    skillsRaw.forEach((k, v) {
      final m = v as Map<String, dynamic>;
      final exp = m['experience'] as Map<String, dynamic>? ?? {};
      final lvl = m['level'] as Map<String, dynamic>? ?? {};
      skills[k] = WomSkillGain(
        metric: k,
        experience: WomGainEntry(
          gained: (exp['gained'] as num?)?.toInt() ?? 0,
          start: (exp['start'] as num?)?.toInt() ?? 0,
          end: (exp['end'] as num?)?.toInt() ?? 0,
        ),
        levelGained: (lvl['gained'] as num?)?.toInt() ?? 0,
      );
    });

    final bosses = <String, WomBossGain>{};
    bossesRaw.forEach((k, v) {
      final m = v as Map<String, dynamic>;
      final kills = m['kills'] as Map<String, dynamic>? ?? {};
      bosses[k] = WomBossGain(
        metric: k,
        killsGained: (kills['gained'] as num?)?.toInt() ?? 0,
      );
    });

    return WomGains(
      startsAt: j['startsAt'] as String?,
      endsAt: j['endsAt'] as String?,
      skills: skills,
      bosses: bosses,
    );
  }
}

class WomAchievement {
  final String name;
  final String metric;
  final int threshold;
  final String measure;
  final String? createdAt;

  WomAchievement(
      {required this.name,
      required this.metric,
      required this.threshold,
      required this.measure,
      this.createdAt});

  factory WomAchievement.fromJson(Map<String, dynamic> j) => WomAchievement(
        name: j['name'] as String? ?? '',
        metric: j['metric'] as String? ?? '',
        threshold: (j['threshold'] as num?)?.toInt() ?? 0,
        measure: j['measure'] as String? ?? '',
        createdAt: j['createdAt'] as String?,
      );
}

class WomRecord {
  final String period;
  final String metric;
  final int value;
  final String? updatedAt;

  WomRecord(
      {required this.period,
      required this.metric,
      required this.value,
      this.updatedAt});

  factory WomRecord.fromJson(Map<String, dynamic> j) => WomRecord(
        period: j['period'] as String? ?? '',
        metric: j['metric'] as String? ?? '',
        value: (j['value'] as num?)?.toInt() ?? 0,
        updatedAt: j['updatedAt'] as String?,
      );
}

// ═══════════════════════════════════════════════════════════════════════
//  OSRS Wiki Bucket API  –  Equipment Best-in-Slot data
// ═══════════════════════════════════════════════════════════════════════

const _bucketFields = [
  'page_name',
  'stab_attack_bonus',
  'slash_attack_bonus',
  'crush_attack_bonus',
  'magic_attack_bonus',
  'range_attack_bonus',
  'stab_defence_bonus',
  'slash_defence_bonus',
  'crush_defence_bonus',
  'magic_defence_bonus',
  'range_defence_bonus',
  'strength_bonus',
  'ranged_strength_bonus',
  'magic_damage_bonus',
  'prayer_bonus',
  'equipment_slot',
  'weapon_attack_speed',
  'combat_style',
];

const equipmentSlots = [
  'head',
  'cape',
  'neck',
  'ammo',
  'weapon',
  '2h',
  'shield',
  'body',
  'legs',
  'hands',
  'feet',
  'ring',
];

const _slotDisplayNames = {
  'head': 'Head',
  'cape': 'Cape',
  'neck': 'Neck',
  'ammo': 'Ammo',
  'weapon': 'Weapon',
  '2h': '2H Weapon',
  'shield': 'Shield',
  'body': 'Body',
  'legs': 'Legs',
  'hands': 'Hands',
  'feet': 'Feet',
  'ring': 'Ring',
};

String slotDisplayName(String slot) => _slotDisplayNames[slot] ?? slot;

enum CombatStyle { melee, ranged, magic }

class EquipmentItem {
  final String name;
  final String slot;
  final int stabAttack;
  final int slashAttack;
  final int crushAttack;
  final int magicAttack;
  final int rangeAttack;
  final int stabDefence;
  final int slashDefence;
  final int crushDefence;
  final int magicDefence;
  final int rangeDefence;
  final int strengthBonus;
  final int rangedStrength;
  final int magicDamage;
  final int prayerBonus;
  final int? weaponSpeed;
  final String? combatStyle;

  const EquipmentItem({
    required this.name,
    required this.slot,
    this.stabAttack = 0,
    this.slashAttack = 0,
    this.crushAttack = 0,
    this.magicAttack = 0,
    this.rangeAttack = 0,
    this.stabDefence = 0,
    this.slashDefence = 0,
    this.crushDefence = 0,
    this.magicDefence = 0,
    this.rangeDefence = 0,
    this.strengthBonus = 0,
    this.rangedStrength = 0,
    this.magicDamage = 0,
    this.prayerBonus = 0,
    this.weaponSpeed,
    this.combatStyle,
  });

  factory EquipmentItem.fromBucket(Map<String, dynamic> j) {
    return EquipmentItem(
      name: j['page_name'] as String? ?? 'Unknown',
      slot: j['equipment_slot'] as String? ?? '',
      stabAttack: _num(j['stab_attack_bonus']),
      slashAttack: _num(j['slash_attack_bonus']),
      crushAttack: _num(j['crush_attack_bonus']),
      magicAttack: _num(j['magic_attack_bonus']),
      rangeAttack: _num(j['range_attack_bonus']),
      stabDefence: _num(j['stab_defence_bonus']),
      slashDefence: _num(j['slash_defence_bonus']),
      crushDefence: _num(j['crush_defence_bonus']),
      magicDefence: _num(j['magic_defence_bonus']),
      rangeDefence: _num(j['range_defence_bonus']),
      strengthBonus: _num(j['strength_bonus']),
      rangedStrength: _num(j['ranged_strength_bonus']),
      magicDamage: _num(j['magic_damage_bonus']),
      prayerBonus: _num(j['prayer_bonus']),
      weaponSpeed: j['weapon_attack_speed'] != null
          ? _num(j['weapon_attack_speed'])
          : null,
      combatStyle: j['combat_style'] as String?,
    );
  }

  static int _num(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// Primary offensive stat for a given combat style.
  int primaryOffence(CombatStyle style) {
    switch (style) {
      case CombatStyle.melee:
        return strengthBonus;
      case CombatStyle.ranged:
        return rangedStrength;
      case CombatStyle.magic:
        return magicDamage;
    }
  }

  /// Secondary offensive stat (accuracy) for a given combat style.
  int secondaryOffence(CombatStyle style) {
    switch (style) {
      case CombatStyle.melee:
        return [stabAttack, slashAttack, crushAttack]
            .reduce((a, b) => a > b ? a : b);
      case CombatStyle.ranged:
        return rangeAttack;
      case CombatStyle.magic:
        return magicAttack;
    }
  }

  int totalAttack() =>
      stabAttack + slashAttack + crushAttack + magicAttack + rangeAttack;
  int totalDefence() =>
      stabDefence + slashDefence + crushDefence + magicDefence + rangeDefence;
}

/// Cache so we don't re-fetch the same slot repeatedly in one session.
final Map<String, List<EquipmentItem>> _bisCache = {};

/// Fetch equipment items for a given slot from the OSRS Wiki Bucket API,
/// sorted by the primary offensive stat for the given combat style.
Future<List<EquipmentItem>> fetchBestInSlot(
  String slot, {
  CombatStyle style = CombatStyle.melee,
  int limit = 50,
}) async {
  final cacheKey = slot;
  List<EquipmentItem> items;

  if (_bisCache.containsKey(cacheKey)) {
    items = _bisCache[cacheKey]!;
  } else {
    final fields = _bucketFields.map((f) => "'$f'").join(',');
    final query = "bucket('infobox_bonuses')"
        '.select($fields)'
        ".where('equipment_slot','$slot')"
        '.limit(500)'
        '.run()';

    final uri = Uri.https(
      'oldschool.runescape.wiki',
      '/api.php',
      {'action': 'bucket', 'query': query, 'format': 'json'},
    );

    final resp = await http.get(uri, headers: {
      'User-Agent': 'OSRS Companion Desktop App',
    });

    if (resp.statusCode != 200) return [];

    final data = jsonDecode(resp.body);
    if (data['error'] != null) return [];

    final list = data['bucket'] as List<dynamic>? ?? [];
    items = list
        .map((e) => EquipmentItem.fromBucket(e as Map<String, dynamic>))
        .toList();

    // De-duplicate by name (keep first occurrence)
    final seen = <String>{};
    items = items.where((e) {
      if (seen.contains(e.name)) return false;
      seen.add(e.name);
      return true;
    }).toList();

    _bisCache[cacheKey] = items;
  }

  // Sort by primary offence, then secondary, for the requested style
  final sorted = List<EquipmentItem>.from(items);
  sorted.sort((a, b) {
    final cmp = b.primaryOffence(style).compareTo(a.primaryOffence(style));
    if (cmp != 0) return cmp;
    return b.secondaryOffence(style).compareTo(a.secondaryOffence(style));
  });

  return sorted.take(limit).toList();
}

void clearBisCache() => _bisCache.clear();
