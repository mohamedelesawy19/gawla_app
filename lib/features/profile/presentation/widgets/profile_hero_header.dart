// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/buttons/app_icon_button.dart';

// Feature imports:
import '/features/profile/presentation/constants/milestone_tiers.dart';
import '/features/profile/presentation/extensions/milestone_tier_l10n.dart';
import '/features/profile/presentation/widgets/trophy_ring_avatar.dart';

class ProfileHeroHeader extends StatelessWidget {
  const ProfileHeroHeader({
    super.key,
    required this.displayName,
    required this.initials,
    required this.avatarUrl,
    required this.level,
    required this.levelProgress,
    required this.isSaving,
    required this.onEditTap,
    required this.onLogoutTap,
  });

  final String displayName;
  final String initials;
  final String? avatarUrl;
  final int level;
  final double levelProgress;
  final bool isSaving;
  final VoidCallback onEditTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final tier = MilestoneTiers.currentFor(level);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppIconButton(
              icon: Icons.logout_rounded,
              onTap: onLogoutTap,
              iconSize: 24,
              backgroundColor: AppColors.buttonDangerPressed.withValues(
                alpha: 0.08,
              ),
              iconColor: AppColors.buttonDangerPressed,
            ),
          ),
          TrophyRingAvatar(
            progress: levelProgress,
            level: level,
            initials: initials,
            avatarUrl: avatarUrl,
            isSaving: isSaving,
            onTap: onEditTap,
          ),
          AppSpacing.verticalSpaceXl,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 26,
                    fontWeight: AppTypography.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              AppIconButton(icon: Icons.edit_rounded, onTap: onEditTap),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.brandAccentBlazeEnd.withValues(alpha: 0.16),
              borderRadius: AppBorders.borderRadiusFull,
              border: Border.all(
                color: AppColors.brandAccentBlazeEnd.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tier.icon, size: 14, color: AppColors.brandAccentBlazeEnd),
                const SizedBox(width: 6),
                Text(
                  tier.localizedName(context),
                  style: AppTypography.overline.copyWith(
                    fontWeight: AppTypography.bold,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
