import 'package:flutter/widgets.dart';

/// Spacing tokens — consistent gaps, padding, and margins throughout the app.
///
/// Usage:
/// ```dart
/// const SizedBox(height: AppSpacing.md);
/// padding: const EdgeInsets.all(AppSpacing.lg);
/// ```
abstract final class AppSpacing {
  // ── Raw values ──────────────────────────────────────────────────────
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double huge = 32;

  // ── Semantic aliases ───────────────────────────────────────────────
  static const double cardPadding = 14;
  static const double screenPadding = 20;
  static const double sectionGap = 14;
  static const double inputGap = 14;

  // ── Pre-built EdgeInsets ───────────────────────────────────────────
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets screenInsets = EdgeInsets.all(screenPadding);

  // ── Gaps (SizedBox shortcuts) ──────────────────────────────────────
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);

  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);
}
