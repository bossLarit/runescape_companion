import 'package:flutter/widgets.dart';

/// Shadow tokens for consistent elevation and depth.
abstract final class AppShadows {
  /// Subtle card shadow — default for most surfaces.
  static final card = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Elevated panel — modals, overlays, popovers.
  static final elevated = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.4),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  /// Glow — used for highlighted / active elements (gold accent).
  static List<BoxShadow> glow(Color color, {double radius = 18}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: radius,
          offset: const Offset(0, 4),
        ),
      ];
}
