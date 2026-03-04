import 'package:flutter/widgets.dart';

/// Border-radius tokens for consistent rounding across the app.
///
/// Usage:
/// ```dart
/// decoration: BoxDecoration(borderRadius: AppRadius.md);
/// ```
abstract final class AppRadius {
  // ── Raw doubles ─────────────────────────────────────────────────────
  static const double smValue = 4;
  static const double mdValue = 8;
  static const double lgValue = 12;
  static const double xlValue = 20;
  static const double circularValue = 999;

  // ── BorderRadius shortcuts ──────────────────────────────────────────
  static final BorderRadius xs = BorderRadius.circular(2);
  static final BorderRadius sm = BorderRadius.circular(smValue);
  static final BorderRadius md = BorderRadius.circular(mdValue);
  static final BorderRadius lg = BorderRadius.circular(lgValue);
  static final BorderRadius xl = BorderRadius.circular(xlValue);
  static final BorderRadius circular = BorderRadius.circular(circularValue);
}
