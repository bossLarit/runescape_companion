// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import '../presentation/widgets/pixel_sprite.dart';

// ─── Compact 8×8 pixel art for gear icons ───────────────────────
// Each sprite is 8 lines of 8 chars. A char maps to a color via palette.
// '.' = transparent.

PixelGrid _p8(List<String> rows, Map<String, Color> pal) {
  return rows.map((row) {
    final chars = row.padRight(8).substring(0, 8).split('');
    return chars.map((ch) => ch == '.' ? null : pal[ch]).toList();
  }).toList();
}

// ─── Shared Colors ──────────────────────────────────────────────
const _k = Color(0xFF1A1208); // outline
const _w = Color(0xFFFFFFFF); // white/silver highlight
const _S = Color(0xFF808080); // grey
const _n = Color(0xFF8D6E63); // brown (wood/leather)
const _N = Color(0xFFBCAAA4); // light brown

// ─── Metal tier colors ──────────────────────────────────────────
class _Tier {
  final Color main;
  final Color light;
  final Color dark;
  const _Tier(this.main, this.light, this.dark);
}

const _bronze = _Tier(Color(0xFF8B4513), Color(0xFFCD853F), Color(0xFF6B3410));
const _iron   = _Tier(Color(0xFF808080), Color(0xFFC0C0C0), Color(0xFF505050));
const _steel  = _Tier(Color(0xFF696969), Color(0xFFB0B0B0), Color(0xFF404040));
const _mithril= _Tier(Color(0xFF3949AB), Color(0xFF7986CB), Color(0xFF1A237E));
const _adamant= _Tier(Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFF1B5E20));
const _rune   = _Tier(Color(0xFF00838F), Color(0xFF4DD0E1), Color(0xFF005662));
const _dragon = _Tier(Color(0xFFB71C1C), Color(0xFFFF8A80), Color(0xFF7F0000));

const _tiers = <String, _Tier>{
  'bronze': _bronze,
  'iron': _iron,
  'steel': _steel,
  'mithril': _mithril,
  'adamant': _adamant,
  'rune': _rune,
  'dragon': _dragon,
};

Map<String, Color> _tierPal(_Tier t) => {
  'k': _k, 'm': t.main, 'l': t.light, 'd': t.dark, 'w': _w,
};

// ═══════════════════════════════════════════════════════════════
// SCIMITAR TEMPLATE — curved blade, OSRS iconic shape
// ═══════════════════════════════════════════════════════════════
const _scimRows = [
  '......kk',
  '.....kml',
  '....kmlk',
  '...kmlk.',
  '..kmlk..',
  '..kmk...',
  '..kdk...',
  '..kk....',
];

// ═══════════════════════════════════════════════════════════════
// FULL HELM TEMPLATE — face-covering helmet
// ═══════════════════════════════════════════════════════════════
const _helmRows = [
  '..kkkk..',
  '.kllllk.',
  '.kmmmml.',
  'kmmmmmmk',
  'kmkmmkmk',
  'kmmmmmmk',
  '.kmdmdk.',
  '..kkkk..',
];

// ═══════════════════════════════════════════════════════════════
// PLATEBODY TEMPLATE — chest armor
// ═══════════════════════════════════════════════════════════════
const _bodyRows = [
  '.kkmmmkk',
  'kmlllllk',
  'kmllllmk',
  '.kmmmmk.',
  '.kmmmmk.',
  '.kmllmk.',
  '.kmmmmk.',
  '..kkkk..',
];

// ═══════════════════════════════════════════════════════════════
// PLATELEGS TEMPLATE
// ═══════════════════════════════════════════════════════════════
const _legsRows = [
  '..kmmk..',
  '.kmmmmk.',
  '.kmmmmk.',
  '.kmlmlk.',
  '.km..mk.',
  '.km..mk.',
  '.km..mk.',
  '.kk..kk.',
];

// ═══════════════════════════════════════════════════════════════
// KITESHIELD TEMPLATE — kite-shaped shield
// ═══════════════════════════════════════════════════════════════
const _shieldRows = [
  '.kkkkkk.',
  'kmmllmmk',
  'kmlllmmk',
  'kmmllmmk',
  '.kmmmml.',
  '..kmmk..',
  '...kmk..',
  '....k...',
];

// ═══════════════════════════════════════════════════════════════
// Generate tiered items from templates
// ═══════════════════════════════════════════════════════════════

PixelGrid _fromTemplate(List<String> template, _Tier tier) {
  return _p8(template, _tierPal(tier));
}

Map<String, PixelGrid> _generateTiered(
  String baseName,
  List<String> template,
  List<String> tierNames,
) {
  final map = <String, PixelGrid>{};
  for (final name in tierNames) {
    final tier = _tiers[name];
    if (tier != null) {
      map['${name}_$baseName'] = _fromTemplate(template, tier);
    }
  }
  return map;
}

final _meleeMetals = ['bronze', 'iron', 'steel', 'mithril', 'adamant', 'rune'];

// ═══════════════════════════════════════════════════════════════
// UNIQUE WEAPON SPRITES
// ═══════════════════════════════════════════════════════════════

final _dragonScimPal = _tierPal(_dragon);

final _dragonScimitar = _p8(_scimRows, _dragonScimPal);

// Abyssal Whip — dark with red cord
final _whipPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB33831), 'R': const Color(0xFFFF5252),
  'd': const Color(0xFF424242),
};
final _abyssalWhip = _p8([
  '........',
  '......kk',
  '.....kRk',
  '....kRk.',
  '...kRk..',
  '..krk...',
  '.kdk....',
  '.kk.....',
], _whipPal);

// Ghrazi Rapier — thin elegant blade
final _rapierPal = <String, Color>{
  'k': _k, 's': _S, 'w': _w, 'r': const Color(0xFFB71C1C),
  'g': const Color(0xFFFFD700),
};
final _ghraziRapier = _p8([
  '.......k',
  '......ks',
  '.....ksk',
  '....ksk.',
  '...ksk..',
  '..kgk...',
  '..krk...',
  '..kk....',
], _rapierPal);

// Abyssal Tentacle
final _tentaclePal = <String, Color>{
  'k': _k, 'p': const Color(0xFF1A237E), 'P': const Color(0xFF3F51B5),
  'r': const Color(0xFFB33831),
};
final _abyssalTentacle = _p8([
  '........',
  '.....kkk',
  '....kPPk',
  '...kPpk.',
  '..kPpk..',
  '.kPpk...',
  '.krk....',
  '.kk.....',
], _tentaclePal);

// Dragon Claws
final _clawsPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF8A80),
};
final _dragonClaws = _p8([
  '..k..k..',
  '.kRkkRk.',
  '.krkkrk.',
  '..krrk..',
  '..krrk..',
  '..krrk..',
  '..kkkk..',
  '........',
], _clawsPal);

// Elder Maul
final _maulPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N, 'S': _S,
};
final _elderMaul = _p8([
  '..kSSSk.',
  '..kSSSk.',
  '...kNk..',
  '...kNk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _maulPal);

// Kodai Wand
final _kodaiPal = <String, Color>{
  'k': _k, 'b': const Color(0xFF2196F3), 'B': const Color(0xFF64B5F6),
  'n': _n, 'p': const Color(0xFF9C27B0),
};
final _kodaiWand = _p8([
  '...kBk..',
  '...kbk..',
  '...kpk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _kodaiPal);

// ═══════════════════════════════════════════════════════════════
// RANGED WEAPONS
// ═══════════════════════════════════════════════════════════════

final _bowPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N, 's': _S,
};

final _shortbow = _p8([
  '...kN...',
  '..kNk...',
  '.kNks...',
  'kNk.s...',
  'kNk.s...',
  '.kNks...',
  '..kNk...',
  '...kN...',
], _bowPal);

final _magicBowPal = <String, Color>{
  'k': _k, 'n': const Color(0xFF4A148C), 'N': const Color(0xFF7B1FA2),
  's': _S,
};
final _magicShortbow = _p8([
  '...kN...',
  '..kNk...',
  '.kNks...',
  'kNk.s...',
  'kNk.s...',
  '.kNks...',
  '..kNk...',
  '...kN...',
], _magicBowPal);

// Crossbows
final _xbowPal = <String, Color>{
  'k': _k, 'm': const Color(0xFF00838F), 'l': const Color(0xFF4DD0E1),
  'n': _n, 's': _S,
};
final _runeCrossbow = _p8([
  '........',
  '.kmmk...',
  'klmlk...',
  '.kkknnk.',
  '..ksnk..',
  '..knnk..',
  '...kk...',
  '........',
], _xbowPal);

final _armadylXbowPal = <String, Color>{
  'k': _k, 'm': const Color(0xFFE0E0E0), 'l': _w,
  'n': _n, 'g': const Color(0xFFFFD700),
};
final _armadylCrossbow = _p8([
  '........',
  '.kmmk...',
  'klglk...',
  '.kkknnk.',
  '..kgnk..',
  '..knnk..',
  '...kk...',
  '........',
], _armadylXbowPal);

// Twisted Bow
final _tbowPal = <String, Color>{
  'k': _k, 'n': const Color(0xFF5D4037), 'N': const Color(0xFF8D6E63),
  'g': const Color(0xFFFFD700), 's': _S,
};
final _twistedBow = _p8([
  '..kNk...',
  '.kgNk...',
  'kNgks...',
  'kNk.s...',
  'kNk.s...',
  'kNgks...',
  '.kgNk...',
  '..kNk...',
], _tbowPal);

// Dragon Hunter Crossbow
final _dhcbPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF8A80),
  'n': _n, 's': _S,
};
final _dragonHunterCrossbow = _p8([
  '........',
  '.krrk...',
  'kRrRk...',
  '.kkknnk.',
  '..ksnk..',
  '..knnk..',
  '...kk...',
  '........',
], _dhcbPal);

// ═══════════════════════════════════════════════════════════════
// MAGIC WEAPONS
// ═══════════════════════════════════════════════════════════════

final _fireStaffPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB33831), 'R': const Color(0xFFFF5252),
  'o': const Color(0xFFD4A017), 'n': _n,
};
final _staffOfFire = _p8([
  '..kRrk..',
  '..kork..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _fireStaffPal);

final _mysticFireStaff = _p8([
  '..kRRk..',
  '..kork..',
  '..kRk...',
  '...knk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _fireStaffPal);

final _ancientStaffPal = <String, Color>{
  'k': _k, 'p': const Color(0xFF9C27B0), 'P': const Color(0xFFCE93D8),
  'g': const Color(0xFFFFD700), 'n': _n,
};
final _ancientStaff = _p8([
  '..kPPk..',
  '..kpgk..',
  '...kgk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _ancientStaffPal);

final _tridentPal = <String, Color>{
  'k': _k, 'b': const Color(0xFF2196F3), 'B': const Color(0xFF64B5F6),
  'g': const Color(0xFFFFD700), 'n': _n,
};
final _tridentOfSeas = _p8([
  '.k.k.k..',
  '.kkBkk..',
  '..kBk...',
  '..kgk...',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _tridentPal);

final _sangPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF5252),
  'g': const Color(0xFFFFD700), 'n': _n,
};
final _sanguinestiStaff = _p8([
  '..kRRk..',
  '..krrk..',
  '..kgk...',
  '...knk..',
  '...knk..',
  '...knk..',
  '...knk..',
  '...kk...',
], _sangPal);

// ═══════════════════════════════════════════════════════════════
// UNIQUE HELMS
// ═══════════════════════════════════════════════════════════════

final _neitiznotPal = <String, Color>{
  'k': _k, 'm': const Color(0xFF808080), 'l': _w,
  'g': const Color(0xFFFFD700), 'n': _n,
};
final _helmOfNeitiznot = _p8([
  '.kkkkk..',
  'kgllglk.',
  'kmmmmmmk',
  'kmkmmkmk',
  'kmmmmmmk',
  '.kmmmmk.',
  '..kkkk..',
  '........',
], _neitiznotPal);

final _serpPal = <String, Color>{
  'k': _k, 'g': const Color(0xFF2E7D32), 'G': const Color(0xFF66BB6A),
  'y': const Color(0xFFFFD700),
};
final _serpentineHelm = _p8([
  '..kkkk..',
  '.kGGGGk.',
  'kGgGgGGk',
  'kGkGGkGk',
  'kGGGGGGk',
  '.kGygGk.',
  '..kkkk..',
  '........',
], _serpPal);

final _torvaPal = <String, Color>{
  'k': _k, 'd': const Color(0xFF263238), 'D': const Color(0xFF455A64),
  'g': const Color(0xFFFFD700),
};
final _torvaFullHelm = _p8([
  '..kkkk..',
  '.kDDDDk.',
  '.kdDDDdk',
  'kdkddkdk',
  'kddddddK',
  '.kddgdk.',
  '..kkkk..',
  '........',
], _torvaPal);

// ═══════════════════════════════════════════════════════════════
// UNIQUE BODIES
// ═══════════════════════════════════════════════════════════════

final _fighterTorsoPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF5252),
  'g': const Color(0xFFFFD700), 'w': _w,
};
final _fighterTorso = _p8([
  '.kkrrrKk',
  'kRgggggk',
  'krggggRk',
  '.krrrrk.',
  '.krrrrk.',
  '.krRRrk.',
  '.krrrrk.',
  '..kkkk..',
], _fighterTorsoPal);

final _bandosPal = <String, Color>{
  'k': _k, 'n': const Color(0xFF5D4037), 'g': const Color(0xFFD4A017),
  'G': const Color(0xFFFFD700),
};
final _bandosChestplate = _p8([
  '.kknnnkk',
  'kngGGGnk',
  'knGGGgnk',
  '.knnnnk.',
  '.knnnnk.',
  '.knGGnk.',
  '.knnnnk.',
  '..kkkk..',
], _bandosPal);

final _torvaBodyPal = <String, Color>{
  'k': _k, 'd': const Color(0xFF263238), 'D': const Color(0xFF455A64),
  'g': const Color(0xFFFFD700),
};
final _torvaPlatebody = _p8([
  '.kkDDDkk',
  'kDgggggk',
  'kDgggDDk',
  '.kDDDDk.',
  '.kDDDDk.',
  '.kDgDDk.',
  '.kDDDDk.',
  '..kkkk..',
], _torvaBodyPal);

// Ranged bodies
final _leatherPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N,
};
final _leatherBody = _p8([
  '.kknnnkk',
  'knNNNNnk',
  'knNNNnnk',
  '.knnnnk.',
  '.knnnnk.',
  '.knNNnk.',
  '.knnnnk.',
  '..kkkk..',
], _leatherPal);

final _dhidePal = <String, Color>{
  'k': _k, 'g': const Color(0xFF2E7D32), 'G': const Color(0xFF66BB6A),
};
final _greenDhideBody = _p8([
  '.kkgggkk',
  'kgGGGGgk',
  'kgGGGggk',
  '.kggggk.',
  '.kggggk.',
  '.kgGGgk.',
  '.kggggk.',
  '..kkkk..',
], _dhidePal);

final _blackDhidePal = <String, Color>{
  'k': _k, 'd': const Color(0xFF212121), 'D': const Color(0xFF424242),
};
final _blackDhideBody = _p8([
  '.kkdddkk',
  'kdDDDDdk',
  'kdDDDddk',
  '.kddddK.',
  '.kddddK.',
  '.kdDDdk.',
  '.kddddK.',
  '..kkkk..',
], _blackDhidePal);

final _armadylBodyPal = <String, Color>{
  'k': _k, 'w': _w, 'W': const Color(0xFFE0E0E0),
  'g': const Color(0xFFFFD700),
};
final _armadylChestplate = _p8([
  '.kkWWWkk',
  'kWgggggk',
  'kwggggWk',
  '.kWWWWk.',
  '.kWWWWk.',
  '.kwggWk.',
  '.kWWWWk.',
  '..kkkk..',
], _armadylBodyPal);

// Magic bodies
final _wizardPal = <String, Color>{
  'k': _k, 'b': const Color(0xFF1A237E), 'B': const Color(0xFF3F51B5),
};
final _wizardRobeTop = _p8([
  '.kkbbbkk',
  'kbBBBBbk',
  'kbBBBbbk',
  '.kbbbbk.',
  '.kbbbbk.',
  '.kbBBbk.',
  '.kbbbbk.',
  '..kkkk..',
], _wizardPal);

final _mysticPal = <String, Color>{
  'k': _k, 'b': const Color(0xFF1A237E), 'B': const Color(0xFF3F51B5),
  'g': const Color(0xFFFFD700),
};
final _mysticRobeTop = _p8([
  '.kkbbbkk',
  'kbgBgBbk',
  'kbBBBbbk',
  '.kbbbbk.',
  '.kbbbbk.',
  '.kbgBbk.',
  '.kbbbbk.',
  '..kkkk..',
], _mysticPal);

final _ahrimsPal = <String, Color>{
  'k': _k, 'p': const Color(0xFF4A148C), 'P': const Color(0xFF7B1FA2),
};
final _ahrimsRobetop = _p8([
  '.kkpppkk',
  'kpPPPPpk',
  'kpPPPppk',
  '.kppppk.',
  '.kppppk.',
  '.kpPPpk.',
  '.kppppk.',
  '..kkkk..',
], _ahrimsPal);

final _ancestralPal = <String, Color>{
  'k': _k, 'b': const Color(0xFF1A237E), 'B': const Color(0xFF3F51B5),
  'w': const Color(0xFFE8EAF6),
};
final _ancestralRobeTop = _p8([
  '.kkBBBkk',
  'kBwwwwBk',
  'kBwwwBBk',
  '.kBBBBk.',
  '.kBBBBk.',
  '.kBwwBk.',
  '.kBBBBk.',
  '..kkkk..',
], _ancestralPal);

// ═══════════════════════════════════════════════════════════════
// UNIQUE LEGS
// ═══════════════════════════════════════════════════════════════

final _bandosTassets = _p8([
  '..knnk..',
  '.knGGnk.',
  '.knGGnk.',
  '.knGgnk.',
  '.kn..nk.',
  '.kn..nk.',
  '.kn..nk.',
  '.kk..kk.',
], _bandosPal);

final _torvaPlatelegs = _p8([
  '..kDDk..',
  '.kDgDDk.',
  '.kDDDDk.',
  '.kDgDDk.',
  '.kD..Dk.',
  '.kD..Dk.',
  '.kD..Dk.',
  '.kk..kk.',
], _torvaBodyPal);

final _ancestralRobeBottom = _p8([
  '..kBBk..',
  '.kBwwBk.',
  '.kBBBBk.',
  '.kBwBBk.',
  '.kB..Bk.',
  '.kB..Bk.',
  '.kB..Bk.',
  '.kk..kk.',
], _ancestralPal);

// ═══════════════════════════════════════════════════════════════
// SHIELDS
// ═══════════════════════════════════════════════════════════════

// Dragon Defender
final _dDefPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF8A80),
  'g': const Color(0xFFFFD700),
};
final _dragonDefender = _p8([
  '..kkkk..',
  '.krrRrk.',
  '.krgrRk.',
  '.krrRrk.',
  '..krrk..',
  '...krk..',
  '....k...',
  '........',
], _dDefPal);

// Avernic Defender
final _avernicPal = <String, Color>{
  'k': _k, 'd': const Color(0xFF424242), 'D': const Color(0xFF616161),
  'r': const Color(0xFFB71C1C),
};
final _avernicDefender = _p8([
  '..kkkk..',
  '.kddDdk.',
  '.kdrDDk.',
  '.kddDdk.',
  '..kddk..',
  '...kdk..',
  '....k...',
  '........',
], _avernicPal);

// Twisted Buckler
final _bucklerPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'n': _n, 'N': _N,
};
final _twistedBuckler = _p8([
  '..kkkk..',
  '.knNNnk.',
  '.kNgNNk.',
  '.knNNnk.',
  '..knnk..',
  '...knk..',
  '....k...',
  '........',
], _bucklerPal);

// Dinh's Bulwark
final _bulwarkPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N, 'g': const Color(0xFFFFD700),
};
final _dinhsBulwark = _p8([
  '.kkkkkk.',
  'kNNgNNNk',
  'kNgggNNk',
  'kNNgNNNk',
  '.kNNNNk.',
  '..kNNk..',
  '...kNk..',
  '....k...',
], _bulwarkPal);

// ═══════════════════════════════════════════════════════════════
// CAPES
// ═══════════════════════════════════════════════════════════════

final _obsCapePal = <String, Color>{
  'k': _k, 'd': const Color(0xFF212121), 'D': const Color(0xFF424242),
};
final _obsidianCape = _p8([
  '..kkkk..',
  '.kDDDDk.',
  '.kdDDdk.',
  '.kdDDdk.',
  '.kddDdk.',
  '..kddk..',
  '..kddk..',
  '...kk...',
], _obsCapePal);

final _fireCapePal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB33831), 'R': const Color(0xFFFF5252),
  'o': const Color(0xFFD4A017), 'y': const Color(0xFFFFD700),
};
final _fireCape = _p8([
  '..kkkk..',
  '.kRRRRk.',
  '.krRRrk.',
  '.krorRk.',
  '.kroyRk.',
  '..kork..',
  '..koyk..',
  '...kk...',
], _fireCapePal);

final _infernalCapePal = <String, Color>{
  'k': _k, 'r': const Color(0xFF7F0000), 'R': const Color(0xFFB71C1C),
  'o': const Color(0xFFD4A017), 'y': const Color(0xFFFFD700),
};
final _infernalCape = _p8([
  '..kkkk..',
  '.kRRRRk.',
  '.kRrRRk.',
  '.kRoRrk.',
  '.kryoRk.',
  '..kork..',
  '..koyk..',
  '...kk...',
], _infernalCapePal);

final _avasPal = <String, Color>{
  'k': _k, 'g': const Color(0xFF2E7D32), 'G': const Color(0xFF66BB6A),
  'r': const Color(0xFFB33831),
};
final _avasAccumulator = _p8([
  '..kkkk..',
  '.kGGGGk.',
  '.kgGGgk.',
  '.kggGgk.',
  '.kgGggk.',
  '..kgrk..',
  '..kggk..',
  '...kk...',
], _avasPal);

final _avasAssembler = _p8([
  '..kkkk..',
  '.kGGGGk.',
  '.kgGGgk.',
  '.kgrGgk.',
  '.kgGrgk.',
  '..kgrk..',
  '..kggk..',
  '...kk...',
], _avasPal);

// ═══════════════════════════════════════════════════════════════
// NECKLACES
// ═══════════════════════════════════════════════════════════════

final _amuletPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'G': const Color(0xFFD4A017),
  'r': const Color(0xFFB33831),
};
final _amuletOfStrength = _p8([
  '........',
  '..kggk..',
  '.kg..gk.',
  '.kg..gk.',
  '..kggk..',
  '..kGk...',
  '..krk...',
  '...k....',
], _amuletPal);

final _amuletOfGlory = _p8([
  '........',
  '..kggk..',
  '.kg..gk.',
  '.kg..gk.',
  '..kggk..',
  '..kGk...',
  '..kgk...',
  '...k....',
], _amuletPal);

final _furyPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'G': const Color(0xFFD4A017),
  'r': const Color(0xFF7F0000),
};
final _amuletOfFury = _p8([
  '........',
  '..kggk..',
  '.kg..gk.',
  '.kG..Gk.',
  '..kGGk..',
  '..kGk...',
  '..krk...',
  '...k....',
], _furyPal);

final _torturePal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'r': const Color(0xFFB71C1C),
  'R': const Color(0xFFFF5252),
};
final _amuletOfTorture = _p8([
  '........',
  '..kggk..',
  '.kg..gk.',
  '.kg..gk.',
  '..kggk..',
  '..kRk...',
  '..krk...',
  '...k....',
], _torturePal);

final _anguishPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'b': const Color(0xFF2196F3),
  'B': const Color(0xFF64B5F6),
};
final _necklaceOfAnguish = _p8([
  '........',
  '..kggk..',
  '.kg..gk.',
  '.kg..gk.',
  '..kggk..',
  '..kBk...',
  '..kbk...',
  '...k....',
], _anguishPal);

final _occultPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'p': const Color(0xFF9C27B0),
  'P': const Color(0xFFCE93D8),
};
final _occultNecklace = _p8([
  '........',
  '..kggk..',
  '.kg..gk.',
  '.kg..gk.',
  '..kggk..',
  '..kPk...',
  '..kpk...',
  '...k....',
], _occultPal);

// ═══════════════════════════════════════════════════════════════
// RINGS
// ═══════════════════════════════════════════════════════════════

final _ringPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'G': const Color(0xFFD4A017),
};
final _ringOfWealth = _p8([
  '........',
  '........',
  '..kkkk..',
  '.kgGGgk.',
  '.kG..Gk.',
  '.kG..Gk.',
  '..kkkk..',
  '........',
], _ringPal);

final _berserkerPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF8A80),
};
final _berserkerRing = _p8([
  '........',
  '........',
  '..kkkk..',
  '.krRRrk.',
  '.kR..Rk.',
  '.kR..Rk.',
  '..kkkk..',
  '........',
], _berserkerPal);

final _archersRingPal = <String, Color>{
  'k': _k, 'g': const Color(0xFF2E7D32), 'G': const Color(0xFF66BB6A),
};
final _archersRing = _p8([
  '........',
  '........',
  '..kkkk..',
  '.kgGGgk.',
  '.kG..Gk.',
  '.kG..Gk.',
  '..kkkk..',
  '........',
], _archersRingPal);

final _seersRingPal = <String, Color>{
  'k': _k, 'b': const Color(0xFF2196F3), 'B': const Color(0xFF64B5F6),
};
final _seersRing = _p8([
  '........',
  '........',
  '..kkkk..',
  '.kbBBbk.',
  '.kB..Bk.',
  '.kB..Bk.',
  '..kkkk..',
  '........',
], _seersRingPal);

final _ultorPal = <String, Color>{
  'k': _k, 'r': const Color(0xFF7F0000), 'R': const Color(0xFFB71C1C),
  'g': const Color(0xFFFFD700),
};
final _ultorRing = _p8([
  '........',
  '........',
  '..kkkk..',
  '.krgRrk.',
  '.kR..Rk.',
  '.kR..Rk.',
  '..kkkk..',
  '........',
], _ultorPal);

// ═══════════════════════════════════════════════════════════════
// GLOVES & BOOTS
// ═══════════════════════════════════════════════════════════════

final _glovesPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N,
};
final _leatherGloves = _p8([
  '........',
  '.kk..kk.',
  'knNkkNnk',
  'knNkkNnk',
  'knnkknnk',
  '.kk..kk.',
  '........',
  '........',
], _glovesPal);

final _combatBraceletPal = <String, Color>{
  'k': _k, 'g': const Color(0xFFFFD700), 'G': const Color(0xFFD4A017),
  'r': const Color(0xFFB33831),
};
final _combatBracelet = _p8([
  '........',
  '.kk..kk.',
  'kgGkkGgk',
  'kgrkkrgk',
  'kggkkggk',
  '.kk..kk.',
  '........',
  '........',
], _combatBraceletPal);

final _barrowsGlovesPal = <String, Color>{
  'k': _k, 'p': const Color(0xFF4A148C), 'P': const Color(0xFF7B1FA2),
};
final _barrowsGloves = _p8([
  '........',
  '.kk..kk.',
  'kpPkkPpk',
  'kpPkkPpk',
  'kppkkppk',
  '.kk..kk.',
  '........',
  '........',
], _barrowsGlovesPal);

final _ferociousPal = <String, Color>{
  'k': _k, 'd': const Color(0xFF424242), 'D': const Color(0xFF616161),
  'r': const Color(0xFFB71C1C),
};
final _ferociousGloves = _p8([
  '........',
  '.kk..kk.',
  'kdDkkDdk',
  'kdrkkrdk',
  'kddkkddk',
  '.kk..kk.',
  '........',
  '........',
], _ferociousPal);

final _bootsPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N,
};
final _leatherBoots = _p8([
  '........',
  '........',
  '..kk.kk.',
  '.knNknNk',
  '.knnknnk',
  'knnnknnk',
  'kkkkkkk.',
  '........',
], _bootsPal);

final _climbingBootsPal = <String, Color>{
  'k': _k, 'n': _n, 'N': _N, 'S': _S,
};
final _climbingBoots = _p8([
  '........',
  '........',
  '..kk.kk.',
  '.knNknNk',
  '.knnknnk',
  'kSnnknnk',
  'kkkkkkk.',
  '........',
], _climbingBootsPal);

final _dBootsPal = <String, Color>{
  'k': _k, 'r': const Color(0xFFB71C1C), 'R': const Color(0xFFFF8A80),
};
final _dragonBoots = _p8([
  '........',
  '........',
  '..kk.kk.',
  '.krRkrRk',
  '.krrkrrk',
  'krrrKrrk',
  'kkkkkkk.',
  '........',
], _dBootsPal);

final _primordialPal = <String, Color>{
  'k': _k, 'd': const Color(0xFF212121), 'D': const Color(0xFF424242),
  'r': const Color(0xFF7F0000),
};
final _primordialBoots = _p8([
  '........',
  '........',
  '..kk.kk.',
  '.kdDkdDk',
  '.kdrkdrk',
  'kdddkddk',
  'kkkkkkk.',
  '........',
], _primordialPal);

// ═══════════════════════════════════════════════════════════════
// AMMO
// ═══════════════════════════════════════════════════════════════

PixelGrid _arrowSprite(Color shaft, Color tip) {
  final pal = <String, Color>{'k': _k, 's': shaft, 't': tip, 'n': _n};
  return _p8([
    '........',
    '......kt',
    '.....ktk',
    '....ksk.',
    '...ksk..',
    '..ksk...',
    '.knk....',
    '.kk.....',
  ], pal);
}

final _ironArrows = _arrowSprite(_S, const Color(0xFF808080));
final _mithrilArrows = _arrowSprite(_S, const Color(0xFF3949AB));
final _adamantArrows = _arrowSprite(_S, const Color(0xFF2E7D32));
final _runeArrows = _arrowSprite(_S, const Color(0xFF00838F));
final _dragonArrows = _arrowSprite(_S, const Color(0xFFB71C1C));

PixelGrid _boltSprite(Color body, Color tip) {
  final pal = <String, Color>{'k': _k, 'b': body, 't': tip, 'n': _n};
  return _p8([
    '........',
    '.....ktk',
    '....kbk.',
    '...kbk..',
    '..kbk...',
    '.knk....',
    '.kk.....',
    '........',
  ], pal);
}

final _rubyBolts = _boltSprite(_S, const Color(0xFFB71C1C));
final _diamondBolts = _boltSprite(_S, const Color(0xFF64B5F6));

// ═══════════════════════════════════════════════════════════════
// RANGED HEAD/LEGS (d'hide etc)
// ═══════════════════════════════════════════════════════════════

// Ancestral Hat
final _ancestralHat = _p8([
  '..kkkk..',
  '.kBwwBk.',
  'kBBBBBBk',
  'kBwBBwBk',
  '.kBBBBk.',
  '..kkkk..',
  '........',
  '........',
], _ancestralPal);

// ═══════════════════════════════════════════════════════════════
// MASTER GEAR SPRITE INDEX
// ═══════════════════════════════════════════════════════════════

final Map<String, PixelGrid> gearSprites = <String, PixelGrid>{
  // ── Tiered scimitars ──
  ..._generateTiered('scimitar', _scimRows, _meleeMetals),
  'dragon_scimitar': _dragonScimitar,

  // ── Unique melee weapons ──
  'abyssal_whip_eq': _abyssalWhip,
  'abyssal_whip': _abyssalWhip,
  'tentacle_whip': _abyssalTentacle,
  'ghrazi_rapier': _ghraziRapier,
  'dragon_claws': _dragonClaws,
  'elder_maul': _elderMaul,

  // ── Ranged weapons ──
  'shortbow': _shortbow,
  'maple_shortbow': _shortbow,
  'magic_shortbow': _magicShortbow,
  'rune_crossbow': _runeCrossbow,
  'armadyl_crossbow': _armadylCrossbow,
  'twisted_bow': _twistedBow,
  'dragon_hunter_crossbow': _dragonHunterCrossbow,

  // ── Magic weapons ──
  'staff_of_fire': _staffOfFire,
  'mystic_fire_staff': _mysticFireStaff,
  'ancient_staff': _ancientStaff,
  'trident_of_the_seas': _tridentOfSeas,
  'sanguinesti_staff': _sanguinestiStaff,
  'kodai_wand': _kodaiWand,

  // ── Tiered helms ──
  ..._generateTiered('full_helm', _helmRows, _meleeMetals),
  'helm_of_neitiznot': _helmOfNeitiznot,
  'serpentine_helm': _serpentineHelm,
  'torva_full_helm': _torvaFullHelm,
  'ancestral_hat': _ancestralHat,

  // ── Tiered bodies ──
  ..._generateTiered('platebody', _bodyRows, _meleeMetals),
  'fighter_torso': _fighterTorso,
  'bandos_chestplate': _bandosChestplate,
  'torva_platebody': _torvaPlatebody,
  'leather_body': _leatherBody,
  'green_dhide_body_eq': _greenDhideBody,
  'green_dhide_body': _greenDhideBody,
  'black_dhide_body_eq': _blackDhideBody,
  'black_dhide_body': _blackDhideBody,
  'armadyl_chestplate': _armadylChestplate,
  'wizard_robe_top': _wizardRobeTop,
  'mystic_robe_top': _mysticRobeTop,
  'ahrims_robetop': _ahrimsRobetop,
  'ancestral_robe_top': _ancestralRobeTop,

  // ── Tiered legs ──
  ..._generateTiered('platelegs', _legsRows, _meleeMetals),
  'bandos_tassets': _bandosTassets,
  'torva_platelegs': _torvaPlatelegs,
  'ancestral_robe_bottom': _ancestralRobeBottom,

  // ── Tiered shields ──
  ..._generateTiered('kiteshield', _shieldRows, _meleeMetals),
  'dragon_defender': _dragonDefender,
  'avernic_defender': _avernicDefender,
  'twisted_buckler': _twistedBuckler,
  'dinhs_bulwark': _dinhsBulwark,

  // ── Capes ──
  'obsidian_cape_eq': _obsidianCape,
  'obsidian_cape': _obsidianCape,
  'fire_cape_eq': _fireCape,
  'fire_cape': _fireCape,
  'infernal_cape': _infernalCape,
  'avas_accumulator': _avasAccumulator,
  'avas_assembler': _avasAssembler,

  // ── Necklaces ──
  'amulet_of_strength': _amuletOfStrength,
  'amulet_of_glory': _amuletOfGlory,
  'amulet_of_fury': _amuletOfFury,
  'amulet_of_torture': _amuletOfTorture,
  'necklace_of_anguish': _necklaceOfAnguish,
  'occult_necklace': _occultNecklace,

  // ── Rings ──
  'ring_of_wealth': _ringOfWealth,
  'berserker_ring': _berserkerRing,
  'berserker_ring_i': _berserkerRing,
  'archers_ring': _archersRing,
  'archers_ring_i': _archersRing,
  'seers_ring': _seersRing,
  'seers_ring_i': _seersRing,
  'ultor_ring': _ultorRing,

  // ── Gloves ──
  'leather_gloves': _leatherGloves,
  'combat_bracelet': _combatBracelet,
  'barrows_gloves': _barrowsGloves,
  'ferocious_gloves': _ferociousGloves,

  // ── Boots ──
  'leather_boots': _leatherBoots,
  'climbing_boots': _climbingBoots,
  'dragon_boots': _dragonBoots,
  'primordial_boots': _primordialBoots,

  // ── Ammo ──
  'iron_arrows': _ironArrows,
  'mithril_arrows': _mithrilArrows,
  'adamant_arrows': _adamantArrows,
  'rune_arrows': _runeArrows,
  'dragon_arrows': _dragonArrows,
  'ruby_bolts_e': _rubyBolts,
  'diamond_bolts_e': _diamondBolts,
};
