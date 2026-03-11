import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A 16×16 pixel grid is a List of 16 rows, each row a List of 16 Color? values.
/// null = transparent pixel.
typedef PixelGrid = List<List<Color?>>;

// ─── Static Sprite ──────────────────────────────────────────────

class PixelSprite extends StatelessWidget {
  final PixelGrid grid;
  final double scale;

  const PixelSprite({super.key, required this.grid, this.scale = 3});

  @override
  Widget build(BuildContext context) {
    final rows = grid.length;
    final cols = rows > 0 ? grid[0].length : 0;
    return CustomPaint(
      size: Size(cols * scale, rows * scale),
      painter: _PixelPainter(grid: grid, scale: scale),
    );
  }
}

class _PixelPainter extends CustomPainter {
  final PixelGrid grid;
  final double scale;
  final Color? flashColor;

  _PixelPainter({required this.grid, required this.scale, this.flashColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int y = 0; y < grid.length; y++) {
      final row = grid[y];
      for (int x = 0; x < row.length; x++) {
        final c = row[x];
        if (c == null) continue;
        if (flashColor != null) {
          paint.color = Color.lerp(c, flashColor, 0.6)!;
        } else {
          paint.color = c;
        }
        canvas.drawRect(
          Rect.fromLTWH(x * scale, y * scale, scale, scale),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter old) =>
      old.grid != grid || old.flashColor != flashColor;
}

// ─── Animated Sprite ────────────────────────────────────────────

class AnimatedPixelSprite extends StatefulWidget {
  /// All animation frames (index 0 = idle).
  final List<PixelGrid> frames;
  final double scale;

  /// Bump this to trigger an attack animation cycle.
  final int? attackTrigger;

  /// Bump this to trigger a hit-taken animation.
  final int? hitTrigger;

  const AnimatedPixelSprite({
    super.key,
    required this.frames,
    this.scale = 3,
    this.attackTrigger,
    this.hitTrigger,
  });

  @override
  State<AnimatedPixelSprite> createState() => _AnimatedPixelSpriteState();
}

class _AnimatedPixelSpriteState extends State<AnimatedPixelSprite>
    with TickerProviderStateMixin {
  int _currentFrame = 0;
  Timer? _frameTimer;

  // Hit shake
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;
  bool _isFlashing = false;

  int? _lastAttackTrigger;
  int? _lastHitTrigger;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
        if (mounted) setState(() => _isFlashing = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedPixelSprite oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Attack animation: cycle through frames 1..N then back to 0
    if (widget.attackTrigger != null &&
        widget.attackTrigger != _lastAttackTrigger &&
        widget.frames.length > 1) {
      _lastAttackTrigger = widget.attackTrigger;
      _playAttackFrames();
    }

    // Hit animation: shake + red flash
    if (widget.hitTrigger != null && widget.hitTrigger != _lastHitTrigger) {
      _lastHitTrigger = widget.hitTrigger;
      _playHitAnimation();
    }
  }

  void _playAttackFrames() {
    _frameTimer?.cancel();
    int frame = 1;
    _currentFrame = frame;
    if (mounted) setState(() {});

    _frameTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      frame++;
      if (frame >= widget.frames.length) {
        timer.cancel();
        if (mounted) setState(() => _currentFrame = 0);
        return;
      }
      if (mounted) setState(() => _currentFrame = frame);
    });
  }

  void _playHitAnimation() {
    setState(() => _isFlashing = true);
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grid = widget.frames[_currentFrame.clamp(0, widget.frames.length - 1)];
    final rows = grid.length;
    final cols = rows > 0 ? grid[0].length : 0;
    final w = cols * widget.scale;
    final h = rows * widget.scale;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        final shake = _shakeController.isAnimating
            ? sin(_shakeAnim.value * pi * 4) * 3
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(w, h),
        painter: _PixelPainter(
          grid: grid,
          scale: widget.scale,
          flashColor: _isFlashing ? Colors.red.shade300 : null,
        ),
      ),
    );
  }
}
