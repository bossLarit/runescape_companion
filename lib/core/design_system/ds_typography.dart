import 'package:flutter/widgets.dart';
import '../constants/app_colors.dart';

/// Typography tokens — named text styles for consistent hierarchy.
///
/// Font sizes used across the app follow this scale:
///   9 → micro, 10 → caption, 11 → body small, 12 → body,
///   13 → body large, 14 → subtitle, 15 → title, 18 → heading,
///   20 → heading large, 22 → display, 26 → display large
abstract final class AppTypography {
  // ── Display ─────────────────────────────────────────────────────────
  static const displayLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: kGold,
    letterSpacing: 4,
  );

  static const display = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: kGold,
  );

  // ── Headings ────────────────────────────────────────────────────────
  static const headingLg = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: kGold,
  );

  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: kGold,
  );

  static const headingSm = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: kCream,
  );

  // ── Titles & Subtitles ──────────────────────────────────────────────
  static const title = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: kCream,
  );

  static const subtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: kCream,
  );

  // ── Body ────────────────────────────────────────────────────────────
  static const bodyLg = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: kParchment,
  );

  static const body = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: kParchment,
  );

  static const bodySm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: kParchment,
  );

  // ── Captions & Micro ────────────────────────────────────────────────
  static const caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: kParchment,
  );

  static const micro = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: kParchment,
  );

  // ── Card headers (icon-aligned section labels) ──────────────────────
  static const cardTitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  // ── Bold variants ──────────────────────────────────────────────────
  static const bodyBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: kCream,
  );

  static const bodySmBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: kCream,
  );

  static const captionBold = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: kParchment,
  );

  // ── Muted / subdued ─────────────────────────────────────────────────
  static TextStyle muted(TextStyle base) =>
      base.copyWith(color: base.color?.withValues(alpha: 0.5));

  static TextStyle faded(TextStyle base) =>
      base.copyWith(color: base.color?.withValues(alpha: 0.3));

  // ── Color overrides ─────────────────────────────────────────────────
  static TextStyle gold(TextStyle base) => base.copyWith(color: kGold);

  static TextStyle green(TextStyle base) => base.copyWith(color: kGreen);

  static TextStyle red(TextStyle base) => base.copyWith(color: kRed);

  static TextStyle orange(TextStyle base) => base.copyWith(color: kOrange);
}
