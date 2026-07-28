// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';

// Feature imports:
import '/features/profile/presentation/constants/milestone_tiers.dart';

extension MilestoneTierL10n on MilestoneTier {
  String localizedName(BuildContext context) {
    final l10n = context.l10n;
    return switch (id) {
      MilestoneTierId.rookie => l10n.milestoneRookie,
      MilestoneTierId.contender => l10n.milestoneContender,
      MilestoneTierId.risingStar => l10n.milestoneRisingStar,
      MilestoneTierId.champion => l10n.milestoneChampion,
      MilestoneTierId.elite => l10n.milestoneElite,
      MilestoneTierId.legend => l10n.milestoneLegend,
    };
  }
}
