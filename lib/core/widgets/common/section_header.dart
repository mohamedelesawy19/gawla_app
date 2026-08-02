// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/spacing.dart';

/// Small icon + title/subtitle header used to introduce each section of
/// the form, with an optional trailing badge (e.g. a selection count).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: AppBorders.borderRadiusLg,
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        AppSpacing.horizontalSpaceSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
