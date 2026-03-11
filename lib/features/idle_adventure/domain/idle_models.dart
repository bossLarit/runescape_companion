import 'dart:convert';

// ─── XP Table (simplified OSRS curve) ────────────────────────────

/// Returns total XP needed for a given level (1–99).
int xpForLevel(int level) {
  if (level <= 1) return 0;
  double total = 0;
  for (int i = 1; i < level; i++) {
    total += (i + 300 * _pow2(i / 7.0)) / 4;
  }
  return total.floor();
}

double _pow2(double exp) {
  // 2^exp
  return _exp(exp * 0.6931471805599453); // ln(2) ≈ 0.693…
}

double _exp(double x) {
  // Fast enough for level calc
  double sum = 1.0;
  double term = 1.0;
  for (int i = 1; i <= 20; i++) {
    term *= x / i;
    sum += term;
  }
  return sum;
}

int levelForXp(int xp) {
  for (int lvl = 99; lvl >= 1; lvl--) {
    if (xp >= xpForLevel(lvl)) return lvl;
  }
  return 1;
}

// ─── Prayer ─────────────────────────────────────────────────────

enum ActivePrayer {
  none,
  protectFromMelee, // Level 43 — reduces incoming damage by 100% (like OSRS)
  piety, // Level 70 — +20% attack, +23% strength, +25% defence
}

/// Prayer level required to use each prayer.
int prayerLevelRequired(ActivePrayer prayer) {
  switch (prayer) {
    case ActivePrayer.none:
      return 1;
    case ActivePrayer.protectFromMelee:
      return 43;
    case ActivePrayer.piety:
      return 70;
  }
}

/// Prayer drain rate per tick (points consumed per combat tick).
int prayerDrainPerTick(ActivePrayer prayer) {
  switch (prayer) {
    case ActivePrayer.none:
      return 0;
    case ActivePrayer.protectFromMelee:
      return 3;
    case ActivePrayer.piety:
      return 5;
  }
}

// ─── Training Style ──────────────────────────────────────────────

enum TrainingStyle { attack, strength, defence, balanced, ranged, magic }

// ─── Food ────────────────────────────────────────────────────────

class FoodItem {
  final String id;
  final String name;
  final String icon;
  final int healAmount;
  final int cost;

  const FoodItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.healAmount,
    required this.cost,
  });
}

// ─── Combat Stats ────────────────────────────────────────────────

class CombatStats {
  final int attackXp;
  final int strengthXp;
  final int defenceXp;
  final int hitpointsXp;
  final int rangedXp;
  final int magicXp;

  const CombatStats({
    this.attackXp = 0,
    this.strengthXp = 0,
    this.defenceXp = 0,
    this.hitpointsXp = 1154, // level 10 starting HP like OSRS
    this.rangedXp = 0,
    this.magicXp = 0,
  });

  int get attackLevel => levelForXp(attackXp);
  int get strengthLevel => levelForXp(strengthXp);
  int get defenceLevel => levelForXp(defenceXp);
  int get hitpointsLevel => levelForXp(hitpointsXp);
  int get rangedLevel => levelForXp(rangedXp);
  int get magicLevel => levelForXp(magicXp);

  CombatStats copyWith({
    int? attackXp,
    int? strengthXp,
    int? defenceXp,
    int? hitpointsXp,
    int? rangedXp,
    int? magicXp,
  }) =>
      CombatStats(
        attackXp: attackXp ?? this.attackXp,
        strengthXp: strengthXp ?? this.strengthXp,
        defenceXp: defenceXp ?? this.defenceXp,
        hitpointsXp: hitpointsXp ?? this.hitpointsXp,
        rangedXp: rangedXp ?? this.rangedXp,
        magicXp: magicXp ?? this.magicXp,
      );

  Map<String, dynamic> toJson() => {
        'attackXp': attackXp,
        'strengthXp': strengthXp,
        'defenceXp': defenceXp,
        'hitpointsXp': hitpointsXp,
        'rangedXp': rangedXp,
        'magicXp': magicXp,
      };

  factory CombatStats.fromJson(Map<String, dynamic> j) => CombatStats(
        attackXp: j['attackXp'] as int? ?? 0,
        strengthXp: j['strengthXp'] as int? ?? 0,
        defenceXp: j['defenceXp'] as int? ?? 0,
        hitpointsXp: j['hitpointsXp'] as int? ?? 1154,
        rangedXp: j['rangedXp'] as int? ?? 0,
        magicXp: j['magicXp'] as int? ?? 0,
      );
}

// ─── Gear (endless level-based) ──────────────────────────────────

const _tierNames = [
  'Bronze',
  'Iron',
  'Steel',
  'Black',
  'Mithril',
  'Adamant',
  'Rune',
  'Dragon',
  'Barrows',
  'Abyssal',
  'Bandos',
  'Armadyl',
  'Ancestral',
  'Justiciar',
  'Torva',
  'Masori',
  'Virtus',
  'Vestas',
  'Statius',
  'Morrigans',
];

/// Derive a display name from an infinite gear level.
String gearName(int level) {
  if (level <= 0) return _tierNames[0];
  final idx = (level - 1) % _tierNames.length;
  final cycle = (level - 1) ~/ _tierNames.length;
  final base = _tierNames[idx];
  return cycle > 0 ? '$base +$cycle' : base;
}

/// Bonuses scale linearly with gear level.
int gearAttackBonus(int level) => level * 4;
int gearStrengthBonus(int level) => level * 5;
int gearDefenceBonus(int level) => level * 4;
int gearRangedAttackBonus(int level) => level * 4;
int gearRangedStrengthBonus(int level) => level * 4;
int gearMagicAttackBonus(int level) => level * 3;
int gearMagicStrengthBonus(int level) => level * 4;

// ─── Monster (base definition, scaled by zone) ──────────────────

class MonsterDef {
  final String id;
  final String name;
  final String icon;
  final int baseHp;
  final int baseAttack;
  final int baseStrength;
  final int baseDefence;
  final int baseGpMin;
  final int baseGpMax;
  final double dropChance; // base chance to drop a gear upgrade (0.0–1.0)

  const MonsterDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseHp,
    required this.baseAttack,
    required this.baseStrength,
    required this.baseDefence,
    required this.baseGpMin,
    required this.baseGpMax,
    required this.dropChance,
  });
}

/// A monster scaled to a specific zone.
class ScaledMonster {
  final MonsterDef def;
  final int zone;

  const ScaledMonster(this.def, this.zone);

  double get _mult => 1.0 + (zone * 0.5);
  String get id => '${def.id}_z$zone';
  String get name => zone == 0 ? def.name : '${def.name} (Zone ${zone + 1})';
  String get icon => def.icon;
  int get maxHp => (def.baseHp * _mult).ceil();
  int get attack => (def.baseAttack * _mult).ceil();
  int get strength => (def.baseStrength * _mult).ceil();
  int get defence => (def.baseDefence * _mult).ceil();
  int get gpMin => (def.baseGpMin * _mult).ceil();
  int get gpMax => (def.baseGpMax * _mult).ceil();
  double get dropChance => def.dropChance;
}

// ─── Loot Item ──────────────────────────────────────────────────

class LootItem {
  final String id;
  final String name;
  final String icon;
  final String
      category; // 'ore', 'bar', 'log', 'fish_raw', 'fish_cooked', 'hide', 'bone', 'rune', 'misc'

  const LootItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
  });
}

// ─── Monster Drop Entry ─────────────────────────────────────────

class DropEntry {
  final String itemId;
  final double chance; // 0.0–1.0 per kill
  final int minQty;
  final int maxQty;

  const DropEntry({
    required this.itemId,
    required this.chance,
    this.minQty = 1,
    this.maxQty = 1,
  });
}

// ─── Skilling ───────────────────────────────────────────────────

enum SkillType {
  woodcutting,
  mining,
  fishing,
  cooking,
  smithing,
  crafting,
}

class SkillingStats {
  final int woodcuttingXp;
  final int miningXp;
  final int fishingXp;
  final int cookingXp;
  final int smithingXp;
  final int craftingXp;

  const SkillingStats({
    this.woodcuttingXp = 0,
    this.miningXp = 0,
    this.fishingXp = 0,
    this.cookingXp = 0,
    this.smithingXp = 0,
    this.craftingXp = 0,
  });

  int get woodcuttingLevel => levelForXp(woodcuttingXp);
  int get miningLevel => levelForXp(miningXp);
  int get fishingLevel => levelForXp(fishingXp);
  int get cookingLevel => levelForXp(cookingXp);
  int get smithingLevel => levelForXp(smithingXp);
  int get craftingLevel => levelForXp(craftingXp);

  int levelFor(SkillType skill) {
    switch (skill) {
      case SkillType.woodcutting:
        return woodcuttingLevel;
      case SkillType.mining:
        return miningLevel;
      case SkillType.fishing:
        return fishingLevel;
      case SkillType.cooking:
        return cookingLevel;
      case SkillType.smithing:
        return smithingLevel;
      case SkillType.crafting:
        return craftingLevel;
    }
  }

  int xpFor(SkillType skill) {
    switch (skill) {
      case SkillType.woodcutting:
        return woodcuttingXp;
      case SkillType.mining:
        return miningXp;
      case SkillType.fishing:
        return fishingXp;
      case SkillType.cooking:
        return cookingXp;
      case SkillType.smithing:
        return smithingXp;
      case SkillType.crafting:
        return craftingXp;
    }
  }

  SkillingStats copyWith({
    int? woodcuttingXp,
    int? miningXp,
    int? fishingXp,
    int? cookingXp,
    int? smithingXp,
    int? craftingXp,
  }) =>
      SkillingStats(
        woodcuttingXp: woodcuttingXp ?? this.woodcuttingXp,
        miningXp: miningXp ?? this.miningXp,
        fishingXp: fishingXp ?? this.fishingXp,
        cookingXp: cookingXp ?? this.cookingXp,
        smithingXp: smithingXp ?? this.smithingXp,
        craftingXp: craftingXp ?? this.craftingXp,
      );

  SkillingStats addXp(SkillType skill, int xp) {
    switch (skill) {
      case SkillType.woodcutting:
        return copyWith(woodcuttingXp: woodcuttingXp + xp);
      case SkillType.mining:
        return copyWith(miningXp: miningXp + xp);
      case SkillType.fishing:
        return copyWith(fishingXp: fishingXp + xp);
      case SkillType.cooking:
        return copyWith(cookingXp: cookingXp + xp);
      case SkillType.smithing:
        return copyWith(smithingXp: smithingXp + xp);
      case SkillType.crafting:
        return copyWith(craftingXp: craftingXp + xp);
    }
  }

  Map<String, dynamic> toJson() => {
        'woodcuttingXp': woodcuttingXp,
        'miningXp': miningXp,
        'fishingXp': fishingXp,
        'cookingXp': cookingXp,
        'smithingXp': smithingXp,
        'craftingXp': craftingXp,
      };

  factory SkillingStats.fromJson(Map<String, dynamic> j) => SkillingStats(
        woodcuttingXp: j['woodcuttingXp'] as int? ?? 0,
        miningXp: j['miningXp'] as int? ?? 0,
        fishingXp: j['fishingXp'] as int? ?? 0,
        cookingXp: j['cookingXp'] as int? ?? 0,
        smithingXp: j['smithingXp'] as int? ?? 0,
        craftingXp: j['craftingXp'] as int? ?? 0,
      );
}

// ─── Skilling Resource ──────────────────────────────────────────

class SkillingResource {
  final String id;
  final String name;
  final String icon;
  final SkillType skill;
  final int levelRequired;
  final int xpPerAction;
  final String? producesItemId; // item added to bank on success
  final int producesQty;
  final Map<String, int> consumesItems; // itemId → qty consumed per action
  final double successRate; // 1.0 = always succeeds, lower = can fail/burn

  const SkillingResource({
    required this.id,
    required this.name,
    required this.icon,
    required this.skill,
    required this.levelRequired,
    required this.xpPerAction,
    this.producesItemId,
    this.producesQty = 1,
    this.consumesItems = const {},
    this.successRate = 1.0,
  });
}

// ─── Active Skilling State ──────────────────────────────────────

class ActiveSkillingState {
  final SkillType skill;
  final String resourceId; // which SkillingResource is being trained

  const ActiveSkillingState({
    required this.skill,
    required this.resourceId,
  });

  Map<String, dynamic> toJson() => {
        'skill': skill.index,
        'resourceId': resourceId,
      };

  factory ActiveSkillingState.fromJson(Map<String, dynamic> j) =>
      ActiveSkillingState(
        skill: SkillType.values[
            (j['skill'] as int? ?? 0).clamp(0, SkillType.values.length - 1)],
        resourceId: j['resourceId'] as String? ?? '',
      );
}

// ─── Slayer Task ────────────────────────────────────────────────

class SlayerTask {
  final String monsterId;
  final int amountTotal;
  final int amountKilled;
  final int bonusGp;
  final int bonusSlayerXp;

  const SlayerTask({
    required this.monsterId,
    required this.amountTotal,
    this.amountKilled = 0,
    this.bonusGp = 0,
    this.bonusSlayerXp = 0,
  });

  bool get isComplete => amountKilled >= amountTotal;
  int get remaining => (amountTotal - amountKilled).clamp(0, amountTotal);

  SlayerTask copyWith({
    String? monsterId,
    int? amountTotal,
    int? amountKilled,
    int? bonusGp,
    int? bonusSlayerXp,
  }) =>
      SlayerTask(
        monsterId: monsterId ?? this.monsterId,
        amountTotal: amountTotal ?? this.amountTotal,
        amountKilled: amountKilled ?? this.amountKilled,
        bonusGp: bonusGp ?? this.bonusGp,
        bonusSlayerXp: bonusSlayerXp ?? this.bonusSlayerXp,
      );

  Map<String, dynamic> toJson() => {
        'monsterId': monsterId,
        'amountTotal': amountTotal,
        'amountKilled': amountKilled,
        'bonusGp': bonusGp,
        'bonusSlayerXp': bonusSlayerXp,
      };

  factory SlayerTask.fromJson(Map<String, dynamic> j) => SlayerTask(
        monsterId: j['monsterId'] as String? ?? 'chicken',
        amountTotal: j['amountTotal'] as int? ?? 10,
        amountKilled: j['amountKilled'] as int? ?? 0,
        bonusGp: j['bonusGp'] as int? ?? 0,
        bonusSlayerXp: j['bonusSlayerXp'] as int? ?? 0,
      );
}

// ─── Offline Progress Result ─────────────────────────────────────

class OfflineProgressResult {
  final int ticksSimulated;
  final int killsGained;
  final int gpGained;
  final int gearLevelsGained;
  final Duration elapsed;

  const OfflineProgressResult({
    this.ticksSimulated = 0,
    this.killsGained = 0,
    this.gpGained = 0,
    this.gearLevelsGained = 0,
    this.elapsed = Duration.zero,
  });
}

// ─── Game State ──────────────────────────────────────────────────

class IdleGameState {
  final CombatStats stats;
  final int gp;
  final int gearLevel; // melee gear, endless, starts at 0
  final int rangedGearLevel;
  final int magicGearLevel;
  final int zone; // monster zone (0 = base, 1+ = scaled)
  final int monsterIndex; // index into base monster list
  final int monsterCurrentHp;
  final int playerCurrentHp;
  final int totalKills;
  final int prestigeLevel;
  final double prestigeMultiplier;
  final bool isRunning;
  final int? lastDamageDealt;
  final int? lastDamageTaken;
  final String? lastDrop; // name of last gear drop, null if none
  final TrainingStyle trainingStyle;
  final Map<String, int> foodInventory; // foodId → quantity
  final int specialAttackCooldown; // ticks remaining (0 = ready)
  final bool specialAttackQueued; // player requested a spec
  final List<String> combatLog; // last N log lines
  final int lastSaveEpochMs; // milliseconds since epoch of last save
  final int slayerXp;
  final SlayerTask? currentSlayerTask;
  final int slayerTasksCompleted;
  final int prayerXp;
  final int prayerPoints; // current prayer points (0 = drained)
  final ActivePrayer activePrayer;
  final Map<String, int> monsterKillCounts; // monsterId → total kills
  final int totalGearDrops;
  final bool
      autoAdvance; // auto-advance to next monster when current is trivial
  final Map<String, int> bank; // itemId → quantity (loot bank)
  final int deathCount;
  final int respawnTicksLeft; // ticks until respawn (0 = alive)
  final SkillingStats skillingStats;
  final ActiveSkillingState? activeSkilling; // null = not skilling
  final List<String> skillingLog; // last N skilling log lines

  const IdleGameState({
    this.stats = const CombatStats(),
    this.gp = 0,
    this.gearLevel = 0,
    this.rangedGearLevel = 0,
    this.magicGearLevel = 0,
    this.zone = 0,
    this.monsterIndex = 0,
    this.monsterCurrentHp = 3,
    this.playerCurrentHp = 10,
    this.totalKills = 0,
    this.prestigeLevel = 0,
    this.prestigeMultiplier = 1.0,
    this.isRunning = false,
    this.lastDamageDealt,
    this.lastDamageTaken,
    this.lastDrop,
    this.trainingStyle = TrainingStyle.balanced,
    this.foodInventory = const {},
    this.specialAttackCooldown = 0,
    this.specialAttackQueued = false,
    this.combatLog = const [],
    this.lastSaveEpochMs = 0,
    this.slayerXp = 0,
    this.currentSlayerTask,
    this.slayerTasksCompleted = 0,
    this.prayerXp = 0,
    this.prayerPoints = 0,
    this.activePrayer = ActivePrayer.none,
    this.monsterKillCounts = const {},
    this.totalGearDrops = 0,
    this.autoAdvance = false,
    this.bank = const {},
    this.deathCount = 0,
    this.respawnTicksLeft = 0,
    this.skillingStats = const SkillingStats(),
    this.activeSkilling,
    this.skillingLog = const [],
  });

  int get slayerLevel => levelForXp(slayerXp);
  int get prayerLevel => levelForXp(prayerXp);
  int get maxPrayerPoints => prayerLevel; // 1 point per prayer level like OSRS

  String get gearDisplayName => gearName(gearLevel);

  IdleGameState copyWith({
    CombatStats? stats,
    int? gp,
    int? gearLevel,
    int? rangedGearLevel,
    int? magicGearLevel,
    int? zone,
    int? monsterIndex,
    int? monsterCurrentHp,
    int? playerCurrentHp,
    int? totalKills,
    int? prestigeLevel,
    double? prestigeMultiplier,
    bool? isRunning,
    int? lastDamageDealt,
    int? lastDamageTaken,
    String? lastDrop,
    bool clearDrop = false,
    TrainingStyle? trainingStyle,
    Map<String, int>? foodInventory,
    int? specialAttackCooldown,
    bool? specialAttackQueued,
    List<String>? combatLog,
    int? lastSaveEpochMs,
    int? slayerXp,
    SlayerTask? currentSlayerTask,
    bool clearSlayerTask = false,
    int? slayerTasksCompleted,
    int? prayerXp,
    int? prayerPoints,
    ActivePrayer? activePrayer,
    Map<String, int>? monsterKillCounts,
    int? totalGearDrops,
    bool? autoAdvance,
    Map<String, int>? bank,
    int? deathCount,
    int? respawnTicksLeft,
    SkillingStats? skillingStats,
    ActiveSkillingState? activeSkilling,
    bool clearActiveSkilling = false,
    List<String>? skillingLog,
  }) =>
      IdleGameState(
        stats: stats ?? this.stats,
        gp: gp ?? this.gp,
        gearLevel: gearLevel ?? this.gearLevel,
        rangedGearLevel: rangedGearLevel ?? this.rangedGearLevel,
        magicGearLevel: magicGearLevel ?? this.magicGearLevel,
        zone: zone ?? this.zone,
        monsterIndex: monsterIndex ?? this.monsterIndex,
        monsterCurrentHp: monsterCurrentHp ?? this.monsterCurrentHp,
        playerCurrentHp: playerCurrentHp ?? this.playerCurrentHp,
        totalKills: totalKills ?? this.totalKills,
        prestigeLevel: prestigeLevel ?? this.prestigeLevel,
        prestigeMultiplier: prestigeMultiplier ?? this.prestigeMultiplier,
        isRunning: isRunning ?? this.isRunning,
        lastDamageDealt: lastDamageDealt,
        lastDamageTaken: lastDamageTaken,
        lastDrop: clearDrop ? null : (lastDrop ?? this.lastDrop),
        trainingStyle: trainingStyle ?? this.trainingStyle,
        foodInventory: foodInventory ?? this.foodInventory,
        specialAttackCooldown:
            specialAttackCooldown ?? this.specialAttackCooldown,
        specialAttackQueued: specialAttackQueued ?? this.specialAttackQueued,
        combatLog: combatLog ?? this.combatLog,
        lastSaveEpochMs: lastSaveEpochMs ?? this.lastSaveEpochMs,
        slayerXp: slayerXp ?? this.slayerXp,
        currentSlayerTask: clearSlayerTask
            ? null
            : (currentSlayerTask ?? this.currentSlayerTask),
        slayerTasksCompleted: slayerTasksCompleted ?? this.slayerTasksCompleted,
        prayerXp: prayerXp ?? this.prayerXp,
        prayerPoints: prayerPoints ?? this.prayerPoints,
        activePrayer: activePrayer ?? this.activePrayer,
        monsterKillCounts: monsterKillCounts ?? this.monsterKillCounts,
        totalGearDrops: totalGearDrops ?? this.totalGearDrops,
        autoAdvance: autoAdvance ?? this.autoAdvance,
        bank: bank ?? this.bank,
        deathCount: deathCount ?? this.deathCount,
        respawnTicksLeft: respawnTicksLeft ?? this.respawnTicksLeft,
        skillingStats: skillingStats ?? this.skillingStats,
        activeSkilling: clearActiveSkilling
            ? null
            : (activeSkilling ?? this.activeSkilling),
        skillingLog: skillingLog ?? this.skillingLog,
      );

  int get totalFood => foodInventory.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
        'stats': stats.toJson(),
        'gp': gp,
        'gearLevel': gearLevel,
        'rangedGearLevel': rangedGearLevel,
        'magicGearLevel': magicGearLevel,
        'zone': zone,
        'monsterIndex': monsterIndex,
        'totalKills': totalKills,
        'prestigeLevel': prestigeLevel,
        'prestigeMultiplier': prestigeMultiplier,
        'trainingStyle': trainingStyle.index,
        'foodInventory': foodInventory,
        'lastSaveEpochMs': DateTime.now().millisecondsSinceEpoch,
        'slayerXp': slayerXp,
        'currentSlayerTask': currentSlayerTask?.toJson(),
        'slayerTasksCompleted': slayerTasksCompleted,
        'prayerXp': prayerXp,
        'prayerPoints': prayerPoints,
        'activePrayer': activePrayer.index,
        'monsterKillCounts': monsterKillCounts,
        'totalGearDrops': totalGearDrops,
        'autoAdvance': autoAdvance,
        'bank': bank,
        'deathCount': deathCount,
        'skillingStats': skillingStats.toJson(),
        'activeSkilling': activeSkilling?.toJson(),
        'skillingLog': skillingLog,
      };

  factory IdleGameState.fromJson(Map<String, dynamic> j) {
    final stats =
        CombatStats.fromJson(j['stats'] as Map<String, dynamic>? ?? {});
    final foodRaw = j['foodInventory'] as Map<String, dynamic>? ?? {};
    final foodInv = foodRaw.map((k, v) => MapEntry(k, v as int? ?? 0));
    final styleIdx = j['trainingStyle'] as int? ?? TrainingStyle.balanced.index;
    return IdleGameState(
      stats: stats,
      gp: j['gp'] as int? ?? 0,
      gearLevel: j['gearLevel'] as int? ?? j['gearIndex'] as int? ?? 0,
      rangedGearLevel: j['rangedGearLevel'] as int? ?? 0,
      magicGearLevel: j['magicGearLevel'] as int? ?? 0,
      zone: j['zone'] as int? ?? 0,
      monsterIndex: j['monsterIndex'] as int? ?? 0,
      playerCurrentHp: stats.hitpointsLevel,
      totalKills: j['totalKills'] as int? ?? 0,
      prestigeLevel: j['prestigeLevel'] as int? ?? 0,
      prestigeMultiplier: (j['prestigeMultiplier'] as num?)?.toDouble() ?? 1.0,
      trainingStyle: TrainingStyle
          .values[styleIdx.clamp(0, TrainingStyle.values.length - 1)],
      foodInventory: foodInv,
      lastSaveEpochMs: j['lastSaveEpochMs'] as int? ?? 0,
      slayerXp: j['slayerXp'] as int? ?? 0,
      currentSlayerTask: j['currentSlayerTask'] != null
          ? SlayerTask.fromJson(j['currentSlayerTask'] as Map<String, dynamic>)
          : null,
      slayerTasksCompleted: j['slayerTasksCompleted'] as int? ?? 0,
      prayerXp: j['prayerXp'] as int? ?? 0,
      prayerPoints: j['prayerPoints'] as int? ?? 0,
      activePrayer: ActivePrayer.values[(j['activePrayer'] as int? ?? 0)
          .clamp(0, ActivePrayer.values.length - 1)],
      monsterKillCounts: (j['monsterKillCounts'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int? ?? 0)),
      totalGearDrops: j['totalGearDrops'] as int? ?? 0,
      autoAdvance: j['autoAdvance'] as bool? ?? false,
      bank: (j['bank'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int? ?? 0)),
      deathCount: j['deathCount'] as int? ?? 0,
      skillingStats: SkillingStats.fromJson(
          j['skillingStats'] as Map<String, dynamic>? ?? {}),
      activeSkilling: j['activeSkilling'] != null
          ? ActiveSkillingState.fromJson(
              j['activeSkilling'] as Map<String, dynamic>)
          : null,
      skillingLog: (j['skillingLog'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  String serialize() => jsonEncode(toJson());

  factory IdleGameState.deserialize(String data) =>
      IdleGameState.fromJson(jsonDecode(data) as Map<String, dynamic>);
}
