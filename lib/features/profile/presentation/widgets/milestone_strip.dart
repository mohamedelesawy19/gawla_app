// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';

// Feature imports:
import '/features/profile/presentation/constants/milestone_tiers.dart';
import '/features/profile/presentation/extensions/milestone_tier_l10n.dart';

class MilestoneStrip extends StatelessWidget {
  const MilestoneStrip({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            context.l10n.milestones,
            style: AppTypography.sectionTitle,
          ),
        ),
        AppSpacing.verticalSpaceMd,
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: MilestoneTiers.all.length,
            separatorBuilder: (_, _) => AppSpacing.horizontalSpaceMd,
            itemBuilder: (context, index) {
              final tier = MilestoneTiers.all[index];
              final unlocked = level >= tier.minLevel;
              return _MilestoneBadge(
                name: tier.localizedName(context),
                icon: tier.icon,
                unlocked: unlocked,
                requirement: tier.minLevel,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({
    required this.name,
    required this.icon,
    required this.unlocked,
    required this.requirement,
  });

  final String name;
  final IconData icon;
  final bool unlocked;
  final int requirement;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: unlocked
          ? name
          : context.l10n.milestoneUnlockTooltip(requirement),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.surfaceElevated : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          border: Border.all(
            color: unlocked
                ? AppColors.brandAccentBlazeStart.withValues(alpha: 0.4)
                : AppColors.borderSubtle,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: unlocked ? AppColors.brandAccentBlazeGradient : null,
                color: unlocked
                    ? null
                    : AppColors.cardHover.withValues(alpha: 0.2),
              ),
              child: Icon(
                unlocked ? icon : Icons.lock_rounded,
                size: 16,
                color: unlocked ? AppColors.iconOnBrand : AppColors.iconMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              unlocked ? name : context.l10n.levelShort(requirement),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: unlocked
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
                fontWeight: unlocked ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
