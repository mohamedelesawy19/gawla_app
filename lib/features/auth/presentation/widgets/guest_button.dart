// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

class GuestButton extends StatelessWidget {
  const GuestButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colorScheme.onSurfaceVariant,
        side: BorderSide(color: context.colorScheme.outline, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorders.borderRadiusXxl,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 21,
            color: context.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.horizontalSpaceMd,
          Text(
            context.l10n.playAsGuest,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
