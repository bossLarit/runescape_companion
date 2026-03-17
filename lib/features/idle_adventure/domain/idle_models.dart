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

// ─── Equipment ──────────────────────────────────────────────────

enum EquipmentSlot {
  head,
  cape,
  neck,
  ammo,
  weapon,
  body,
  shield,
  legs,
  hands,
  feet,
  ring
}

class EquipmentItemDef {
  final String id;
  final String name;
  final String icon;
  final EquipmentSlot slot;
  final int meleeAttack;
  final int meleeStrength;
  final int meleeDefence;
  final int rangedAttack;
  final int rangedStrength;
  final int magicAttack;
  final int magicStrength;
  final int prayerBonus;
  final int attackReq;
  final int defenceReq;
  final int rangedReq;
  final int magicReq;
  final int prayerReq;
  final int buyPrice; // 0 = not buyable

  const EquipmentItemDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.slot,
    this.meleeAttack = 0,
    this.meleeStrength = 0,
    this.meleeDefence = 0,
    this.rangedAttack = 0,
    this.rangedStrength = 0,
    this.magicAttack = 0,
    this.magicStrength = 0,
    this.prayerBonus = 0,
    this.attackReq = 0,
    this.defenceReq = 0,
    this.rangedReq = 0,
    this.magicReq = 0,
    this.prayerReq = 0,
    this.buyPrice = 0,
  });
}

/// Sum stat bonuses across all equipped items.
class EquipmentBonuses {
  final int meleeAttack;
  final int meleeStrength;
  final int meleeDefence;
  final int rangedAttack;
  final int rangedStrength;
  final int magicAttack;
  final int magicStrength;
  final int prayerBonus;

  const EquipmentBonuses({
    this.meleeAttack = 0,
    this.meleeStrength = 0,
    this.meleeDefence = 0,
    this.rangedAttack = 0,
    this.rangedStrength = 0,
    this.magicAttack = 0,
    this.magicStrength = 0,
    this.prayerBonus = 0,
  });
}

// ─── Monster (fixed OSRS stats, no zone scaling) ────────────────

class MonsterDef {
  final String id;
  final String name;
  final String icon;
  final int hitpoints;
  final int attack;
  final int strength;
  final int defence;
  final int maxHit;
  final int combatLevel;
  final int gpMin;
  final int gpMax;
  final bool isBoss;

  const MonsterDef({
    required this.id,
    required this.name,
    this.icon = '👹',
    required this.hitpoints,
    required this.attack,
    required this.strength,
    required this.defence,
    required this.maxHit,
    required this.combatLevel,
    this.gpMin = 0,
    this.gpMax = 0,
    this.isBoss = false,
  });
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

// ─── Raids ──────────────────────────────────────────────────────

class RaidDropEntry {
  final String itemId;
  final int weight; // relative weight within the unique table

  const RaidDropEntry({required this.itemId, this.weight = 1});
}

class RaidDef {
  final String id;
  final String name;
  final String icon;
  final List<MonsterDef> bosses;
  final double uniqueDropChance; // 0.0–1.0 per completion
  final List<RaidDropEntry> uniqueDropTable;
  final int minAttack;
  final int minStrength;
  final int minDefence;

  const RaidDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.bosses,
    required this.uniqueDropChance,
    required this.uniqueDropTable,
    this.minAttack = 90,
    this.minStrength = 90,
    this.minDefence = 90,
  });
}

class RaidState {
  final String raidId;
  final int bossIndex; // current boss in the sequence
  final bool isActive;

  const RaidState({
    required this.raidId,
    this.bossIndex = 0,
    this.isActive = true,
  });

  RaidState copyWith({String? raidId, int? bossIndex, bool? isActive}) =>
      RaidState(
        raidId: raidId ?? this.raidId,
        bossIndex: bossIndex ?? this.bossIndex,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'raidId': raidId,
        'bossIndex': bossIndex,
        'isActive': isActive,
      };

  factory RaidState.fromJson(Map<String, dynamic> j) => RaidState(
        raidId: j['raidId'] as String? ?? '',
        bossIndex: j['bossIndex'] as int? ?? 0,
        isActive: j['isActive'] as bool? ?? false,
      );
}

// ─── Offline Progress Result ─────────────────────────────────────

class OfflineProgressResult {
  final int ticksSimulated;
  final int killsGained;
  final int gpGained;
  final int equipmentDropsGained;
  final Duration elapsed;

  const OfflineProgressResult({
    this.ticksSimulated = 0,
    this.killsGained = 0,
    this.gpGained = 0,
    this.equipmentDropsGained = 0,
    this.elapsed = Duration.zero,
  });
}

// ─── Game State ──────────────────────────────────────────────────

class IdleGameState {
  final CombatStats stats;
  final int gp;
  final Map<String, String> equipment; // slot name → equipped item id
  final int monsterIndex; // index into monster list
  final int monsterCurrentHp;
  final int playerCurrentHp;
  final int totalKills;
  final int prestigeLevel;
  final double prestigeMultiplier;
  final bool isRunning;
  final int? lastDamageDealt;
  final int? lastDamageTaken;
  final String? lastDrop; // name of last drop, null if none
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
  final bool autoAdvance;
  final Map<String, int> bank; // itemId → quantity (loot bank)
  final int deathCount;
  final int respawnTicksLeft; // ticks until respawn (0 = alive)
  final SkillingStats skillingStats;
  final ActiveSkillingState? activeSkilling; // null = not skilling
  final List<String> skillingLog; // last N skilling log lines
  final RaidState? activeRaid; // null = not raiding
  final int raidBossCurrentHp;
  final Map<String, int> raidCompletions; // raidId → completion count

  const IdleGameState({
    this.stats = const CombatStats(),
    this.gp = 0,
    this.equipment = const {},
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
    this.activeRaid,
    this.raidBossCurrentHp = 0,
    this.raidCompletions = const {},
  });

  int get slayerLevel => levelForXp(slayerXp);
  int get prayerLevel => levelForXp(prayerXp);
  int get maxPrayerPoints => prayerLevel; // 1 point per prayer level like OSRS

  String? equippedInSlot(EquipmentSlot slot) => equipment[slot.name];

  IdleGameState copyWith({
    CombatStats? stats,
    int? gp,
    Map<String, String>? equipment,
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
    RaidState? activeRaid,
    bool clearActiveRaid = false,
    int? raidBossCurrentHp,
    Map<String, int>? raidCompletions,
  }) =>
      IdleGameState(
        stats: stats ?? this.stats,
        gp: gp ?? this.gp,
        equipment: equipment ?? this.equipment,
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
        activeRaid: clearActiveRaid ? null : (activeRaid ?? this.activeRaid),
        raidBossCurrentHp: raidBossCurrentHp ?? this.raidBossCurrentHp,
        raidCompletions: raidCompletions ?? this.raidCompletions,
      );

  int get totalFood => foodInventory.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
        'stats': stats.toJson(),
        'gp': gp,
        'equipment': equipment,
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
        'activeRaid': activeRaid?.toJson(),
        'raidCompletions': raidCompletions,
      };

  factory IdleGameState.fromJson(Map<String, dynamic> j) {
    final stats =
        CombatStats.fromJson(j['stats'] as Map<String, dynamic>? ?? {});
    final foodRaw = j['foodInventory'] as Map<String, dynamic>? ?? {};
    final foodInv = foodRaw.map((k, v) => MapEntry(k, v as int? ?? 0));
    final styleIdx = j['trainingStyle'] as int? ?? TrainingStyle.balanced.index;
    final eqRaw = j['equipment'] as Map<String, dynamic>? ?? {};
    final eq = eqRaw.map((k, v) => MapEntry(k, v as String? ?? ''));
    eq.removeWhere((k, v) => v.isEmpty);
    return IdleGameState(
      stats: stats,
      gp: j['gp'] as int? ?? 0,
      equipment: eq,
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
      activeRaid: j['activeRaid'] != null
          ? RaidState.fromJson(j['activeRaid'] as Map<String, dynamic>)
          : null,
      raidCompletions: (j['raidCompletions'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int? ?? 0)),
    );
  }

  String serialize() => jsonEncode(toJson());

  factory IdleGameState.deserialize(String data) =>
      IdleGameState.fromJson(jsonDecode(data) as Map<String, dynamic>);
}
