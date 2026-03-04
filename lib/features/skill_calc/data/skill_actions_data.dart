// Comprehensive OSRS skill actions for the Skill Calculator.
// Each action represents a single trainable activity with level req and XP.

class SkillAction {
  final String name;
  final int levelReq;
  final double xpPerAction;
  final int? xpPerHour;
  final String? category;
  final String? notes;

  const SkillAction({
    required this.name,
    required this.levelReq,
    required this.xpPerAction,
    this.xpPerHour,
    this.category,
    this.notes,
  });
}

const Map<String, List<SkillAction>> allSkillActions = {
  // ═══════════════════════════════════════════════════════════
  //  COOKING
  // ═══════════════════════════════════════════════════════════
  'Cooking': [
    // Raw fish
    SkillAction(
        name: 'Shrimps', levelReq: 1, xpPerAction: 30, category: 'Fish'),
    SkillAction(
        name: 'Sardine', levelReq: 1, xpPerAction: 40, category: 'Fish'),
    SkillAction(
        name: 'Herring', levelReq: 5, xpPerAction: 50, category: 'Fish'),
    SkillAction(
        name: 'Mackerel', levelReq: 10, xpPerAction: 60, category: 'Fish'),
    SkillAction(name: 'Trout', levelReq: 15, xpPerAction: 70, category: 'Fish'),
    SkillAction(name: 'Cod', levelReq: 18, xpPerAction: 75, category: 'Fish'),
    SkillAction(name: 'Pike', levelReq: 20, xpPerAction: 80, category: 'Fish'),
    SkillAction(
        name: 'Salmon', levelReq: 25, xpPerAction: 90, category: 'Fish'),
    SkillAction(name: 'Tuna', levelReq: 30, xpPerAction: 100, category: 'Fish'),
    SkillAction(
        name: 'Karambwan',
        levelReq: 30,
        xpPerAction: 190,
        category: 'Fish',
        notes: '1-tick cookable'),
    SkillAction(
        name: 'Rainbow fish', levelReq: 35, xpPerAction: 110, category: 'Fish'),
    SkillAction(
        name: 'Lobster', levelReq: 40, xpPerAction: 120, category: 'Fish'),
    SkillAction(name: 'Bass', levelReq: 43, xpPerAction: 130, category: 'Fish'),
    SkillAction(
        name: 'Swordfish', levelReq: 45, xpPerAction: 140, category: 'Fish'),
    SkillAction(
        name: 'Monkfish', levelReq: 62, xpPerAction: 150, category: 'Fish'),
    SkillAction(
        name: 'Shark', levelReq: 80, xpPerAction: 210, category: 'Fish'),
    SkillAction(
        name: 'Sea turtle', levelReq: 82, xpPerAction: 211.3, category: 'Fish'),
    SkillAction(
        name: 'Anglerfish', levelReq: 84, xpPerAction: 230, category: 'Fish'),
    SkillAction(
        name: 'Dark crab', levelReq: 90, xpPerAction: 215, category: 'Fish'),
    SkillAction(
        name: 'Manta ray', levelReq: 91, xpPerAction: 216.3, category: 'Fish'),
    // Pies
    SkillAction(
        name: 'Redberry pie', levelReq: 10, xpPerAction: 78, category: 'Pie'),
    SkillAction(
        name: 'Meat pie', levelReq: 20, xpPerAction: 110, category: 'Pie'),
    SkillAction(
        name: 'Apple pie', levelReq: 30, xpPerAction: 130, category: 'Pie'),
    SkillAction(
        name: 'Garden pie', levelReq: 34, xpPerAction: 138, category: 'Pie'),
    SkillAction(
        name: 'Fish pie', levelReq: 47, xpPerAction: 164, category: 'Pie'),
    SkillAction(
        name: 'Botanical pie', levelReq: 52, xpPerAction: 180, category: 'Pie'),
    SkillAction(
        name: 'Wild pie', levelReq: 85, xpPerAction: 240, category: 'Pie'),
    SkillAction(
        name: 'Summer pie', levelReq: 95, xpPerAction: 260, category: 'Pie'),
    // Wine
    SkillAction(
        name: 'Jug of wine',
        levelReq: 35,
        xpPerAction: 200,
        category: 'Wine',
        notes: 'Fastest cooking XP — ~500k xp/hr'),
    SkillAction(
        name: 'Wine of Zamorak',
        levelReq: 65,
        xpPerAction: 245,
        category: 'Wine'),
    // Other
    SkillAction(
        name: 'Plain pizza', levelReq: 35, xpPerAction: 143, category: 'Pizza'),
    SkillAction(
        name: 'Meat pizza', levelReq: 45, xpPerAction: 169, category: 'Pizza'),
    SkillAction(
        name: 'Anchovy pizza',
        levelReq: 55,
        xpPerAction: 182,
        category: 'Pizza'),
    SkillAction(
        name: 'Pineapple pizza',
        levelReq: 65,
        xpPerAction: 189,
        category: 'Pizza'),
    SkillAction(
        name: 'Curry', levelReq: 60, xpPerAction: 280, category: 'Other'),
    SkillAction(name: 'Bread', levelReq: 1, xpPerAction: 40, category: 'Other'),
    SkillAction(
        name: 'Sweetcorn', levelReq: 28, xpPerAction: 104, category: 'Other'),
    SkillAction(
        name: 'Stew', levelReq: 25, xpPerAction: 117, category: 'Other'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  AGILITY
  // ═══════════════════════════════════════════════════════════
  'Agility': [
    SkillAction(
        name: 'Gnome Stronghold Course',
        levelReq: 1,
        xpPerAction: 86.5,
        xpPerHour: 8000,
        category: 'Course'),
    SkillAction(
        name: 'Draynor Village Rooftop',
        levelReq: 10,
        xpPerAction: 120,
        xpPerHour: 9000,
        category: 'Course'),
    SkillAction(
        name: 'Al Kharid Rooftop',
        levelReq: 20,
        xpPerAction: 180,
        xpPerHour: 13000,
        category: 'Course'),
    SkillAction(
        name: 'Varrock Rooftop',
        levelReq: 30,
        xpPerAction: 238,
        xpPerHour: 13000,
        category: 'Course'),
    SkillAction(
        name: 'Penguin Agility Course',
        levelReq: 30,
        xpPerAction: 540,
        xpPerHour: 18000,
        category: 'Course'),
    SkillAction(
        name: 'Canifis Rooftop',
        levelReq: 40,
        xpPerAction: 240,
        xpPerHour: 19000,
        category: 'Course'),
    SkillAction(
        name: 'Ape Atoll Course',
        levelReq: 48,
        xpPerAction: 580,
        xpPerHour: 53000,
        category: 'Course'),
    SkillAction(
        name: 'Falador Rooftop',
        levelReq: 50,
        xpPerAction: 440,
        xpPerHour: 27000,
        category: 'Course'),
    SkillAction(
        name: 'Wilderness Course',
        levelReq: 52,
        xpPerAction: 571.4,
        xpPerHour: 47000,
        category: 'Course',
        notes: 'Skull required — dangerous'),
    SkillAction(
        name: "Seers' Village Rooftop",
        levelReq: 60,
        xpPerAction: 570,
        xpPerHour: 46000,
        category: 'Course',
        notes: 'Kandarin Hard diary = 60k+/hr'),
    SkillAction(
        name: 'Pollnivneach Rooftop',
        levelReq: 70,
        xpPerAction: 890,
        xpPerHour: 52000,
        category: 'Course'),
    SkillAction(
        name: 'Rellekka Rooftop',
        levelReq: 80,
        xpPerAction: 780,
        xpPerHour: 55000,
        category: 'Course'),
    SkillAction(
        name: 'Ardougne Rooftop',
        levelReq: 90,
        xpPerAction: 793,
        xpPerHour: 62000,
        category: 'Course'),
    SkillAction(
        name: 'Hallowed Sepulchre (Floor 1-2)',
        levelReq: 52,
        xpPerAction: 575,
        xpPerHour: 45000,
        category: 'Minigame'),
    SkillAction(
        name: 'Hallowed Sepulchre (Floor 1-3)',
        levelReq: 62,
        xpPerAction: 2000,
        xpPerHour: 55000,
        category: 'Minigame'),
    SkillAction(
        name: 'Hallowed Sepulchre (Floor 1-4)',
        levelReq: 72,
        xpPerAction: 3500,
        xpPerHour: 65000,
        category: 'Minigame'),
    SkillAction(
        name: 'Hallowed Sepulchre (Floor 1-5)',
        levelReq: 92,
        xpPerAction: 5500,
        xpPerHour: 100000,
        category: 'Minigame',
        notes: 'Best Agility XP/hr in game'),
    SkillAction(
        name: 'Brimhaven Agility Arena',
        levelReq: 1,
        xpPerAction: 10,
        xpPerHour: 30000,
        category: 'Minigame',
        notes: 'Tickets for XP lamps + Pirate\'s Hook'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  FISHING
  // ═══════════════════════════════════════════════════════════
  'Fishing': [
    SkillAction(
        name: 'Shrimps / Anchovies (net)',
        levelReq: 1,
        xpPerAction: 10,
        xpPerHour: 10000,
        category: 'Net'),
    SkillAction(
        name: 'Sardine (bait)',
        levelReq: 5,
        xpPerAction: 20,
        xpPerHour: 11000,
        category: 'Bait'),
    SkillAction(
        name: 'Herring (bait)',
        levelReq: 10,
        xpPerAction: 30,
        xpPerHour: 14000,
        category: 'Bait'),
    SkillAction(
        name: 'Trout (fly)',
        levelReq: 20,
        xpPerAction: 50,
        xpPerHour: 25000,
        category: 'Fly'),
    SkillAction(
        name: 'Salmon (fly)',
        levelReq: 30,
        xpPerAction: 70,
        xpPerHour: 30000,
        category: 'Fly'),
    SkillAction(
        name: 'Tuna (harpoon)',
        levelReq: 35,
        xpPerAction: 80,
        xpPerHour: 20000,
        category: 'Harpoon'),
    SkillAction(
        name: 'Lobster (cage)',
        levelReq: 40,
        xpPerAction: 90,
        xpPerHour: 25000,
        category: 'Cage'),
    SkillAction(
        name: 'Swordfish (harpoon)',
        levelReq: 50,
        xpPerAction: 100,
        xpPerHour: 30000,
        category: 'Harpoon'),
    SkillAction(
        name: 'Monkfish',
        levelReq: 62,
        xpPerAction: 120,
        xpPerHour: 35000,
        category: 'Net',
        notes: 'Requires Swan Song'),
    SkillAction(
        name: 'Karambwan',
        levelReq: 65,
        xpPerAction: 50,
        xpPerHour: 30000,
        category: 'Other',
        notes: 'Good for ironmen (cooking XP)'),
    SkillAction(
        name: 'Shark (harpoon)',
        levelReq: 76,
        xpPerAction: 110,
        xpPerHour: 25000,
        category: 'Harpoon'),
    SkillAction(
        name: 'Infernal eel',
        levelReq: 80,
        xpPerAction: 120,
        xpPerHour: 26000,
        category: 'Other',
        notes: 'AFK — requires fire cape'),
    SkillAction(
        name: 'Anglerfish',
        levelReq: 82,
        xpPerAction: 120,
        xpPerHour: 20000,
        category: 'Bait',
        notes: 'Great AFK — Piscarilius favour'),
    SkillAction(
        name: 'Minnows',
        levelReq: 82,
        xpPerAction: 26.1,
        xpPerHour: 40000,
        category: 'Net',
        notes: 'Trade minnows for sharks'),
    SkillAction(
        name: 'Dark crab',
        levelReq: 85,
        xpPerAction: 130,
        xpPerHour: 35000,
        category: 'Other',
        notes: 'Wilderness resource area'),
    SkillAction(
        name: 'Sacred eel',
        levelReq: 87,
        xpPerAction: 105,
        xpPerHour: 33000,
        category: 'Other',
        notes: 'AFK — Zul-Andra'),
    SkillAction(
        name: 'Tempoross',
        levelReq: 35,
        xpPerAction: 7000,
        xpPerHour: 70000,
        category: 'Minigame',
        notes: 'Skilling boss — permits + fish barrel'),
    SkillAction(
        name: 'Aerial fishing',
        levelReq: 43,
        xpPerAction: 40,
        xpPerHour: 43000,
        category: 'Other',
        notes: 'Also gives Hunter XP'),
    SkillAction(
        name: 'Drift net fishing',
        levelReq: 47,
        xpPerAction: 77,
        xpPerHour: 87000,
        category: 'Net',
        notes:
            'Requires 44 Hunter. Also gives Hunter XP — best combined rates'),
    SkillAction(
        name: 'Barbarian fishing (leaping trout)',
        levelReq: 48,
        xpPerAction: 50,
        xpPerHour: 45000,
        category: 'Fly',
        notes: 'Also gives Agility + Strength XP. 3-tick = 65k+/hr at 58+'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  WOODCUTTING
  // ═══════════════════════════════════════════════════════════
  'Woodcutting': [
    SkillAction(
        name: 'Regular tree',
        levelReq: 1,
        xpPerAction: 25,
        xpPerHour: 7000,
        category: 'Tree'),
    SkillAction(
        name: 'Achey tree', levelReq: 1, xpPerAction: 25, category: 'Tree'),
    SkillAction(
        name: 'Oak tree',
        levelReq: 15,
        xpPerAction: 37.5,
        xpPerHour: 15000,
        category: 'Tree'),
    SkillAction(
        name: 'Willow tree',
        levelReq: 30,
        xpPerAction: 67.5,
        xpPerHour: 30000,
        category: 'Tree'),
    SkillAction(
        name: 'Teak tree',
        levelReq: 35,
        xpPerAction: 85,
        xpPerHour: 80000,
        category: 'Tree',
        notes: '1.5t = up to 160k/hr'),
    SkillAction(
        name: 'Maple tree',
        levelReq: 45,
        xpPerAction: 100,
        xpPerHour: 40000,
        category: 'Tree'),
    SkillAction(
        name: 'Mahogany tree',
        levelReq: 50,
        xpPerAction: 125,
        xpPerHour: 45000,
        category: 'Tree'),
    SkillAction(
        name: 'Arctic pine',
        levelReq: 54,
        xpPerAction: 40,
        xpPerHour: 42000,
        category: 'Tree',
        notes: 'Neitiznot'),
    SkillAction(
        name: 'Yew tree',
        levelReq: 60,
        xpPerAction: 175,
        xpPerHour: 35000,
        category: 'Tree',
        notes: 'AFK — good GP for mains'),
    SkillAction(
        name: 'Blisterwood tree',
        levelReq: 62,
        xpPerAction: 76,
        xpPerHour: 55000,
        category: 'Tree',
        notes: 'AFK — Darkmeyer'),
    SkillAction(
        name: 'Magic tree',
        levelReq: 75,
        xpPerAction: 250,
        xpPerHour: 25000,
        category: 'Tree',
        notes: 'Very AFK — slow'),
    SkillAction(
        name: 'Redwood tree',
        levelReq: 90,
        xpPerAction: 380,
        xpPerHour: 60000,
        category: 'Tree',
        notes: 'Best AFK Woodcutting XP'),
    SkillAction(
        name: 'Sulliuscep (Fossil Island)',
        levelReq: 65,
        xpPerAction: 127,
        xpPerHour: 90000,
        category: 'Other',
        notes: 'Best active WC XP + fossils'),
    SkillAction(
        name: 'Forestry events',
        levelReq: 1,
        xpPerAction: 0,
        xpPerHour: 0,
        category: 'Other',
        notes: 'Bonus XP while chopping'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  MINING
  // ═══════════════════════════════════════════════════════════
  'Mining': [
    SkillAction(
        name: 'Copper / Tin',
        levelReq: 1,
        xpPerAction: 17.5,
        xpPerHour: 10000,
        category: 'Rock'),
    SkillAction(
        name: 'Clay',
        levelReq: 1,
        xpPerAction: 5,
        xpPerHour: 25000,
        category: 'Rock'),
    SkillAction(
        name: 'Limestone', levelReq: 10, xpPerAction: 26.5, category: 'Rock'),
    SkillAction(
        name: 'Iron ore',
        levelReq: 15,
        xpPerAction: 35,
        xpPerHour: 55000,
        category: 'Rock',
        notes: '3-tick = 70k+/hr'),
    SkillAction(
        name: 'Silver ore',
        levelReq: 20,
        xpPerAction: 40,
        xpPerHour: 30000,
        category: 'Rock'),
    SkillAction(
        name: 'Coal',
        levelReq: 30,
        xpPerAction: 50,
        xpPerHour: 30000,
        category: 'Rock'),
    SkillAction(
        name: 'Sandstone (quarry)',
        levelReq: 35,
        xpPerAction: 50,
        xpPerHour: 70000,
        category: 'Rock',
        notes: 'Grind for Superglass Make'),
    SkillAction(
        name: 'Gem rocks (Shilo Village)',
        levelReq: 40,
        xpPerAction: 65,
        xpPerHour: 50000,
        category: 'Rock',
        notes: 'Good GP + gems for ironmen'),
    SkillAction(
        name: 'Gold ore',
        levelReq: 40,
        xpPerAction: 65,
        xpPerHour: 30000,
        category: 'Rock'),
    SkillAction(
        name: 'Granite (quarry)',
        levelReq: 45,
        xpPerAction: 60,
        xpPerHour: 80000,
        category: 'Rock',
        notes: '3-tick = 100k+/hr — fastest Mining XP'),
    SkillAction(
        name: 'Mithril ore',
        levelReq: 55,
        xpPerAction: 80,
        xpPerHour: 20000,
        category: 'Rock'),
    SkillAction(
        name: 'Adamantite ore',
        levelReq: 70,
        xpPerAction: 95,
        xpPerHour: 15000,
        category: 'Rock'),
    SkillAction(
        name: 'Runite ore',
        levelReq: 85,
        xpPerAction: 125,
        xpPerHour: 10000,
        category: 'Rock',
        notes: 'Slow respawn — good GP'),
    SkillAction(
        name: 'Amethyst',
        levelReq: 92,
        xpPerAction: 240,
        xpPerHour: 20000,
        category: 'Rock',
        notes: 'Very AFK — Mining Guild'),
    SkillAction(
        name: 'Motherlode Mine (lower)',
        levelReq: 30,
        xpPerAction: 60,
        xpPerHour: 30000,
        category: 'Minigame',
        notes: 'AFK — nuggets for Prospector + upper'),
    SkillAction(
        name: 'Motherlode Mine (upper)',
        levelReq: 72,
        xpPerAction: 60,
        xpPerHour: 42000,
        category: 'Minigame',
        notes: 'AFK — requires 100 nuggets'),
    SkillAction(
        name: 'Volcanic Mine',
        levelReq: 50,
        xpPerAction: 200,
        xpPerHour: 80000,
        category: 'Minigame',
        notes: 'Team minigame — great XP'),
    SkillAction(
        name: 'Shooting Stars',
        levelReq: 10,
        xpPerAction: 32,
        xpPerHour: 20000,
        category: 'Other',
        notes: 'AFK — stardust for celestial ring'),
    SkillAction(
        name: 'Zalcano',
        levelReq: 70,
        xpPerAction: 1100,
        xpPerHour: 15000,
        category: 'Boss',
        notes: 'Also gives Smithing + RC XP + GP'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  SMITHING
  // ═══════════════════════════════════════════════════════════
  'Smithing': [
    // Smelting
    SkillAction(
        name: 'Bronze bar',
        levelReq: 1,
        xpPerAction: 6.2,
        category: 'Smelting'),
    SkillAction(
        name: 'Iron bar',
        levelReq: 15,
        xpPerAction: 12.5,
        category: 'Smelting',
        notes: '50% success rate without ring of forging'),
    SkillAction(
        name: 'Silver bar',
        levelReq: 20,
        xpPerAction: 13.7,
        category: 'Smelting'),
    SkillAction(
        name: 'Steel bar',
        levelReq: 30,
        xpPerAction: 17.5,
        category: 'Smelting'),
    SkillAction(
        name: 'Gold bar',
        levelReq: 40,
        xpPerAction: 22.5,
        category: 'Smelting',
        notes: 'Goldsmith gauntlets = 56.2 xp'),
    SkillAction(
        name: 'Gold bar (Goldsmith gauntlets)',
        levelReq: 40,
        xpPerAction: 56.2,
        xpPerHour: 380000,
        category: 'Smelting',
        notes: 'At Blast Furnace — fastest Smithing XP'),
    SkillAction(
        name: 'Mithril bar',
        levelReq: 50,
        xpPerAction: 30,
        category: 'Smelting'),
    SkillAction(
        name: 'Adamantite bar',
        levelReq: 70,
        xpPerAction: 37.5,
        category: 'Smelting'),
    SkillAction(
        name: 'Runite bar',
        levelReq: 85,
        xpPerAction: 50,
        category: 'Smelting'),
    // Blast Furnace smelting
    SkillAction(
        name: 'Steel bar (Blast Furnace)',
        levelReq: 30,
        xpPerAction: 17.5,
        xpPerHour: 90000,
        category: 'Blast Furnace',
        notes: 'Good GP for mains'),
    SkillAction(
        name: 'Mithril bar (Blast Furnace)',
        levelReq: 50,
        xpPerAction: 30,
        xpPerHour: 100000,
        category: 'Blast Furnace'),
    SkillAction(
        name: 'Adamantite bar (Blast Furnace)',
        levelReq: 70,
        xpPerAction: 37.5,
        xpPerHour: 110000,
        category: 'Blast Furnace'),
    SkillAction(
        name: 'Runite bar (Blast Furnace)',
        levelReq: 85,
        xpPerAction: 50,
        xpPerHour: 90000,
        category: 'Blast Furnace'),
    // Anvil smithing
    SkillAction(
        name: 'Bronze items',
        levelReq: 1,
        xpPerAction: 12.5,
        category: 'Anvil'),
    SkillAction(
        name: 'Iron items', levelReq: 15, xpPerAction: 25, category: 'Anvil'),
    SkillAction(
        name: 'Steel items',
        levelReq: 30,
        xpPerAction: 37.5,
        category: 'Anvil'),
    SkillAction(
        name: 'Mithril items',
        levelReq: 50,
        xpPerAction: 50,
        category: 'Anvil'),
    SkillAction(
        name: 'Adamant items',
        levelReq: 70,
        xpPerAction: 62.5,
        category: 'Anvil'),
    SkillAction(
        name: 'Rune items', levelReq: 85, xpPerAction: 75, category: 'Anvil'),
    SkillAction(
        name: 'Cannonballs',
        levelReq: 35,
        xpPerAction: 25.6,
        xpPerHour: 14000,
        category: 'Other',
        notes: 'AFK — 4 per steel bar'),
    SkillAction(
        name: 'Dart tips (mithril)',
        levelReq: 54,
        xpPerAction: 50,
        xpPerHour: 210000,
        category: 'Other',
        notes: 'Requires Tourist Trap — fast XP'),
    SkillAction(
        name: 'Dart tips (adamant)',
        levelReq: 74,
        xpPerAction: 62.5,
        xpPerHour: 260000,
        category: 'Other',
        notes: 'Requires Tourist Trap'),
    SkillAction(
        name: 'Dart tips (rune)',
        levelReq: 89,
        xpPerAction: 75,
        xpPerHour: 310000,
        category: 'Other',
        notes: 'Requires Tourist Trap'),
    SkillAction(
        name: 'Giants\' Foundry (med quality)',
        levelReq: 15,
        xpPerAction: 500,
        xpPerHour: 60000,
        category: 'Minigame'),
    SkillAction(
        name: 'Giants\' Foundry (high quality)',
        levelReq: 50,
        xpPerAction: 2000,
        xpPerHour: 120000,
        category: 'Minigame',
        notes: 'Best Smithing training + moulds'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  CRAFTING
  // ═══════════════════════════════════════════════════════════
  'Crafting': [
    // Leather
    SkillAction(
        name: 'Leather gloves',
        levelReq: 1,
        xpPerAction: 13.8,
        category: 'Leather'),
    SkillAction(
        name: 'Leather boots',
        levelReq: 7,
        xpPerAction: 16.25,
        category: 'Leather'),
    SkillAction(
        name: 'Leather cowl',
        levelReq: 9,
        xpPerAction: 18.5,
        category: 'Leather'),
    SkillAction(
        name: 'Leather vambraces',
        levelReq: 11,
        xpPerAction: 22,
        category: 'Leather'),
    SkillAction(
        name: 'Leather body',
        levelReq: 14,
        xpPerAction: 25,
        category: 'Leather'),
    SkillAction(
        name: 'Leather chaps',
        levelReq: 18,
        xpPerAction: 27,
        category: 'Leather'),
    SkillAction(
        name: 'Hard leather body',
        levelReq: 28,
        xpPerAction: 35,
        category: 'Leather'),
    SkillAction(
        name: 'Coif', levelReq: 38, xpPerAction: 37, category: 'Leather'),
    SkillAction(
        name: 'Studded body',
        levelReq: 41,
        xpPerAction: 40,
        category: 'Leather'),
    SkillAction(
        name: 'Studded chaps',
        levelReq: 44,
        xpPerAction: 42,
        category: 'Leather'),
    // Dragonhide
    SkillAction(
        name: 'Green d\'hide vambraces',
        levelReq: 57,
        xpPerAction: 62,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Green d\'hide chaps',
        levelReq: 60,
        xpPerAction: 124,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Green d\'hide body',
        levelReq: 63,
        xpPerAction: 186,
        xpPerHour: 130000,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Blue d\'hide vambraces',
        levelReq: 66,
        xpPerAction: 70,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Blue d\'hide chaps',
        levelReq: 68,
        xpPerAction: 140,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Blue d\'hide body',
        levelReq: 71,
        xpPerAction: 210,
        xpPerHour: 145000,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Red d\'hide vambraces',
        levelReq: 73,
        xpPerAction: 78,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Red d\'hide chaps',
        levelReq: 75,
        xpPerAction: 156,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Red d\'hide body',
        levelReq: 77,
        xpPerAction: 234,
        xpPerHour: 160000,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Black d\'hide vambraces',
        levelReq: 79,
        xpPerAction: 86,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Black d\'hide chaps',
        levelReq: 82,
        xpPerAction: 172,
        category: 'Dragonhide'),
    SkillAction(
        name: 'Black d\'hide body',
        levelReq: 84,
        xpPerAction: 258,
        xpPerHour: 170000,
        category: 'Dragonhide'),
    // Gems
    SkillAction(
        name: 'Cut opal',
        levelReq: 1,
        xpPerAction: 15,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut jade',
        levelReq: 13,
        xpPerAction: 20,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut red topaz',
        levelReq: 16,
        xpPerAction: 25,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut sapphire',
        levelReq: 20,
        xpPerAction: 50,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut emerald',
        levelReq: 27,
        xpPerAction: 67.5,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut ruby',
        levelReq: 43,
        xpPerAction: 85,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut diamond',
        levelReq: 63,
        xpPerAction: 107.5,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut dragonstone',
        levelReq: 55,
        xpPerAction: 137.5,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut onyx',
        levelReq: 67,
        xpPerAction: 167.5,
        category: 'Gem cutting'),
    SkillAction(
        name: 'Cut zenyte',
        levelReq: 89,
        xpPerAction: 200,
        category: 'Gem cutting'),
    // Jewellery
    SkillAction(
        name: 'Gold ring', levelReq: 5, xpPerAction: 15, category: 'Jewellery'),
    SkillAction(
        name: 'Gold necklace',
        levelReq: 6,
        xpPerAction: 20,
        category: 'Jewellery'),
    SkillAction(
        name: 'Gold amulet (u)',
        levelReq: 8,
        xpPerAction: 30,
        category: 'Jewellery'),
    SkillAction(
        name: 'Sapphire ring',
        levelReq: 20,
        xpPerAction: 40,
        category: 'Jewellery'),
    SkillAction(
        name: 'Sapphire necklace',
        levelReq: 22,
        xpPerAction: 55,
        category: 'Jewellery'),
    SkillAction(
        name: 'Sapphire amulet (u)',
        levelReq: 24,
        xpPerAction: 65,
        category: 'Jewellery'),
    SkillAction(
        name: 'Emerald ring',
        levelReq: 27,
        xpPerAction: 55,
        category: 'Jewellery'),
    SkillAction(
        name: 'Emerald necklace',
        levelReq: 29,
        xpPerAction: 60,
        category: 'Jewellery'),
    SkillAction(
        name: 'Ruby ring',
        levelReq: 34,
        xpPerAction: 70,
        category: 'Jewellery'),
    SkillAction(
        name: 'Ruby necklace',
        levelReq: 40,
        xpPerAction: 75,
        category: 'Jewellery'),
    SkillAction(
        name: 'Diamond ring',
        levelReq: 43,
        xpPerAction: 85,
        category: 'Jewellery'),
    SkillAction(
        name: 'Diamond necklace',
        levelReq: 56,
        xpPerAction: 90,
        category: 'Jewellery'),
    SkillAction(
        name: 'Dragonstone ring',
        levelReq: 55,
        xpPerAction: 100,
        category: 'Jewellery'),
    SkillAction(
        name: 'Dragonstone necklace',
        levelReq: 72,
        xpPerAction: 105,
        category: 'Jewellery'),
    SkillAction(
        name: 'Onyx ring',
        levelReq: 67,
        xpPerAction: 115,
        category: 'Jewellery'),
    SkillAction(
        name: 'Onyx necklace',
        levelReq: 82,
        xpPerAction: 120,
        category: 'Jewellery'),
    SkillAction(
        name: 'Zenyte ring',
        levelReq: 89,
        xpPerAction: 150,
        category: 'Jewellery'),
    SkillAction(
        name: 'Zenyte necklace',
        levelReq: 92,
        xpPerAction: 165,
        category: 'Jewellery'),
    SkillAction(
        name: 'Zenyte amulet (u)',
        levelReq: 98,
        xpPerAction: 200,
        category: 'Jewellery'),
    // Glassblowing
    SkillAction(
        name: 'Beer glass',
        levelReq: 1,
        xpPerAction: 17.5,
        category: 'Glassblowing'),
    SkillAction(
        name: 'Candle lantern',
        levelReq: 4,
        xpPerAction: 19,
        category: 'Glassblowing'),
    SkillAction(
        name: 'Oil lamp',
        levelReq: 12,
        xpPerAction: 25,
        category: 'Glassblowing'),
    SkillAction(
        name: 'Vial', levelReq: 33, xpPerAction: 35, category: 'Glassblowing'),
    SkillAction(
        name: 'Fishbowl',
        levelReq: 42,
        xpPerAction: 42.5,
        category: 'Glassblowing'),
    SkillAction(
        name: 'Unpowered orb',
        levelReq: 46,
        xpPerAction: 52.5,
        category: 'Glassblowing'),
    SkillAction(
        name: 'Lantern lens',
        levelReq: 49,
        xpPerAction: 55,
        category: 'Glassblowing'),
    SkillAction(
        name: 'Dorgeshuun light orb',
        levelReq: 87,
        xpPerAction: 70,
        category: 'Glassblowing'),
    // Battlestaves
    SkillAction(
        name: 'Water battlestaff',
        levelReq: 54,
        xpPerAction: 100,
        category: 'Battlestaff'),
    SkillAction(
        name: 'Earth battlestaff',
        levelReq: 58,
        xpPerAction: 112.5,
        category: 'Battlestaff'),
    SkillAction(
        name: 'Fire battlestaff',
        levelReq: 62,
        xpPerAction: 125,
        category: 'Battlestaff'),
    SkillAction(
        name: 'Air battlestaff',
        levelReq: 66,
        xpPerAction: 137.5,
        category: 'Battlestaff',
        notes: 'Good for ironmen — daily from Zaff'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  FLETCHING
  // ═══════════════════════════════════════════════════════════
  'Fletching': [
    // Bows
    SkillAction(
        name: 'Shortbow (u)',
        levelReq: 5,
        xpPerAction: 5,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Longbow (u)',
        levelReq: 10,
        xpPerAction: 10,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Oak shortbow (u)',
        levelReq: 20,
        xpPerAction: 16.5,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Oak longbow (u)',
        levelReq: 25,
        xpPerAction: 25,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Willow shortbow (u)',
        levelReq: 35,
        xpPerAction: 33.3,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Willow longbow (u)',
        levelReq: 40,
        xpPerAction: 41.5,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Maple shortbow (u)',
        levelReq: 50,
        xpPerAction: 50,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Maple longbow (u)',
        levelReq: 55,
        xpPerAction: 58.3,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Yew shortbow (u)',
        levelReq: 65,
        xpPerAction: 67.5,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Yew longbow (u)',
        levelReq: 70,
        xpPerAction: 75,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Magic shortbow (u)',
        levelReq: 80,
        xpPerAction: 83.3,
        category: 'Bow (unstrung)'),
    SkillAction(
        name: 'Magic longbow (u)',
        levelReq: 85,
        xpPerAction: 91.5,
        category: 'Bow (unstrung)'),
    // Stringing
    SkillAction(
        name: 'Shortbow', levelReq: 5, xpPerAction: 5, category: 'Stringing'),
    SkillAction(
        name: 'Longbow', levelReq: 10, xpPerAction: 10, category: 'Stringing'),
    SkillAction(
        name: 'Oak shortbow',
        levelReq: 20,
        xpPerAction: 16.5,
        category: 'Stringing'),
    SkillAction(
        name: 'Oak longbow',
        levelReq: 25,
        xpPerAction: 25,
        category: 'Stringing'),
    SkillAction(
        name: 'Willow shortbow',
        levelReq: 35,
        xpPerAction: 33.3,
        category: 'Stringing'),
    SkillAction(
        name: 'Willow longbow',
        levelReq: 40,
        xpPerAction: 41.5,
        category: 'Stringing'),
    SkillAction(
        name: 'Maple shortbow',
        levelReq: 50,
        xpPerAction: 50,
        category: 'Stringing'),
    SkillAction(
        name: 'Maple longbow',
        levelReq: 55,
        xpPerAction: 58.3,
        category: 'Stringing'),
    SkillAction(
        name: 'Yew shortbow',
        levelReq: 65,
        xpPerAction: 67.5,
        category: 'Stringing'),
    SkillAction(
        name: 'Yew longbow',
        levelReq: 70,
        xpPerAction: 75,
        category: 'Stringing'),
    SkillAction(
        name: 'Magic shortbow',
        levelReq: 80,
        xpPerAction: 83.3,
        category: 'Stringing'),
    SkillAction(
        name: 'Magic longbow',
        levelReq: 85,
        xpPerAction: 91.5,
        category: 'Stringing'),
    // Arrows
    SkillAction(
        name: 'Headless arrow (15)',
        levelReq: 1,
        xpPerAction: 15,
        category: 'Arrow'),
    SkillAction(
        name: 'Bronze arrow (15)',
        levelReq: 1,
        xpPerAction: 19.5,
        category: 'Arrow'),
    SkillAction(
        name: 'Iron arrow (15)',
        levelReq: 15,
        xpPerAction: 37.5,
        category: 'Arrow'),
    SkillAction(
        name: 'Steel arrow (15)',
        levelReq: 30,
        xpPerAction: 75,
        category: 'Arrow'),
    SkillAction(
        name: 'Mithril arrow (15)',
        levelReq: 45,
        xpPerAction: 112.5,
        category: 'Arrow'),
    SkillAction(
        name: 'Broad arrow (15)',
        levelReq: 52,
        xpPerAction: 225,
        xpPerHour: 500000,
        category: 'Arrow',
        notes: 'Fastest Fletching XP — expensive'),
    SkillAction(
        name: 'Adamant arrow (15)',
        levelReq: 60,
        xpPerAction: 150,
        category: 'Arrow'),
    SkillAction(
        name: 'Rune arrow (15)',
        levelReq: 75,
        xpPerAction: 187.5,
        category: 'Arrow'),
    SkillAction(
        name: 'Amethyst arrow (15)',
        levelReq: 82,
        xpPerAction: 202.5,
        category: 'Arrow'),
    SkillAction(
        name: 'Dragon arrow (15)',
        levelReq: 90,
        xpPerAction: 225,
        category: 'Arrow'),
    // Bolts
    SkillAction(
        name: 'Bronze bolts (10)',
        levelReq: 9,
        xpPerAction: 5,
        category: 'Bolt'),
    SkillAction(
        name: 'Iron bolts (10)',
        levelReq: 39,
        xpPerAction: 15,
        category: 'Bolt'),
    SkillAction(
        name: 'Steel bolts (10)',
        levelReq: 46,
        xpPerAction: 35,
        category: 'Bolt'),
    SkillAction(
        name: 'Mithril bolts (10)',
        levelReq: 54,
        xpPerAction: 50,
        category: 'Bolt'),
    SkillAction(
        name: 'Broad bolts (10)',
        levelReq: 55,
        xpPerAction: 30,
        xpPerHour: 250000,
        category: 'Bolt',
        notes: 'Good cheap Fletching XP'),
    SkillAction(
        name: 'Adamant bolts (10)',
        levelReq: 61,
        xpPerAction: 70,
        category: 'Bolt'),
    SkillAction(
        name: 'Rune bolts (10)',
        levelReq: 69,
        xpPerAction: 100,
        category: 'Bolt'),
    SkillAction(
        name: 'Dragon bolts (10)',
        levelReq: 84,
        xpPerAction: 120,
        category: 'Bolt'),
    // Darts
    SkillAction(
        name: 'Bronze dart', levelReq: 10, xpPerAction: 1.8, category: 'Dart'),
    SkillAction(
        name: 'Iron dart', levelReq: 22, xpPerAction: 3.8, category: 'Dart'),
    SkillAction(
        name: 'Steel dart', levelReq: 37, xpPerAction: 7.5, category: 'Dart'),
    SkillAction(
        name: 'Mithril dart',
        levelReq: 52,
        xpPerAction: 11.2,
        category: 'Dart'),
    SkillAction(
        name: 'Adamant dart', levelReq: 67, xpPerAction: 15, category: 'Dart'),
    SkillAction(
        name: 'Rune dart', levelReq: 81, xpPerAction: 18.8, category: 'Dart'),
    SkillAction(
        name: 'Dragon dart', levelReq: 95, xpPerAction: 25, category: 'Dart'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  FIREMAKING
  // ═══════════════════════════════════════════════════════════
  'Firemaking': [
    SkillAction(
        name: 'Regular logs',
        levelReq: 1,
        xpPerAction: 40,
        xpPerHour: 45000,
        category: 'Log'),
    SkillAction(
        name: 'Achey tree logs', levelReq: 1, xpPerAction: 40, category: 'Log'),
    SkillAction(
        name: 'Oak logs',
        levelReq: 15,
        xpPerAction: 60,
        xpPerHour: 70000,
        category: 'Log'),
    SkillAction(
        name: 'Willow logs',
        levelReq: 30,
        xpPerAction: 90,
        xpPerHour: 105000,
        category: 'Log'),
    SkillAction(
        name: 'Teak logs',
        levelReq: 35,
        xpPerAction: 105,
        xpPerHour: 120000,
        category: 'Log'),
    SkillAction(
        name: 'Arctic pine logs',
        levelReq: 42,
        xpPerAction: 125,
        category: 'Log'),
    SkillAction(
        name: 'Maple logs',
        levelReq: 45,
        xpPerAction: 135,
        xpPerHour: 155000,
        category: 'Log'),
    SkillAction(
        name: 'Mahogany logs',
        levelReq: 50,
        xpPerAction: 157.5,
        category: 'Log'),
    SkillAction(
        name: 'Yew logs',
        levelReq: 60,
        xpPerAction: 202.5,
        xpPerHour: 200000,
        category: 'Log'),
    SkillAction(
        name: 'Magic logs',
        levelReq: 75,
        xpPerAction: 303.8,
        xpPerHour: 250000,
        category: 'Log'),
    SkillAction(
        name: 'Redwood logs',
        levelReq: 90,
        xpPerAction: 350,
        xpPerHour: 350000,
        category: 'Log'),
    SkillAction(
        name: 'Wintertodt (500kc avg)',
        levelReq: 50,
        xpPerAction: 5000,
        xpPerHour: 300000,
        category: 'Minigame',
        notes: 'XP scales with FM level — crates + pyromancer'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  HERBLORE
  // ═══════════════════════════════════════════════════════════
  'Herblore': [
    // Potions
    SkillAction(
        name: 'Attack potion',
        levelReq: 3,
        xpPerAction: 25,
        category: 'Potion'),
    SkillAction(
        name: 'Antipoison', levelReq: 5, xpPerAction: 37.5, category: 'Potion'),
    SkillAction(
        name: 'Strength potion',
        levelReq: 12,
        xpPerAction: 50,
        category: 'Potion'),
    SkillAction(
        name: 'Serum 207',
        levelReq: 15,
        xpPerAction: 50,
        category: 'Potion',
        notes: 'Cheap training — tarromin + ashes'),
    SkillAction(
        name: 'Restore potion',
        levelReq: 22,
        xpPerAction: 62.5,
        category: 'Potion'),
    SkillAction(
        name: 'Energy potion',
        levelReq: 26,
        xpPerAction: 67.5,
        category: 'Potion'),
    SkillAction(
        name: 'Defence potion',
        levelReq: 30,
        xpPerAction: 75,
        category: 'Potion'),
    SkillAction(
        name: 'Agility potion',
        levelReq: 34,
        xpPerAction: 80,
        category: 'Potion'),
    SkillAction(
        name: 'Combat potion',
        levelReq: 36,
        xpPerAction: 84,
        category: 'Potion'),
    SkillAction(
        name: 'Prayer potion',
        levelReq: 38,
        xpPerAction: 87.5,
        category: 'Potion'),
    SkillAction(
        name: 'Super attack',
        levelReq: 45,
        xpPerAction: 100,
        category: 'Potion'),
    SkillAction(
        name: 'Super antipoison',
        levelReq: 48,
        xpPerAction: 106.3,
        category: 'Potion'),
    SkillAction(
        name: 'Super energy',
        levelReq: 52,
        xpPerAction: 117.5,
        category: 'Potion'),
    SkillAction(
        name: 'Super strength',
        levelReq: 55,
        xpPerAction: 125,
        category: 'Potion'),
    SkillAction(
        name: 'Super restore',
        levelReq: 63,
        xpPerAction: 142.5,
        category: 'Potion'),
    SkillAction(
        name: 'Super defence',
        levelReq: 66,
        xpPerAction: 150,
        category: 'Potion'),
    SkillAction(
        name: 'Antifire', levelReq: 69, xpPerAction: 157.5, category: 'Potion'),
    SkillAction(
        name: 'Ranging potion',
        levelReq: 72,
        xpPerAction: 162.5,
        category: 'Potion'),
    SkillAction(
        name: 'Magic potion',
        levelReq: 76,
        xpPerAction: 172.5,
        category: 'Potion'),
    SkillAction(
        name: 'Stamina potion',
        levelReq: 77,
        xpPerAction: 102,
        category: 'Potion',
        notes: '4-dose from super energy + amylase'),
    SkillAction(
        name: 'Saradomin brew',
        levelReq: 81,
        xpPerAction: 180,
        category: 'Potion'),
    SkillAction(
        name: 'Extended antifire',
        levelReq: 84,
        xpPerAction: 110,
        category: 'Potion'),
    SkillAction(
        name: 'Anti-venom', levelReq: 87, xpPerAction: 120, category: 'Potion'),
    SkillAction(
        name: 'Super combat',
        levelReq: 90,
        xpPerAction: 150,
        category: 'Potion'),
    SkillAction(
        name: 'Anti-venom+',
        levelReq: 94,
        xpPerAction: 125,
        category: 'Potion'),
    SkillAction(
        name: 'Extended super antifire',
        levelReq: 98,
        xpPerAction: 160,
        category: 'Potion'),
    // Cleaning herbs
    SkillAction(
        name: 'Clean guam',
        levelReq: 3,
        xpPerAction: 2.5,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean marrentill',
        levelReq: 5,
        xpPerAction: 3.8,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean tarromin',
        levelReq: 11,
        xpPerAction: 5,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean harralander',
        levelReq: 20,
        xpPerAction: 6.3,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean ranarr',
        levelReq: 25,
        xpPerAction: 7.5,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean toadflax',
        levelReq: 30,
        xpPerAction: 8,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean irit',
        levelReq: 40,
        xpPerAction: 8.8,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean avantoe',
        levelReq: 48,
        xpPerAction: 10,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean kwuarm',
        levelReq: 54,
        xpPerAction: 11.3,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean snapdragon',
        levelReq: 59,
        xpPerAction: 11.8,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean cadantine',
        levelReq: 65,
        xpPerAction: 12.5,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean lantadyme',
        levelReq: 67,
        xpPerAction: 13.1,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean dwarf weed',
        levelReq: 70,
        xpPerAction: 13.8,
        category: 'Herb cleaning'),
    SkillAction(
        name: 'Clean torstol',
        levelReq: 75,
        xpPerAction: 15,
        category: 'Herb cleaning'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  PRAYER
  // ═══════════════════════════════════════════════════════════
  'Prayer': [
    SkillAction(name: 'Bones', levelReq: 1, xpPerAction: 4.5, category: 'Bury'),
    SkillAction(
        name: 'Wolf bones', levelReq: 1, xpPerAction: 4.5, category: 'Bury'),
    SkillAction(
        name: 'Burnt bones', levelReq: 1, xpPerAction: 4.5, category: 'Bury'),
    SkillAction(
        name: 'Monkey bones', levelReq: 1, xpPerAction: 5, category: 'Bury'),
    SkillAction(
        name: 'Bat bones', levelReq: 1, xpPerAction: 5.3, category: 'Bury'),
    SkillAction(
        name: 'Big bones', levelReq: 1, xpPerAction: 15, category: 'Bury'),
    SkillAction(
        name: 'Babydragon bones',
        levelReq: 1,
        xpPerAction: 30,
        category: 'Bury'),
    SkillAction(
        name: 'Dragon bones', levelReq: 1, xpPerAction: 72, category: 'Bury'),
    SkillAction(
        name: 'Wyvern bones', levelReq: 1, xpPerAction: 72, category: 'Bury'),
    SkillAction(
        name: 'Lava dragon bones',
        levelReq: 1,
        xpPerAction: 85,
        category: 'Bury'),
    SkillAction(
        name: 'Drake bones', levelReq: 1, xpPerAction: 80, category: 'Bury'),
    SkillAction(
        name: 'Fayrg bones', levelReq: 1, xpPerAction: 84, category: 'Bury'),
    SkillAction(
        name: 'Raurg bones', levelReq: 1, xpPerAction: 96, category: 'Bury'),
    SkillAction(
        name: 'Hydra bones', levelReq: 1, xpPerAction: 110, category: 'Bury'),
    SkillAction(
        name: 'Dagannoth bones',
        levelReq: 1,
        xpPerAction: 125,
        category: 'Bury'),
    SkillAction(
        name: 'Ourg bones', levelReq: 1, xpPerAction: 140, category: 'Bury'),
    SkillAction(
        name: 'Superior dragon bones',
        levelReq: 1,
        xpPerAction: 150,
        category: 'Bury'),
    // Gilded altar (×3.5)
    SkillAction(
        name: 'Big bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 52.5,
        category: 'Gilded altar'),
    SkillAction(
        name: 'Dragon bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 252,
        xpPerHour: 500000,
        category: 'Gilded altar'),
    SkillAction(
        name: 'Wyvern bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 252,
        category: 'Gilded altar'),
    SkillAction(
        name: 'Lava dragon bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 297.5,
        category: 'Gilded altar'),
    SkillAction(
        name: 'Hydra bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 385,
        category: 'Gilded altar'),
    SkillAction(
        name: 'Dagannoth bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 437.5,
        category: 'Gilded altar'),
    SkillAction(
        name: 'Superior dragon bones (gilded altar)',
        levelReq: 1,
        xpPerAction: 525,
        xpPerHour: 1050000,
        category: 'Gilded altar',
        notes: 'Most expensive — fastest'),
    // Chaos Temple (wilderness, ×3.5, 50% save)
    SkillAction(
        name: 'Dragon bones (Chaos Temple)',
        levelReq: 1,
        xpPerAction: 252,
        category: 'Wilderness altar',
        notes: 'Dangerous — 50% chance to save bone'),
    SkillAction(
        name: 'Superior dragon bones (Chaos Temple)',
        levelReq: 1,
        xpPerAction: 525,
        category: 'Wilderness altar',
        notes: 'Dangerous — 50% chance to save bone'),
    // Ensouled heads
    SkillAction(
        name: 'Ensouled goblin head',
        levelReq: 3,
        xpPerAction: 130,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled monkey head',
        levelReq: 7,
        xpPerAction: 182,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled imp head',
        levelReq: 12,
        xpPerAction: 286,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled scorpion head',
        levelReq: 19,
        xpPerAction: 454,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled bear head',
        levelReq: 24,
        xpPerAction: 480,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled dog head',
        levelReq: 35,
        xpPerAction: 520,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled chaos druid head',
        levelReq: 45,
        xpPerAction: 584,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled giant head',
        levelReq: 50,
        xpPerAction: 650,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled ogre head',
        levelReq: 52,
        xpPerAction: 716,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled elf head',
        levelReq: 57,
        xpPerAction: 754,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled troll head',
        levelReq: 60,
        xpPerAction: 780,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled horror head',
        levelReq: 65,
        xpPerAction: 832,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled kalphite head',
        levelReq: 72,
        xpPerAction: 884,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled dagannoth head',
        levelReq: 75,
        xpPerAction: 936,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled bloodveld head',
        levelReq: 78,
        xpPerAction: 1040,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled tzhaar head',
        levelReq: 80,
        xpPerAction: 1104,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled demon head',
        levelReq: 82,
        xpPerAction: 1170,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled aviansie head',
        levelReq: 85,
        xpPerAction: 1234,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled abyssal head',
        levelReq: 88,
        xpPerAction: 1300,
        category: 'Ensouled head'),
    SkillAction(
        name: 'Ensouled dragon head',
        levelReq: 93,
        xpPerAction: 1560,
        category: 'Ensouled head'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  RUNECRAFT
  // ═══════════════════════════════════════════════════════════
  'Runecraft': [
    SkillAction(
        name: 'Air rune', levelReq: 1, xpPerAction: 5, category: 'Rune'),
    SkillAction(
        name: 'Mind rune', levelReq: 2, xpPerAction: 5.5, category: 'Rune'),
    SkillAction(
        name: 'Water rune', levelReq: 5, xpPerAction: 6, category: 'Rune'),
    SkillAction(
        name: 'Earth rune', levelReq: 9, xpPerAction: 6.5, category: 'Rune'),
    SkillAction(
        name: 'Fire rune', levelReq: 14, xpPerAction: 7, category: 'Rune'),
    SkillAction(
        name: 'Body rune', levelReq: 20, xpPerAction: 7.5, category: 'Rune'),
    SkillAction(
        name: 'Cosmic rune', levelReq: 27, xpPerAction: 8, category: 'Rune'),
    SkillAction(
        name: 'Chaos rune', levelReq: 35, xpPerAction: 8.5, category: 'Rune'),
    SkillAction(
        name: 'Astral rune',
        levelReq: 40,
        xpPerAction: 8.7,
        xpPerHour: 32000,
        category: 'Rune',
        notes: 'Good for ironmen — Lunar Isle'),
    SkillAction(
        name: 'Nature rune',
        levelReq: 44,
        xpPerAction: 9,
        xpPerHour: 25000,
        category: 'Rune',
        notes: 'Good GP via Abyss'),
    SkillAction(
        name: 'Law rune',
        levelReq: 54,
        xpPerAction: 9.5,
        xpPerHour: 27000,
        category: 'Rune'),
    SkillAction(
        name: 'Death rune',
        levelReq: 65,
        xpPerAction: 10,
        xpPerHour: 30000,
        category: 'Rune'),
    SkillAction(
        name: 'Wrath rune',
        levelReq: 95,
        xpPerAction: 8,
        xpPerHour: 25000,
        category: 'Rune',
        notes: 'Requires DS2'),
    SkillAction(
        name: 'Blood rune (true altar)',
        levelReq: 77,
        xpPerAction: 23.8,
        xpPerHour: 38000,
        category: 'Rune',
        notes: 'AFK + good GP'),
    SkillAction(
        name: 'Soul rune (true altar)',
        levelReq: 90,
        xpPerAction: 29.7,
        xpPerHour: 45000,
        category: 'Rune',
        notes: 'AFK — highest RC XP/hr at altar'),
    SkillAction(
        name: 'Lava rune (with binding necklace)',
        levelReq: 23,
        xpPerAction: 10,
        xpPerHour: 72000,
        category: 'Combination',
        notes: 'Fastest traditional RC XP'),
    SkillAction(
        name: 'Steam rune (with binding necklace)',
        levelReq: 19,
        xpPerAction: 10,
        xpPerHour: 55000,
        category: 'Combination'),
    SkillAction(
        name: 'Guardians of the Rift',
        levelReq: 27,
        xpPerAction: 0,
        xpPerHour: 55000,
        category: 'Minigame',
        notes: 'Great RC XP + outfit + talisman'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  THIEVING
  // ═══════════════════════════════════════════════════════════
  'Thieving': [
    // Stalls
    SkillAction(
        name: 'Vegetable stall',
        levelReq: 2,
        xpPerAction: 10,
        category: 'Stall'),
    SkillAction(
        name: 'Baker\'s stall',
        levelReq: 5,
        xpPerAction: 16,
        category: 'Stall'),
    SkillAction(
        name: 'Tea stall',
        levelReq: 5,
        xpPerAction: 16,
        xpPerHour: 50000,
        category: 'Stall',
        notes: 'Easy AFK low-level'),
    SkillAction(
        name: 'Silk stall', levelReq: 20, xpPerAction: 24, category: 'Stall'),
    SkillAction(
        name: 'Fruit stall',
        levelReq: 25,
        xpPerAction: 28.5,
        xpPerHour: 45000,
        category: 'Stall',
        notes: 'Hosidius — good for ironmen'),
    SkillAction(
        name: 'Gem stall', levelReq: 75, xpPerAction: 160, category: 'Stall'),
    // Pickpocket
    SkillAction(
        name: 'Man / Woman',
        levelReq: 1,
        xpPerAction: 8,
        xpPerHour: 14000,
        category: 'Pickpocket'),
    SkillAction(
        name: 'Farmer',
        levelReq: 10,
        xpPerAction: 14.5,
        category: 'Pickpocket'),
    SkillAction(
        name: 'H.A.M. Member',
        levelReq: 15,
        xpPerAction: 22.5,
        category: 'Pickpocket',
        notes: 'Good for easy clue items'),
    SkillAction(
        name: 'Warrior', levelReq: 25, xpPerAction: 26, category: 'Pickpocket'),
    SkillAction(
        name: 'Rogue', levelReq: 32, xpPerAction: 36.5, category: 'Pickpocket'),
    SkillAction(
        name: 'Master Farmer',
        levelReq: 38,
        xpPerAction: 43,
        xpPerHour: 120000,
        category: 'Pickpocket',
        notes: 'Good for seeds (ironman)'),
    SkillAction(
        name: 'Guard', levelReq: 40, xpPerAction: 46.8, category: 'Pickpocket'),
    SkillAction(
        name: 'Knight of Ardougne',
        levelReq: 55,
        xpPerAction: 84.3,
        xpPerHour: 230000,
        category: 'Pickpocket',
        notes: 'Splashing method = AFK, great GP'),
    SkillAction(
        name: 'Menaphite Thug',
        levelReq: 65,
        xpPerAction: 137.5,
        category: 'Pickpocket',
        notes: 'Blackjacking — very click intensive'),
    SkillAction(
        name: 'Paladin',
        levelReq: 70,
        xpPerAction: 151.8,
        category: 'Pickpocket'),
    SkillAction(
        name: 'Gnome',
        levelReq: 75,
        xpPerAction: 198.3,
        category: 'Pickpocket'),
    SkillAction(
        name: 'Hero', levelReq: 80, xpPerAction: 273.3, category: 'Pickpocket'),
    SkillAction(
        name: 'Elf (Prif)',
        levelReq: 85,
        xpPerAction: 353.3,
        xpPerHour: 250000,
        category: 'Pickpocket',
        notes: 'Best GP/hr thieving — enhanced crystal teleport seeds'),
    SkillAction(
        name: 'TzHaar-Hur',
        levelReq: 90,
        xpPerAction: 103.4,
        category: 'Pickpocket',
        notes: 'Tokkul + gems'),
    SkillAction(
        name: 'Vyre pickpocketing',
        levelReq: 82,
        xpPerAction: 306.9,
        xpPerHour: 270000,
        category: 'Pickpocket',
        notes: 'Darkmeyer — blood shards'),
    // Other
    SkillAction(
        name: 'Pyramid Plunder',
        levelReq: 21,
        xpPerAction: 0,
        xpPerHour: 100000,
        category: 'Minigame',
        notes: 'Good XP rates + Pharaoh\'s sceptre'),
    SkillAction(
        name: 'Sorceress\'s Garden',
        levelReq: 1,
        xpPerAction: 0,
        xpPerHour: 80000,
        category: 'Minigame'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  HUNTER
  // ═══════════════════════════════════════════════════════════
  'Hunter': [
    SkillAction(
        name: 'Crimson swift (bird snare)',
        levelReq: 1,
        xpPerAction: 34,
        xpPerHour: 8000,
        category: 'Bird snare'),
    SkillAction(
        name: 'Golden warbler',
        levelReq: 5,
        xpPerAction: 47,
        category: 'Bird snare'),
    SkillAction(
        name: 'Copper longtail',
        levelReq: 9,
        xpPerAction: 61,
        category: 'Bird snare'),
    SkillAction(
        name: 'Cerulean twitch',
        levelReq: 11,
        xpPerAction: 64.5,
        category: 'Bird snare'),
    SkillAction(
        name: 'Tropical wagtail',
        levelReq: 19,
        xpPerAction: 95.2,
        xpPerHour: 40000,
        category: 'Bird snare'),
    SkillAction(
        name: 'Ruby harvest (butterfly net)',
        levelReq: 15,
        xpPerAction: 24,
        category: 'Butterfly'),
    SkillAction(
        name: 'Sapphire glacialis',
        levelReq: 25,
        xpPerAction: 34,
        category: 'Butterfly'),
    SkillAction(
        name: 'Snowy knight',
        levelReq: 35,
        xpPerAction: 44,
        category: 'Butterfly'),
    SkillAction(
        name: 'Black warlock',
        levelReq: 45,
        xpPerAction: 54,
        category: 'Butterfly'),
    SkillAction(
        name: 'Swamp lizard (net trap)',
        levelReq: 29,
        xpPerAction: 152,
        xpPerHour: 55000,
        category: 'Net trap'),
    SkillAction(
        name: 'Orange salamander',
        levelReq: 47,
        xpPerAction: 224,
        xpPerHour: 70000,
        category: 'Net trap'),
    SkillAction(
        name: 'Red salamander',
        levelReq: 59,
        xpPerAction: 272,
        xpPerHour: 100000,
        category: 'Net trap'),
    SkillAction(
        name: 'Black salamander',
        levelReq: 67,
        xpPerAction: 319.2,
        xpPerHour: 130000,
        category: 'Net trap'),
    SkillAction(
        name: 'Red chinchompa (box trap)',
        levelReq: 63,
        xpPerAction: 265,
        xpPerHour: 120000,
        category: 'Box trap',
        notes: 'Good GP + great Ranged ammo'),
    SkillAction(
        name: 'Black chinchompa',
        levelReq: 73,
        xpPerAction: 315,
        xpPerHour: 180000,
        category: 'Box trap',
        notes: 'Wilderness — best GP'),
    SkillAction(
        name: 'Birdhouse runs',
        levelReq: 5,
        xpPerAction: 280,
        xpPerHour: 0,
        category: 'Passive',
        notes: 'Passive XP every 50 min — nests + seeds'),
    SkillAction(
        name: 'Herbiboar',
        levelReq: 80,
        xpPerAction: 1950,
        xpPerHour: 160000,
        category: 'Tracking',
        notes: 'Fossil Island — herbs + XP'),
    SkillAction(
        name: 'Drift net fishing',
        levelReq: 44,
        xpPerAction: 100,
        xpPerHour: 110000,
        category: 'Net',
        notes: 'Also gives Fishing XP'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  CONSTRUCTION
  // ═══════════════════════════════════════════════════════════
  'Construction': [
    SkillAction(
        name: 'Crude wooden chair',
        levelReq: 1,
        xpPerAction: 58,
        category: 'Furniture'),
    SkillAction(
        name: 'Wooden bookcase',
        levelReq: 4,
        xpPerAction: 115,
        category: 'Furniture'),
    SkillAction(
        name: 'Wooden larder',
        levelReq: 9,
        xpPerAction: 228,
        category: 'Furniture'),
    SkillAction(
        name: 'Oak chair', levelReq: 19, xpPerAction: 120, category: 'Oak'),
    SkillAction(
        name: 'Oak dining table',
        levelReq: 22,
        xpPerAction: 240,
        category: 'Oak'),
    SkillAction(
        name: 'Oak larder',
        levelReq: 33,
        xpPerAction: 480,
        xpPerHour: 280000,
        category: 'Oak',
        notes: 'Good mid-level XP'),
    SkillAction(
        name: 'Carved oak table',
        levelReq: 31,
        xpPerAction: 360,
        category: 'Oak'),
    SkillAction(
        name: 'Teak table', levelReq: 38, xpPerAction: 360, category: 'Teak'),
    SkillAction(
        name: 'Teak larder', levelReq: 43, xpPerAction: 540, category: 'Teak'),
    SkillAction(
        name: 'Mythical cape rack',
        levelReq: 47,
        xpPerAction: 370,
        xpPerHour: 350000,
        category: 'Teak',
        notes: 'Requires DS2 — very fast'),
    SkillAction(
        name: 'Mahogany table',
        levelReq: 52,
        xpPerAction: 840,
        xpPerHour: 700000,
        category: 'Mahogany',
        notes: 'Fastest XP — expensive'),
    SkillAction(
        name: 'Gilded altar (with burners)',
        levelReq: 75,
        xpPerAction: 2230,
        category: 'Special',
        notes: 'Build once — use for Prayer training'),
    SkillAction(
        name: 'Jewellery box',
        levelReq: 81,
        xpPerAction: 0,
        category: 'Special',
        notes: 'Unlimited teleports — useful unlock'),
    SkillAction(
        name: 'Ornate pool',
        levelReq: 90,
        xpPerAction: 0,
        category: 'Special',
        notes: 'Restore HP/Prayer/Run/Stats'),
    SkillAction(
        name: 'Mahogany Homes (beginner)',
        levelReq: 1,
        xpPerAction: 200,
        xpPerHour: 80000,
        category: 'Minigame'),
    SkillAction(
        name: 'Mahogany Homes (adept)',
        levelReq: 20,
        xpPerAction: 400,
        xpPerHour: 120000,
        category: 'Minigame'),
    SkillAction(
        name: 'Mahogany Homes (expert)',
        levelReq: 50,
        xpPerAction: 700,
        xpPerHour: 200000,
        category: 'Minigame',
        notes: 'Cheaper than tables — good XP'),
    SkillAction(
        name: 'Mahogany Homes (master)',
        levelReq: 70,
        xpPerAction: 1100,
        xpPerHour: 320000,
        category: 'Minigame',
        notes: 'Best value XP — carpenter outfit points'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  FARMING
  // ═══════════════════════════════════════════════════════════
  'Farming': [
    // Allotments
    SkillAction(
        name: 'Potato', levelReq: 1, xpPerAction: 8, category: 'Allotment'),
    SkillAction(
        name: 'Onion', levelReq: 5, xpPerAction: 9.5, category: 'Allotment'),
    SkillAction(
        name: 'Cabbage', levelReq: 7, xpPerAction: 10, category: 'Allotment'),
    SkillAction(
        name: 'Tomato', levelReq: 12, xpPerAction: 12.5, category: 'Allotment'),
    SkillAction(
        name: 'Sweetcorn',
        levelReq: 20,
        xpPerAction: 17,
        category: 'Allotment'),
    SkillAction(
        name: 'Strawberry',
        levelReq: 31,
        xpPerAction: 26,
        category: 'Allotment'),
    SkillAction(
        name: 'Watermelon',
        levelReq: 47,
        xpPerAction: 48.5,
        category: 'Allotment'),
    SkillAction(
        name: 'Snape grass',
        levelReq: 61,
        xpPerAction: 82,
        category: 'Allotment'),
    // Herbs
    SkillAction(name: 'Guam', levelReq: 9, xpPerAction: 11, category: 'Herb'),
    SkillAction(
        name: 'Marrentill', levelReq: 14, xpPerAction: 13.5, category: 'Herb'),
    SkillAction(
        name: 'Tarromin', levelReq: 19, xpPerAction: 16, category: 'Herb'),
    SkillAction(
        name: 'Harralander', levelReq: 26, xpPerAction: 21.5, category: 'Herb'),
    SkillAction(
        name: 'Ranarr',
        levelReq: 32,
        xpPerAction: 27,
        category: 'Herb',
        notes: 'Best GP herb'),
    SkillAction(
        name: 'Toadflax', levelReq: 38, xpPerAction: 34, category: 'Herb'),
    SkillAction(name: 'Irit', levelReq: 44, xpPerAction: 43, category: 'Herb'),
    SkillAction(
        name: 'Avantoe', levelReq: 50, xpPerAction: 54.5, category: 'Herb'),
    SkillAction(
        name: 'Kwuarm', levelReq: 56, xpPerAction: 69, category: 'Herb'),
    SkillAction(
        name: 'Snapdragon',
        levelReq: 62,
        xpPerAction: 87.5,
        category: 'Herb',
        notes: 'Expensive — good XP'),
    SkillAction(
        name: 'Cadantine', levelReq: 67, xpPerAction: 106.5, category: 'Herb'),
    SkillAction(
        name: 'Lantadyme', levelReq: 73, xpPerAction: 134.5, category: 'Herb'),
    SkillAction(
        name: 'Dwarf weed', levelReq: 79, xpPerAction: 170.5, category: 'Herb'),
    SkillAction(
        name: 'Torstol', levelReq: 85, xpPerAction: 199.5, category: 'Herb'),
    // Trees
    SkillAction(
        name: 'Oak tree', levelReq: 15, xpPerAction: 467.3, category: 'Tree'),
    SkillAction(
        name: 'Willow tree',
        levelReq: 30,
        xpPerAction: 1456.5,
        category: 'Tree'),
    SkillAction(
        name: 'Maple tree',
        levelReq: 45,
        xpPerAction: 3403.4,
        category: 'Tree'),
    SkillAction(
        name: 'Yew tree', levelReq: 60, xpPerAction: 7069.9, category: 'Tree'),
    SkillAction(
        name: 'Magic tree',
        levelReq: 75,
        xpPerAction: 13768.3,
        category: 'Tree',
        notes: 'Big XP — long grow time'),
    // Fruit trees
    SkillAction(
        name: 'Apple tree',
        levelReq: 27,
        xpPerAction: 1199.5,
        category: 'Fruit tree'),
    SkillAction(
        name: 'Banana tree',
        levelReq: 33,
        xpPerAction: 1750.5,
        category: 'Fruit tree'),
    SkillAction(
        name: 'Orange tree',
        levelReq: 39,
        xpPerAction: 2470.2,
        category: 'Fruit tree'),
    SkillAction(
        name: 'Curry tree',
        levelReq: 42,
        xpPerAction: 2906.9,
        category: 'Fruit tree'),
    SkillAction(
        name: 'Pineapple tree',
        levelReq: 51,
        xpPerAction: 4605.7,
        category: 'Fruit tree'),
    SkillAction(
        name: 'Papaya tree',
        levelReq: 57,
        xpPerAction: 6146.4,
        category: 'Fruit tree',
        notes: 'Best value fruit tree for XP'),
    SkillAction(
        name: 'Palm tree',
        levelReq: 68,
        xpPerAction: 10150.1,
        category: 'Fruit tree'),
    SkillAction(
        name: 'Dragonfruit tree',
        levelReq: 81,
        xpPerAction: 17335,
        category: 'Fruit tree'),
    // Special
    SkillAction(
        name: 'Calquat tree',
        levelReq: 72,
        xpPerAction: 12096,
        category: 'Special',
        notes: 'One patch — Tai Bwo Wannai'),
    SkillAction(
        name: 'Spirit tree',
        levelReq: 83,
        xpPerAction: 19301.8,
        category: 'Special'),
    SkillAction(
        name: 'Celastrus tree',
        levelReq: 85,
        xpPerAction: 14130,
        category: 'Special',
        notes: 'Battlestaves'),
    SkillAction(
        name: 'Redwood tree',
        levelReq: 90,
        xpPerAction: 22450,
        category: 'Special'),
    SkillAction(
        name: 'Hespori',
        levelReq: 65,
        xpPerAction: 12600,
        category: 'Special',
        notes: 'Boss — anima seeds + bucket'),
    SkillAction(
        name: 'Giant seaweed',
        levelReq: 23,
        xpPerAction: 21,
        category: 'Seaweed',
        notes: 'Underwater farming — for Superglass Make'),
    SkillAction(
        name: 'Tithe Farm',
        levelReq: 34,
        xpPerAction: 26,
        xpPerHour: 90000,
        category: 'Minigame',
        notes: 'Farming outfit + seed box'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  MAGIC
  // ═══════════════════════════════════════════════════════════
  'Magic': [
    SkillAction(
        name: 'Wind Strike',
        levelReq: 1,
        xpPerAction: 5.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Water Strike',
        levelReq: 5,
        xpPerAction: 7.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Earth Strike',
        levelReq: 9,
        xpPerAction: 9.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Fire Strike',
        levelReq: 13,
        xpPerAction: 11.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Wind Bolt',
        levelReq: 17,
        xpPerAction: 13.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Water Bolt',
        levelReq: 23,
        xpPerAction: 16.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Earth Bolt',
        levelReq: 29,
        xpPerAction: 19.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Fire Bolt',
        levelReq: 35,
        xpPerAction: 22.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Wind Blast',
        levelReq: 41,
        xpPerAction: 25.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Water Blast',
        levelReq: 47,
        xpPerAction: 28.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Earth Blast',
        levelReq: 53,
        xpPerAction: 31.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Fire Blast',
        levelReq: 59,
        xpPerAction: 34.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Wind Wave',
        levelReq: 62,
        xpPerAction: 36,
        category: 'Combat spell'),
    SkillAction(
        name: 'Water Wave',
        levelReq: 65,
        xpPerAction: 37.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Earth Wave',
        levelReq: 70,
        xpPerAction: 40,
        category: 'Combat spell'),
    SkillAction(
        name: 'Fire Wave',
        levelReq: 75,
        xpPerAction: 42.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Wind Surge',
        levelReq: 81,
        xpPerAction: 44.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Water Surge',
        levelReq: 85,
        xpPerAction: 46.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Earth Surge',
        levelReq: 90,
        xpPerAction: 48.5,
        category: 'Combat spell'),
    SkillAction(
        name: 'Fire Surge',
        levelReq: 95,
        xpPerAction: 50.5,
        category: 'Combat spell'),
    // Utility
    SkillAction(
        name: 'Telekinetic Grab',
        levelReq: 33,
        xpPerAction: 43,
        category: 'Utility'),
    SkillAction(
        name: 'High Level Alchemy',
        levelReq: 55,
        xpPerAction: 65,
        xpPerHour: 78000,
        category: 'Utility',
        notes: 'Can alch while doing other activities'),
    SkillAction(
        name: 'Superheat Item',
        levelReq: 43,
        xpPerAction: 53,
        category: 'Utility',
        notes: 'Also gives Smithing XP'),
    SkillAction(
        name: 'Enchant bolts',
        levelReq: 4,
        xpPerAction: 9,
        xpPerHour: 100000,
        category: 'Utility',
        notes: 'Fast + cheap XP'),
    SkillAction(
        name: 'Tan Leather (Lunar)',
        levelReq: 78,
        xpPerAction: 81,
        xpPerHour: 130000,
        category: 'Lunar',
        notes: 'Good GP'),
    SkillAction(
        name: 'Plank Make (Lunar)',
        levelReq: 86,
        xpPerAction: 90,
        xpPerHour: 105000,
        category: 'Lunar'),
    SkillAction(
        name: 'String Jewellery (Lunar)',
        levelReq: 80,
        xpPerAction: 83,
        xpPerHour: 140000,
        category: 'Lunar'),
    SkillAction(
        name: 'Stun/alch',
        levelReq: 80,
        xpPerAction: 155,
        xpPerHour: 185000,
        category: 'Other',
        notes: 'Stun + alch combo — click intensive'),
    SkillAction(
        name: 'Bursting/barraging (Slayer)',
        levelReq: 70,
        xpPerAction: 50,
        xpPerHour: 250000,
        category: 'Combat',
        notes: 'Dust devils / Nechryael — great XP'),
    SkillAction(
        name: 'Splashing (w/ full -65 magic)',
        levelReq: 1,
        xpPerAction: 5.5,
        xpPerHour: 13000,
        category: 'Other',
        notes: 'Pure AFK — very slow'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  RANGED
  // ═══════════════════════════════════════════════════════════
  'Ranged': [
    SkillAction(
        name: 'Ammonite Crabs (iron knives)',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 25000,
        category: 'Training',
        notes: 'AFK — Fossil Island'),
    SkillAction(
        name: 'Ammonite Crabs (mithril darts)',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 30000,
        category: 'Training',
        notes: 'AFK — cheap'),
    SkillAction(
        name: 'Sand Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 25000,
        category: 'Training',
        notes: 'AFK — Hosidius'),
    SkillAction(
        name: 'NMZ (MSB + rune arrows)',
        levelReq: 50,
        xpPerAction: 10,
        xpPerHour: 65000,
        category: 'Training',
        notes: 'AFK'),
    SkillAction(
        name: 'NMZ (blowpipe)',
        levelReq: 75,
        xpPerAction: 15,
        xpPerHour: 100000,
        category: 'Training',
        notes: 'AFK — expensive ammo'),
    SkillAction(
        name: 'Chinning (MM2 tunnels)',
        levelReq: 65,
        xpPerAction: 250,
        xpPerHour: 500000,
        category: 'Chinchompa',
        notes: 'Red/black chins — fastest Ranged XP'),
    SkillAction(
        name: 'Cannon (multi-combat Slayer)',
        levelReq: 1,
        xpPerAction: 2,
        xpPerHour: 40000,
        category: 'Cannon',
        notes: 'Supplementary XP during Slayer'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  ATTACK / STRENGTH / DEFENCE
  // ═══════════════════════════════════════════════════════════
  'Attack': [
    SkillAction(
        name: 'Ammonite Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 30000,
        category: 'AFK Training'),
    SkillAction(
        name: 'Sand Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 25000,
        category: 'AFK Training'),
    SkillAction(
        name: 'Slayer (Konar/Nieve/Duradel)',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 40000,
        category: 'Slayer',
        notes: 'Best long-term — trains Slayer + GP'),
    SkillAction(
        name: 'NMZ (Obsidian)',
        levelReq: 60,
        xpPerAction: 4,
        xpPerHour: 90000,
        category: 'Minigame',
        notes: 'AFK — full obsidian + berserker necklace'),
    SkillAction(
        name: 'NMZ (Dharok)',
        levelReq: 70,
        xpPerAction: 4,
        xpPerHour: 110000,
        category: 'Minigame',
        notes: 'AFK — 1 HP method'),
    SkillAction(
        name: 'Nightmare Zone (absorption)',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 50000,
        category: 'Minigame',
        notes: 'AFK — absorption potions + overload'),
  ],

  'Strength': [
    SkillAction(
        name: 'Ammonite Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 30000,
        category: 'AFK Training'),
    SkillAction(
        name: 'Sand Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 25000,
        category: 'AFK Training'),
    SkillAction(
        name: 'Slayer (Konar/Nieve/Duradel)',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 40000,
        category: 'Slayer',
        notes: 'Best long-term'),
    SkillAction(
        name: 'NMZ (Obsidian)',
        levelReq: 60,
        xpPerAction: 4,
        xpPerHour: 90000,
        category: 'Minigame',
        notes: 'AFK — full obsidian + berserker necklace'),
    SkillAction(
        name: 'NMZ (Dharok)',
        levelReq: 70,
        xpPerAction: 4,
        xpPerHour: 120000,
        category: 'Minigame',
        notes: 'AFK — 1 HP method — fastest melee XP'),
    SkillAction(
        name: 'Barbarian fishing',
        levelReq: 48,
        xpPerAction: 7,
        xpPerHour: 10000,
        category: 'Passive',
        notes: 'While training Fishing + Agility'),
  ],

  'Defence': [
    SkillAction(
        name: 'Ammonite Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 30000,
        category: 'AFK Training'),
    SkillAction(
        name: 'Sand Crabs',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 25000,
        category: 'AFK Training'),
    SkillAction(
        name: 'Slayer (Konar/Nieve/Duradel)',
        levelReq: 1,
        xpPerAction: 4,
        xpPerHour: 40000,
        category: 'Slayer',
        notes: 'Best long-term'),
    SkillAction(
        name: 'NMZ (Obsidian)',
        levelReq: 60,
        xpPerAction: 4,
        xpPerHour: 90000,
        category: 'Minigame'),
    SkillAction(
        name: 'Bursting/barraging (Slayer)',
        levelReq: 1,
        xpPerAction: 1.33,
        xpPerHour: 80000,
        category: 'Magic',
        notes: 'Defensive casting — trains Magic too'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  HITPOINTS
  // ═══════════════════════════════════════════════════════════
  'Hitpoints': [
    SkillAction(
        name: 'Any combat training',
        levelReq: 1,
        xpPerAction: 1.33,
        xpPerHour: 15000,
        category: 'Passive',
        notes: 'Gained passively from all combat (1.33 HP xp per 4 combat xp)'),
    SkillAction(
        name: 'NMZ',
        levelReq: 1,
        xpPerAction: 1.33,
        xpPerHour: 30000,
        category: 'Minigame'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  SLAYER
  // ═══════════════════════════════════════════════════════════
  'Slayer': [
    SkillAction(
        name: 'Turael tasks',
        levelReq: 1,
        xpPerAction: 25,
        xpPerHour: 8000,
        category: 'Task',
        notes: 'Very easy — point boosting'),
    SkillAction(
        name: 'Konar tasks',
        levelReq: 1,
        xpPerAction: 50,
        xpPerHour: 15000,
        category: 'Task',
        notes: 'Brimstone keys — location-specific'),
    SkillAction(
        name: 'Nieve/Steve tasks',
        levelReq: 1,
        xpPerAction: 80,
        xpPerHour: 25000,
        category: 'Task'),
    SkillAction(
        name: 'Duradel tasks',
        levelReq: 1,
        xpPerAction: 100,
        xpPerHour: 30000,
        category: 'Task',
        notes: 'Best XP — Shilo Village'),
    SkillAction(
        name: 'Barrage Slayer (dust devils)',
        levelReq: 65,
        xpPerAction: 130,
        xpPerHour: 45000,
        category: 'Burst/Barrage',
        notes: 'Multi-combat — fast XP'),
    SkillAction(
        name: 'Barrage Slayer (nechryael)',
        levelReq: 80,
        xpPerAction: 150,
        xpPerHour: 50000,
        category: 'Burst/Barrage',
        notes: 'Catacombs — good alchables'),
    SkillAction(
        name: 'Wilderness Slayer',
        levelReq: 1,
        xpPerAction: 80,
        xpPerHour: 20000,
        category: 'Task',
        notes: 'Larran\'s keys + emblems'),
  ],

  // ═══════════════════════════════════════════════════════════
  //  SAILING
  // ═══════════════════════════════════════════════════════════
  'Sailing': [
    SkillAction(
        name: 'Courier tasks (early)',
        levelReq: 1,
        xpPerAction: 500,
        xpPerHour: 10000,
        category: 'Courier',
        notes: 'Port Sarim ↔ Pandemonium'),
    SkillAction(
        name: 'Sea charting',
        levelReq: 12,
        xpPerAction: 200,
        xpPerHour: 10000,
        category: 'Exploration',
        notes: 'One-off XP rewards from charting oceans'),
    SkillAction(
        name: 'Shipwreck salvaging',
        levelReq: 15,
        xpPerAction: 50,
        xpPerHour: 15000,
        category: 'Gathering',
        notes: 'Low-intensity — salvaging hooks'),
    SkillAction(
        name: 'Courier tasks (Summer Shore)',
        levelReq: 46,
        xpPerAction: 4000,
        xpPerHour: 30000,
        category: 'Courier',
        notes: '~9 trips/hr'),
    SkillAction(
        name: 'Shipwreck salvaging (with station)',
        levelReq: 42,
        xpPerAction: 80,
        xpPerHour: 40000,
        category: 'Gathering',
        notes: 'Salvaging station from Chinchompa Island'),
    SkillAction(
        name: 'Bounty tasks',
        levelReq: 30,
        xpPerAction: 5000,
        xpPerHour: 50000,
        category: 'Combat',
        notes: 'Kill sea monsters for bounty items'),
    SkillAction(
        name: 'Barracuda Trials (Tempor Tantrum)',
        levelReq: 30,
        xpPerAction: 3000,
        xpPerHour: 60000,
        category: 'Trials',
        notes: 'Obstacle course — fastest from 30'),
    SkillAction(
        name: 'Courier tasks (Rellekka)',
        levelReq: 62,
        xpPerAction: 6000,
        xpPerHour: 70000,
        category: 'Courier',
        notes: 'Up to 90k/hr at 65+'),
    SkillAction(
        name: 'Barracuda Trials (Jubbly Jive)',
        levelReq: 55,
        xpPerAction: 5000,
        xpPerHour: 100000,
        category: 'Trials',
        notes: 'Second trial — faster than Tempor Tantrum'),
    SkillAction(
        name: 'Bounty tasks (optimised)',
        levelReq: 55,
        xpPerAction: 8000,
        xpPerHour: 130000,
        category: 'Combat',
        notes: 'Bird + ray tasks from Prifddinas/Rellekka'),
    SkillAction(
        name: 'Barracuda Trials (Gwenith Glide)',
        levelReq: 72,
        xpPerAction: 8000,
        xpPerHour: 160000,
        category: 'Trials',
        notes: 'Third trial — Song of the Elves area'),
    SkillAction(
        name: 'Bounty tasks (Deepfin Point)',
        levelReq: 67,
        xpPerAction: 10000,
        xpPerHour: 200000,
        category: 'Combat',
        notes: 'Best bounty XP — up to 200k/hr BiS ship'),
    SkillAction(
        name: 'Barracuda Trials (Gwenith + Rosewood)',
        levelReq: 93,
        xpPerAction: 10000,
        xpPerHour: 200000,
        category: 'Trials',
        notes: 'Rosewood hull (93 Sail, 84 Con) + crystal extractor'),
    SkillAction(
        name: 'Deep sea trawling',
        levelReq: 40,
        xpPerAction: 100,
        xpPerHour: 25000,
        category: 'Gathering',
        notes: 'Hybrid Fishing + Sailing'),
    SkillAction(
        name: 'Crystal extractor (passive)',
        levelReq: 73,
        xpPerAction: 250,
        xpPerHour: 15000,
        category: 'Passive',
        notes: 'Harvest every ~63s — stacks with other methods'),
  ],
};
