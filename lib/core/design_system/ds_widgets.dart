import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'ds_spacing.dart';
import 'ds_radius.dart';
import 'ds_typography.dart';

// ═══════════════════════════════════════════════════════════════════
//  DsCardHeader — icon + title row used at the top of every card
// ═══════════════════════════════════════════════════════════════════

class DsCardHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;

  const DsCardHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTypography.cardTitle.copyWith(color: color)),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsSectionHeader — larger heading used to separate page sections
// ═══════════════════════════════════════════════════════════════════

class DsSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const DsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTypography.heading),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: AppTypography.muted(AppTypography.body)),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsBadge — small colored label (e.g. style badges, tag badges)
// ═══════════════════════════════════════════════════════════════════

class DsBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const DsBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.sm,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsInfoChip — compact read-only chip (key-value pair)
// ═══════════════════════════════════════════════════════════════════

class DsInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const DsInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kParchment;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.06),
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c.withValues(alpha: 0.6)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: c.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsStatCard — metric display (value + label + icon)
// ═══════════════════════════════════════════════════════════════════

class DsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color? bgColor;

  const DsStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? color.withValues(alpha: 0.08);
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: AppRadius.md,
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: AppTypography.muted(AppTypography.caption),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsEmptyState — placeholder for when a list/panel has no data
// ═══════════════════════════════════════════════════════════════════

class DsEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const DsEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.white12),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsNavLink — subtle inline link (e.g. "View all →")
// ═══════════════════════════════════════════════════════════════════

class DsNavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DsNavLink({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.sm,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: kGold.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsProgressBar — compact linear progress indicator with label
// ═══════════════════════════════════════════════════════════════════

class DsProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const DsProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.xs,
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.6)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DsPanel — bordered container used for grouped content sections
// ═══════════════════════════════════════════════════════════════════

class DsPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const DsPanel({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: color ?? kDarkBrown.withValues(alpha: 0.5),
        borderRadius: AppRadius.md,
        border: Border.all(color: kLightBrown.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}
