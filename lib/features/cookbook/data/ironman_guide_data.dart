import '../domain/cookbook_models.dart';

/// Real guide data sourced from ironman.guide (Oziris v4.0)
/// Credit: OzirisLoL — https://ironman.guide/guide
List<CookbookTemplate> getBuiltInTemplates() {
  return [
    _ozirisIronmanGuide(),
    _hcimGuide(),
    _uimGuide(),
    _gimGuide(),
    _bossOrderGuide(),
    _gearProgressionGuide(),
    _questCapeRoadmap(),
  ];
}

CookbookTemplate _ozirisIronmanGuide() {
  return CookbookTemplate(
    id: 'oziris_ironman_v4',
    title: 'Oziris Ironman Efficiency Guide v4.0',
    description: 'The complete 570-step ironman efficiency guide by OzirisLoL. '
        'Covers early game through Corrupted Gauntlet. '
        'Source: ironman.guide/guide',
    mode: CookbookMode.iron,
    tags: ['ironman', 'efficiency', 'oziris', 'complete-guide'],
    version: '4.0',
    author: 'OzirisLoL',
    sections: [
      _section11EarlyGame(),
      _section12ThievingFishingMining(),
      _section13FairyRingsPrayerKingdom(),
      _section14SkillingGraceful(),
      _section15DiariesRfd(),
      _section20AfterBarrowsGloves(),
    ],
  );
}

CookbookSection _section11EarlyGame() {
  return CookbookSection(
    id: 'oziris_1_1',
    title: '1.1 Early Quests, Wintertodt & Ardy Cloak 1',
    description:
        'Starting your ironman journey. Complete early quests, get 50+ firemaking at Wintertodt, and unlock the Ardougne cloak 1.',
    order: 0,
    steps: [
      CookbookStep(
          id: 'e1',
          order: 0,
          title:
              'Start as female character, make yourself an ironman before leaving Tutorial Island',
          category: StepCategory.quest,
          estimatedMinutes: 10),
      CookbookStep(
          id: 'e2',
          order: 1,
          title:
              'Use every book and lamp on Herblore until 77, then Prayer (HCIM) or Agility/RC',
          category: StepCategory.prep,
          notes: 'Long-term rule for all lamps'),
      CookbookStep(
          id: 'e3',
          order: 2,
          title:
              'Use Authenticator AND 2-step verification on registered email',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e4',
          order: 3,
          title:
              'Sell bronze dagger, sword, axe, wooden shield and shortbow to general store',
          category: StepCategory.banking,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e5',
          order: 4,
          title: 'Buy a spade, start X Marks the Spot quest',
          category: StepCategory.quest,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e6',
          order: 5,
          title:
              'Drop runes and ask for more from the magic tutor, pick up runes',
          category: StepCategory.prep,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e7',
          order: 6,
          title:
              'Pick up every item spawn in the castle including cellar, don\'t forget cabbage',
          category: StepCategory.prep,
          location: 'Lumbridge Castle'),
      CookbookStep(
          id: 'e8',
          order: 7,
          title: 'Fill a jug with water, talk to duke for Rune Mysteries',
          category: StepCategory.quest,
          location: 'Lumbridge Castle'),
      CookbookStep(
          id: 'e9',
          order: 8,
          title:
              'Bank everything, light 4 logs to 15 FM, fletch into 1000 arrow shafts',
          category: StepCategory.skilling,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e10',
          order: 9,
          title:
              'Bank 4 ashes, 7 logs. Take GP, clue, air talisman, spade, runes, food',
          category: StepCategory.banking),
      CookbookStep(
          id: 'e11',
          order: 10,
          title: 'Thieve men until 5 Thieving',
          category: StepCategory.skilling,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e12',
          order: 11,
          title:
              'Dig up X Marks the Spot clue north of Bob\'s Axes, buy steel axe',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e13',
          order: 12,
          title: 'Start Restless Ghost — talk to Father Aereck',
          category: StepCategory.quest,
          location: 'Lumbridge church'),
      CookbookStep(
          id: 'e14',
          order: 13,
          title: 'Kill a rat (safespot with wind strike) for its meat',
          category: StepCategory.combat,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e15',
          order: 14,
          title: 'Pick up 5 swamp tar at swamp cave entrance',
          category: StepCategory.prep,
          location: 'Lumbridge Swamp'),
      CookbookStep(
          id: 'e16',
          order: 15,
          title: 'Talk to Father Urhney for ghostspeak amulet, equip it',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e17',
          order: 16,
          title: 'Take air talisman to wizard tower, run to Draynor',
          category: StepCategory.travel),
      CookbookStep(
          id: 'e18',
          order: 17,
          title: 'Finish X Marks the Spot — dig clues, talk to Veos',
          category: StepCategory.quest,
          location: 'Draynor/Port Sarim'),
      CookbookStep(
          id: 'e19',
          order: 18,
          title: 'Pick up 1 snape grass near crafting guild, walk to Falador',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e20',
          order: 19,
          title: 'Start The Knight\'s Sword quest — talk to squire',
          category: StepCategory.quest,
          location: 'Falador'),
      CookbookStep(
          id: 'e21',
          order: 20,
          title: 'Minigame tele to Clan Wars, pick up 2 iron bars NW of Ferox',
          category: StepCategory.travel),
      CookbookStep(
          id: 'e22',
          order: 21,
          title: 'Recharge run at pool, portal to Castle Wars, walk to Yanille',
          category: StepCategory.travel),
      CookbookStep(
          id: 'e23',
          order: 22,
          title:
              'Buy pie dish at Yanille, swamp paste from Port Khazard general store',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e24',
          order: 23,
          title: 'Do Monk\'s Friend quest',
          category: StepCategory.quest,
          estimatedMinutes: 10,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e25',
          order: 24,
          title:
              'Get 35 WC at oaks south of Ardy zoo, firemake logs as you cut',
          category: StepCategory.skilling,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e26',
          order: 25,
          title:
              'Get 20 Thieving with cake stall, steal silk until 25 Thieving',
          category: StepCategory.skilling,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e27',
          order: 26,
          title: 'Do Sheep Herder quest',
          category: StepCategory.quest,
          estimatedMinutes: 10,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e28',
          order: 27,
          title: 'Do Sea Slug — fish shrimp while doing quest for diary',
          category: StepCategory.quest,
          estimatedMinutes: 15),
      CookbookStep(
          id: 'e29',
          order: 28,
          title:
              'Sell silk for 60gp each, buy POH with 10k GP. Use X Marks lamp on Construction',
          category: StepCategory.prep,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e30',
          order: 29,
          title:
              'Buy 2 ropes, 5 vials, 30 balls of wool, 7 papyrus from Ardy general store',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e31',
          order: 30,
          title: 'Buy greenman\'s ale from Rasolo, start Dwarf Cannon quest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e32',
          order: 31,
          title:
              'Pick up 130 planks north of Barb Agility course, do BA tutorial for minigame tele',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e33',
          order: 32,
          title: 'Start Barcrawl miniquest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e34',
          order: 33,
          title:
              'Do Waterfall Quest until gnome maze part — remember to read the book',
          category: StepCategory.quest,
          estimatedMinutes: 25,
          links: ['https://oldschool.runescape.wiki/w/Waterfall_Quest']),
      CookbookStep(
          id: 'e35',
          order: 34,
          title:
              'At Gnome Stronghold: buy drink for barcrawl, buy items from Heckel Funch, buy 1000 bronze arrowheads',
          category: StepCategory.prep,
          location: 'Tree Gnome Stronghold'),
      CookbookStep(
          id: 'e36',
          order: 35,
          title: 'Make hangover cure, do Plague City quest',
          category: StepCategory.quest,
          estimatedMinutes: 15,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e37',
          order: 36,
          title:
              'Complete Daddy\'s Home miniquest in Varrock, sell bolts of cloth to sawmill',
          category: StepCategory.quest,
          location: 'Varrock'),
      CookbookStep(
          id: 'e38',
          order: 37,
          title: 'Buy 500 bronze nails from sawmill',
          category: StepCategory.prep,
          location: 'Varrock'),
      CookbookStep(
          id: 'e39',
          order: 38,
          title:
              'Cut and firemake teak logs until 50 Firemaking SW of Castle Wars',
          category: StepCategory.skilling,
          location: 'Castle Wars'),
      CookbookStep(
          id: 'e40',
          order: 39,
          title:
              'Home tele, talk to ghost for Restless Ghost. Run to Draynor bank',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e41',
          order: 40,
          title: 'Buy chronicle + 2 teleport cards from Diango',
          category: StepCategory.prep,
          location: 'Draynor'),
      CookbookStep(
          id: 'e42',
          order: 41,
          title:
              'Train Construction with planks — make bookcases until out of planks',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'e43',
          order: 42,
          title:
              'Walk to Port Sarim, buy 1000 feathers, take boat to Great Kourend',
          category: StepCategory.travel),
      CookbookStep(
          id: 'e44',
          order: 43,
          title: 'Do Wintertodt until 200k cash, get at least 22 fletching',
          category: StepCategory.skilling,
          estimatedMinutes: 180,
          location: 'Wintertodt'),
      CookbookStep(
          id: 'e45',
          order: 44,
          title:
              'Home tele, get more runes from mage tutor. Buy 3 buckets + bucket pack',
          category: StepCategory.prep,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e46',
          order: 45,
          title:
              'Kill chicken, pick up egg, kill cow calf for meat, fill 3 buckets of milk',
          category: StepCategory.prep,
          location: 'Lumbridge farms'),
      CookbookStep(
          id: 'e47',
          order: 46,
          title: 'Get ammo mould + Dwarf Cannon notes at Ice Mountain',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e48',
          order: 47,
          title:
              'Start Gertrude\'s Cat, Romeo & Juliet, Demon Slayer, Shield of Arrav',
          category: StepCategory.quest,
          location: 'Varrock'),
      CookbookStep(
          id: 'e49',
          order: 48,
          title:
              'Buy fire staff, buy items from shops. Do Museum for 9 Hunter + Slayer',
          category: StepCategory.quest,
          location: 'Varrock'),
      CookbookStep(
          id: 'e50',
          order: 49,
          title: 'Buy 100 fire, 300 earth/water, 4000 mind, 8000 air runes',
          category: StepCategory.prep,
          location: 'Varrock'),
      CookbookStep(
          id: 'e51',
          order: 50,
          title:
              'Get barcrawl drinks from Varrock pubs. Continue Gertrude\'s Cat at lumberyard',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e52',
          order: 51,
          title:
              'Fill inv of buckets with water, pick cadava + 16 redberries, mine 4 copper + 1 iron',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e53',
          order: 52,
          title:
              'Finish Gertrude\'s Cat, talk to Juliet, start Abyss miniquest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e54',
          order: 53,
          title:
              'Do Witch\'s House, Druidic Ritual. Buy eye of newt packs + pestle in Taverley',
          category: StepCategory.quest,
          estimatedMinutes: 20),
      CookbookStep(
          id: 'e55',
          order: 54,
          title:
              'Finish Knight\'s Sword quest chain — mine 2 blurite ore, talk to squire',
          category: StepCategory.quest,
          estimatedMinutes: 15,
          location: 'Falador'),
      CookbookStep(
          id: 'e56',
          order: 55,
          title:
              'Buy 50 thread, 3 needles, all moulds from Al-Kharid crafting shop',
          category: StepCategory.prep,
          location: 'Al-Kharid'),
      CookbookStep(
          id: 'e57',
          order: 56,
          title:
              'Start Prince Ali Rescue. Fish anchovies for diary. Buy bronze bars from Shantay',
          category: StepCategory.quest,
          location: 'Al-Kharid'),
      CookbookStep(
          id: 'e58',
          order: 57,
          title: 'Do The Tourist Trap quest',
          category: StepCategory.quest,
          estimatedMinutes: 30),
      CookbookStep(
          id: 'e59',
          order: 58,
          title:
              'Buy 10 buckets of slime, flour, sand + soda ash at Port Khazard',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e60',
          order: 59,
          title:
              'Fire strike imps for 4 beads. Do Fight Arena, Tree Gnome Village',
          category: StepCategory.quest,
          estimatedMinutes: 30),
      CookbookStep(
          id: 'e61',
          order: 60,
          title: 'Safespot zamorak warrior at ZMI for rune scimitar',
          category: StepCategory.combat,
          location: 'ZMI'),
      CookbookStep(
          id: 'e62',
          order: 61,
          title: 'Train 42 Magic at Moss Giants near Fishing Guild',
          category: StepCategory.combat),
      CookbookStep(
          id: 'e63',
          order: 62,
          title: 'Do Hazeel Cult, Tribal Totem. Finish Dwarf Cannon',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e64',
          order: 63,
          title:
              'Drop runes outside Glarial\'s tomb, get amulet + urn. Finish Waterfall Quest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e65',
          order: 64,
          title:
              'Get 100 compost + saltpetre in Zeah. Train 42 Thieving at fruit stall',
          category: StepCategory.skilling,
          location: 'Hosidius'),
      CookbookStep(
          id: 'e66',
          order: 65,
          title:
              'Do Cook\'s Assistant, start RFD, watch cutscene to unlock bank chest',
          category: StepCategory.quest,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'e67',
          order: 66,
          title:
              'Do Sheep Shearer, Imp Catcher, Rune Mysteries, Vampire Slayer setup',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e68',
          order: 67,
          title: 'Finish Demon Slayer, Romeo & Juliet. Start Grand Tree quest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e69',
          order: 68,
          title: 'Do Pirate\'s Treasure, Biohazard quest chain',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e70',
          order: 69,
          title:
              'Do Murder Mystery, Fishing Contest, Doric\'s Quest, Black Knight\'s Fortress',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e71',
          order: 70,
          title: 'Do Recruitment Drive, Observatory Quest, Lost Tribe',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e72',
          order: 71,
          title: 'Finish Abyss miniquest, Merlin\'s Crystal, Biohazard',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e73',
          order: 72,
          title: 'Finish Ardy Easy diary tasks, get Ardougne Cloak 1',
          category: StepCategory.quest,
          location: 'Ardougne'),
      CookbookStep(
          id: 'e74',
          order: 73,
          title: 'Trade cat for 200 death runes, buy a new kitten',
          category: StepCategory.prep),
      CookbookStep(
          id: 'e75',
          order: 74,
          title:
              'Do Jungle Potion, Shilo Village. Finish Merlin\'s Crystal + start Holy Grail',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e76',
          order: 75,
          title: 'Get boots of lightness, do Elemental Workshop 1',
          category: StepCategory.quest),
      CookbookStep(
          id: 'e77',
          order: 76,
          title: 'Do Goblin Diplomacy, finish Lost Tribe',
          category: StepCategory.quest),
    ],
  );
}

CookbookSection _section12ThievingFishingMining() {
  return CookbookSection(
    id: 'oziris_1_2',
    title: '1.2 Thieving, Fishing and Mining',
    description:
        'Build core skills. Blackjack to 50+ thieving, fish for food and cooking XP, mine iron for smithing.',
    order: 1,
    steps: [
      CookbookStep(
          id: 'tf1',
          order: 0,
          title: 'Start The Feud at Ali Morrisane, buy desert disguise',
          category: StepCategory.quest,
          location: 'Al-Kharid'),
      CookbookStep(
          id: 'tf2',
          order: 1,
          title:
              'Smelt 5 silver, make sickle + unstrung holy symbol, keep 3 bars',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'tf3',
          order: 2,
          title:
              'Give key imprint and bronze bar to Osman for Prince Ali Rescue',
          category: StepCategory.quest),
      CookbookStep(
          id: 'tf4',
          order: 3,
          title: 'Do The Feud quest',
          category: StepCategory.quest,
          estimatedMinutes: 20,
          location: 'Pollnivneach'),
      CookbookStep(
          id: 'tf5',
          order: 4,
          title: 'Blackjack until 50 Thieving — buy wines from bar as food',
          category: StepCategory.skilling,
          estimatedMinutes: 120,
          location: 'Pollnivneach'),
      CookbookStep(
          id: 'tf6',
          order: 5,
          title:
              'Ardy cloak tele, take boat to Brimhaven, cart to Shilo Village',
          category: StepCategory.travel),
      CookbookStep(
          id: 'tf7',
          order: 6,
          title: 'Cut uncut gems until 32 Crafting, buy 20k feathers',
          category: StepCategory.skilling,
          location: 'Shilo Village'),
      CookbookStep(
          id: 'tf8',
          order: 7,
          title: 'Get 58 Fishing with trout and salmon',
          category: StepCategory.skilling,
          estimatedMinutes: 90),
      CookbookStep(
          id: 'tf9',
          order: 8,
          title: 'Cook all trout (don\'t cook salmon yet)',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'tf10',
          order: 9,
          title:
              'Minigame tele to Barb Assault. Get 50 Agility from barb fishing to ~74 Fishing',
          category: StepCategory.skilling,
          estimatedMinutes: 180),
      CookbookStep(
          id: 'tf11',
          order: 10,
          title: 'After 50 Agility — do Rogues\' Den for full rogue outfit',
          category: StepCategory.skilling,
          estimatedMinutes: 30,
          location: 'Burthorpe'),
      CookbookStep(
          id: 'tf12',
          order: 11,
          title: 'Equip rogue set, blackjack until 2.4M GP (~83 Thieving)',
          category: StepCategory.skilling,
          estimatedMinutes: 300,
          location: 'Pollnivneach'),
      CookbookStep(
          id: 'tf13',
          order: 12,
          title: 'Start The Golem, finish it. Do Shadow of the Storm',
          category: StepCategory.quest,
          estimatedMinutes: 30),
      CookbookStep(
          id: 'tf14',
          order: 13,
          title:
              'Talk to Oziach for Dragon Slayer. Go to Mage Bank — buy 6k nats, cosmics, 300 laws',
          category: StepCategory.prep),
      CookbookStep(
          id: 'tf15',
          order: 14,
          title: 'Buy addy and rune pickaxes from pickaxe shop in mines',
          category: StepCategory.prep),
      CookbookStep(
          id: 'tf16',
          order: 15,
          title: 'Complete Varrock Easy diary for armour',
          category: StepCategory.quest,
          location: 'Varrock'),
      CookbookStep(
          id: 'tf17',
          order: 16,
          title:
              'Mine 2300 iron ore at Ardy monastery, superheat while walking to bank',
          category: StepCategory.skilling,
          estimatedMinutes: 240,
          location: 'Ardougne Monastery'),
    ],
  );
}

CookbookSection _section13FairyRingsPrayerKingdom() {
  return CookbookSection(
    id: 'oziris_1_3',
    title: '1.3 Fairy Rings, 43 Prayer, Kingdom, 99 Thieving',
    description:
        'Unlock fairy rings for fast travel, get 43 prayer for protection prayers, and set up Miscellania.',
    order: 2,
    steps: [
      CookbookStep(
          id: 'fr1',
          order: 0,
          title: 'Buy bronze sword from Varrock, smith 3 bronze wire',
          category: StepCategory.prep,
          location: 'Varrock'),
      CookbookStep(
          id: 'fr2',
          order: 1,
          title: 'Start Priest in Peril. Start Rag and Bone Man on the way',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr3',
          order: 2,
          title: 'Do Priest in Peril, Nature Spirit',
          category: StepCategory.quest,
          estimatedMinutes: 30),
      CookbookStep(
          id: 'fr4',
          order: 3,
          title:
              'Buy 1 raw shark from Canifis food shop. Do Creature of Fenkenstrain',
          category: StepCategory.quest,
          location: 'Canifis'),
      CookbookStep(
          id: 'fr5',
          order: 4,
          title:
              'Kill ram, bear, unicorn, giant bat for Rag and Bone Man bones',
          category: StepCategory.combat),
      CookbookStep(
          id: 'fr6',
          order: 5,
          title: 'Do Elemental Workshop 2',
          category: StepCategory.quest,
          estimatedMinutes: 15,
          location: 'Seers Village'),
      CookbookStep(
          id: 'fr7',
          order: 6,
          title: 'Get anti-dragon shield from Duke. Start Lost City',
          category: StepCategory.quest,
          location: 'Lumbridge'),
      CookbookStep(
          id: 'fr8',
          order: 7,
          title: 'Do Ernest the Chicken, finish Vampire Slayer',
          category: StepCategory.quest,
          location: 'Draynor Manor'),
      CookbookStep(
          id: 'fr9',
          order: 8,
          title: 'Get 5+ Dramen branches, make 2 staffs. Finish Lost City',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr10',
          order: 9,
          title: 'Start Fairytale Part 1. Flinch Tanglefoot',
          category: StepCategory.quest,
          estimatedMinutes: 20),
      CookbookStep(
          id: 'fr11',
          order: 10,
          title: 'Talk to Martin to start Fairytale 2. Buy 35 jugs of vinegar',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr12',
          order: 11,
          title:
              'Rescue Prince Ali, start Evil Dave RFD subquest, unlock fairy rings',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr13',
          order: 12,
          title:
              'Do Melzar\'s Maze, get 2nd map piece (Dragon Slayer). Buy and repair ship',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr14',
          order: 13,
          title:
              'Kill Elvarg — can do multiple trips. Finish Dragon Slayer, buy green d\'hide top',
          category: StepCategory.quest,
          estimatedMinutes: 20),
      CookbookStep(
          id: 'fr15',
          order: 14,
          title: 'Make stew for Evil Dave, finish Evil Dave RFD subquest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr16',
          order: 15,
          title:
              'Do Death to the Dorgeshuun — buy dorg crossbow + 4000 bone bolts',
          category: StepCategory.quest,
          estimatedMinutes: 25),
      CookbookStep(
          id: 'fr17',
          order: 16,
          title: 'Finish Holy Grail',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr18',
          order: 17,
          title: 'Do Horror from the Deep quest',
          category: StepCategory.quest,
          estimatedMinutes: 15),
      CookbookStep(
          id: 'fr19',
          order: 18,
          title: 'Do Turael slayer with dorg cbow until 37 Range and 18 Slayer',
          category: StepCategory.combat,
          estimatedMinutes: 60),
      CookbookStep(
          id: 'fr20',
          order: 19,
          title:
              'Kill tree spirits with fire strike for mithril axe + addy/rune axe',
          category: StepCategory.combat),
      CookbookStep(
          id: 'fr21',
          order: 20,
          title:
              'Do Animal Magnetism. Buy mith plate from Horvik, mith legs from Al-Kharid',
          category: StepCategory.quest,
          estimatedMinutes: 20),
      CookbookStep(
          id: 'fr22',
          order: 21,
          title: 'Do Spirits of the Elid, Underground Pass quest',
          category: StepCategory.quest,
          estimatedMinutes: 90,
          links: ['https://oldschool.runescape.wiki/w/Underground_Pass']),
      CookbookStep(
          id: 'fr23',
          order: 22,
          title: 'Upgrade Iban staff. Get 50 Attack doing Turael slayer',
          category: StepCategory.combat),
      CookbookStep(
          id: 'fr24',
          order: 23,
          title: 'Kill blue dragons with Iban\'s Blast for 43 Prayer bones',
          category: StepCategory.combat,
          estimatedMinutes: 120),
      CookbookStep(
          id: 'fr25',
          order: 24,
          title: 'Buy buckets of slime, grind bones. Start Ghosts Ahoy',
          category: StepCategory.quest,
          location: 'Port Phasmatys'),
      CookbookStep(
          id: 'fr26',
          order: 25,
          title:
              'Grind 9 d bones and offer at ectofuntus, finish Ghosts Ahoy, get 43 Prayer',
          category: StepCategory.quest,
          estimatedMinutes: 20),
      CookbookStep(
          id: 'fr27',
          order: 26,
          title: 'Do Monkey Madness — reward on Attack + Defence',
          category: StepCategory.quest,
          estimatedMinutes: 90),
      CookbookStep(
          id: 'fr28',
          order: 27,
          title: 'Do Wanted! quest, get 40 Slayer with Turael',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr29',
          order: 28,
          title:
              'Do Shades of Morton. Get 25 Herblore if needed. Do Heroes\' Quest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr30',
          order: 29,
          title: 'Do Fremennik Trials, Throne of Miscellania, Royal Trouble',
          category: StepCategory.quest,
          estimatedMinutes: 60),
      CookbookStep(
          id: 'fr31',
          order: 30,
          title: 'Put 750k+ GP into Kingdom — 10 maples, 5 herbs',
          category: StepCategory.prep,
          location: 'Miscellania'),
      CookbookStep(
          id: 'fr32',
          order: 31,
          title: 'Do Bone Voyage, set up first birdhouses. Do Tears of Guthix',
          category: StepCategory.quest),
      CookbookStep(
          id: 'fr33',
          order: 32,
          title:
              'Move house to Pollnivneach. Blackjack to 88 Thieving (~1.4M GP)',
          category: StepCategory.skilling,
          estimatedMinutes: 360,
          location: 'Pollnivneach'),
    ],
  );
}

CookbookSection _section14SkillingGraceful() {
  return CookbookSection(
    id: 'oziris_1_4',
    title: '1.4 Various Skilling, Agility for Graceful',
    description: 'Train various skills and complete the graceful outfit grind.',
    order: 3,
    steps: [
      CookbookStep(
          id: 'sg1',
          order: 0,
          title:
              'Thieve master farmers for low level farming seeds (mainly harralanders)',
          category: StepCategory.skilling,
          estimatedMinutes: 60),
      CookbookStep(
          id: 'sg2',
          order: 1,
          title:
              'Get 100% Hosidius favour. Put 15 pineapples into each compost bin',
          category: StepCategory.skilling,
          location: 'Hosidius'),
      CookbookStep(
          id: 'sg3',
          order: 2,
          title:
              'Buy ~200 chocolate from grand tree food shop, make energy pots',
          category: StepCategory.prep),
      CookbookStep(
          id: 'sg4',
          order: 3,
          title: 'Plant barley at hops patch NW of Seers, pay farmer 3 compost',
          category: StepCategory.skilling,
          location: 'Seers Village'),
      CookbookStep(
          id: 'sg5',
          order: 4,
          title: 'Do The Giant Dwarf, Forgettable Tale, Garden of Tranquility',
          category: StepCategory.quest,
          estimatedMinutes: 90,
          location: 'Keldagrim'),
      CookbookStep(
          id: 'sg6',
          order: 5,
          title: 'Start Enlightened Journey quest',
          category: StepCategory.quest),
      CookbookStep(
          id: 'sg7',
          order: 6,
          title: 'Do Eyes of Glouphrie, Tower of Life. Smith iron dart tips',
          category: StepCategory.quest),
      CookbookStep(
          id: 'sg8',
          order: 7,
          title:
              'Mine volcanic ash for ultracompost (~2k). Do farm runs with ultracompost',
          category: StepCategory.skilling,
          location: 'Fossil Island'),
      CookbookStep(
          id: 'sg9',
          order: 8,
          title: 'Do Temple of Ikov quest',
          category: StepCategory.quest,
          estimatedMinutes: 20),
      CookbookStep(
          id: 'sg10',
          order: 9,
          title:
              'Finish Enlightened Journey — unlock Varrock + Castle Wars balloons',
          category: StepCategory.quest),
      CookbookStep(
          id: 'sg11',
          order: 10,
          title:
              'Cut oaks near Varrock balloon, turn into planks at sawmill, balloon to Castle Wars, repeat',
          category: StepCategory.skilling,
          notes: 'Construction method'),
      CookbookStep(
          id: 'sg12',
          order: 11,
          title:
              'Get 50 Construction — un-note with Phials at Rimmington. Move house to Kourend',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'sg13',
          order: 12,
          title: 'Start daily tree runs with birdhouse seeds',
          category: StepCategory.skilling,
          notes: 'Do this every day from now on'),
      CookbookStep(
          id: 'sg14',
          order: 13,
          title:
              'Do Big Chompy, Rag and Bone Man, Family Crest (goldsmith gauntlets!), Death Plateau, Troll Stronghold',
          category: StepCategory.quest,
          estimatedMinutes: 120),
      CookbookStep(
          id: 'sg15',
          order: 14,
          title:
              'Fletch maple shortbows (u) to 55 Fletching underwater at Fossil Island',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'sg16',
          order: 15,
          title: 'Do seaweed farming every birdhouse run — very important!',
          category: StepCategory.skilling,
          notes: 'Critical for crafting long-term'),
      CookbookStep(
          id: 'sg17',
          order: 16,
          title:
              'Buy 2800 gold ore from Blast Furnace. Get 60 Smithing with goldsmith gauntlets',
          category: StepCategory.skilling,
          location: 'Blast Furnace'),
      CookbookStep(
          id: 'sg18',
          order: 17,
          title:
              'Craft gold bracelets at Edgeville. Get Mage Arena cape if 60 Magic',
          category: StepCategory.skilling,
          location: 'Edgeville'),
      CookbookStep(
          id: 'sg19',
          order: 18,
          title: 'Buy 5k nats + cosmics',
          category: StepCategory.prep,
          location: 'Mage Bank'),
      CookbookStep(
          id: 'sg20',
          order: 19,
          title: 'Do Agility until full Graceful — 50-60 Canifis, 60+ Seers',
          category: StepCategory.skilling,
          estimatedMinutes: 600,
          notes: 'Major grind'),
      CookbookStep(
          id: 'sg21',
          order: 20,
          title: 'Optional: Fish 3k raw karambwans, bank at Zanaris',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'sg22',
          order: 21,
          title: 'Kingdom reminder — take out GP after 7th day (6.2k maples)',
          category: StepCategory.prep,
          location: 'Miscellania'),
      CookbookStep(
          id: 'sg23',
          order: 22,
          title: 'Do Regicide quest, Hand in the Sand quest',
          category: StepCategory.quest,
          estimatedMinutes: 45),
    ],
  );
}

CookbookSection _section15DiariesRfd() {
  return CookbookSection(
    id: 'oziris_1_5',
    title: '1.5 Diaries and Finishing RFD',
    description:
        'Complete achievement diaries and finish Recipe for Disaster for Barrows gloves.',
    order: 4,
    steps: [
      CookbookStep(
          id: 'rd1',
          order: 0,
          title: 'Do all RFD subquests',
          category: StepCategory.quest,
          estimatedMinutes: 180),
      CookbookStep(
          id: 'rd2',
          order: 1,
          title: 'Buy chocolate dust from RFD chest, make energy pots',
          category: StepCategory.prep),
      CookbookStep(
          id: 'rd3',
          order: 2,
          title: 'Plant toadflax seeds, make agility potions',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'rd4',
          order: 3,
          title: 'Make a mithril grapple',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'rd5',
          order: 4,
          title:
              'Do quests for QP and diaries: A Soul\'s Bane, Another Slice of H.A.M, Ichtlarin\'s Little Helper, In Search/Aid of Myreque, Eagles\' Peak, Enakhra\'s Lament, Rat Catchers, Olaf\'s Quest, Between a Rock, Tai Bwo Wannai Trio, Zogre Flesh Eaters',
          category: StepCategory.quest,
          estimatedMinutes: 360),
      CookbookStep(
          id: 'rd6',
          order: 5,
          title:
              'Do Rum Deal (requires 42 Slayer), Cabin Fever, One Small Favour, Watchtower',
          category: StepCategory.quest,
          estimatedMinutes: 180),
      CookbookStep(
          id: 'rd7',
          order: 6,
          title: 'Do all Easy and Medium achievement diaries',
          category: StepCategory.quest,
          estimatedMinutes: 240),
      CookbookStep(
          id: 'rd8',
          order: 7,
          title:
              'Get 50 Range at Pest Control with bone cbow (for Lumby diary)',
          category: StepCategory.combat,
          estimatedMinutes: 60),
      CookbookStep(
          id: 'rd9',
          order: 8,
          title: 'Do Eadgar\'s Ruse, My Arm\'s Big Adventure',
          category: StepCategory.quest,
          estimatedMinutes: 60),
      CookbookStep(
          id: 'rd10',
          order: 9,
          title: 'Do Desert Treasure quest',
          category: StepCategory.quest,
          estimatedMinutes: 90,
          links: ['https://oldschool.runescape.wiki/w/Desert_Treasure']),
      CookbookStep(
          id: 'rd11',
          order: 10,
          title: 'Finish RFD, buy Barrows Gloves!',
          category: StepCategory.quest,
          estimatedMinutes: 30,
          links: ['https://oldschool.runescape.wiki/w/Recipe_for_Disaster'],
          notes: 'Major milestone — BiS gloves'),
    ],
  );
}

CookbookSection _section20AfterBarrowsGloves() {
  return CookbookSection(
    id: 'oziris_2_0',
    title: '2.0 Goals After Barrows Gloves',
    description:
        'End-game progression: Song of the Elves, Dragon Slayer 2, and Corrupted Gauntlet.',
    order: 5,
    steps: [
      CookbookStep(
          id: 'ag1',
          order: 0,
          title: 'Get autoweed perk from Tithe Farm (if 54 Farming)',
          category: StepCategory.skilling,
          location: 'Tithe Farm'),
      CookbookStep(
          id: 'ag2',
          order: 1,
          title:
              'Start doing Farming Contracts ASAP — use garden pies for medium at 62, hard at 82',
          category: StepCategory.skilling,
          notes: 'Very important!'),
      CookbookStep(
          id: 'ag3',
          order: 2,
          title: 'AFK training option: ammonite crabs with bone cbow or melee',
          category: StepCategory.combat,
          location: 'Fossil Island'),
      CookbookStep(
          id: 'ag4',
          order: 3,
          title: 'Get 61 Crafting, mine sandstone for 1.2k buckets of sand',
          category: StepCategory.skilling,
          location: 'Desert Quarry'),
      CookbookStep(
          id: 'ag5',
          order: 4,
          title:
              'Burn giant seaweed at rogues\' den, make molten glass at Edgeville furnace',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'ag6',
          order: 5,
          title:
              'Blow glass lenses, do seaweed farming for more spores underwater',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'ag7',
          order: 6,
          title: 'Get 70 Mining, do Lunar Diplomacy',
          category: StepCategory.quest,
          estimatedMinutes: 45),
      CookbookStep(
          id: 'ag8',
          order: 7,
          title: 'Get Helm of Neitiznot, Fighter Torso from BA',
          category: StepCategory.combat,
          estimatedMinutes: 180),
      CookbookStep(
          id: 'ag9',
          order: 8,
          title: 'Do Slayer until 65/80/65 melee stats. Get Dragon Defender',
          category: StepCategory.combat,
          estimatedMinutes: 600),
      CookbookStep(
          id: 'ag10',
          order: 9,
          title: 'Train STR priority during slayer (65/80/65 then +5 each)',
          category: StepCategory.combat,
          notes: 'Recommended melee progression'),
      CookbookStep(
          id: 'ag11',
          order: 10,
          title:
              'Slayer point priority: Superior > Blocklist > Extend > Slay Ring > Slay Helm > Garg Smasher',
          category: StepCategory.prep),
      CookbookStep(
          id: 'ag12',
          order: 11,
          title: 'At 58 Slayer: camp Cave Horrors for black mask',
          category: StepCategory.combat,
          location: 'Mos Le\'Harmless'),
      CookbookStep(
          id: 'ag13',
          order: 12,
          title:
              'Do Making Friends with My Arm, build basalt tele portals in POH',
          category: StepCategory.quest,
          estimatedMinutes: 30),
      CookbookStep(
          id: 'ag14',
          order: 13,
          title:
              'Do Fremennik Hard diary (70 Agility), use shortcut for herb runs',
          category: StepCategory.quest),
      CookbookStep(
          id: 'ag15',
          order: 14,
          title: 'Do Dream Mentor, imbue slayer helm',
          category: StepCategory.quest),
      CookbookStep(
          id: 'ag16',
          order: 15,
          title: 'Keep slaying to 75 Slayer. Do Mage Arena 2',
          category: StepCategory.combat),
      CookbookStep(
          id: 'ag17',
          order: 16,
          title: 'Get 77 Herblore (should be banked from farming)',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'ag18',
          order: 17,
          title:
              'Cut + bank 2.2k teak logs at Fossil Island. Do Mahogany Homes for 70 Construction',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'ag19',
          order: 18,
          title: 'Get 60 Range, 70 Smithing, 70 Woodcutting',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'ag20',
          order: 19,
          title: 'Make botanical pies, +4 herblore boost for sara brews',
          category: StepCategory.skilling),
      CookbookStep(
          id: 'ag21',
          order: 20,
          title: 'Do Song of the Elves',
          category: StepCategory.quest,
          estimatedMinutes: 120,
          links: ['https://oldschool.runescape.wiki/w/Song_of_the_Elves'],
          notes: 'Major quest — unlocks Prifddinas'),
      CookbookStep(
          id: 'ag22',
          order: 21,
          title: 'Hunt 15k red chins at Prif hunter area',
          category: StepCategory.skilling,
          estimatedMinutes: 600,
          location: 'Prifddinas'),
      CookbookStep(
          id: 'ag23',
          order: 22,
          title: 'Get Range Void from Pest Control',
          category: StepCategory.combat,
          estimatedMinutes: 300,
          location: 'Pest Control'),
      CookbookStep(
          id: 'ag24',
          order: 23,
          title: 'Unlock MM2 chinning area, chin to 87+ Range',
          category: StepCategory.combat,
          estimatedMinutes: 120),
      CookbookStep(
          id: 'ag25',
          order: 24,
          title: 'Do Dragon Slayer 2',
          category: StepCategory.quest,
          estimatedMinutes: 90,
          links: ['https://oldschool.runescape.wiki/w/Dragon_Slayer_II'],
          notes: 'Unlocks Vorkath + Ava\'s Assembler'),
      CookbookStep(
          id: 'ag26',
          order: 25,
          title: 'Set Kingdom to 10 teaks/mahogany + 5 herbs',
          category: StepCategory.prep,
          location: 'Miscellania'),
      CookbookStep(
          id: 'ag27',
          order: 26,
          title:
              'Camp Corrupted Gauntlet for 2 enhanced weapon seeds + 6 armor seeds',
          category: StepCategory.combat,
          estimatedMinutes: 1200,
          location: 'Prifddinas',
          notes: 'End-game grind — BiS weapons',
          links: ['https://oldschool.runescape.wiki/w/Corrupted_Gauntlet']),
    ],
  );
}

CookbookTemplate _questCapeRoadmap() {
  return CookbookTemplate(
    id: 'quest_cape_roadmap',
    title: 'Quest Cape Roadmap',
    description:
        'High-level roadmap for achieving the Quest Cape. Organized by priority unlocks.',
    mode: CookbookMode.main,
    tags: ['questing', 'quest-cape', 'endgame'],
    version: '1.0',
    author: 'Community',
    sections: [
      CookbookSection(
        id: 'qc_priority',
        title: 'Priority Unlock Quests',
        order: 0,
        steps: [
          CookbookStep(
              id: 'qp1',
              order: 0,
              title: 'Recipe for Disaster (full)',
              description: 'Requires many subquests. Unlock Barrows Gloves.',
              category: StepCategory.quest,
              estimatedMinutes: 300,
              links: [
                'https://oldschool.runescape.wiki/w/Recipe_for_Disaster'
              ]),
          CookbookStep(
              id: 'qp2',
              order: 1,
              title: 'Desert Treasure',
              description: 'Unlock Ancient Magicks.',
              category: StepCategory.quest,
              estimatedMinutes: 60,
              links: ['https://oldschool.runescape.wiki/w/Desert_Treasure']),
          CookbookStep(
              id: 'qp3',
              order: 2,
              title: 'Monkey Madness II',
              description: 'Unlock demonic gorillas, zenyte jewelry.',
              category: StepCategory.quest,
              estimatedMinutes: 90,
              links: ['https://oldschool.runescape.wiki/w/Monkey_Madness_II']),
          CookbookStep(
              id: 'qp4',
              order: 3,
              title: 'Dragon Slayer II',
              description: 'Unlock Vorkath, Ava\'s Assembler.',
              category: StepCategory.quest,
              estimatedMinutes: 90,
              links: ['https://oldschool.runescape.wiki/w/Dragon_Slayer_II']),
          CookbookStep(
              id: 'qp5',
              order: 4,
              title: 'Song of the Elves',
              description: 'Unlock Prifddinas.',
              category: StepCategory.quest,
              estimatedMinutes: 120,
              links: ['https://oldschool.runescape.wiki/w/Song_of_the_Elves']),
          CookbookStep(
              id: 'qp6',
              order: 5,
              title: 'A Night at the Theatre',
              description: 'Unlock ToB story mode completion.',
              category: StepCategory.quest,
              estimatedMinutes: 60),
          CookbookStep(
              id: 'qp7',
              order: 6,
              title: 'Beneath Cursed Sands',
              description: 'Unlock Tombs of Amascut.',
              category: StepCategory.quest,
              estimatedMinutes: 45),
        ],
      ),
      CookbookSection(
        id: 'qc_medium',
        title: 'Mid-Priority Quests',
        order: 1,
        steps: [
          CookbookStep(
              id: 'qm1',
              order: 0,
              title: 'Lunar Diplomacy',
              description:
                  'Lunar spellbook — superglass make, NPC contact, etc.',
              category: StepCategory.quest,
              estimatedMinutes: 45),
          CookbookStep(
              id: 'qm2',
              order: 1,
              title: 'Dream Mentor',
              description: 'Imbue items, NPC Contact spell.',
              category: StepCategory.quest,
              estimatedMinutes: 30),
          CookbookStep(
              id: 'qm3',
              order: 2,
              title: 'King\'s Ransom',
              description: 'Unlock Piety + other prayers via Knight Waves.',
              category: StepCategory.quest,
              estimatedMinutes: 30),
          CookbookStep(
              id: 'qm4',
              order: 3,
              title: 'Regicide + Roving Elves',
              description: 'Elf quest line progression.',
              category: StepCategory.quest,
              estimatedMinutes: 60),
          CookbookStep(
              id: 'qm5',
              order: 4,
              title: 'Sins of the Father',
              description: 'Unlock Darkmeyer and blood shard.',
              category: StepCategory.quest,
              estimatedMinutes: 60),
          CookbookStep(
              id: 'qm6',
              order: 5,
              title: 'Making Friends with My Arm',
              description: 'Disease-free herb patch on Weiss.',
              category: StepCategory.quest,
              estimatedMinutes: 30),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// HCIM Guide — Source: https://ironman.guide/hcim
// ---------------------------------------------------------------------------
CookbookTemplate _hcimGuide() {
  return CookbookTemplate(
    id: 'hcim_guide',
    title: 'Hardcore Ironman Survival Guide',
    description:
        'Safe training methods, dangers to avoid, and survival strategies '
        'for HCIM. One death and your status is gone forever. '
        'Source: ironman.guide/hcim',
    mode: CookbookMode.hcim,
    tags: ['hcim', 'hardcore', 'survival', 'safe-training'],
    version: '1.0',
    author: 'ironman.guide',
    sections: [
      CookbookSection(
        id: 'hcim_priorities',
        title: 'Top Priorities for HCIM',
        description:
            'The most important things to do first on a Hardcore Ironman.',
        order: 0,
        steps: [
          CookbookStep(
              id: 'hp1',
              order: 0,
              title: '43 Prayer ASAP',
              description:
                  'Protection prayers are your lifeline. Prioritize blue dragon bones at Taverley dungeon (safe with Iban Blast).',
              category: StepCategory.combat,
              estimatedMinutes: 120,
              location: 'Taverley Dungeon'),
          CookbookStep(
              id: 'hp2',
              order: 1,
              title: 'Ring of Life',
              description:
                  'Always wear one when doing any risky content. Craft them yourself or buy from GE after completing easy diaries.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hp3',
              order: 2,
              title: 'Emergency Teleports',
              description:
                  'Keep teleport tabs in your inventory at all times. Royal seed pod (from MM2) is instant and works up to level 30 wilderness.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hp4',
              order: 3,
              title: 'Use XP Lamps on Prayer',
              description:
                  'After 77 Herblore, put all lamps and books into Prayer to minimize dangerous bone grinding.',
              category: StepCategory.prep),
        ],
      ),
      CookbookSection(
        id: 'hcim_dangers',
        title: 'Dangers to Avoid',
        description: 'High-risk activities and common death causes for HCIM.',
        order: 1,
        steps: [
          CookbookStep(
              id: 'hd1',
              order: 0,
              title: 'AVOID: Wilderness content',
              description:
                  'PKers and multi-combat zones. Never risk your status here.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd2',
              order: 1,
              title: 'AVOID: Fight Caves before proper gear',
              description:
                  'Jad can easily kill you if you\'re not prepared. Wait for good ranged stats and gear.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd3',
              order: 2,
              title: 'AVOID: Demonic Gorillas unprepared',
              description:
                  'High damage output. Only attempt with proper stats and protection prayers.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd4',
              order: 3,
              title: 'WATCH: Disconnections during combat',
              description:
                  'The #1 HCIM killer. Use safe spots when possible, avoid AFK in dangerous areas.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd5',
              order: 4,
              title: 'WATCH: Forgetting to restore prayer',
              description:
                  'Always monitor prayer points. Keep prayer pots in inventory for risky content.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd6',
              order: 5,
              title: 'WATCH: Misclicking into multi-combat',
              description:
                  'Be very careful around multi zones. One misclick can stack damage and kill you.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd7',
              order: 6,
              title: 'WATCH: Poison/venom without antipoison',
              description:
                  'Always carry antipoison when doing content with poisonous monsters.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'hd8',
              order: 7,
              title: 'WATCH: Aggressive NPCs while AFKing',
              description:
                  'Never AFK in areas with aggressive monsters. Use Sand/Ammonite Crabs for safe AFK.',
              category: StepCategory.prep),
        ],
      ),
      CookbookSection(
        id: 'hcim_safe_combat',
        title: 'Safe Combat Training',
        description: 'Low-risk combat methods that protect your HCIM status.',
        order: 2,
        steps: [
          CookbookStep(
              id: 'hsc1',
              order: 0,
              title: 'Sand Crabs / Ammonite Crabs',
              description: 'AFK, no risk. Best safe combat training for HCIM.',
              category: StepCategory.combat,
              location: 'Hosidius / Fossil Island'),
          CookbookStep(
              id: 'hsc2',
              order: 1,
              title: 'Slayer with protection prayers active',
              description:
                  'Always pray when on Slayer tasks. Never trust monsters not to hit hard.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'hsc3',
              order: 2,
              title: 'Nightmare Zone (safe deaths)',
              description:
                  'After unlocking enough quest bosses, NMZ is a safe death minigame for combat XP.',
              category: StepCategory.combat,
              location: 'NMZ'),
          CookbookStep(
              id: 'hsc4',
              order: 3,
              title: 'Pest Control (safe minigame)',
              description:
                  'Good for ranged training. No risk of losing HCIM status.',
              category: StepCategory.combat,
              location: 'Pest Control'),
        ],
      ),
      CookbookSection(
        id: 'hcim_safe_prayer',
        title: 'Safe Prayer Training',
        description: 'Methods to train Prayer with minimal risk.',
        order: 3,
        steps: [
          CookbookStep(
              id: 'hsp1',
              order: 0,
              title: 'Blue dragons in Taverley Dungeon',
              description:
                  'Safespot with magic. The standard HCIM prayer training method.',
              category: StepCategory.combat,
              location: 'Taverley Dungeon'),
          CookbookStep(
              id: 'hsp2',
              order: 1,
              title: 'Green dragons with anti-dragon shield',
              description:
                  'Lower risk than wilderness green dragons. Use shield and protection prayers.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'hsp3',
              order: 2,
              title: 'Ensouled heads with Arceuus spellbook',
              description:
                  'Safe and efficient. Collect heads during Slayer tasks.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'hsp4',
              order: 3,
              title: 'Forthos Dungeon red dragons',
              description: 'Safespottable red dragons in Forthos Dungeon.',
              category: StepCategory.combat,
              location: 'Forthos Dungeon'),
        ],
      ),
      CookbookSection(
        id: 'hcim_safe_skilling',
        title: 'Safe Skilling Methods',
        description: 'Skilling methods with minimal death risk.',
        order: 4,
        steps: [
          CookbookStep(
              id: 'hss1',
              order: 0,
              title: 'Wintertodt at 10 HP',
              description:
                  'Minimal damage taken at low HP. Do this very early before HP levels up.',
              category: StepCategory.skilling,
              location: 'Wintertodt'),
          CookbookStep(
              id: 'hss2',
              order: 1,
              title: 'Tempoross (safe fishing boss)',
              description:
                  'Safe fishing boss minigame. Good rewards, no death risk.',
              category: StepCategory.skilling,
              location: 'Tempoross'),
          CookbookStep(
              id: 'hss3',
              order: 2,
              title: 'Rooftop agility courses',
              description:
                  'Low risk agility training. Marks of grace for graceful outfit.',
              category: StepCategory.skilling),
          CookbookStep(
              id: 'hss4',
              order: 3,
              title: 'Hallowed Sepulchre after practice',
              description:
                  'Higher agility training once comfortable. Practice first to learn the mechanics.',
              category: StepCategory.skilling,
              location: 'Darkmeyer'),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// UIM Guide — Source: https://ironman.guide/uim
// ---------------------------------------------------------------------------
CookbookTemplate _uimGuide() {
  return CookbookTemplate(
    id: 'uim_guide',
    title: 'Ultimate Ironman Strategy Guide',
    description:
        'Inventory management, death storage, and bankless gameplay strategies. '
        'Without bank access, you must manage 28 inventory slots creatively. '
        'Source: ironman.guide/uim',
    mode: CookbookMode.uim,
    tags: ['uim', 'ultimate', 'inventory', 'storage', 'bankless'],
    version: '1.0',
    author: 'ironman.guide',
    sections: [
      CookbookSection(
        id: 'uim_storage',
        title: 'Storage Solutions',
        description:
            'Essential storage methods for UIM — looting bag, death storage, STASH units, and more.',
        order: 0,
        steps: [
          CookbookStep(
              id: 'us1',
              order: 0,
              title: 'Get Looting Bag (Essential)',
              description:
                  'Obtain from wilderness NPCs (guaranteed at 60 kills). Stores 28 additional items. Only deposit in wilderness, withdraw anywhere by destroying. Keep multiple bags.',
              category: StepCategory.prep,
              location: 'Wilderness'),
          CookbookStep(
              id: 'us2',
              order: 1,
              title: 'Zulrah death storage',
              description:
                  'Items stored on death at Zulrah (1 hour timer). Commonly used for temporary storage.',
              category: StepCategory.prep,
              location: 'Zulrah',
              links: ['https://oldschool.runescape.wiki/w/Zulrah']),
          CookbookStep(
              id: 'us3',
              order: 2,
              title: 'Hespori death storage',
              description:
                  'Safe death, items stored until claimed. Good passive storage.',
              category: StepCategory.prep,
              location: 'Farming Guild'),
          CookbookStep(
              id: 'us4',
              order: 3,
              title: 'Vorkath death storage',
              description: 'Items stored on death at Vorkath.',
              category: StepCategory.prep,
              location: 'Vorkath'),
          CookbookStep(
              id: 'us5',
              order: 4,
              title: 'Theatre of Blood entry mode',
              description: 'Safe death storage for ToB entry mode.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'us6',
              order: 5,
              title: 'Corrupted Gauntlet death storage',
              description: 'Safe death — items stored until claimed.',
              category: StepCategory.prep,
              location: 'Prifddinas'),
          CookbookStep(
              id: 'us7',
              order: 6,
              title: 'Build STASH units early',
              description:
                  'Store clue scroll items in STASH units. Every item stored frees an inventory slot for future clues.',
              category: StepCategory.skilling),
          CookbookStep(
              id: 'us8',
              order: 7,
              title: 'Seed Vault at Farming Guild',
              description: 'Store seeds only. Unlocked at 45 Farming.',
              category: StepCategory.skilling,
              location: 'Farming Guild'),
          CookbookStep(
              id: 'us9',
              order: 8,
              title: 'POH storage (costume room, armor case)',
              description:
                  'Build costume room and armor case in your POH for permanent storage.',
              category: StepCategory.skilling),
          CookbookStep(
              id: 'us10',
              order: 9,
              title: 'NMZ coffer for GP storage',
              description: 'Store GP in the Nightmare Zone coffer.',
              category: StepCategory.prep,
              location: 'NMZ'),
        ],
      ),
      CookbookSection(
        id: 'uim_inventory',
        title: 'Inventory Management Tips',
        description: 'How to manage your 28 slots effectively.',
        order: 1,
        steps: [
          CookbookStep(
              id: 'ui1',
              order: 0,
              title: 'Plan ahead before every activity',
              description:
                  'Before any activity, plan what items you need and what you can drop or store. Impulsive decisions lead to lost items.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ui2',
              order: 1,
              title: 'Prioritize multitasking items',
              description:
                  'Items like graceful, construction supplies, and teleports that serve multiple purposes.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ui3',
              order: 2,
              title: 'Quest efficiently — do quest chains together',
              description:
                  'Complete quest chains together to minimize bank trips and maximize inventory usage.',
              category: StepCategory.quest),
          CookbookStep(
              id: 'ui4',
              order: 3,
              title: 'Use noted items wisely',
              description:
                  'Shops that buy/sell noted items are valuable for converting stackable resources.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ui5',
              order: 4,
              title: 'Build STASH units early',
              description:
                  'Every clue item stored is an inventory slot saved for future clue scrolls.',
              category: StepCategory.skilling),
        ],
      ),
      CookbookSection(
        id: 'uim_early',
        title: 'UIM Early Game Priorities',
        description: 'First week goals and essential items to always carry.',
        order: 2,
        steps: [
          CookbookStep(
              id: 'ue1',
              order: 0,
              title: 'Get looting bag from wilderness',
              description:
                  'Priority #1. Kill wilderness NPCs until you get it (guaranteed at 60 kills).',
              category: StepCategory.prep,
              location: 'Wilderness'),
          CookbookStep(
              id: 'ue2',
              order: 1,
              title: 'Complete Priest in Peril for Morytania',
              description:
                  'Unlock Morytania access early for Canifis rooftop agility and Barrows.',
              category: StepCategory.quest),
          CookbookStep(
              id: 'ue3',
              order: 2,
              title: 'Build basic POH (portal, costume room)',
              description:
                  'Construction is essential for UIM. Costume room stores gear permanently.',
              category: StepCategory.skilling),
          CookbookStep(
              id: 'ue4',
              order: 3,
              title: 'Unlock fairy rings',
              description:
                  'Critical transportation — saves inventory slots on teleport items.',
              category: StepCategory.quest),
          CookbookStep(
              id: 'ue5',
              order: 4,
              title: 'Start building STASH units',
              description:
                  'Build them as you encounter clue locations. Long-term investment.',
              category: StepCategory.skilling),
        ],
      ),
      CookbookSection(
        id: 'uim_essentials',
        title: 'Essential Items to Always Carry',
        description: 'Items that should always be in your inventory or worn.',
        order: 3,
        steps: [
          CookbookStep(
              id: 'uk1',
              order: 0,
              title: 'Graceful outfit (always wear)',
              description:
                  'Run energy restoration is critical for UIM who walk everywhere.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'uk2',
              order: 1,
              title: 'Dramen staff (fairy rings)',
              description: 'Essential for fairy ring transportation.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'uk3',
              order: 2,
              title: 'Teleport jewelry/runes',
              description: 'Always carry some form of teleportation.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'uk4',
              order: 3,
              title: 'Construction supplies',
              description:
                  'Always carry some planks/nails for building storage when needed.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'uk5',
              order: 4,
              title: 'Looting bags (2-3 minimum)',
              description: 'Always have backup looting bags in your inventory.',
              category: StepCategory.prep),
        ],
      ),
      CookbookSection(
        id: 'uim_death',
        title: 'Death Mechanics for UIM',
        description: 'Understanding safe vs dangerous deaths is crucial.',
        order: 4,
        steps: [
          CookbookStep(
              id: 'ud1',
              order: 0,
              title: 'SAFE: Zulrah, Vorkath, Hespori, Gauntlet',
              description:
                  'Items stored on death. Can be reclaimed. Use for strategic storage.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ud2',
              order: 1,
              title: 'SAFE: ToB Entry, NMZ, Pest Control',
              description: 'Safe death minigames — no items lost.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ud3',
              order: 2,
              title: 'DANGEROUS: Wilderness (lost to PKer)',
              description:
                  'Items lost to PKer. Never bring anything you can\'t afford to lose.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ud4',
              order: 3,
              title: 'DANGEROUS: Regular overworld, some quest bosses',
              description:
                  'Items dropped on the ground with a timer. Very risky.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ud5',
              order: 4,
              title: 'Always verify death mechanics before new content',
              description:
                  'Mechanics can change with updates. Check the wiki before attempting new bosses.',
              category: StepCategory.prep,
              notes: 'Critical for UIM survival'),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// GIM Guide — Source: https://ironman.guide/gim
// ---------------------------------------------------------------------------
CookbookTemplate _gimGuide() {
  return CookbookTemplate(
    id: 'gim_guide',
    title: 'Group Ironman Team Strategy Guide',
    description:
        'Team coordination, role splitting, shared storage optimization, '
        'and GIM-specific features. 2-5 players sharing a group storage. '
        'Source: ironman.guide/gim',
    mode: CookbookMode.gim,
    tags: ['gim', 'group', 'team', 'coordination', 'roles'],
    version: '1.0',
    author: 'ironman.guide',
    sections: [
      CookbookSection(
        id: 'gim_roles',
        title: 'Role Splitting Guide',
        description:
            'Divide responsibilities among team members for maximum efficiency.',
        order: 0,
        steps: [
          CookbookStep(
              id: 'gr1',
              order: 0,
              title: 'Resource Gatherer — Mining, Smithing, Crafting',
              description:
                  'Provides gear and supplies to group. Blast Furnace specialist. Gem mining for jewelry.',
              category: StepCategory.skilling),
          CookbookStep(
              id: 'gr2',
              order: 1,
              title: 'PvM Specialist — Combat and Slayer',
              description:
                  'Boss farming for uniques. Provides drops to group. Raids when ready.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'gr3',
              order: 2,
              title: 'Skiller Support — Herblore and Farming',
              description:
                  'Provides potions for PvM. Manages herb runs for group. Cooking and food prep.',
              category: StepCategory.skilling),
          CookbookStep(
              id: 'gr4',
              order: 3,
              title: 'Quest/Diary Specialist',
              description:
                  'Prioritizes quest unlocks and achievement diaries. Unlocks teleports and areas. Fairy rings and spirit trees early.',
              category: StepCategory.quest),
        ],
      ),
      CookbookSection(
        id: 'gim_storage',
        title: 'Shared Storage Optimization',
        description: 'Making the most of your 80-slot shared storage.',
        order: 1,
        steps: [
          CookbookStep(
              id: 'gs1',
              order: 0,
              title: 'Prioritize shared items',
              description:
                  'Store items that benefit multiple members: teleport jewelry, runes, potions, and food.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'gs2',
              order: 1,
              title: 'Coordinate deposits',
              description:
                  'Communicate before depositing large stacks. 80 slots fills up fast with poor planning.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'gs3',
              order: 2,
              title: 'Use for trading safely',
              description:
                  'Drop trades are allowed, but shared storage is safer and faster for transferring items.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'gs4',
              order: 3,
              title: 'Keep supplies stocked',
              description:
                  'Designate someone to keep food, potions, and commonly needed items always available.',
              category: StepCategory.prep),
        ],
      ),
      CookbookSection(
        id: 'gim_early_coord',
        title: 'Early Game Coordination',
        description: 'How to start efficiently as a group.',
        order: 2,
        steps: [
          CookbookStep(
              id: 'ge1',
              order: 0,
              title: 'One person rushes quests, others skill',
              description:
                  'Split early game — quester unlocks teleports/fairy rings while others gather resources.',
              category: StepCategory.quest),
          CookbookStep(
              id: 'ge2',
              order: 1,
              title: 'Share early teleport jewelry',
              description:
                  'Whoever gets crafting up first shares rings of dueling, games necklaces, etc.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'ge3',
              order: 2,
              title: 'Coordinate Wintertodt as a group',
              description:
                  'Great early group activity. Everyone gets supplies and firemaking XP.',
              category: StepCategory.skilling,
              location: 'Wintertodt'),
          CookbookStep(
              id: 'ge4',
              order: 3,
              title: 'Split up achievement diaries',
              description:
                  'Each member focuses on different diary regions for efficient completion.',
              category: StepCategory.quest),
        ],
      ),
      CookbookSection(
        id: 'gim_mid_late',
        title: 'Mid/Late Game Team Play',
        description: 'Coordination for bossing and endgame content.',
        order: 3,
        steps: [
          CookbookStep(
              id: 'gm1',
              order: 0,
              title: 'Team bossing for faster kills',
              description:
                  'Coordinate boss trips together. Duo/trio bosses are much faster than solo.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'gm2',
              order: 1,
              title: 'Share rare drops fairly',
              description:
                  'Discuss drop distribution — based on need or predetermined rules.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'gm3',
              order: 2,
              title: 'Coordinate Raids learner runs',
              description:
                  'Learn CoX and ToB together as a group. Much easier to learn with a team.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'gm4',
              order: 3,
              title: 'Help carry newer members',
              description:
                  'If some members are behind, help them through content with higher-level support.',
              category: StepCategory.combat),
        ],
      ),
      CookbookSection(
        id: 'gim_features',
        title: 'GIM-Specific Features',
        description: 'Prestige, hardcore mode, and group hiscores.',
        order: 4,
        steps: [
          CookbookStep(
              id: 'gf1',
              order: 0,
              title: 'Prestige System',
              description:
                  'Groups start with full prestige. Leaving or adding members affects prestige level and hiscores visibility. Consider carefully before making group changes.',
              category: StepCategory.prep),
          CookbookStep(
              id: 'gf2',
              order: 1,
              title: 'Hardcore Group Ironman option',
              description:
                  'Optional hardcore mode. Group loses HCGIM status after a set number of deaths based on group size. Extra challenging!',
              category: StepCategory.prep),
          CookbookStep(
              id: 'gf3',
              order: 2,
              title: 'Group Hiscores',
              description:
                  'Track your group\'s total level and compete against other GIM groups. Coordinate leveling for hiscores rankings.',
              category: StepCategory.prep),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Boss Order Guide — Source: https://ironman.guide/bosses
// ---------------------------------------------------------------------------
CookbookTemplate _bossOrderGuide() {
  return CookbookTemplate(
    id: 'boss_order_guide',
    title: 'Ironman Boss Order Guide',
    description: 'Recommended boss progression from Barrows through Inferno. '
        'Priority drops and tips for each boss. '
        'Source: ironman.guide/bosses',
    mode: CookbookMode.iron,
    tags: ['bosses', 'pvm', 'progression', 'drops', 'endgame'],
    version: '1.0',
    author: 'ironman.guide',
    sections: [
      CookbookSection(
        id: 'boss_early',
        title: 'Early Game Bosses (Combat 3-70)',
        description:
            'First bosses to tackle. Focus on quest rewards and safespottable content.',
        order: 0,
        steps: [
          CookbookStep(
              id: 'be1',
              order: 0,
              title: 'Barrows',
              description:
                  'Excellent early rune supply and magic armour. Twinflame Staff makes this efficient. Do 50-100 chests for rune supply and Ahrim\'s pieces.',
              category: StepCategory.combat,
              location: 'Barrows',
              links: ['https://oldschool.runescape.wiki/w/Barrows']),
          CookbookStep(
              id: 'be2',
              order: 1,
              title: 'Dagannoth Rex',
              description:
                  'Camp Rex only (safespot with magic). Imbue Berserker Ring at Soul Wars or NMZ for +8 strength. Do on Dagannoth task.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Dagannoth_Rex']),
          CookbookStep(
              id: 'be3',
              order: 2,
              title: 'Blue Moon',
              description:
                  'Priority from Moons of Peril. Blue Moon magic armour provides +30 magic attack (body) needed for Royal Titans. Farm full set first.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Blue_Moon']),
          CookbookStep(
              id: 'be4',
              order: 3,
              title: 'Blood Moon',
              description:
                  'Blood Moon melee set has Bloodrager set effect with Dual Macuahuitl. Strong for Slayer. Return with Bowfa after CG for faster kills.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Blood_Moon']),
          CookbookStep(
              id: 'be5',
              order: 4,
              title: 'Royal Titans',
              description:
                  'Do BEFORE Corrupted Gauntlet! Deadeye (+18% ranged) and Mystic Vigour (+18% magic) are permanent prayer upgrades. Crown drops combine into Twinflame Staff.',
              category: StepCategory.combat,
              notes: 'Critical before CG',
              links: ['https://oldschool.runescape.wiki/w/Royal_Titans']),
          CookbookStep(
              id: 'be6',
              order: 5,
              title: 'TzTok-Jad (Fight Caves)',
              description:
                  'Major ironman milestone. Practice prayer flicking. With Deadeye prayer and decent ranged gear this is achievable.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/TzTok-Jad']),
        ],
      ),
      CookbookSection(
        id: 'boss_mid',
        title: 'Mid Game Bosses (Combat 70-90)',
        description:
            'Post-Barrows Gloves through Corrupted Gauntlet. Major upgrades from Slayer and quests.',
        order: 1,
        steps: [
          CookbookStep(
              id: 'bm1',
              order: 0,
              title: 'Corrupted Gauntlet',
              description:
                  'THE defining mid-game grind. Bowfa + Crystal armour is strongest ranged setup until Masori. Deadeye from Royal Titans helps significantly. Expect 100-400+ KC.',
              category: StepCategory.combat,
              location: 'Prifddinas',
              links: ['https://oldschool.runescape.wiki/w/Corrupted_Gauntlet']),
          CookbookStep(
              id: 'bm2',
              order: 1,
              title: 'Zulrah',
              description:
                  'Farm for blowpipe and magic fang. Bowfa makes Zulrah very consistent. Blowpipe still great for Slayer.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Zulrah']),
          CookbookStep(
              id: 'bm3',
              order: 2,
              title: 'Vorkath',
              description:
                  'Guaranteed head at 50 KC. Excellent consistent money maker. Bowfa or Fang both work. One of the best GP/hr for ironmen.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Vorkath']),
          CookbookStep(
              id: 'bm4',
              order: 3,
              title: 'Demonic Gorillas',
              description:
                  'Need 4 zenyte shards for all jewelry pieces. Requires 93/98 Crafting. Bowfa + melee switch. Expect 300-600 KC per shard.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Demonic_gorilla']),
          CookbookStep(
              id: 'bm5',
              order: 4,
              title: 'Phantom Muspah',
              description:
                  'Bowfa very effective. Ancient Sceptre useful for Ancient Magicks content. Good rune and resource drops.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Phantom_Muspah']),
          CookbookStep(
              id: 'bm6',
              order: 5,
              title: 'Kraken',
              description:
                  'Easy AFK Slayer boss. Get tentacle for Abyssal Tentacle upgrade. Trident drops too.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Kraken']),
          CookbookStep(
              id: 'bm7',
              order: 6,
              title: 'General Graardor (Bandos)',
              description:
                  'BCP + Tassets are core melee armour. Fang or Bowfa both work. BGS spec useful for bossing until DWH.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/General_Graardor']),
          CookbookStep(
              id: 'bm8',
              order: 7,
              title: 'Kree\'arra (Armadyl)',
              description:
                  'Armadyl pieces needed to fortify Masori from ToA. Bowfa with Crystal makes this soloable. Priority after Masori unfortified.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Kree%27arra']),
          CookbookStep(
              id: 'bm9',
              order: 8,
              title: 'Tombs of Amascut',
              description:
                  'Most ironman-friendly raid with scalable difficulty. Start entry mode, push to 150+. Fang and Lightbearer are priority drops. Soloable.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Tombs_of_Amascut']),
        ],
      ),
      CookbookSection(
        id: 'boss_late',
        title: 'Late Game Bosses (Combat 90-100)',
        description: 'DT2 bosses, Slayer bosses, Raids, and endgame content.',
        order: 2,
        steps: [
          CookbookStep(
              id: 'bl1',
              order: 0,
              title: 'Vardorvis (DT2 — do first)',
              description:
                  'Easiest DT2 boss. Ultor Ring (BIS melee ring +12 str) and Soulreaper Axe (highest str weapon). Fang very effective.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Vardorvis']),
          CookbookStep(
              id: 'bl2',
              order: 1,
              title: 'The Leviathan (DT2)',
              description:
                  'Venator Ring BIS ranged ring (+10 ranged accuracy). Lower priority than Vardorvis.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/The_Leviathan']),
          CookbookStep(
              id: 'bl3',
              order: 2,
              title: 'The Whisperer (DT2 — hardest)',
              description:
                  'Magus Ring BIS magic ring (+8 magic, +2% damage). Tumeken\'s Shadow ideal here.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/The_Whisperer']),
          CookbookStep(
              id: 'bl4',
              order: 3,
              title: 'Duke Sucellus (DT2)',
              description:
                  'Bellator Ring melee accuracy ring. Lower priority than Ultor. Farm chromium ingots from any DT2 boss.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Duke_Sucellus']),
          CookbookStep(
              id: 'bl5',
              order: 4,
              title: 'Cerberus',
              description:
                  'Three crystals for BIS boots in each style. Primordial is priority. Must be on Hellhound/Cerberus task.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Cerberus']),
          CookbookStep(
              id: 'bl6',
              order: 5,
              title: 'Alchemical Hydra',
              description:
                  'DHL BIS against dragons. Ferocious Gloves BIS melee gloves. Consistent GP. Very rewarding Slayer boss.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Alchemical_Hydra']),
          CookbookStep(
              id: 'bl7',
              order: 6,
              title: 'Thermonuclear Smoke Devil',
              description:
                  'Occult Necklace (+10% magic damage) BIS magic necklace. Very easy boss. Done on Smoke Devil tasks.',
              category: StepCategory.combat,
              links: [
                'https://oldschool.runescape.wiki/w/Thermonuclear_smoke_devil'
              ]),
          CookbookStep(
              id: 'bl8',
              order: 7,
              title: 'Tormented Demons',
              description:
                  'Dragon Claws spec one of the best. Purging Staff strong magic weapon. Requires gear switches. Post-WGS.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Tormented_demon']),
          CookbookStep(
              id: 'bl9',
              order: 8,
              title: 'Nex',
              description:
                  'Torva BIS melee armour. Best in masses. Zaryte Crossbow enhances bolt procs. Zaryte Vambraces BIS ranged gloves.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Nex']),
          CookbookStep(
              id: 'bl10',
              order: 9,
              title: 'Chambers of Xeric',
              description:
                  'Rigour + Augury prayers massive upgrades (replace Deadeye/Mystic Vigour). Twisted Bow most powerful ranged weapon. Learn in trios.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Chambers_of_Xeric']),
          CookbookStep(
              id: 'bl11',
              order: 10,
              title: 'Theatre of Blood',
              description:
                  'Scythe hits 3x on large monsters — BIS for many bosses. Rapier BIS stab. Sanguinesti heals on hit. Expensive to learn.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Theatre_of_Blood']),
          CookbookStep(
              id: 'bl12',
              order: 11,
              title: 'Corporeal Beast',
              description:
                  'Arcane Sigil needed to fortify Elidinis\' Ward. Solo by speccing down stats. Very long grind (1/585 sigils). Only when you have Ward drop.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Corporeal_Beast']),
        ],
      ),
      CookbookSection(
        id: 'boss_endgame',
        title: 'Endgame Bosses (Combat 100+)',
        description: 'The hardest PvM challenges in OSRS.',
        order: 3,
        steps: [
          CookbookStep(
              id: 'bg1',
              order: 0,
              title: 'Fortis Colosseum',
              description:
                  'Wave-based combat. Sol Heredit final boss. Near-endgame gear required. Dizana\'s Quiver BIS ranged ammo slot.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Fortis_Colosseum']),
          CookbookStep(
              id: 'bg2',
              order: 1,
              title: 'Yama',
              description:
                  '2025 boss. Oathplate slash-focused endgame melee armour. Surge potions (25% spec per dose) essential for high-level PvM. Duo recommended.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Yama']),
          CookbookStep(
              id: 'bg3',
              order: 2,
              title: 'Doom of Mokhaiotl',
              description:
                  'Endgame delve content. Eye of Ayak fastest powered staff (3-tick, 83 Magic). Avernic Treads multi-style endgame boots. Scale levels for better drops.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Doom_of_Mokhaiotl']),
          CookbookStep(
              id: 'bg4',
              order: 3,
              title: 'TzKal-Zuk (Inferno)',
              description:
                  'The hardest PvM challenge in OSRS. BIS melee cape. Requires mastery of prayer flicking, wave management, and Zuk fight. Tbow or Bowfa + ACB setup.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/TzKal-Zuk']),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Gear Progression Guide — Source: https://ironman.guide/gear
// ---------------------------------------------------------------------------
CookbookTemplate _gearProgressionGuide() {
  return CookbookTemplate(
    id: 'gear_progression_guide',
    title: 'Ironman Gear Progression Guide',
    description: 'Complete ironman gear guide from early game through endgame. '
        'Recommended loadouts and upgrade paths for every combat tier. '
        'Source: ironman.guide/gear',
    mode: CookbookMode.iron,
    tags: ['gear', 'progression', 'upgrades', 'equipment', 'loadouts'],
    version: '1.0',
    author: 'ironman.guide',
    sections: [
      CookbookSection(
        id: 'gear_early',
        title: 'Early Game Gear (Combat 3-70)',
        description:
            'Starting gear through Barrows Gloves. Focus on quest rewards and easily obtainable upgrades.',
        order: 0,
        steps: [
          CookbookStep(
              id: 'gre1',
              order: 0,
              title: 'Melee: Rune Scimitar → Dragon Scimitar',
              description:
                  'Rune scimitar from fire giants/zamorak warrior. Dragon scimitar after Monkey Madness.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Dragon_scimitar']),
          CookbookStep(
              id: 'gre2',
              order: 1,
              title: 'Ranged: Dorgeshuun Crossbow → Magic Shortbow (i)',
              description:
                  'Dorg cbow from Death to Dorgeshuun. MSB(i) with rune arrows for mid-range.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'gre3',
              order: 2,
              title: 'Magic: Iban\'s Blast (upgraded staff)',
              description:
                  'Iban\'s Blast from Underground Pass. Upgrade the staff for 2500 charges.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Iban%27s_staff']),
          CookbookStep(
              id: 'gre4',
              order: 3,
              title: 'Armour: Proselyte → Fighter Torso + Rune/Barrows',
              description:
                  'Proselyte for prayer. Fighter Torso from BA. Rune platelegs until Barrows.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'gre5',
              order: 4,
              title: 'Gloves: Barrows Gloves (from RFD)',
              description:
                  'BIS gloves for most of the game. Major milestone to work toward.',
              category: StepCategory.quest,
              links: ['https://oldschool.runescape.wiki/w/Barrows_gloves']),
          CookbookStep(
              id: 'gre6',
              order: 5,
              title: 'Cape: Fire Cape (from Fight Caves)',
              description:
                  'BIS melee cape until Inferno. Major ironman milestone.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Fire_cape']),
          CookbookStep(
              id: 'gre7',
              order: 6,
              title: 'Ring: Berserker Ring (i) from Dagannoth Rex',
              description: 'Imbue at NMZ or Soul Wars. +8 melee strength.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Berserker_ring_(i)']),
          CookbookStep(
              id: 'gre8',
              order: 7,
              title: 'Necklace: Amulet of Glory → Fury',
              description:
                  'Glory is fine until you can craft a Fury (requires 85 Crafting + onyx).',
              category: StepCategory.skilling),
        ],
      ),
      CookbookSection(
        id: 'gear_mid',
        title: 'Mid Game Gear (Combat 70-90)',
        description:
            'Post-Barrows Gloves through Corrupted Gauntlet. Major Slayer and quest upgrades.',
        order: 1,
        steps: [
          CookbookStep(
              id: 'grm1',
              order: 0,
              title: 'Melee: Abyssal Whip → Blade of Saeldor',
              description:
                  'Whip from abyssal demons (85 Slayer). Blade of Saeldor from CG.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Blade_of_saeldor']),
          CookbookStep(
              id: 'grm2',
              order: 1,
              title: 'Ranged: Bow of Faerdhinen (Bowfa)',
              description:
                  'THE ironman ranged weapon. From Corrupted Gauntlet. With Crystal armour it\'s BIS until Tbow.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Bow_of_faerdhinen']),
          CookbookStep(
              id: 'grm3',
              order: 2,
              title: 'Magic: Trident of the Swamp → Tumeken\'s Shadow',
              description:
                  'Trident from Kraken. Tumeken\'s Shadow from ToA (endgame magic weapon).',
              category: StepCategory.combat),
          CookbookStep(
              id: 'grm4',
              order: 3,
              title: 'Armour: Crystal Armour (CG) + Barrows sets',
              description:
                  'Crystal armour essential for Bowfa. Barrows for Slayer (Karil\'s, Ahrim\'s).',
              category: StepCategory.combat),
          CookbookStep(
              id: 'grm5',
              order: 4,
              title: 'Slayer Helm (i)',
              description:
                  'Imbue at NMZ or Soul Wars. 15% damage + accuracy on task. Core Slayer item.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Slayer_helmet_(i)']),
          CookbookStep(
              id: 'grm6',
              order: 5,
              title: 'Dragon Defender',
              description:
                  'From Warriors\' Guild. BIS melee offhand until Avernic.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Dragon_defender']),
          CookbookStep(
              id: 'grm7',
              order: 6,
              title: 'Helm of Neitiznot → Nezzy Faceguard',
              description:
                  'Neitiznot from Fremennik quests. Faceguard upgrade from Basilisk Knights (60 Slayer).',
              category: StepCategory.combat),
        ],
      ),
      CookbookSection(
        id: 'gear_late',
        title: 'Late Game Gear (Combat 90-100)',
        description: 'Raids and DT2 upgrades. BIS items from endgame content.',
        order: 2,
        steps: [
          CookbookStep(
              id: 'grl1',
              order: 0,
              title: 'Osmumten\'s Fang (ToA)',
              description:
                  'BIS stab weapon. Incredible accuracy mechanic. From Tombs of Amascut.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Osmumten%27s_fang']),
          CookbookStep(
              id: 'grl2',
              order: 1,
              title: 'Soulreaper Axe (Vardorvis)',
              description:
                  'Highest strength weapon in game. From Vardorvis DT2 boss.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Soulreaper_axe']),
          CookbookStep(
              id: 'grl3',
              order: 2,
              title: 'DT2 Rings: Ultor → Venator → Magus → Bellator',
              description:
                  'BIS rings from DT2 bosses. Priority: Ultor (melee str), then based on needs.',
              category: StepCategory.combat),
          CookbookStep(
              id: 'grl4',
              order: 3,
              title: 'Bandos (BCP + Tassets)',
              description:
                  'Core melee armour from General Graardor. Major upgrade over Barrows/Fighter Torso.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Bandos_chestplate']),
          CookbookStep(
              id: 'grl5',
              order: 4,
              title: 'Masori Armour (ToA + Armadyl)',
              description:
                  'BIS ranged armour. Unfortified from ToA, fortified with Armadyl pieces.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Masori_armour']),
          CookbookStep(
              id: 'grl6',
              order: 5,
              title: 'Primordial Boots (Cerberus)',
              description:
                  'BIS melee boots. From Cerberus crystal + dragon boots.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Primordial_boots']),
          CookbookStep(
              id: 'grl7',
              order: 6,
              title: 'Ferocious Gloves (Hydra)',
              description: 'BIS melee gloves. From Alchemical Hydra leather.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Ferocious_gloves']),
          CookbookStep(
              id: 'grl8',
              order: 7,
              title: 'Zenyte Jewelry (Demonic Gorillas)',
              description:
                  'Torture, Anguish, Tormented Bracelet, Ring of Suffering. 4 zenyte shards needed.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Zenyte_jewellery']),
        ],
      ),
      CookbookSection(
        id: 'gear_endgame',
        title: 'Endgame Gear (Combat 100+)',
        description: 'Final upgrades from raids and endgame bosses.',
        order: 3,
        steps: [
          CookbookStep(
              id: 'grg1',
              order: 0,
              title: 'Twisted Bow (CoX)',
              description:
                  'Most powerful ranged weapon. Scales with target magic level. From Chambers of Xeric.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Twisted_bow']),
          CookbookStep(
              id: 'grg2',
              order: 1,
              title: 'Scythe of Vitur (ToB)',
              description:
                  'Hits 3 times on large monsters. BIS for many bosses. From Theatre of Blood.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Scythe_of_vitur']),
          CookbookStep(
              id: 'grg3',
              order: 2,
              title: 'Tumeken\'s Shadow (ToA)',
              description:
                  'BIS magic weapon. 3x magic damage and accuracy bonus. From Tombs of Amascut.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Tumeken%27s_shadow']),
          CookbookStep(
              id: 'grg4',
              order: 3,
              title: 'Torva Armour (Nex)',
              description: 'BIS melee armour. Full set from Nex.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Torva_armour']),
          CookbookStep(
              id: 'grg5',
              order: 4,
              title: 'Infernal Cape (Inferno)',
              description:
                  'BIS melee cape. From TzKal-Zuk. Hardest PvM challenge.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Infernal_cape']),
          CookbookStep(
              id: 'grg6',
              order: 5,
              title: 'Dizana\'s Quiver (Colosseum)',
              description: 'BIS ranged ammo slot. From Fortis Colosseum.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Dizana%27s_quiver']),
          CookbookStep(
              id: 'grg7',
              order: 6,
              title: 'Oathplate (Yama)',
              description:
                  'Slash-focused endgame melee armour. Duo recommended for Yama.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Yama']),
          CookbookStep(
              id: 'grg8',
              order: 7,
              title: 'Eye of Ayak + Avernic Treads (Mokhaiotl)',
              description:
                  'Fastest powered staff (3-tick) and multi-style endgame boots from delve content.',
              category: StepCategory.combat,
              links: ['https://oldschool.runescape.wiki/w/Doom_of_Mokhaiotl']),
        ],
      ),
    ],
  );
}
