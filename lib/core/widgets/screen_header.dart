import 'package:flutter/material.dart';

/// Standardized screen header used across all feature screens.
///
/// Provides consistent layout: Title + optional character badge | Spacer | Action buttons
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? characterName;
  final List<Widget> actions;

  const ScreenHeader({
    super.key,
    required this.title,
    this.characterName,
    this.actions = const [],
  });

  static const _gold = Color(0xFFD4A017);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.headlineMedium),
        if (characterName != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person,
                    size: 13, color: _gold.withValues(alpha: 0.7)),
                const SizedBox(width: 5),
                Text(characterName!,
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        const Spacer(),
        ...actions,
      ],
    );
  }
}
