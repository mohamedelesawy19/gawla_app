// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/design_system/borders.dart';
import '/core/widgets/design_system/spacing.dart';

class QuickActionChips extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  const QuickActionChips({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StubButton(
            icon: Icons.add_circle_outline_rounded,
            label: context.l10n.createRoom,
            accent: colorScheme.primary,
            onTap: onCreateRoom,
          ),
        ),
        AppSpacing.horizontalSpaceMd,
        Expanded(
          child: _StubButton(
            icon: Icons.confirmation_number_outlined,
            label: context.l10n.joinRoom,
            accent: colorScheme.tertiary,
            onTap: onJoinRoom,
          ),
        ),
      ],
    );
  }
}

class _StubButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _StubButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppBorders.borderRadiusXl,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: AppBorders.borderRadiusXl,
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: accent),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  label,
                  style: textTheme.titleMedium!.copyWith(fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
