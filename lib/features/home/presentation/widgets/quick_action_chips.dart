// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

class QuickActionChips extends StatelessWidget {
  const QuickActionChips({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StubButton(
            icon: Icons.add_circle_outline_rounded,
            label: context.l10n.createRoom,
            accent: AppColors.brandPrimary,
            onTap: onCreateRoom,
          ),
        ),
        AppSpacing.horizontalSpaceMd,
        Expanded(
          child: _StubButton(
            icon: Icons.confirmation_number_outlined,
            label: context.l10n.joinRoom,
            accent: AppColors.brandAccentCyan,
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
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.14),
              AppColors.cardDefault,
            ),
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
