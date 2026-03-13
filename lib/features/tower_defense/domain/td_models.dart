import 'dart:convert';

// ─── Enums ───────────────────────────────────────────────────────

enum TowerType { archer, mage, warrior, house, cannon, ballista, poisonTrap }

enum NodeType { tree, runeAltar, mine }

enum ProjectileType {
  arrow,
  magicBolt,
  garrisonArrow,
  cannonBall,
  ballistaBolt
}

enum PeasantState { idle, walking, gathering }

enum TdPhase { idle, waveActive, waveComplete, gameOver }

enum AbilityType { iceBarrage, cannonBlast, heal }

enum WaveModifier { none, armoured, swift, horde, regen, shielded }

enum LootRarity { common, uncommon, rare, legendary }

enum LootSlot { hero, tower }

String towerTypeName(TowerType t) => switch (t) {
      TowerType.archer => 'Archer',
      TowerType.mage => 'Mage',
      TowerType.warrior => 'Warrior',
      TowerType.house => 'House',
      TowerType.cannon => 'Dwarf Cannon',
      TowerType.ballista => 'Ballista',
      TowerType.poisonTrap => 'Poison Trap',
    };

String waveModifierName(WaveModifier m) => switch (m) {
      WaveModifier.none => '',
      WaveModifier.armoured => 'ARMOURED',
      WaveModifier.swift => 'SWIFT',
      WaveModifier.horde => 'HORDE',
      WaveModifier.regen => 'REGEN',
      WaveModifier.shielded => 'SHIELDED',
    };

String nodeTypeName(NodeType n) => switch (n) {
      NodeType.tree => 'Tree',
      NodeType.runeAltar => 'Rune Altar',
      NodeType.mine => 'Mine',
    };

String nodeResourceName(NodeType n) => switch (n) {
      NodeType.tree => 'Logs',
      NodeType.runeAltar => 'Runes',
      NodeType.mine => 'Ore',
    };

String nodeTierName(NodeType type, int level) {
  if (level <= 1) return nodeTypeName(type);
  return switch (type) {
    NodeType.tree => level == 2 ? 'Yew Tree' : 'Magic Tree',
    NodeType.runeAltar => level == 2 ? 'Chaos Altar' : 'Nature Altar',
    NodeType.mine => level == 2 ? 'Mith Mine' : 'Rune Mine',
  };
}

// ─── Resources ───────────────────────────────────────────────────

class Resources {
  final int gold;
  final int logs;
  final int runes;
  final int ore;

  const Resources({this.gold = 0, this.logs = 0, this.runes = 0, this.ore = 0});

  Resources copyWith({int? gold, int? logs, int? runes, int? ore}) => Resources(
        gold: gold ?? this.gold,
        logs: logs ?? this.logs,
        runes: runes ?? this.runes,
        ore: ore ?? this.ore,
      );

  bool canAfford(Resources cost) =>
      gold >= cost.gold &&
      logs >= cost.logs &&
      runes >= cost.runes &&
      ore >= cost.ore;

  Resources subtract(Resources cost) => Resources(
        gold: gold - cost.gold,
        logs: logs - cost.logs,
        runes: runes - cost.runes,
        ore: ore - cost.ore,
      );

  Resources add(Resources other) => Resources(
        gold: gold + other.gold,
        logs: logs + other.logs,
        runes: runes + other.runes,
        ore: ore + other.ore,
      );

  Map<String, dynamic> toJson() =>
      {'gold': gold, 'logs': logs, 'runes': runes, 'ore': ore};

  factory Resources.fromJson(Map<String, dynamic> j) => Resources(
        gold: j['gold'] as int? ?? 0,
        logs: j['logs'] as int? ?? 0,
        runes: j['runes'] as int? ?? 0,
        ore: j['ore'] as int? ?? 0,
      );
}

// ─── Garrison ────────────────────────────────────────────────────

class GarrisonState {
  final int hp;
  final int maxHp;
  final int damageLevel;
  final int healthLevel;
  final int armourLevel;
  final double fireCooldown;

  const GarrisonState({
    this.hp = 100,
    this.maxHp = 100,
    this.damageLevel = 1,
    this.healthLevel = 1,
    this.armourLevel = 0,
    this.fireCooldown = 0,
  });

  double get armourReduction => armourLevel / (armourLevel + 100);

  GarrisonState copyWith({
    int? hp,
    int? maxHp,
    int? damageLevel,
    int? healthLevel,
    int? armourLevel,
    double? fireCooldown,
  }) =>
      GarrisonState(
        hp: hp ?? this.hp,
        maxHp: maxHp ?? this.maxHp,
        damageLevel: damageLevel ?? this.damageLevel,
        healthLevel: healthLevel ?? this.healthLevel,
        armourLevel: armourLevel ?? this.armourLevel,
        fireCooldown: fireCooldown ?? this.fireCooldown,
      );

  Map<String, dynamic> toJson() => {
        'hp': hp,
        'maxHp': maxHp,
        'damageLevel': damageLevel,
        'healthLevel': healthLevel,
        'armourLevel': armourLevel,
      };

  factory GarrisonState.fromJson(Map<String, dynamic> j) => GarrisonState(
        hp: j['hp'] as int? ?? 100,
        maxHp: j['maxHp'] as int? ?? 100,
        damageLevel: j['damageLevel'] as int? ?? 1,
        healthLevel: j['healthLevel'] as int? ?? 1,
        armourLevel: j['armourLevel'] as int? ?? 0,
      );
}

// ─── Tower Slot ──────────────────────────────────────────────────

class TowerSlot {
  final double x;
  final double y;
  TowerType? towerType;
  int level;
  double fireCooldown;
  String? equippedLootId;

  TowerSlot({
    required this.x,
    required this.y,
    this.towerType,
    this.level = 0,
    this.fireCooldown = 0,
    this.equippedLootId,
  });

  bool get isEmpty => towerType == null;
  bool get hasTower => towerType != null;

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'towerType': towerType?.index,
        'level': level,
        if (equippedLootId != null) 'equippedLootId': equippedLootId,
      };

  factory TowerSlot.fromJson(Map<String, dynamic> j) => TowerSlot(
        x: (j['x'] as num?)?.toDouble() ?? 0,
        y: (j['y'] as num?)?.toDouble() ?? 0,
        towerType: j['towerType'] != null
            ? TowerType.values[j['towerType'] as int]
            : null,
        level: j['level'] as int? ?? 0,
        equippedLootId: j['equippedLootId'] as String?,
      );
}

// ─── Resource Node ───────────────────────────────────────────────

class ResourceNode {
  final NodeType type;
  final double x;
  final double y;
  int level;

  ResourceNode(
      {required this.type, required this.x, required this.y, this.level = 1});

  Map<String, dynamic> toJson() =>
      {'type': type.index, 'x': x, 'y': y, 'level': level};

  factory ResourceNode.fromJson(Map<String, dynamic> j) => ResourceNode(
        type: NodeType.values[j['type'] as int? ?? 0],
        x: (j['x'] as num?)?.toDouble() ?? 0,
        y: (j['y'] as num?)?.toDouble() ?? 0,
        level: j['level'] as int? ?? 1,
      );
}

// ─── Ability Cooldowns ──────────────────────────────────────────

class AbilityCooldowns {
  final int iceBarrageWavesLeft;
  final int cannonBlastWavesLeft;
  final int healWavesLeft;

  const AbilityCooldowns({
    this.iceBarrageWavesLeft = 0,
    this.cannonBlastWavesLeft = 0,
    this.healWavesLeft = 0,
  });

  bool canUse(AbilityType type) => switch (type) {
        AbilityType.iceBarrage => iceBarrageWavesLeft <= 0,
        AbilityType.cannonBlast => cannonBlastWavesLeft <= 0,
        AbilityType.heal => healWavesLeft <= 0,
      };

  int cooldownLeft(AbilityType type) => switch (type) {
        AbilityType.iceBarrage => iceBarrageWavesLeft,
        AbilityType.cannonBlast => cannonBlastWavesLeft,
        AbilityType.heal => healWavesLeft,
      };

  AbilityCooldowns withUsed(AbilityType type) => switch (type) {
        AbilityType.iceBarrage => AbilityCooldowns(
            iceBarrageWavesLeft: 3,
            cannonBlastWavesLeft: cannonBlastWavesLeft,
            healWavesLeft: healWavesLeft),
        AbilityType.cannonBlast => AbilityCooldowns(
            iceBarrageWavesLeft: iceBarrageWavesLeft,
            cannonBlastWavesLeft: 2,
            healWavesLeft: healWavesLeft),
        AbilityType.heal => AbilityCooldowns(
            iceBarrageWavesLeft: iceBarrageWavesLeft,
            cannonBlastWavesLeft: cannonBlastWavesLeft,
            healWavesLeft: 2),
      };

  AbilityCooldowns tickWave() => AbilityCooldowns(
        iceBarrageWavesLeft: (iceBarrageWavesLeft - 1).clamp(0, 99),
        cannonBlastWavesLeft: (cannonBlastWavesLeft - 1).clamp(0, 99),
        healWavesLeft: (healWavesLeft - 1).clamp(0, 99),
      );

  Map<String, dynamic> toJson() => {
        'ice': iceBarrageWavesLeft,
        'cannon': cannonBlastWavesLeft,
        'heal': healWavesLeft,
      };

  factory AbilityCooldowns.fromJson(Map<String, dynamic> j) => AbilityCooldowns(
        iceBarrageWavesLeft: j['ice'] as int? ?? 0,
        cannonBlastWavesLeft: j['cannon'] as int? ?? 0,
        healWavesLeft: j['heal'] as int? ?? 0,
      );
}

// ─── Hero Unit ──────────────────────────────────────────────────

class HeroUnit {
  double x;
  double y;
  double patrolProgress;
  int hp;
  int maxHp;
  int damageLevel;
  double attackCooldown;
  int respawnTimer;
  bool alive;
  bool patrolForward;
  String? equippedLootId;

  HeroUnit({
    this.x = 0.5,
    this.y = 0.5,
    this.patrolProgress = 0.3,
    this.hp = 30,
    this.maxHp = 30,
    this.damageLevel = 1,
    this.attackCooldown = 0,
    this.respawnTimer = 0,
    this.alive = true,
    this.patrolForward = true,
    this.equippedLootId,
  });

  Map<String, dynamic> toJson() => {
        'damageLevel': damageLevel,
        'hp': hp,
        'maxHp': maxHp,
        if (equippedLootId != null) 'equippedLootId': equippedLootId,
      };

  factory HeroUnit.fromJson(Map<String, dynamic> j) => HeroUnit(
        damageLevel: j['damageLevel'] as int? ?? 1,
        hp: j['hp'] as int? ?? 30,
        maxHp: j['maxHp'] as int? ?? 30,
        equippedLootId: j['equippedLootId'] as String?,
      );
}

// ─── Wall Slot ──────────────────────────────────────────────────

class WallSlot {
  final double x;
  final double y;
  final double pathProgress;
  int hp;
  int maxHp;
  int level;

  WallSlot({
    required this.x,
    required this.y,
    required this.pathProgress,
    this.hp = 0,
    this.maxHp = 0,
    this.level = 0,
  });

  bool get isBuilt => level > 0 && hp > 0;
  bool get isDestroyed => level > 0 && hp <= 0;
  bool get isEmpty => level == 0;

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'pathProgress': pathProgress,
        'hp': hp,
        'maxHp': maxHp,
        'level': level,
      };

  factory WallSlot.fromJson(Map<String, dynamic> j) => WallSlot(
        x: (j['x'] as num?)?.toDouble() ?? 0,
        y: (j['y'] as num?)?.toDouble() ?? 0,
        pathProgress: (j['pathProgress'] as num?)?.toDouble() ?? 0,
        hp: j['hp'] as int? ?? 0,
        maxHp: j['maxHp'] as int? ?? 0,
        level: j['level'] as int? ?? 0,
      );
}

// ─── Peasant ─────────────────────────────────────────────────────

class Peasant {
  final int id;
  int assignedNodeIndex;
  double x;
  double y;
  PeasantState state;
  double gatherTimer;

  Peasant({
    required this.id,
    this.assignedNodeIndex = -1,
    required this.x,
    required this.y,
    this.state = PeasantState.idle,
    this.gatherTimer = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'assignedNodeIndex': assignedNodeIndex,
      };

  factory Peasant.fromJson(Map<String, dynamic> j) => Peasant(
        id: j['id'] as int? ?? 0,
        assignedNodeIndex: j['assignedNodeIndex'] as int? ?? -1,
        x: 0.5,
        y: 0.92,
      );
}

// ─── Enemy Definition ────────────────────────────────────────────

class EnemyDef {
  final String id;
  final String name;
  final int baseHp;
  final double baseSpeed;
  final int baseGpReward;
  final int baseDamage;

  const EnemyDef({
    required this.id,
    required this.name,
    required this.baseHp,
    required this.baseSpeed,
    required this.baseGpReward,
    this.baseDamage = 1,
  });
}

// ─── Active Enemy ────────────────────────────────────────────────

class ActiveEnemy {
  final int defIndex;
  double pathProgress;
  double hp;
  final double maxHp;
  double speed;
  final int gpReward;
  final int damage;
  bool alive;
  final bool isTreasure;
  bool frozen;
  bool shielded;
  int poisonTicksLeft;

  ActiveEnemy({
    required this.defIndex,
    required this.hp,
    required this.maxHp,
    required this.speed,
    required this.gpReward,
    required this.damage,
    this.pathProgress = 0.0,
    this.alive = true,
    this.isTreasure = false,
    this.frozen = false,
    this.shielded = false,
    this.poisonTicksLeft = 0,
  });
}

// ─── Projectile ──────────────────────────────────────────────────

class Projectile {
  double x;
  double y;
  double targetX;
  double targetY;
  final double damage;
  final ProjectileType type;
  final int targetEnemyIndex;
  bool active;

  Projectile({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.damage,
    required this.type,
    required this.targetEnemyIndex,
    this.active = true,
  });
}

// ─── Damage Number ───────────────────────────────────────────────

class DamageNumber {
  double x;
  double y;
  final int amount;
  int ticksLeft;

  DamageNumber({
    required this.x,
    required this.y,
    required this.amount,
    this.ticksLeft = 40,
  });
}

// ─── Loot Item ──────────────────────────────────────────────────

class LootItem {
  final String id;
  final String name;
  final LootRarity rarity;
  final LootSlot slot;
  final double dmgBonus;
  final double rangeBonus;
  final double speedBonus;
  final double hpBonus;
  final double gpBonus;

  const LootItem({
    required this.id,
    required this.name,
    required this.rarity,
    required this.slot,
    this.dmgBonus = 0,
    this.rangeBonus = 0,
    this.speedBonus = 0,
    this.hpBonus = 0,
    this.gpBonus = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rarity': rarity.index,
        'slot': slot.index,
        'dmgBonus': dmgBonus,
        'rangeBonus': rangeBonus,
        'speedBonus': speedBonus,
        'hpBonus': hpBonus,
        'gpBonus': gpBonus,
      };

  factory LootItem.fromJson(Map<String, dynamic> j) => LootItem(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        rarity: LootRarity.values[j['rarity'] as int? ?? 0],
        slot: LootSlot.values[j['slot'] as int? ?? 0],
        dmgBonus: (j['dmgBonus'] as num?)?.toDouble() ?? 0,
        rangeBonus: (j['rangeBonus'] as num?)?.toDouble() ?? 0,
        speedBonus: (j['speedBonus'] as num?)?.toDouble() ?? 0,
        hpBonus: (j['hpBonus'] as num?)?.toDouble() ?? 0,
        gpBonus: (j['gpBonus'] as num?)?.toDouble() ?? 0,
      );
}

// ─── Prestige Bonuses ───────────────────────────────────────────

class PrestigeBonuses {
  final int startingGoldBonus;
  final int peasantCapBonus;
  final int towerDmgPercent;
  final int garrisonHpPercent;

  const PrestigeBonuses({
    this.startingGoldBonus = 0,
    this.peasantCapBonus = 0,
    this.towerDmgPercent = 0,
    this.garrisonHpPercent = 0,
  });

  PrestigeBonuses copyWith({
    int? startingGoldBonus,
    int? peasantCapBonus,
    int? towerDmgPercent,
    int? garrisonHpPercent,
  }) =>
      PrestigeBonuses(
        startingGoldBonus: startingGoldBonus ?? this.startingGoldBonus,
        peasantCapBonus: peasantCapBonus ?? this.peasantCapBonus,
        towerDmgPercent: towerDmgPercent ?? this.towerDmgPercent,
        garrisonHpPercent: garrisonHpPercent ?? this.garrisonHpPercent,
      );

  Map<String, dynamic> toJson() => {
        'startingGoldBonus': startingGoldBonus,
        'peasantCapBonus': peasantCapBonus,
        'towerDmgPercent': towerDmgPercent,
        'garrisonHpPercent': garrisonHpPercent,
      };

  factory PrestigeBonuses.fromJson(Map<String, dynamic> j) => PrestigeBonuses(
        startingGoldBonus: j['startingGoldBonus'] as int? ?? 0,
        peasantCapBonus: j['peasantCapBonus'] as int? ?? 0,
        towerDmgPercent: j['towerDmgPercent'] as int? ?? 0,
        garrisonHpPercent: j['garrisonHpPercent'] as int? ?? 0,
      );
}

// ─── Game State ──────────────────────────────────────────────────

class TdGameState {
  final Resources resources;
  final GarrisonState garrison;
  final List<TowerSlot> towerSlots;
  final List<Peasant> peasants;
  final int peasantCap;
  final int wave;
  final int highestWave;
  final TdPhase phase;
  final List<ActiveEnemy> enemies;
  final List<Projectile> projectiles;
  final List<DamageNumber> damageNumbers;
  final int enemiesKilledThisWave;
  final int totalEnemiesThisWave;
  final int totalKills;
  final int totalGpEarned;
  final int enemiesLeftToSpawn;
  final double spawnCooldown;
  final int? selectedSlotIndex;
  final AbilityCooldowns abilityCooldowns;
  final int freezeTicksLeft;
  final HeroUnit? hero;
  final List<WallSlot> wallSlots;
  final List<ResourceNode> resourceNodes;
  final WaveModifier currentModifier;
  final int prestigePoints;
  final int totalPrestigePoints;
  final PrestigeBonuses prestigeBonuses;
  final List<LootItem> inventory;

  const TdGameState({
    this.resources = const Resources(gold: 25),
    this.garrison = const GarrisonState(),
    this.towerSlots = const [],
    this.peasants = const [],
    this.peasantCap = 2,
    this.wave = 1,
    this.highestWave = 0,
    this.phase = TdPhase.idle,
    this.enemies = const [],
    this.projectiles = const [],
    this.damageNumbers = const [],
    this.enemiesKilledThisWave = 0,
    this.totalEnemiesThisWave = 0,
    this.totalKills = 0,
    this.totalGpEarned = 0,
    this.enemiesLeftToSpawn = 0,
    this.spawnCooldown = 0,
    this.selectedSlotIndex,
    this.abilityCooldowns = const AbilityCooldowns(),
    this.freezeTicksLeft = 0,
    this.hero,
    this.wallSlots = const [],
    this.resourceNodes = const [],
    this.currentModifier = WaveModifier.none,
    this.prestigePoints = 0,
    this.totalPrestigePoints = 0,
    this.prestigeBonuses = const PrestigeBonuses(),
    this.inventory = const [],
  });

  TdGameState copyWith({
    Resources? resources,
    GarrisonState? garrison,
    List<TowerSlot>? towerSlots,
    List<Peasant>? peasants,
    int? peasantCap,
    int? wave,
    int? highestWave,
    TdPhase? phase,
    List<ActiveEnemy>? enemies,
    List<Projectile>? projectiles,
    List<DamageNumber>? damageNumbers,
    int? enemiesKilledThisWave,
    int? totalEnemiesThisWave,
    int? totalKills,
    int? totalGpEarned,
    int? enemiesLeftToSpawn,
    double? spawnCooldown,
    int? Function()? selectedSlotIndex,
    AbilityCooldowns? abilityCooldowns,
    int? freezeTicksLeft,
    HeroUnit? Function()? hero,
    List<WallSlot>? wallSlots,
    List<ResourceNode>? resourceNodes,
    WaveModifier? currentModifier,
    int? prestigePoints,
    int? totalPrestigePoints,
    PrestigeBonuses? prestigeBonuses,
    List<LootItem>? inventory,
  }) =>
      TdGameState(
        resources: resources ?? this.resources,
        garrison: garrison ?? this.garrison,
        towerSlots: towerSlots ?? this.towerSlots,
        peasants: peasants ?? this.peasants,
        peasantCap: peasantCap ?? this.peasantCap,
        wave: wave ?? this.wave,
        highestWave: highestWave ?? this.highestWave,
        phase: phase ?? this.phase,
        enemies: enemies ?? this.enemies,
        projectiles: projectiles ?? this.projectiles,
        damageNumbers: damageNumbers ?? this.damageNumbers,
        enemiesKilledThisWave:
            enemiesKilledThisWave ?? this.enemiesKilledThisWave,
        totalEnemiesThisWave: totalEnemiesThisWave ?? this.totalEnemiesThisWave,
        totalKills: totalKills ?? this.totalKills,
        totalGpEarned: totalGpEarned ?? this.totalGpEarned,
        enemiesLeftToSpawn: enemiesLeftToSpawn ?? this.enemiesLeftToSpawn,
        spawnCooldown: spawnCooldown ?? this.spawnCooldown,
        selectedSlotIndex: selectedSlotIndex != null
            ? selectedSlotIndex()
            : this.selectedSlotIndex,
        abilityCooldowns: abilityCooldowns ?? this.abilityCooldowns,
        freezeTicksLeft: freezeTicksLeft ?? this.freezeTicksLeft,
        hero: hero != null ? hero() : this.hero,
        wallSlots: wallSlots ?? this.wallSlots,
        resourceNodes: resourceNodes ?? this.resourceNodes,
        currentModifier: currentModifier ?? this.currentModifier,
        prestigePoints: prestigePoints ?? this.prestigePoints,
        totalPrestigePoints: totalPrestigePoints ?? this.totalPrestigePoints,
        prestigeBonuses: prestigeBonuses ?? this.prestigeBonuses,
        inventory: inventory ?? this.inventory,
      );

  // ── Persistence ────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'resources': resources.toJson(),
        'garrison': garrison.toJson(),
        'towerSlots': towerSlots.map((s) => s.toJson()).toList(),
        'peasants': peasants.map((p) => p.toJson()).toList(),
        'peasantCap': peasantCap,
        'wave': wave,
        'highestWave': highestWave,
        'totalKills': totalKills,
        'totalGpEarned': totalGpEarned,
        'abilityCooldowns': abilityCooldowns.toJson(),
        'hero': hero?.toJson(),
        'wallSlots': wallSlots.map((w) => w.toJson()).toList(),
        'resourceNodes': resourceNodes.map((n) => n.toJson()).toList(),
        'prestigePoints': prestigePoints,
        'totalPrestigePoints': totalPrestigePoints,
        'prestigeBonuses': prestigeBonuses.toJson(),
        'inventory': inventory.map((l) => l.toJson()).toList(),
      };

  factory TdGameState.fromJson(Map<String, dynamic> j) => TdGameState(
        resources:
            Resources.fromJson(j['resources'] as Map<String, dynamic>? ?? {}),
        garrison: GarrisonState.fromJson(
            j['garrison'] as Map<String, dynamic>? ?? {}),
        peasantCap: j['peasantCap'] as int? ?? 2,
        wave: j['wave'] as int? ?? 1,
        highestWave: j['highestWave'] as int? ?? 0,
        totalKills: j['totalKills'] as int? ?? 0,
        totalGpEarned: j['totalGpEarned'] as int? ?? 0,
        abilityCooldowns: j['abilityCooldowns'] != null
            ? AbilityCooldowns.fromJson(
                j['abilityCooldowns'] as Map<String, dynamic>)
            : const AbilityCooldowns(),
        hero: j['hero'] != null
            ? HeroUnit.fromJson(j['hero'] as Map<String, dynamic>)
            : null,
        wallSlots: (j['wallSlots'] as List<dynamic>?)
                ?.map((e) => WallSlot.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        resourceNodes: (j['resourceNodes'] as List<dynamic>?)
                ?.map((e) => ResourceNode.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        prestigePoints: j['prestigePoints'] as int? ?? 0,
        totalPrestigePoints: j['totalPrestigePoints'] as int? ?? 0,
        prestigeBonuses: j['prestigeBonuses'] != null
            ? PrestigeBonuses.fromJson(
                j['prestigeBonuses'] as Map<String, dynamic>)
            : const PrestigeBonuses(),
        inventory: (j['inventory'] as List<dynamic>?)
                ?.map((e) => LootItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  String serialize() => jsonEncode(toJson());

  factory TdGameState.deserialize(String data) =>
      TdGameState.fromJson(jsonDecode(data) as Map<String, dynamic>);
}
