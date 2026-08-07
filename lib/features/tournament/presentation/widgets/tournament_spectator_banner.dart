// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/common/info_badge.dart';

class TournamentSpectatorBanner extends StatelessWidget {
  const TournamentSpectatorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoBadge(
      icon: Icons.visibility_rounded,
      label: context.l10n.tournamentSpectating,
      background: AppColors.backgroundPrimary.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }
}
