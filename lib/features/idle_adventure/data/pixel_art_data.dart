// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import '../presentation/widgets/pixel_sprite.dart';
import '../domain/idle_models.dart';

// ─── Compact pixel art format ───────────────────────────────────
// Each sprite is 16 lines of 16 chars. A char maps to a color via palette.
// '.' = transparent.

PixelGrid _parse(List<String> rows, Map<String, Color> pal) {
  return rows.map((row) {
    final chars = row.padRight(16).substring(0, 16).split('');
    return chars.map((ch) => ch == '.' ? null : pal[ch]).toList();
  }).toList();
}

// ─── Color Palettes ─────────────────────────────────────────────

const _k = Color(0xFF1A1208); // black/outline
const _w = Color(0xFFFFFFFF); // white
const _r = Color(0xFFB33831); // red
const _R = Color(0xFFFF5252); // bright red
const _o = Color(0xFFD4A017); // gold/orange
const _y = Color(0xFFFFD700); // yellow
const _g = Color(0xFF4CAF50); // green
const _G = Color(0xFF81C784); // light green
const _b = Color(0xFF2196F3); // blue
const _B = Color(0xFF64B5F6); // light blue
const _p = Color(0xFF9C27B0); // purple
const _P = Color(0xFFCE93D8); // light purple
const _n = Color(0xFF8D6E63); // brown
const _N = Color(0xFFBCAAA4); // light brown
const _s = Color(0xFFF5D6BA); // skin
const _S = Color(0xFF808080); // grey
const _d = Color(0xFF424242); // dark grey
// Cyan reserved for future use

// ─── Monster Palettes ───────────────────────────────────────────

final _chickenPal = <String, Color>{
  'k': _k,
  'w': _w,
  'r': _r,
  'o': _o,
  'y': _y,
  'n': _n,
};

final _cowPal = <String, Color>{
  'k': _k,
  'w': _w,
  'n': _n,
  'N': _N,
  'p': const Color(0xFFFFB6C1),
};

final _goblinPal = <String, Color>{
  'k': _k,
  'g': _g,
  'G': _G,
  'n': _n,
  'r': _r,
  'y': _y,
};

final _guardPal = <String, Color>{
  'k': _k,
  's': _s,
  'S': _S,
  'd': _d,
  'b': _b,
  'w': _w,
  'o': _o,
};

final _hillGiantPal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  's': _s,
  'S': _S,
  'g': _g,
};

final _mossGiantPal = <String, Color>{
  'k': _k,
  'g': _g,
  'G': _G,
  'n': _n,
  'N': _N,
};

final _lesserDemonPal = <String, Color>{
  'k': _k,
  'r': _r,
  'R': _R,
  'o': _o,
  'y': _y,
};

final _greaterDemonPal = <String, Color>{
  'k': _k,
  'r': const Color(0xFF8B0000),
  'R': _r,
  'o': _o,
  'y': _y,
  'p': _p,
};

final _blackDragonPal = <String, Color>{
  'k': _k,
  'd': _d,
  'S': _S,
  'r': _r,
  'R': _R,
  'o': _o,
  'y': _y,
};

final _jadPal = <String, Color>{
  'k': _k,
  'r': _r,
  'R': _R,
  'o': _o,
  'y': _y,
  'w': _w,
};

final _dustDevilPal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'S': _S,
  'y': _y,
};

final _wyvernPal = <String, Color>{
  'k': _k,
  'w': _w,
  'S': _S,
  'b': _b,
  'B': _B,
  'N': _N,
};

final _abyssalDemonPal = <String, Color>{
  'k': _k,
  'p': _p,
  'P': _P,
  'r': _r,
  'R': _R,
};

final _cerberusPal = <String, Color>{
  'k': _k,
  'd': _d,
  'S': _S,
  'r': _r,
  'R': _R,
  'o': _o,
};

final _hydraPal = <String, Color>{
  'k': _k,
  'g': _g,
  'G': _G,
  'b': _b,
  'B': _B,
  'y': _y,
  'r': _r,
};

// ═══════════════════════════════════════════════════════════════
// MONSTER SPRITES  (idle frame + attack frames)
// ═══════════════════════════════════════════════════════════════

// ── Chicken ─────────────────────────────────────────────────────
final _chickenIdle = _parse([
  '................',
  '......rrk.......',
  '.....krrk.......',
  '....kwwwk.......',
  '....kwkwk.......',
  '....kwwwk.......',
  '.....koyk.......',
  '....kwwwwk......',
  '...kwwwwwwk.....',
  '...kwwwwwwk.....',
  '..kwwwwwwwkk....',
  '...kwwwwwwk.....',
  '....kwwwwk......',
  '.....k..k.......',
  '....ko..ok......',
  '................',
], _chickenPal);

final _chickenAtk = _parse([
  '.....rrk........',
  '....krrk........',
  '....kwwwk.......',
  '....kwkwk.......',
  '....kwwwk.......',
  '.....koyk.......',
  '...kwwwwwk......',
  '..kwwwwwwwk.....',
  '..kwwwwwwwwkk...',
  '..kwwwwwwwwk....',
  '...kwwwwwwk.....',
  '....kwwwwk......',
  '...kkwwwwkk.....',
  '....k....k......',
  '...ko....ok.....',
  '................',
], _chickenPal);

// ── Cow ─────────────────────────────────────────────────────────
final _cowIdle = _parse([
  '................',
  '.kkk......kkk...',
  '.kwwk....kwwk...',
  '..kwwkkkkkwNk...',
  '..kNNNNNNNNk....',
  '..kNkNNkNNNk....',
  '..kNNNNNNNNk....',
  '...kNNppNNk.....',
  '..knwnnnnwnk....',
  '.knwnnnnnnwnk...',
  '.knnwnnnnwnnk...',
  '.knnnnnnnnnnk...',
  '..knnnnnnnnk....',
  '..kn..kk..nk....',
  '..kk..kk..kk....',
  '................',
], _cowPal);

final _cowAtk = _parse([
  '..kkk....kkk....',
  '..kwwk..kwwk....',
  '...kwwkkkkwNk...',
  '...kNNNNNNNk....',
  '...kNkNNkNNk....',
  '...kNNNNNNNk....',
  '...kkNNppNNk....',
  '..knwnnnnwnk....',
  '.knwnnnnnnwnk...',
  '.knnwnnnnwnnk...',
  '.knnnnnnnnnnk...',
  '..knnnnnnnnk....',
  '..knnnnnnnnk....',
  '..kn..kk..nk....',
  '..kk..kk..kk....',
  '................',
], _cowPal);

// ── Goblin ──────────────────────────────────────────────────────
final _goblinIdle = _parse([
  '................',
  '...kk..kk.......',
  '..kGgkkgGk......',
  '....kggggk......',
  '....kgGGgk......',
  '...kgkggkgk.....',
  '...kggGGggk.....',
  '....kgrrk.......',
  '.....kggk.......',
  '....knnnnnk.....',
  '....knnnnnk.....',
  '...kgknnnkgk....',
  '...k.knnnk.k....',
  '.....kggk.......',
  '......k..k......',
  '.....kk..kk.....',
], _goblinPal);

final _goblinAtk = _parse([
  '................',
  '...kk..kk..k....',
  '..kGgkkgGk.k....',
  '....kggggk.k....',
  '....kgGGgkkk....',
  '...kgkggkgk.....',
  '...kggGGggk.kk..',
  '....kgrrk..kyk..',
  '.....kggk..kyk..',
  '....knnnnnkkk...',
  '....knnnnnk.....',
  '...kgknnnkgk....',
  '...k.knnnk.k....',
  '.....kggk.......',
  '....kk..kk......',
  '................',
], _goblinPal);

// ── Al-Kharid Warrior ───────────────────────────────────────────
final _guardIdle = _parse([
  '.....kkkkk......',
  '....kwwwwwk.....',
  '....kdddwdk.....',
  '.....kssskk.....',
  '.....kskskk.....',
  '.....kssskk.....',
  '......ksk.......',
  '....kkSSSkkk....',
  '...kSkSSSk.k....',
  '...kSkSSSk......',
  '....kkSSSk......',
  '.....kSSSk......',
  '.....kdkdk......',
  '......k.k.......',
  '.....kk.kk......',
  '................',
], _guardPal);

final _guardAtk = _parse([
  '.....kkkkk......',
  '....kwwwwwk.....',
  '....kdddwdk.....',
  '.....kssskk.....',
  '.....kskskk.....',
  '.....kssskk.....',
  '......ksk.......',
  '...kkkSSSkkk....',
  '..kSSkSSSk.k....',
  '..kok.kSSSk.....',
  '..kkk.kSSSk.....',
  '.....kSSSk......',
  '.....kdkdk......',
  '....kk..k.......',
  '....k...kk......',
  '................',
], _guardPal);

// ── Hill Giant ──────────────────────────────────────────────────
final _hillGiantIdle = _parse([
  '...kkkkkkkk.....',
  '..ksssssssssk...',
  '..ksksskssssk...',
  '..kssssssssk....',
  '...kssNNssk.....',
  '....ksssk.......',
  '..kksssssskk....',
  '.ksssssssssSk...',
  '.ksssssssssSk...',
  '.ksssssssssSk...',
  '..kssssssssk....',
  '..kgnnnnnngk....',
  '...kgnnnngk.....',
  '...kss..ssk.....',
  '..kkk...kkk.....',
  '................',
], _hillGiantPal);

final _hillGiantAtk = _parse([
  '...kkkkkkkk.....',
  '..ksssssssssk...',
  '..ksksskssssk...',
  '..kssssssssk....',
  '...kssNNssk.....',
  '....ksssk.......',
  '.kkkssssskkkkk..',
  'ksssssssssSknSk.',
  '.kssssssssSknnk.',
  '.kssssssssSkk...',
  '..kssssssssk....',
  '..kgnnnnnngk....',
  '...kgnnnngk.....',
  '..kss....ssk....',
  '.kkk.....kkk....',
  '................',
], _hillGiantPal);

// ── Moss Giant ──────────────────────────────────────────────────
final _mossGiantIdle = _parse([
  '...kkkkkkk......',
  '..kggGgGggk.....',
  '..kgkGgkGgk.....',
  '..kggGGGggk.....',
  '...kgGGGk.......',
  '....kgGk........',
  '..kkGGGGGkk.....',
  '.kGGGGGGGGGk....',
  '.kGGnGGGnGGk....',
  '.kGGGGGGGGGk....',
  '..kGGGGGGGk.....',
  '..kgnGGGngk.....',
  '...kGGGGGk......',
  '...kGg..gGk.....',
  '..kkk...kkk.....',
  '................',
], _mossGiantPal);

final _mossGiantAtk = _parse([
  '...kkkkkkk......',
  '..kggGgGggk.....',
  '..kgkGgkGgk.....',
  '..kggGGGggk.....',
  '...kgGGGk.......',
  '....kgGk........',
  '.kkkGGGGGkkk....',
  'kGGGGGGGGGGGk...',
  'kGGnGGGGnGGGk...',
  '.kGGGGGGGGGk....',
  '..kGGGGGGGk.....',
  '..kgnGGGngk.....',
  '...kGGGGGk......',
  '..kGg....gGk....',
  '.kkk......kkk...',
  '................',
], _mossGiantPal);

// ── Lesser Demon ────────────────────────────────────────────────
final _lesserDemonIdle = _parse([
  '....kr...rk.....',
  '....kkr.rkk.....',
  '...krRRRRRrk....',
  '...krkRRkrrk....',
  '...krrRRRrrk....',
  '....krRooRk.....',
  '.....krrRk......',
  '.kk.kkRRRRkk.kk',
  'krk.krrRRrrkk.rk',
  '.kk.krrRRrrk.kk.',
  '....krRRRRrk....',
  '.....kRRRRk.....',
  '.....krrrrk.....',
  '.....kr..rk.....',
  '....kkr.krkk....',
  '................',
], _lesserDemonPal);

final _lesserDemonAtk = _parse([
  '....kr...rk.....',
  '....kkr.rkk.....',
  '...krRRRRRrk....',
  '...krkRRkrrk....',
  '...krrRRRrrk....',
  '....krRooRk.....',
  '.....krrRk......',
  '.kkkkkRRRRkkkkk.',
  'krrrkrrRRrrkrrrk',
  '.kkkkrrRRrrkkrk.',
  '....krRRRRrk.k..',
  '.....kRRRRk.....',
  '.....krrrrk.....',
  '....kr....rk....',
  '...kkr..krkk....',
  '................',
], _lesserDemonPal);

// ── Greater Demon ───────────────────────────────────────────────
final _greaterDemonIdle = _parse([
  '...kr.....rk....',
  '...kkr...rkk....',
  '..kkRRRRRRRkk...',
  '..kRkRrrrkRRk...',
  '..kRRrrrrrRRk...',
  '...kRroorRRk....',
  '....kRrrrRk.....',
  'kkk.kRRRRRk.kkk',
  'kRRkkRRRRRRkkRRk',
  'kRrkRRRRRRRRkRrk',
  '.kkkkRRRRRRkkkk.',
  '...kRRRRRRRRk...',
  '....kRrrrRk.....',
  '....kRr.rRk.....',
  '...kkR..kRkk....',
  '................',
], _greaterDemonPal);

final _greaterDemonAtk = _parse([
  '...kr.....rk....',
  '...kkr...rkk....',
  '..kkRRRRRRRkk...',
  '..kRkRrrrkRRk...',
  '..kRRrrrrrRRk...',
  '...kRroorRRk....',
  '....kRrrrRk.....',
  'kkkkkRRRRRRkkkkk',
  'kRRRRRRRRRRRRRRk',
  'kRrrRRRRRRRRrRrk',
  '.kkkkRRRRRRkkkk.',
  '...kRRRRRRRRk...',
  '....kRrrrRk.....',
  '...kRr...rRk....',
  '..kkR..kR.kk....',
  '................',
], _greaterDemonPal);

// ── Black Dragon ────────────────────────────────────────────────
final _blackDragonIdle = _parse([
  '................',
  '..kk........kk..',
  '.kdSk......kdSk.',
  '..kddkkkkkkkdk..',
  '...kddddddddk...',
  '...kdkdddkddk...',
  '...kdddddddk....',
  '....kddrrdk.....',
  '.....kdddk......',
  'kkk.kddddddkkkk',
  'kddkkddddddkkddk',
  'kdSkddddddddkSdk',
  '.kkkkddddddkkkk.',
  '....kddd.dddk...',
  '...kkk...kkkk...',
  '................',
], _blackDragonPal);

final _blackDragonAtk = _parse([
  '.......rRr......',
  '..kk..kRRRk.kk..',
  '.kdSk..krk.kdSk.',
  '..kddkkkkkkkdk..',
  '...kddddddddk...',
  '...kdkdddkddk...',
  '...kdddddddk....',
  '....kddrrdk.....',
  '.....kdddk......',
  'kkkkkddddddkkkkk',
  'kddddddddddddddK',
  'kdSkddddddddkSdk',
  '.kkkkddddddkkkk.',
  '...kddd...dddk..',
  '..kkk.....kkkk..',
  '................',
], _blackDragonPal);

// ── TzTok-Jad ───────────────────────────────────────────────────
final _jadIdle = _parse([
  '..krrk....krrk..',
  '.krRRrk..krRRrk.',
  '.krRRRRkkRRRRrk.',
  '..kRRoRRRRoRRk..',
  '..kRkRRRRkRRk...',
  '..kRRRRRRRRRk...',
  '...kRRoooRRk....',
  '....kRRRRRk.....',
  '..kkRRoRRoRkk...',
  '.kRRRRRRRRRRRk..',
  '.kRRRoRRRoRRRk..',
  '..kRRRRRRRRRk...',
  '...kRRRRRRk.....',
  '...kRRr.rRk.....',
  '..kkRk..kRkk....',
  '................',
], _jadPal);

final _jadAtk = _parse([
  '..yyy...........',
  '.kyRyk...krrk...',
  '..kRRRkkRRRRrk..',
  '..kRRoRRRRoRRk..',
  '..kRkRRRRkRRk...',
  '..kRRRRRRRRRk...',
  '...kRRoooRRk....',
  '....kRRRRRk.....',
  '.kkkRRoRRoRkkk..',
  'kyRRRRRRRRRRRyk.',
  '.kRRRoRRRoRRRk..',
  '..kRRRRRRRRRk...',
  '...kRRRRRRk.....',
  '..kRRr...rRk....',
  '.kkRk....kRkk...',
  '................',
], _jadPal);

// ── Dust Devil ──────────────────────────────────────────────────
final _dustDevilIdle = _parse([
  '................',
  '......NNN.......',
  '.....NSSN.......',
  '....NSSSN.......',
  '....NSkSkN......',
  '....NSSSSN......',
  '.....NnN........',
  '....NnnnN.......',
  '...NnSnnSN......',
  '...NnnnnnN......',
  '..NnSnnnSnN.....',
  '...NnnnnnN......',
  '....NnSnN.......',
  '.....NnN........',
  '...NNnSnNN......',
  '....NNNNN.......',
], _dustDevilPal);

final _dustDevilAtk = _parse([
  '........yyy.....',
  '......NNNyy.....',
  '.....NSSNy......',
  '....NSSSN.......',
  '....NSkSkN......',
  '....NSSSSN......',
  '.....NnN........',
  '...NNnnnNN......',
  '..NnSnnSnNNN....',
  '..NnnnnnnnN.....',
  '.NnSnnnSnnnN....',
  '..NnnnnnnnN.....',
  '...NnnSnnnN.....',
  '....NnnnN.......',
  '..NNnSnSnNN.....',
  '...NNNNNNN......',
], _dustDevilPal);

// ── Skeletal Wyvern ─────────────────────────────────────────────
final _wyvernIdle = _parse([
  '................',
  '..kk........kk..',
  '.kwNk......kwNk.',
  '..kwwkkkkkkwwk..',
  '...kwwwwwwwwk...',
  '...kwkwwwkwwk...',
  '...kwwwwwwwk....',
  '....kwwBBwk.....',
  '.....kwwwk......',
  'kkk.kkwwwwkk.kkk',
  'kwNkkwwwwwwkkNwk',
  'kwwkwwwwwwwwkwwk',
  '.kkkkwwwwwwkkkk.',
  '....kww..wwk....',
  '...kkk...kkk....',
  '................',
], _wyvernPal);

final _wyvernAtk = _parse([
  '......bBb.......',
  '..kk.kBBBk..kk..',
  '.kwNk.kBk..kwNk.',
  '..kwwkkkkkkwwk..',
  '...kwwwwwwwwk...',
  '...kwkwwwkwwk...',
  '...kwwwwwwwk....',
  '....kwwBBwk.....',
  '.....kwwwk......',
  'kkkkkkwwwwkkkkkk',
  'kwNwwwwwwwwwwNwk',
  'kwwkwwwwwwwwkwwk',
  '.kkkkwwwwwwkkkk.',
  '...kww....wwk...',
  '..kkk.....kkk...',
  '................',
], _wyvernPal);

// ── Abyssal Demon ───────────────────────────────────────────────
final _abyssalDemonIdle = _parse([
  '..kPk..kPk.kPk..',
  '..kpk..kpk.kpk..',
  '...kkkkkkkkk....',
  '...kPPpPPpPk....',
  '...kPkPPkPPk....',
  '...kPPPPPPPk....',
  '....kPrrPPk.....',
  '.....kPPk.......',
  '....kkPPPPkk....',
  '...kPPPPPPPPk...',
  '...kPPPPPPPPk...',
  '....kPPpPPPk....',
  '.....kPPPPk.....',
  '.....kPp.pPk....',
  '....kkP..kPkk...',
  '................',
], _abyssalDemonPal);

final _abyssalDemonAtk = _parse([
  '..kPk..kPk.kPk..',
  '..kpk..kpk.kpk..',
  '...kkkkkkkkk....',
  '...kPPpPPpPk....',
  '...kPkPPkPPk....',
  '...kPPPPPPPk....',
  '....kPrrPPk.....',
  '.....kPPk.......',
  '..kkkPPPPPkkk...',
  '.kPPPPPPPPPPPk..',
  '..kPPPPPPPPPk...',
  '....kPPpPPPk....',
  '.....kPPPPk.....',
  '....kPp...pPk...',
  '...kkP....kPkk..',
  '................',
], _abyssalDemonPal);

// ── Cerberus ────────────────────────────────────────────────────
final _cerberusIdle = _parse([
  '................',
  '.kkk.kkk.kkk....',
  'kdrkkdrdkkrdk...',
  'kddkkdddkkddk...',
  'kdkdkdkdkdkdk...',
  'kdddddddddddk...',
  '.kdddddddddk....',
  '..kdddddddk.....',
  '..kddddddddkk...',
  '..kdddddddddddk.',
  '...kdddddddddk..',
  '...kdddddddddk..',
  '....kdddddddk...',
  '....kdd..dddk...',
  '...kkk...kkkk...',
  '................',
], _cerberusPal);

final _cerberusAtk = _parse([
  '..rr..rrr..rr...',
  '.kRRk.kRRk.kRRk.',
  'kdrkkdrdkkrdk...',
  'kddkkdddkkddk...',
  'kdkdkdkdkdkdk...',
  'kdddddddddddk...',
  '.kdddddddddk....',
  '..kdddddddk.....',
  '.kkddddddddkkk..',
  '.kdddddddddddk..',
  '..kdddddddddk...',
  '...kdddddddddk..',
  '....kdddddddk...',
  '...kdd...dddk...',
  '..kkk....kkkk...',
  '................',
], _cerberusPal);

// ── Alchemical Hydra ────────────────────────────────────────────
final _hydraIdle = _parse([
  'kgk.kBk.kgk.....',
  'kGgkkBBkkGgk....',
  '.kgkkkkkkkgk....',
  '..k.kBBBBk.k....',
  '.....kBBBk......',
  '....kBBBBBk.....',
  '...kBBgBBgBk....',
  '...kBBBBBBBk....',
  '...kBBBBBBBk....',
  '....kBBBBBk.....',
  '....kBBBBBk.....',
  '.....kBBBk......',
  '.....kBB.Bk.....',
  '....kkB..Bkk....',
  '................',
  '................',
], _hydraPal);

final _hydraAtk = _parse([
  'kgk.kBk.kgk.....',
  'kGgkkBBkkGgk....',
  '.kgkkkkkkkgk....',
  '..k.kBBBBk.k....',
  '.....kBBBk......',
  '..kkBBBBBBBkk...',
  '.kBBBgBBBgBBBk..',
  '.kBBBBBBBBBBBk..',
  '..kBBBBBBBBBk...',
  '....kBBBBBk.....',
  '....kBBBBBk.....',
  '.....kBBBk......',
  '....kBB...Bk....',
  '...kkB....Bkk...',
  '................',
  '................',
], _hydraPal);

// ═══════════════════════════════════════════════════════════════
// MONSTER SPRITE INDEX
// ═══════════════════════════════════════════════════════════════

final monsterSprites = <String, List<PixelGrid>>{
  'chicken': [_chickenIdle, _chickenAtk],
  'cow': [_cowIdle, _cowAtk],
  'goblin': [_goblinIdle, _goblinAtk],
  'guard': [_guardIdle, _guardAtk],
  'hill_giant': [_hillGiantIdle, _hillGiantAtk],
  'moss_giant': [_mossGiantIdle, _mossGiantAtk],
  'lesser_demon': [_lesserDemonIdle, _lesserDemonAtk],
  'greater_demon': [_greaterDemonIdle, _greaterDemonAtk],
  'black_dragon': [_blackDragonIdle, _blackDragonAtk],
  'tztok_jad': [_jadIdle, _jadAtk],
  'dust_devil': [_dustDevilIdle, _dustDevilAtk],
  'wyvern': [_wyvernIdle, _wyvernAtk],
  'abyssal_demon': [_abyssalDemonIdle, _abyssalDemonAtk],
  'cerberus': [_cerberusIdle, _cerberusAtk],
  'hydra': [_hydraIdle, _hydraAtk],
};

// ═══════════════════════════════════════════════════════════════
// PLAYER AVATAR
// ═══════════════════════════════════════════════════════════════

// ── Base body (skin + outline) ──────────────────────────────────
final _bodyPal = <String, Color>{
  'k': _k, 's': _s, 'h': const Color(0xFF5D4037), // hair
};

final _baseBody = _parse([
  '................',
  '.....kkkk.......',
  '....khhhhk......',
  '....khhhhk......',
  '....kssskk......',
  '....kskskk......',
  '....kssskk......',
  '.....ksk........',
  '................', // torso row 0 — filled by armor
  '................', // torso row 1
  '................', // torso row 2
  '................', // torso row 3
  '................', // legs row 0
  '................', // legs row 1
  '.....ks.sk......',
  '.....kk.kk......',
], _bodyPal);

// ── Armor overlays by tier ──────────────────────────────────────
// Each returns rows 8-13 (torso + legs) as a partial grid

class _ArmorDef {
  final Color primary;
  final Color secondary;
  final Color highlight;
  const _ArmorDef(this.primary, this.secondary, this.highlight);
}

const _armorTiers = <_ArmorDef>[
  _ArmorDef(Color(0xFF8B4513), Color(0xFFA0522D), Color(0xFFCD853F)), // Bronze
  _ArmorDef(Color(0xFF808080), Color(0xFFA9A9A9), Color(0xFFC0C0C0)), // Iron
  _ArmorDef(Color(0xFF696969), Color(0xFF808080), Color(0xFFB0B0B0)), // Steel
  _ArmorDef(Color(0xFF1A1A2E), Color(0xFF2D2D44), Color(0xFF454560)), // Black
  _ArmorDef(Color(0xFF3949AB), Color(0xFF5C6BC0), Color(0xFF7986CB)), // Mithril
  _ArmorDef(Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A)), // Adamant
  _ArmorDef(Color(0xFF00838F), Color(0xFF00ACC1), Color(0xFF4DD0E1)), // Rune
  _ArmorDef(Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFFF8A80)), // Dragon
  _ArmorDef(Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFBA68C8)), // Barrows
  _ArmorDef(Color(0xFF1A1A1A), Color(0xFF4A0072), Color(0xFFE040FB)), // Abyssal
  _ArmorDef(Color(0xFF5D4037), Color(0xFFD4A017), Color(0xFFFFD700)), // Bandos
  _ArmorDef(Color(0xFFE0E0E0), Color(0xFFFFFFFF), Color(0xFFFFD700)), // Armadyl
  _ArmorDef(
      Color(0xFF1A237E), Color(0xFF3F51B5), Color(0xFFE8EAF6)), // Ancestral
  _ArmorDef(
      Color(0xFFBDBDBD), Color(0xFFE0E0E0), Color(0xFFFFD700)), // Justiciar
  _ArmorDef(Color(0xFF263238), Color(0xFF455A64), Color(0xFFFFD700)), // Torva
  _ArmorDef(Color(0xFF1B5E20), Color(0xFF66BB6A), Color(0xFFFFD700)), // Masori
  _ArmorDef(Color(0xFF311B92), Color(0xFF7C4DFF), Color(0xFFE8EAF6)), // Virtus
  _ArmorDef(Color(0xFF880E4F), Color(0xFFE91E63), Color(0xFFF8BBD0)), // Vestas
  _ArmorDef(Color(0xFF3E2723), Color(0xFF6D4C41), Color(0xFFFFD700)), // Statius
  _ArmorDef(
      Color(0xFF004D40), Color(0xFF26A69A), Color(0xFFE0F2F1)), // Morrigans
];

List<List<Color?>> _armorRows(_ArmorDef a) {
  const k = _k;
  final p = a.primary;
  final s = a.secondary;
  final h = a.highlight;
  return [
    // row 8: shoulders
    [null, null, null, k, k, p, s, s, s, p, k, k, null, null, null, null],
    // row 9: upper torso
    [null, null, null, k, p, s, h, h, s, p, k, null, null, null, null, null],
    // row 10: mid torso
    [null, null, null, k, p, s, s, s, s, p, k, null, null, null, null, null],
    // row 11: lower torso
    [
      null,
      null,
      null,
      null,
      k,
      p,
      s,
      s,
      p,
      k,
      null,
      null,
      null,
      null,
      null,
      null
    ],
    // row 12: upper legs
    [
      null,
      null,
      null,
      null,
      k,
      p,
      k,
      k,
      p,
      k,
      null,
      null,
      null,
      null,
      null,
      null
    ],
    // row 13: lower legs
    [
      null,
      null,
      null,
      null,
      k,
      p,
      null,
      null,
      p,
      k,
      null,
      null,
      null,
      null,
      null,
      null
    ],
  ];
}

// ── Weapon overlays ─────────────────────────────────────────────
// Returns pixels to overlay on the right side of the sprite.
// Each weapon has 3 frames: idle, swing1, swing2

typedef WeaponFrame = Map<(int, int), Color>; // (row, col) → color

// Melee sword
final _swordIdle = <(int, int), Color>{
  (7, 11): _S, (7, 12): _S, // handle
  (6, 13): _w, (5, 14): _w, (4, 15): _w, // blade
};
final _swordSwing1 = <(int, int), Color>{
  (7, 11): _S, (8, 12): _S, // handle
  (9, 13): _w, (10, 14): _w, (11, 15): _w, // blade swung down
};
final _swordSwing2 = <(int, int), Color>{
  (8, 11): _S, (8, 12): _S, // handle
  (8, 13): _w, (8, 14): _w, (8, 15): _w, // blade horizontal
};

// Ranged bow
final _bowIdle = <(int, int), Color>{
  (6, 11): _n, (7, 11): _n, (8, 11): _n, (9, 11): _n, (10, 11): _n, // bow
  (6, 12): _N, (10, 12): _N, // string
  (8, 12): _S, (8, 13): _S, (8, 14): _S, // arrow
};
final _bowDraw = <(int, int), Color>{
  (6, 11): _n, (7, 11): _n, (8, 11): _n, (9, 11): _n, (10, 11): _n,
  (6, 12): _N, (10, 12): _N, (7, 12): _N, (9, 12): _N,
  (8, 12): _S, (8, 13): _S, // arrow pulled back
};
final _bowRelease = <(int, int), Color>{
  (6, 11): _n, (7, 11): _n, (8, 11): _n, (9, 11): _n, (10, 11): _n,
  (6, 12): _N, (10, 12): _N,
  (8, 13): _S, (8, 14): _S, (8, 15): _S, // arrow flying
};

// Magic staff
final _staffIdle = <(int, int), Color>{
  (5, 11): _p, (5, 12): _P, // orb
  (6, 11): _n, (7, 11): _n, (8, 11): _n, (9, 11): _n, (10, 11): _n, // shaft
};
final _staffCast1 = <(int, int), Color>{
  (5, 11): _p, (5, 12): _P,
  (6, 11): _n, (7, 11): _n, (8, 11): _n, (9, 11): _n, (10, 11): _n,
  (4, 13): _P, (3, 14): _b, // spark
};
final _staffCast2 = <(int, int), Color>{
  (5, 11): _p, (5, 12): _P,
  (6, 11): _n, (7, 11): _n, (8, 11): _n, (9, 11): _n, (10, 11): _n,
  (3, 14): _b, (2, 15): _B, (4, 13): _P, (3, 13): _B, // bigger spark
};

final _weaponFrames = <TrainingStyle, List<WeaponFrame>>{
  TrainingStyle.attack: [_swordIdle, _swordSwing1, _swordSwing2],
  TrainingStyle.strength: [_swordIdle, _swordSwing1, _swordSwing2],
  TrainingStyle.defence: [_swordIdle, _swordSwing1, _swordSwing2],
  TrainingStyle.balanced: [_swordIdle, _swordSwing1, _swordSwing2],
  TrainingStyle.ranged: [_bowIdle, _bowDraw, _bowRelease],
  TrainingStyle.magic: [_staffIdle, _staffCast1, _staffCast2],
};

// ── Equipment → Armor Tier mapping ───────────────────────────────────

const _bodyToTier = <String, int>{
  'bronze_platebody': 0,
  'iron_platebody': 1,
  'steel_platebody': 2,
  'mithril_platebody': 4,
  'adamant_platebody': 5,
  'rune_platebody': 6,
  'fighter_torso': 7,
  'bandos_chestplate': 10,
  'torva_platebody': 14,
  'leather_body': 1,
  'green_dhide_body_eq': 5,
  'black_dhide_body_eq': 3,
  'armadyl_chestplate': 11,
  'wizard_robe_top': 4,
  'mystic_robe_top': 4,
  'ahrims_robetop': 8,
  'ancestral_robe_top': 12,
};

// ── Equipment → Weapon overlay mapping ─────────────────────────────

List<WeaponFrame> _coloredSword(Color blade, Color handle) => [
      {
        (7, 11): handle,
        (7, 12): handle,
        (6, 13): blade,
        (5, 14): blade,
        (4, 15): blade
      },
      {
        (7, 11): handle,
        (8, 12): handle,
        (9, 13): blade,
        (10, 14): blade,
        (11, 15): blade
      },
      {
        (8, 11): handle,
        (8, 12): handle,
        (8, 13): blade,
        (8, 14): blade,
        (8, 15): blade
      },
    ];

List<WeaponFrame> _coloredBow(Color wood, Color string, Color arrow) => [
      {
        (6, 11): wood,
        (7, 11): wood,
        (8, 11): wood,
        (9, 11): wood,
        (10, 11): wood,
        (6, 12): string,
        (10, 12): string,
        (8, 12): arrow,
        (8, 13): arrow,
        (8, 14): arrow
      },
      {
        (6, 11): wood,
        (7, 11): wood,
        (8, 11): wood,
        (9, 11): wood,
        (10, 11): wood,
        (6, 12): string,
        (10, 12): string,
        (7, 12): string,
        (9, 12): string,
        (8, 12): arrow,
        (8, 13): arrow
      },
      {
        (6, 11): wood,
        (7, 11): wood,
        (8, 11): wood,
        (9, 11): wood,
        (10, 11): wood,
        (6, 12): string,
        (10, 12): string,
        (8, 13): arrow,
        (8, 14): arrow,
        (8, 15): arrow
      },
    ];

List<WeaponFrame> _coloredStaff(Color orb, Color orbLight, Color shaft) => [
      {
        (5, 11): orb,
        (5, 12): orbLight,
        (6, 11): shaft,
        (7, 11): shaft,
        (8, 11): shaft,
        (9, 11): shaft,
        (10, 11): shaft
      },
      {
        (5, 11): orb,
        (5, 12): orbLight,
        (6, 11): shaft,
        (7, 11): shaft,
        (8, 11): shaft,
        (9, 11): shaft,
        (10, 11): shaft,
        (4, 13): orbLight,
        (3, 14): const Color(0xFF2196F3)
      },
      {
        (5, 11): orb,
        (5, 12): orbLight,
        (6, 11): shaft,
        (7, 11): shaft,
        (8, 11): shaft,
        (9, 11): shaft,
        (10, 11): shaft,
        (3, 14): const Color(0xFF2196F3),
        (2, 15): const Color(0xFF64B5F6),
        (4, 13): orbLight,
        (3, 13): const Color(0xFF64B5F6)
      },
    ];

List<WeaponFrame> _whipFrames(Color cord) => [
      {(7, 11): _S, (7, 12): _S, (6, 13): cord, (5, 14): cord, (4, 15): cord},
      {
        (7, 11): _S,
        (8, 12): cord,
        (9, 13): cord,
        (10, 14): cord,
        (11, 15): cord
      },
      {(8, 11): _S, (8, 12): cord, (8, 13): cord, (7, 14): cord, (6, 15): cord},
    ];

final _weaponIdToFrames = <String, List<WeaponFrame>>{
  // Bronze→Rune scimitars
  'bronze_scimitar': _coloredSword(const Color(0xFFCD853F), _S),
  'iron_scimitar': _coloredSword(const Color(0xFFC0C0C0), _S),
  'steel_scimitar': _coloredSword(const Color(0xFFB0B0B0), _S),
  'mithril_scimitar': _coloredSword(const Color(0xFF7986CB), _S),
  'adamant_scimitar': _coloredSword(const Color(0xFF66BB6A), _S),
  'rune_scimitar': _coloredSword(const Color(0xFF4DD0E1), _S),
  'dragon_scimitar':
      _coloredSword(const Color(0xFFFF8A80), const Color(0xFFB71C1C)),
  // High-tier melee
  'abyssal_whip_eq': _whipFrames(const Color(0xFFFF5252)),
  'tentacle_whip': _whipFrames(const Color(0xFF3F51B5)),
  'ghrazi_rapier': _coloredSword(_w, const Color(0xFFFFD700)),
  'dragon_claws':
      _coloredSword(const Color(0xFFFF8A80), const Color(0xFFB71C1C)),
  'elder_maul': _coloredSword(_S, _n),
  // Ranged
  'shortbow': _coloredBow(_n, _N, _S),
  'maple_shortbow': _coloredBow(_n, _N, _S),
  'magic_shortbow': _coloredBow(const Color(0xFF7B1FA2), _N, _S),
  'rune_crossbow': _coloredBow(const Color(0xFF00838F), _N, _S),
  'armadyl_crossbow': _coloredBow(_w, const Color(0xFFFFD700), _S),
  'twisted_bow':
      _coloredBow(const Color(0xFF8D6E63), const Color(0xFFFFD700), _S),
  'dragon_hunter_crossbow': _coloredBow(const Color(0xFFB71C1C), _N, _S),
  // Magic
  'staff_of_fire':
      _coloredStaff(const Color(0xFFFF5252), const Color(0xFFD4A017), _n),
  'mystic_fire_staff':
      _coloredStaff(const Color(0xFFFF5252), const Color(0xFFD4A017), _n),
  'ancient_staff':
      _coloredStaff(const Color(0xFF9C27B0), const Color(0xFFCE93D8), _n),
  'trident_of_the_seas':
      _coloredStaff(const Color(0xFF2196F3), const Color(0xFF64B5F6), _n),
  'sanguinesti_staff':
      _coloredStaff(const Color(0xFFB71C1C), const Color(0xFFFF5252), _n),
  'kodai_wand':
      _coloredStaff(const Color(0xFF2196F3), const Color(0xFF64B5F6), _n),
};

// Determine weapon category from equipped weapon ID
String _weaponCategory(String? weaponId) {
  if (weaponId == null) return 'melee';
  const rangedIds = {
    'shortbow',
    'maple_shortbow',
    'magic_shortbow',
    'rune_crossbow',
    'armadyl_crossbow',
    'twisted_bow',
    'dragon_hunter_crossbow'
  };
  const magicIds = {
    'staff_of_fire',
    'mystic_fire_staff',
    'ancient_staff',
    'trident_of_the_seas',
    'sanguinesti_staff',
    'kodai_wand'
  };
  if (rangedIds.contains(weaponId)) return 'ranged';
  if (magicIds.contains(weaponId)) return 'magic';
  return 'melee';
}

// ── Compositing ───────────────────────────────────────────────────

/// Build a complete player sprite for the given gear level, style, and frame.
PixelGrid getPlayerSprite(int gearLevel, TrainingStyle style, {int frame = 0}) {
  // Deep-copy base body
  final grid = _baseBody.map((row) => List<Color?>.from(row)).toList();

  // Overlay armor
  final tierIdx = gearLevel <= 0 ? 0 : ((gearLevel - 1) % _armorTiers.length);
  final armor = _armorRows(_armorTiers[tierIdx]);
  for (int i = 0; i < armor.length; i++) {
    final row = 8 + i;
    if (row >= grid.length) break;
    for (int x = 0; x < armor[i].length && x < 16; x++) {
      if (armor[i][x] != null) grid[row][x] = armor[i][x];
    }
  }

  // Overlay weapon
  final frames = _weaponFrames[style] ?? _weaponFrames[TrainingStyle.balanced]!;
  final weaponFrame = frames[frame.clamp(0, frames.length - 1)];
  for (final entry in weaponFrame.entries) {
    final (wy, wx) = entry.key;
    if (wy >= 0 && wy < 16 && wx >= 0 && wx < 16) {
      grid[wy][wx] = entry.value;
    }
  }

  // Prestige glow: if gear cycles past tier list, add sparkle
  final cycle = gearLevel <= 0 ? 0 : (gearLevel - 1) ~/ _armorTiers.length;
  if (cycle > 0) {
    final sparkle = _armorTiers[tierIdx].highlight;
    // Add corner sparkles that grow with cycle count
    final spots = <(int, int)>[
      (1, 10),
      (2, 11),
      (0, 8),
      (14, 10),
      (13, 11),
      (15, 8),
    ];
    for (int i = 0; i < spots.length && i < cycle * 2; i++) {
      final (sy, sx) = spots[i];
      if (sy >= 0 && sy < 16 && sx >= 0 && sx < 16 && grid[sy][sx] == null) {
        grid[sy][sx] = sparkle;
      }
    }
  }

  return grid;
}

/// Get all player frames (idle + attack frames) for animation.
List<PixelGrid> getPlayerFrames(int gearLevel, TrainingStyle style) {
  final frames = _weaponFrames[style] ?? _weaponFrames[TrainingStyle.balanced]!;
  return List.generate(
    frames.length,
    (i) => getPlayerSprite(gearLevel, style, frame: i),
  );
}

// ── Equipment-aware compositing ─────────────────────────────────

/// Build a player sprite using actual equipped item IDs.
/// [equipment] is a `Map<slotName, itemId>` from IdleGameState.equipment.
/// [style] is the current TrainingStyle (used as fallback for weapon type).
PixelGrid getPlayerSpriteFromEquipment(
  Map<String, String> equipment,
  TrainingStyle style, {
  int frame = 0,
}) {
  final grid = _baseBody.map((row) => List<Color?>.from(row)).toList();

  // Determine armor tier from equipped body piece
  final bodyId = equipment['body'];
  final tierIdx = (bodyId != null && _bodyToTier.containsKey(bodyId))
      ? _bodyToTier[bodyId]!
      : 0;
  final armor =
      _armorRows(_armorTiers[tierIdx.clamp(0, _armorTiers.length - 1)]);
  for (int i = 0; i < armor.length; i++) {
    final row = 8 + i;
    if (row >= grid.length) break;
    for (int x = 0; x < armor[i].length && x < 16; x++) {
      if (armor[i][x] != null) grid[row][x] = armor[i][x];
    }
  }

  // Determine weapon overlay from equipped weapon
  final weaponId = equipment['weapon'];
  List<WeaponFrame> weaponFrameList;

  if (weaponId != null && _weaponIdToFrames.containsKey(weaponId)) {
    weaponFrameList = _weaponIdToFrames[weaponId]!;
  } else {
    // Fallback: use weapon category to pick generic weapon type
    final cat = _weaponCategory(weaponId);
    switch (cat) {
      case 'ranged':
        weaponFrameList = _weaponFrames[TrainingStyle.ranged]!;
        break;
      case 'magic':
        weaponFrameList = _weaponFrames[TrainingStyle.magic]!;
        break;
      default:
        weaponFrameList =
            _weaponFrames[style] ?? _weaponFrames[TrainingStyle.balanced]!;
    }
  }

  final weaponFrame =
      weaponFrameList[frame.clamp(0, weaponFrameList.length - 1)];
  for (final entry in weaponFrame.entries) {
    final (wy, wx) = entry.key;
    if (wy >= 0 && wy < 16 && wx >= 0 && wx < 16) {
      grid[wy][wx] = entry.value;
    }
  }

  return grid;
}

/// Get all player frames using actual equipped items.
List<PixelGrid> getPlayerFramesFromEquipment(
  Map<String, String> equipment,
  TrainingStyle style,
) {
  // Determine frame count from weapon
  final weaponId = equipment['weapon'];
  int frameCount;
  if (weaponId != null && _weaponIdToFrames.containsKey(weaponId)) {
    frameCount = _weaponIdToFrames[weaponId]!.length;
  } else {
    final cat = _weaponCategory(weaponId);
    switch (cat) {
      case 'ranged':
        frameCount = _weaponFrames[TrainingStyle.ranged]!.length;
        break;
      case 'magic':
        frameCount = _weaponFrames[TrainingStyle.magic]!.length;
        break;
      default:
        frameCount =
            (_weaponFrames[style] ?? _weaponFrames[TrainingStyle.balanced]!)
                .length;
    }
  }
  return List.generate(
    frameCount,
    (i) => getPlayerSpriteFromEquipment(equipment, style, frame: i),
  );
}
