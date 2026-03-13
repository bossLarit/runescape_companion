import 'package:flutter/material.dart';

import '../../domain/td_models.dart';
import '../../data/td_game_data.dart';
import '../../data/td_pixel_art.dart';

// ─── Colors ──────────────────────────────────────────────────────

const _grassDark = Color(0xFF2D5A1E);
const _grassMid = Color(0xFF336823);
const _grassLight = Color(0xFF3A6B2A);
const _pathColor = Color(0xFF8B7355);
const _pathBorder = Color(0xFF6B5A45);
const _hpBarBg = Color(0xFF1A1208);
const _hpBarGreen = Color(0xFF4CAF50);
const _hpBarRed = Color(0xFFB33831);
const _dmgTextColor = Color(0xFFFFD700);
const _slotHighlight = Color(0xFFFFD700);
const _freezeTint = Color(0xFF64B5F6);

class TdGameCanvasPainter extends CustomPainter {
  final TdGameState state;

  TdGameCanvasPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawPath(canvas, size);
    _drawWalls(canvas, size);
    _drawResourceNodes(canvas, size);
    _drawTowerSlots(canvas, size);
    _drawGarrison(canvas, size);
    _drawHero(canvas, size);
    _drawPeasants(canvas, size);
    _drawEnemies(canvas, size);
    _drawProjectiles(canvas, size);
    _drawDamageNumbers(canvas, size);
    _drawRangeIndicator(canvas, size);
    _drawFreezeOverlay(canvas, size);
  }

  // ── Background ─────────────────────────────────────────────

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint();
    const tileSize = 16.0;
    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        final ix = (x / tileSize).floor();
        final iy = (y / tileSize).floor();
        final v = (ix + iy) % 3;
        paint.color = v == 0
            ? _grassDark
            : v == 1
                ? _grassMid
                : _grassLight;
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), paint);
      }
    }
  }

  // ── Path ───────────────────────────────────────────────────

  void _drawPath(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = _pathBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pathPaint = Paint()
      ..color = _pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(
        pathWaypoints[0].x * size.width, pathWaypoints[0].y * size.height);
    for (int i = 1; i < pathWaypoints.length; i++) {
      path.lineTo(
          pathWaypoints[i].x * size.width, pathWaypoints[i].y * size.height);
    }
    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, pathPaint);
  }

  // ── Walls ──────────────────────────────────────────────────

  void _drawWalls(Canvas canvas, Size size) {
    for (final wall in state.wallSlots) {
      final px = wall.x * size.width;
      final py = wall.y * size.height;
      if (wall.isBuilt) {
        _drawPixelGrid(canvas, wallSprite, px - 20, py - 8, 2.5);
        // HP bar
        const barW = 30.0;
        const barH = 3.0;
        final hpRatio = (wall.hp / wall.maxHp).clamp(0.0, 1.0);
        canvas.drawRect(Rect.fromLTWH(px - barW / 2, py - 14, barW, barH),
            Paint()..color = _hpBarBg);
        canvas.drawRect(
            Rect.fromLTWH(px - barW / 2, py - 14, barW * hpRatio, barH),
            Paint()..color = hpRatio > 0.5 ? _hpBarGreen : _hpBarRed);
      } else if (wall.isDestroyed) {
        _drawPixelGrid(canvas, wallDestroyedSprite, px - 20, py - 8, 2.5);
      } else {
        // Empty wall slot indicator
        canvas.drawCircle(
            Offset(px, py),
            8,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.1)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
    }
  }

  // ── Resource Nodes ─────────────────────────────────────────

  void _drawResourceNodes(Canvas canvas, Size size) {
    for (final node in state.resourceNodes) {
      final px = node.x * size.width;
      final py = node.y * size.height;
      final grid = nodeSprites[node.type];
      if (grid != null) {
        final spriteW = grid[0].length * 2.0;
        final spriteH = grid.length * 2.0;
        _drawPixelGrid(canvas, grid, px - spriteW / 2, py - spriteH / 2, 2.0);
      }
      // Label with tier name
      final label = nodeTierName(node.type, node.level);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: node.level >= 3
                ? const Color(0xFFFFD700)
                : node.level == 2
                    ? const Color(0xFF81C784)
                    : Colors.white.withValues(alpha: 0.7),
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py + 14));
      // Level stars
      if (node.level > 1) {
        final stars = '★' * node.level;
        final starTp = TextPainter(
          text: TextSpan(
            text: stars,
            style: TextStyle(
                color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                fontSize: 6),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        starTp.paint(canvas, Offset(px - starTp.width / 2, py + 22));
      }
    }
  }

  // ── Tower Slots ────────────────────────────────────────────

  void _drawTowerSlots(Canvas canvas, Size size) {
    for (int i = 0; i < state.towerSlots.length; i++) {
      final slot = state.towerSlots[i];
      final px = slot.x * size.width;
      final py = slot.y * size.height;

      if (slot.hasTower) {
        // Pick tiered sprite
        PixelGrid? grid;
        final type = slot.towerType!;
        if (type == TowerType.cannon ||
            type == TowerType.ballista ||
            type == TowerType.poisonTrap) {
          grid = newTowerSprites[type];
        } else if (slot.level >= 8) {
          grid = towerSpriteTier3[type] ?? towerSprites[type];
        } else if (slot.level >= 4) {
          grid = towerSpriteTier2[type] ?? towerSprites[type];
        } else {
          grid = towerSprites[type];
        }
        if (grid != null) {
          // Tier 3 glow ring
          if (slot.level >= 8 && type != TowerType.house) {
            canvas.drawCircle(
                Offset(px, py),
                22,
                Paint()
                  ..color = _slotHighlight.withValues(alpha: 0.15)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
          }
          final spriteW = grid[0].length * 2.5;
          final spriteH = grid.length * 2.5;
          _drawPixelGrid(canvas, grid, px - spriteW / 2, py - spriteH / 2, 2.5);
        }
        // Level label for all towers with level > 1
        if (slot.level > 1) {
          final tp = TextPainter(
            text: TextSpan(
              text: 'Lv${slot.level}',
              style: TextStyle(
                  color: slot.level >= 8
                      ? const Color(0xFFFF8C00)
                      : slot.level >= 4
                          ? const Color(0xFF81D4FA)
                          : _slotHighlight,
                  fontSize: 7,
                  fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(px - tp.width / 2, py + 22));
        }
        // Equipped loot indicator
        if (slot.equippedLootId != null) {
          canvas.drawCircle(Offset(px + 14, py - 14), 3,
              Paint()..color = const Color(0xFF4CAF50));
        }
      } else {
        _drawPixelGrid(canvas, emptySlotSprite, px - 20, py - 8, 2.5);
        if (state.selectedSlotIndex == i) {
          canvas.drawCircle(
              Offset(px, py),
              18,
              Paint()
                ..color = _slotHighlight.withValues(alpha: 0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);
        }
      }
    }
  }

  // ── Garrison ───────────────────────────────────────────────

  void _drawGarrison(Canvas canvas, Size size) {
    final px = garrisonX * size.width;
    final py = garrisonY * size.height;
    final spriteW = garrisonSprite[0].length * 2.5;
    final spriteH = garrisonSprite.length * 2.5;
    _drawPixelGrid(
        canvas, garrisonSprite, px - spriteW / 2, py - spriteH / 2, 2.5);

    const barW = 50.0;
    const barH = 5.0;
    final hpRatio = (state.garrison.hp / state.garrison.maxHp).clamp(0.0, 1.0);
    final barX = px - barW / 2;
    final barY = py - spriteH / 2 - 8;
    canvas.drawRect(
        Rect.fromLTWH(barX, barY, barW, barH), Paint()..color = _hpBarBg);
    canvas.drawRect(Rect.fromLTWH(barX, barY, barW * hpRatio, barH),
        Paint()..color = hpRatio > 0.5 ? _hpBarGreen : _hpBarRed);
    final hpTp = TextPainter(
      text: TextSpan(
        text: '${state.garrison.hp}/${state.garrison.maxHp}',
        style: const TextStyle(
            color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hpTp.paint(canvas, Offset(px - hpTp.width / 2, barY - 10));
  }

  // ── Hero ───────────────────────────────────────────────────

  void _drawHero(Canvas canvas, Size size) {
    final hero = state.hero;
    if (hero == null) return;
    final px = hero.x * size.width;
    final py = hero.y * size.height;
    if (hero.alive) {
      final spriteW = heroSprite[0].length * 2.0;
      final spriteH = heroSprite.length * 2.0;
      _drawPixelGrid(
          canvas, heroSprite, px - spriteW / 2, py - spriteH / 2, 2.0);
      // HP bar
      const barW = 20.0;
      const barH = 3.0;
      final hpRatio = (hero.hp / hero.maxHp).clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(px - barW / 2, py - 18, barW, barH),
          Paint()..color = _hpBarBg);
      canvas.drawRect(
          Rect.fromLTWH(px - barW / 2, py - 18, barW * hpRatio, barH),
          Paint()..color = hpRatio > 0.5 ? _hpBarGreen : _hpBarRed);
      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: 'Hero Lv${hero.damageLevel}',
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 6,
              fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py + 14));
    } else {
      // Dead indicator
      final tp = TextPainter(
        text: TextSpan(
          text: '💀 ${(hero.respawnTimer / 60).ceil()}s',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 7),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - 5));
    }
  }

  // ── Peasants ───────────────────────────────────────────────

  void _drawPeasants(Canvas canvas, Size size) {
    for (final p in state.peasants) {
      final px = p.x * size.width;
      final py = p.y * size.height;
      final spriteW = peasantSprite[0].length * 1.5;
      final spriteH = peasantSprite.length * 1.5;
      _drawPixelGrid(
          canvas, peasantSprite, px - spriteW / 2, py - spriteH / 2, 1.5);
    }
  }

  // ── Enemies ────────────────────────────────────────────────

  void _drawEnemies(Canvas canvas, Size size) {
    for (final enemy in state.enemies) {
      if (!enemy.alive) continue;
      final pos = positionOnPath(enemy.pathProgress);
      final px = pos.x * size.width;
      final py = pos.y * size.height;

      if (enemy.isTreasure) {
        _drawPixelGrid(canvas, impSprite, px - 9, py - 9, 1.5);
      } else {
        final def = enemyDefs[enemy.defIndex];
        final grid = enemySprites[def.id];
        if (grid != null) {
          _drawPixelGrid(canvas, grid, px - 12, py - 12, 1.5);
        } else {
          canvas.drawCircle(
              Offset(px, py), 6, Paint()..color = const Color(0xFFB33831));
        }
      }

      // Freeze tint
      if (state.freezeTicksLeft > 0) {
        canvas.drawCircle(Offset(px, py), 8,
            Paint()..color = _freezeTint.withValues(alpha: 0.3));
      }

      // Poison tint
      if (enemy.poisonTicksLeft > 0) {
        canvas.drawCircle(Offset(px, py), 7,
            Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.3));
      }

      // Shield indicator
      if (enemy.shielded) {
        canvas.drawCircle(
            Offset(px, py),
            10,
            Paint()
              ..color = const Color(0xFF90CAF9).withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
      }

      // HP bar
      const hpBarWidth = 20.0;
      const hpBarHeight = 3.0;
      final hpRatio = (enemy.hp / enemy.maxHp).clamp(0.0, 1.0);
      canvas.drawRect(
          Rect.fromLTWH(px - hpBarWidth / 2, py - 16, hpBarWidth, hpBarHeight),
          Paint()..color = _hpBarBg);
      canvas.drawRect(
        Rect.fromLTWH(
            px - hpBarWidth / 2, py - 16, hpBarWidth * hpRatio, hpBarHeight),
        Paint()
          ..color = enemy.isTreasure
              ? const Color(0xFFFFD700)
              : (hpRatio > 0.5 ? _hpBarGreen : _hpBarRed),
      );
    }
  }

  // ── Projectiles ────────────────────────────────────────────

  void _drawProjectiles(Canvas canvas, Size size) {
    for (final p in state.projectiles) {
      if (!p.active) continue;
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pSize = projectileSize(p.type);
      final color = projectileColor(p.type);
      final glow = projectileGlowColor(p.type);
      canvas.drawCircle(
          Offset(px, py),
          pSize + 2,
          Paint()
            ..color = glow.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(Offset(px, py), pSize, Paint()..color = color);
    }
  }

  // ── Damage Numbers ─────────────────────────────────────────

  void _drawDamageNumbers(Canvas canvas, Size size) {
    for (final d in state.damageNumbers) {
      final alpha = (d.ticksLeft / 40.0).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: '${d.amount}',
          style: TextStyle(
            color: _dmgTextColor.withValues(alpha: alpha),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                  color: Colors.black.withValues(alpha: alpha * 0.8),
                  blurRadius: 2)
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset(d.x * size.width - tp.width / 2,
              d.y * size.height - tp.height / 2));
    }
  }

  // ── Range Indicator ────────────────────────────────────────

  void _drawRangeIndicator(Canvas canvas, Size size) {
    final selIdx = state.selectedSlotIndex;
    if (selIdx == null || selIdx < 0 || selIdx >= state.towerSlots.length) {
      return;
    }
    final slot = state.towerSlots[selIdx];
    if (slot.isEmpty) return;
    if (slot.towerType == TowerType.house) return;
    final range = towerRangeAtLevel(slot.towerType!, slot.level);
    final rangePixels = range * size.height;
    final px = slot.x * size.width;
    final py = slot.y * size.height;
    canvas.drawCircle(
        Offset(px, py),
        rangePixels,
        Paint()
          ..color = _slotHighlight.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(px, py),
        rangePixels,
        Paint()
          ..color = _slotHighlight.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  // ── Freeze Overlay ─────────────────────────────────────────

  void _drawFreezeOverlay(Canvas canvas, Size size) {
    if (state.freezeTicksLeft <= 0) return;
    final alpha =
        (state.freezeTicksLeft / freezeDuration * 0.12).clamp(0.0, 0.12);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = _freezeTint.withValues(alpha: alpha));
  }

  // ── Pixel Grid Helper ──────────────────────────────────────

  void _drawPixelGrid(
      Canvas canvas, PixelGrid grid, double x, double y, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        final color = grid[row][col];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(
            Rect.fromLTWH(x + col * scale, y + row * scale, scale, scale),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TdGameCanvasPainter old) => true;
}

// ─── Hit Testing ─────────────────────────────────────────────────

int? hitTestTowerSlot(TdGameState state, Size size, Offset tapPos) {
  for (int i = 0; i < state.towerSlots.length; i++) {
    final slot = state.towerSlots[i];
    final px = slot.x * size.width;
    final py = slot.y * size.height;
    if ((tapPos - Offset(px, py)).distance < 24) return i;
  }
  return null;
}

int? hitTestResourceNode(TdGameState state, Size size, Offset tapPos) {
  for (int i = 0; i < state.resourceNodes.length; i++) {
    final node = state.resourceNodes[i];
    final px = node.x * size.width;
    final py = node.y * size.height;
    if ((tapPos - Offset(px, py)).distance < 20) return i;
  }
  return null;
}

int? hitTestWallSlot(TdGameState state, Size size, Offset tapPos) {
  for (int i = 0; i < state.wallSlots.length; i++) {
    final wall = state.wallSlots[i];
    final px = wall.x * size.width;
    final py = wall.y * size.height;
    if ((tapPos - Offset(px, py)).distance < 20) return i;
  }
  return null;
}
