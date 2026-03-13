// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import '../domain/td_models.dart';

// ─── Compact pixel art format ───────────────────────────────────
// Each sprite row is a string of chars. A char maps to a color via palette.
// '.' = transparent. Width is determined by the longest row.

typedef PixelGrid = List<List<Color?>>;

PixelGrid _parse(List<String> rows, Map<String, Color> pal) {
  final w = rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);
  return rows.map((row) {
    final chars = row.padRight(w).substring(0, w).split('');
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
const _t = Color(0xFF5C4033); // dark brown (timber)
const _T = Color(0xFF8B5E3C); // medium brown (timber)

// ─── Tower Palettes ─────────────────────────────────────────────

final _archerPal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  't': _t,
  'T': _T,
  'g': _g,
  'G': _G,
  'o': _o,
  'w': _w,
  'd': _d,
};

final _magePal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'b': _b,
  'B': _B,
  'p': _p,
  'P': _P,
  's': _S,
  'S': _d,
  'w': _w,
  'o': _o,
};

final _warriorPal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'S': _S,
  'd': _d,
  'r': _r,
  'R': _R,
  'o': _o,
  'w': _w,
};

final _housePal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  't': _t,
  'T': _T,
  'o': _o,
  'w': _w,
  'r': _r,
};

// ─── Tower Sprites (16×16 building style) ────────────────────────

final towerSprites = <TowerType, PixelGrid>{
  TowerType.archer: _parse([
    '......kkkk......',
    '.....koookk.....',
    '....koooookk....',
    '...kkkkkkkkkk...',
    '...kTTTTTTTTk...',
    '...kTTTTTTTTk...',
    '...kTTkkkkTTk...',
    '...kTTk..kTTk...',
    '...kTTk..kTTk...',
    '...kTTk..kTTk...',
    '...kTTkkkkTTk...',
    '...kTTTTTTTTk...',
    '...kttttttttk...',
    '...kttttttttk...',
    '..kkkkkkkkkkkk..',
    '..knnnnnnnnnnk..',
  ], _archerPal),
  TowerType.mage: _parse([
    '.......kk.......',
    '......kPPk......',
    '.....kPppPk.....',
    '......kPPk......',
    '......kbbk......',
    '.....kbbbbk.....',
    '....kkkkkkkk....',
    '...ksssssssSk...',
    '...ksssssssSk...',
    '...ksskkkksSk...',
    '...ksskbbksSk...',
    '...ksskbbksSk...',
    '...ksskkkksSk...',
    '...ksssssssSk...',
    '..kkkkkkkkkkkk..',
    '..kSSSSSSSSSSk..',
  ], _magePal),
  TowerType.warrior: _parse([
    '...kk......kk...',
    '...kdk....kdk...',
    '..kkdkkkkkdkk...',
    '..kdddddddddk..',
    '..kdddddddddk..',
    '..kddSSSSdddk..',
    '..kddSrrSdddk..',
    '..kddSrrSdddk..',
    '..kddSSSSdddk..',
    '..kdddddddddk..',
    '..kddkkkkdddk..',
    '..kddk..kdddk..',
    '..kddk..kdddk..',
    '..kddkkkkdddk..',
    '.kkkkkkkkkkkkk..',
    '.kNNNNNNNNNNNk..',
  ], _warriorPal),
  TowerType.house: _parse([
    '................',
    '......kkkk......',
    '.....kTTTTk.....',
    '....kTTTTTTk....',
    '...kTTTTTTTTk...',
    '..kkkkkkkkkkkk..',
    '..kttttttttttk..',
    '..kttttttttttk..',
    '..kttkkkkttttk..',
    '..kttkNNkttttk..',
    '..kttkNNkttttk..',
    '..kttkkkkttttk..',
    '..kttttttttttk..',
    '..kttttttttttk..',
    '..kkkkkkkkkkkk..',
    '..knnnnnnnnnnk..',
  ], _housePal),
};

// ─── Tier 2 Tower Palettes (Lv 4–7) ─────────────────────────────

final _archerT2Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  't': const Color(0xFF3E6B8A),
  'T': const Color(0xFF5A9CC0),
  'g': _g,
  'G': _G,
  'o': _o,
  'w': _w,
  'd': _d,
};
final _mageT2Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'b': const Color(0xFF7B1FA2),
  'B': const Color(0xFFAB47BC),
  'p': const Color(0xFFE040FB),
  'P': const Color(0xFFF48FB1),
  's': _S,
  'S': _d,
  'w': _w,
  'o': _o,
};
final _warriorT2Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'S': const Color(0xFFDAA520),
  'd': const Color(0xFF555555),
  'r': _r,
  'R': _R,
  'o': _o,
  'w': _w,
};
final _houseT2Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  't': const Color(0xFF6D4C41),
  'T': const Color(0xFFA1887F),
  'o': _o,
  'w': _w,
  'r': _r,
  'S': _S,
};

// ─── Tier 3 Tower Palettes (Lv 8+) ──────────────────────────────

final _archerT3Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  't': const Color(0xFF8B0000),
  'T': const Color(0xFFB22222),
  'g': _g,
  'G': _G,
  'o': _y,
  'w': _w,
  'd': _d,
};
final _mageT3Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'b': const Color(0xFF212121),
  'B': const Color(0xFF424242),
  'p': const Color(0xFFFF4081),
  'P': const Color(0xFFFF80AB),
  's': _S,
  'S': _d,
  'w': _w,
  'o': _o,
};
final _warriorT3Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  'S': const Color(0xFFB71C1C),
  'd': const Color(0xFF333333),
  'r': const Color(0xFFFFD700),
  'R': _y,
  'o': _o,
  'w': _w,
};
final _houseT3Pal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  't': const Color(0xFF4E342E),
  'T': const Color(0xFFD4A017),
  'o': _y,
  'w': _w,
  'r': _r,
  'S': _S,
};

// ─── Tier 2 Tower Sprites ───────────────────────────────────────

final towerSpriteTier2 = <TowerType, PixelGrid>{
  TowerType.archer: _parse([
    '......kkkk......',
    '.....koookk.....',
    '....koooookk....',
    '...kkkkkkkkkk...',
    '...kTTTTTTTTk...',
    '...kTToTToTTk...',
    '...kTTkkkkTTk...',
    '...kTTk..kTTk...',
    '...kTTk..kTTk...',
    '...kTTk..kTTk...',
    '...kTTkkkkTTk...',
    '...kTToTToTTk...',
    '...kttttttttk...',
    '...kttttttttk...',
    '..kkkkkkkkkkkk..',
    '..knnnnnnnnnnk..',
  ], _archerT2Pal),
  TowerType.mage: _parse([
    '.......kk.......',
    '......kPPk......',
    '.....kPppPk.....',
    '......kPPk......',
    '......kbbk......',
    '.....kbbbbk.....',
    '....kkkkkkkk....',
    '...ksssssssSk...',
    '...ksssPsssSk...',
    '...ksskkkksSk...',
    '...ksskbbksSk...',
    '...ksskbbksSk...',
    '...ksskkkksSk...',
    '...ksssssssSk...',
    '..kkkkkkkkkkkk..',
    '..kSSSSSSSSSSk..',
  ], _mageT2Pal),
  TowerType.warrior: _parse([
    '...kk......kk...',
    '...kdk....kdk...',
    '..kkdkkkkkdkk...',
    '..kdddddddddk..',
    '..kddoddodddk..',
    '..kddSSSSdddk..',
    '..kddSrrSdddk..',
    '..kddSrrSdddk..',
    '..kddSSSSdddk..',
    '..kddoddodddk..',
    '..kddkkkkdddk..',
    '..kddk..kdddk..',
    '..kddk..kdddk..',
    '..kddkkkkdddk..',
    '.kkkkkkkkkkkkk..',
    '.kNNNNNNNNNNNk..',
  ], _warriorT2Pal),
  TowerType.house: _parse([
    '..........kk....',
    '......kkkkkSk...',
    '.....kTTTTk.k...',
    '....kTTTTTTk....',
    '...kTTTTTTTTk...',
    '..kkkkkkkkkkkk..',
    '..kttttttttttk..',
    '..kttottottttk..',
    '..kttkkkkttttk..',
    '..kttkNNkttttk..',
    '..kttkNNkttttk..',
    '..kttkkkkttttk..',
    '..kttttttttttk..',
    '..kttttttttttk..',
    '..kkkkkkkkkkkk..',
    '..knnnnnnnnnnk..',
  ], _houseT2Pal),
};

// ─── Tier 3 Tower Sprites ───────────────────────────────────────

final towerSpriteTier3 = <TowerType, PixelGrid>{
  TowerType.archer: _parse([
    '..kk..kkkk..kk..',
    '..ko.koookk.ok..',
    '....koooookk....',
    '...kkkkkkkkkk...',
    '...kTToTToTTk...',
    '...kTToTToTTk...',
    '...kTTkkkkTTk...',
    '...kTTk..kTTk...',
    '...kTTk..kTTk...',
    '...kTTk..kTTk...',
    '...kTTkkkkTTk...',
    '...kTToTToTTk...',
    '...kttttttttk...',
    '...kttttttttk...',
    '..kkkkkkkkkkkk..',
    '..knnnnnnnnnnk..',
  ], _archerT3Pal),
  TowerType.mage: _parse([
    '......kppk......',
    '.....kpPPpk.....',
    '......kPPk......',
    '......kPPk......',
    '......kbbk......',
    '.....kbbbbk.....',
    '....kkkkkkkk....',
    '...ksssPPssSk...',
    '...ksssPPssSk...',
    '...ksskkkksSk...',
    '...ksskbbksSk...',
    '...ksskbbksSk...',
    '...ksskkkksSk...',
    '...ksssssssSk...',
    '..kkkkkkkkkkkk..',
    '..kSSSSSSSSSSk..',
  ], _mageT3Pal),
  TowerType.warrior: _parse([
    '..kkk....kkk....',
    '..kdkk..kkdk....',
    '..kkdkkkkkdkk...',
    '..kdddddddddk..',
    '..kddoddodddk..',
    '..kddSSSSdddk..',
    '..kddSrrSdddk..',
    '..kddSrrSdddk..',
    '..kddSSSSdddk..',
    '..kddoddodddk..',
    '..kddkkkkdddk..',
    '..kddk..kdddk..',
    '..kddk..kdddk..',
    '..kddkkkkdddk..',
    '.kkkkkkkkkkkkk..',
    '.kNNNNNNNNNNNk..',
  ], _warriorT3Pal),
  TowerType.house: _parse([
    '..........kk....',
    '......kkkkkSk...',
    '.....kTTTTk.k...',
    '....kTToTTTTk...',
    '...kTToTTTTTTk..',
    '..kkkkkkkkkkkk..',
    '..kttottottttk..',
    '..kttottottttk..',
    '..kttkkkkttttk..',
    '..kttkNNkttttk..',
    '..kttkNNkttttk..',
    '..kttkkkkttttk..',
    '..kttttttttttk..',
    '..kttttttttttk..',
    '..kkkkkkkkkkkk..',
    '..knnnnnnnnnnk..',
  ], _houseT3Pal),
};

// ─── New Tower Sprites (Cannon, Ballista, Poison Trap) ──────────

final _cannonPal = <String, Color>{
  'k': _k,
  'S': _S,
  'd': _d,
  'n': _n,
  'N': _N,
  'o': _o,
  'r': _r,
};
final _ballistaPal = <String, Color>{
  'k': _k,
  't': _t,
  'T': _T,
  'n': _n,
  'N': _N,
  'S': _S,
  'd': _d,
  'r': _r,
};
final _trapPal = <String, Color>{
  'k': _k,
  'g': _g,
  'G': _G,
  'n': _n,
  'N': _N,
  'p': _p,
};

final Map<TowerType, PixelGrid> newTowerSprites = {
  TowerType.cannon: _parse([
    '................',
    '................',
    '....kkkkkk......',
    '...kSSSSSSk.....',
    '..kSddddddSk...',
    '..kSddddddSk...',
    '..kSddooodSk...',
    '...kSSSSSSk.....',
    '....kkkkkk......',
    '...knnnnnnk.....',
    '..kNk....kNk....',
    '..kk......kk....',
    '................',
    '................',
    '................',
    '................',
  ], _cannonPal),
  TowerType.ballista: _parse([
    '................',
    '.......kk.......',
    '......kTTk......',
    '.....kTTTTk.....',
    '....kttttttk....',
    '...kttSSSttk....',
    '...kttSdSttk....',
    '...kttSdSttk....',
    '...kttSSSttk....',
    '....kttttttk....',
    '.....kTTTTk.....',
    '....knnnnnnk....',
    '...kNk....kNk...',
    '...kk......kk...',
    '................',
    '................',
  ], _ballistaPal),
  TowerType.poisonTrap: _parse([
    '................',
    '................',
    '................',
    '................',
    '....kkkkkk......',
    '...kGGGGGGk.....',
    '...kGgppgGk.....',
    '...kGpggpGk.....',
    '...kGgppgGk.....',
    '...kGGGGGGk.....',
    '....kkkkkk......',
    '.....knnk.......',
    '................',
    '................',
    '................',
    '................',
  ], _trapPal),
};

// ─── Enemy Palettes ─────────────────────────────────────────────

final _chickenPal = <String, Color>{
  'k': _k,
  'w': _w,
  'r': _r,
  'o': _o,
  'y': _y
};
final _goblinPal = <String, Color>{'k': _k, 'g': _g, 'G': _G, 'n': _n, 's': _s};
final _guardPal = <String, Color>{
  'k': _k,
  's': _s,
  'S': _S,
  'd': _d,
  'b': _b,
  'o': _o
};
final _hillGiantPal = <String, Color>{
  'k': _k,
  'n': _n,
  'N': _N,
  's': _s,
  'S': _S
};
final _mossGiantPal = <String, Color>{
  'k': _k,
  'g': _g,
  'G': _G,
  'n': _n,
  'N': _N
};
final _lesserDemonPal = <String, Color>{
  'k': _k,
  'r': _r,
  'R': _R,
  'o': _o,
  'y': _y
};
final _greaterDemonPal = <String, Color>{
  'k': _k,
  'r': const Color(0xFF8B0000),
  'R': _r,
  'o': _o,
  'y': _y
};
final _dragonPal = <String, Color>{
  'k': _k,
  'd': _d,
  'S': _S,
  'r': _r,
  'R': _R,
  'o': _o
};
final _jadPal = <String, Color>{
  'k': _k,
  'r': _r,
  'R': _R,
  'o': _o,
  'y': _y,
  'n': _n,
  'N': _N
};

// ─── Enemy Sprites (16×16) ──────────────────────────────────────

final enemySprites = <String, PixelGrid>{
  'chicken': _parse([
    '......kk........',
    '.....kwwk.......',
    '.....kwwk.......',
    '....kkwwkk......',
    '...kwwwwwk......',
    '...kwwwwwk......',
    '....kwwwk.......',
    '.....kwk........',
    '....ko.ok.......',
    '....kk.kk.......',
  ], _chickenPal),
  'goblin': _parse([
    '......kk........',
    '.....kggk.......',
    '.....kGGk.......',
    '......kk........',
    '....kknnkk......',
    '...knnnnnk......',
    '...knnnnnk......',
    '....kggk........',
    '...kggggk.......',
    '....kg.gk.......',
    '....kk.kk.......',
  ], _goblinPal),
  'guard': _parse([
    '......kk........',
    '.....kssk.......',
    '.....kssk.......',
    '......kk........',
    '...kkbbbbkk.....',
    '..kbbbbbbbbk....',
    '..kbbbobbbbk....',
    '...kkbbbbkk.....',
    '....kdddk.......',
    '...kdddddk......',
    '....kd.dk.......',
    '....kk.kk.......',
  ], _guardPal),
  'hill_giant': _parse([
    '.....kkkk.......',
    '....kssssk......',
    '....ksSsSk......',
    '....kssssk......',
    '.....kkkk.......',
    '...knnnnnnk.....',
    '..knnnnnnnk.....',
    '..knnnnnnk......',
    '...knnnnk.......',
    '..ksssssk.......',
    '...kk.kk........',
    '..kk...kk.......',
  ], _hillGiantPal),
  'moss_giant': _parse([
    '....kkkkk.......',
    '...kgGGgk.......',
    '...kGkkGk.......',
    '...kgGGgk.......',
    '....kkkkk.......',
    '..kkgggggkk.....',
    '.kgggggggggk....',
    '.kgggggggggk....',
    '..kkgggggkk.....',
    '...kgggk........',
    '..kk..kk........',
    '.kk....kk.......',
  ], _mossGiantPal),
  'lesser_demon': _parse([
    '..kk....kk......',
    '..krk..krk......',
    '...krkkkrk......',
    '....krrk........',
    '...kRrrRk.......',
    '...kRrrRk.......',
    '..kkrrrrkk......',
    '.krrrrrrrrk.....',
    '..kkrrrrkk......',
    '...krrrrk.......',
    '...kk..kk.......',
    '..kk....kk......',
  ], _lesserDemonPal),
  'greater_demon': _parse([
    '.kk......kk.....',
    '.krk....krk.....',
    '..krkkkkkrk.....',
    '...kkRRRkk......',
    '..kRRRRRRk......',
    '..kRRoRRRk......',
    '..kkRRRRkk......',
    '.kRRRRRRRRk.....',
    '..kkRRRRkk......',
    '...kRRRRk.......',
    '...kk..kk.......',
    '..kk....kk......',
  ], _greaterDemonPal),
  'black_dragon': _parse([
    '..kk.......kk...',
    '..kdk.....kdk...',
    '...kdkkkkkdk....',
    '....kkdddkk.....',
    '...kddSddddk...',
    '..kddddddddk...',
    '..kdddrdddddk..',
    '...kdddddddk...',
    '...kkddddkk....',
    '.kdk.kdddk.kdk.',
    '......kddk......',
    '.....kk..kk.....',
  ], _dragonPal),
  'tztok_jad': _parse([
    '..kk......kk....',
    '..kRk....kRk....',
    '...kRkkkkRk.....',
    '....kRRRRk......',
    '...kRoRRoRk.....',
    '..kRRRRRRRk.....',
    '..kRRyRRyRk.....',
    '..kRRRRRRRRk....',
    '.kNRRRRRRRNk....',
    '..kNRRRRRNk.....',
    '..kRR..RRk......',
    '.kk......kk.....',
  ], _jadPal),
};

// ─── Peasant Sprite ──────────────────────────────────────────────

final _peasantPal = <String, Color>{
  'k': _k,
  's': _s,
  'n': _n,
  'N': _N,
  'g': _g,
  'G': _G,
};

final peasantSprite = _parse([
  '....kk..',
  '...kssk.',
  '...kssk.',
  '....kk..',
  '..kgggk.',
  '..kgggk.',
  '..kkkkk.',
  '...knk..',
  '..knnk..',
  '..kk.kk.',
], _peasantPal);

// ─── Resource Node Sprites ───────────────────────────────────────

final _treePal = <String, Color>{
  'k': _k,
  'g': _g,
  'G': _G,
  'n': _n,
  'N': _N,
  't': _t,
  'T': _T,
};

final _altarPal = <String, Color>{
  'k': _k,
  'b': _b,
  'B': _B,
  'p': _p,
  'P': _P,
  'S': _S,
  'd': _d,
};

final _minePal = <String, Color>{
  'k': _k,
  'S': _S,
  'd': _d,
  'n': _n,
  'N': _N,
  'o': _o,
  'y': _y,
};

final nodeSprites = <NodeType, PixelGrid>{
  NodeType.tree: _parse([
    '....kkkkk.......',
    '...kGGGGGk......',
    '..kGGgGGGGk.....',
    '..kGGGGGGGk.....',
    '..kGGGgGGGk.....',
    '...kGGGGGk......',
    '....kkkkk.......',
    '......kk........',
    '.....kttk.......',
    '.....kttk.......',
    '.....kttk.......',
    '....knnnnk......',
  ], _treePal),
  NodeType.runeAltar: _parse([
    '......kk........',
    '.....kBBk.......',
    '....kBppBk......',
    '....kBPPBk......',
    '.....kBBk.......',
    '......kk........',
    '...kkSSSSkk.....',
    '..kSSSSSSSSk....',
    '..kSddddddSk...',
    '..kSddddddSk...',
    '..kSSSSSSSSk....',
    '..kkkkkkkkkk....',
  ], _altarPal),
  NodeType.mine: _parse([
    '...kkk..kkk.....',
    '..kSSSkSSSk.....',
    '.kSSddddSSSk...',
    '.kSddoddddSk...',
    '.kSddddyddSk...',
    '.kSSddddddSk...',
    '..kSSSSSSSk.....',
    '...kkkkkkk......',
    '....knnnnk......',
    '...knnnnnnk.....',
    '..knnnnnnnnk....',
    '..kkkkkkkkkk....',
  ], _minePal),
};

// ─── Garrison Sprite ─────────────────────────────────────────────

final _garrisonPal = <String, Color>{
  'k': _k,
  'S': _S,
  'd': _d,
  'n': _n,
  'N': _N,
  'o': _o,
  'y': _y,
  't': _t,
  'T': _T,
  'w': _w,
};

final garrisonSprite = _parse([
  '..kk..........kk',
  '..kSk........kSk',
  '..kSk..kkkk..kSk',
  '..kSk.koooyk.kSk',
  '.kkSkkkkkkkkkSkkk',
  '.kSSSSSSSSSSSSSSk',
  '.kSSddddddddddSk',
  '.kSSddddddddddSk',
  '.kSSddkkkkkkddSk',
  '.kSSddk....kddSk',
  '.kSSddk....kddSk',
  '.kSSddkkkkkkddSk',
  '.kSSddddddddddSk',
  '.kkkkkkkkkkkkkkkk',
  '.kNNNNNNNNNNNNNk',
  '.knnnnnnnnnnnnnnk',
], _garrisonPal);

// ─── Tower Slot (empty platform) ─────────────────────────────────

final _slotPal = <String, Color>{'k': _k, 'S': _S, 'N': _N, 'n': _n};

final emptySlotSprite = _parse([
  '..kkkkkkkkkk....',
  '.kSSSSSSSSSSk...',
  '.kSNNNNNNNNSk...',
  '.kSNNNNNNNNSk...',
  '.kSSSSSSSSSSk...',
  '..kkkkkkkkkk....',
], _slotPal);

// ─── Imp Sprite (treasure wave) ─────────────────────────────────

final _impPal = <String, Color>{
  'k': _k,
  'r': _r,
  'R': _R,
  'o': _o,
  'y': _y,
  's': _s,
};

final impSprite = _parse([
  '...kk..kk...',
  '..krk..krk..',
  '...krrrrk...',
  '...krRRrk...',
  '...krrrrk...',
  '....krrk....',
  '...krrrrk...',
  '....krrk....',
  '...kr..rk...',
  '...kk..kk...',
], _impPal);

// ─── Hero Sprite ────────────────────────────────────────────────

final _heroPal = <String, Color>{
  'k': _k,
  's': _s,
  'o': _o,
  'y': _y,
  'S': _S,
  'd': _d,
  'r': _r,
  'b': _b,
  'n': _n,
  'N': _N,
  'w': _w,
};

final heroSprite = _parse([
  '....kk......',
  '...kssk.....',
  '...kssk.....',
  '....kk......',
  '..kkSSkk....',
  '.kSSSSSSSk..',
  '.kSSdddSSk..',
  '..kkSSSkkork',
  '...kSSSk.kk.',
  '...knnk.....',
  '..knnnnk....',
  '..kk..kk....',
], _heroPal);

// ─── Wall Sprite ────────────────────────────────────────────────

final _wallPal = <String, Color>{
  'k': _k,
  'S': _S,
  'd': _d,
  'n': _n,
  'N': _N,
};

final wallSprite = _parse([
  'kkkkkkkkkkkkkkkk',
  'kSdSdSdSdSdSdSSk',
  'kNNNNNNNNNNNNNNk',
  'kSdSdSdSdSdSdSSk',
  'kNNNNNNNNNNNNNNk',
  'kkkkkkkkkkkkkkkk',
], _wallPal);

final wallDestroyedSprite = _parse([
  '..k...k...k.....',
  '.kSk.kdk.kSk....',
  '..k...k...k.....',
  '................',
  '..kN..kN..kN....',
  '..kk..kk..kk....',
], _wallPal);

// ─── Projectile Colors ──────────────────────────────────────────

Color projectileColor(ProjectileType type) => switch (type) {
      ProjectileType.arrow => const Color(0xFFCD7F32),
      ProjectileType.magicBolt => _b,
      ProjectileType.garrisonArrow => _S,
      ProjectileType.cannonBall => _d,
      ProjectileType.ballistaBolt => _t,
    };

Color projectileGlowColor(ProjectileType type) => switch (type) {
      ProjectileType.arrow => const Color(0xFFDEB887),
      ProjectileType.magicBolt => _B,
      ProjectileType.garrisonArrow => _w,
      ProjectileType.cannonBall => _S,
      ProjectileType.ballistaBolt => _T,
    };

double projectileSize(ProjectileType type) => switch (type) {
      ProjectileType.arrow => 3.0,
      ProjectileType.magicBolt => 4.5,
      ProjectileType.garrisonArrow => 3.5,
      ProjectileType.cannonBall => 5.0,
      ProjectileType.ballistaBolt => 4.0,
    };
