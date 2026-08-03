// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

/// Indicates that the room has filled and the tournament is about to begin.
/// The remaining wait is typically brief while the backend prepares the
/// first round.
class TournamentStartingBanner extends StatelessWidget {
  const TournamentStartingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withAlpha(64),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.textPrimary,
                backgroundColor: AppColors.progressTrackBackground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.tournamentStartingGetReady,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
