// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';
import '/core/utils/string_utils.dart';
import '/core/widgets/common/avatar_face.dart';
import '/core/widgets/common/info_badge.dart';

class TournamentRankedRow extends StatelessWidget {
  const TournamentRankedRow({
    super.key,
    required this.rank,
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.isViewer,
    this.rankColor,
    this.avatarSize = 36,
    this.trailing,
    this.onTap,
  });

  final int? rank;
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final bool isViewer;
  final Color? rankColor;
  final double avatarSize;
  final Widget? trailing;
  final VoidCallback? onTap;

  static const Color _gold = AppColors.rankFirst;
  static const Color _silver = AppColors.rankSecond;
  static const Color _bronze = AppColors.rankThird;

  bool get _isPodium => rank != null && rank! <= 3;

  Color get _podiumColor {
    switch (rank) {
      case 1:
        return _gold;
      case 2:
        return _silver;
      case 3:
        return _bronze;
      default:
        return AppColors.rankDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color resolvedRankColor = rankColor ?? _podiumColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.borderRadiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isViewer
                ? AppColors.leaderboardRowSelf
                : AppColors.leaderboardRowDefault,
            borderRadius: AppBorders.borderRadiusLg,
            border: Border.all(
              color: isViewer ? AppColors.borderSelected : Colors.transparent,
              width: isViewer ? 1.5 : 1,
            ),
            boxShadow: rank == 1
                ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.22),
                      blurRadius: 16,
                      spreadRadius: -6,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _RankBadge(
                rank: rank,
                color: resolvedRankColor,
                isPodium: _isPodium,
              ),
              AppSpacing.horizontalSpaceMd,
              _RingedAvatar(
                avatarUrl: avatarUrl,
                displayName: displayName,
                size: avatarSize,
                ringColor: _isPodium ? resolvedRankColor : null,
              ),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: isViewer
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isViewer) ...[
                      const SizedBox(width: 6),
                      InfoBadge(
                        label: context.l10n.you,
                        background: AppColors.borderSelected.withValues(
                          alpha: 0.15,
                        ),
                        foreground: AppColors.borderSelected,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                AppSpacing.horizontalSpaceMd,
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.color,
    required this.isPodium,
  });

  final int? rank;
  final Color color;
  final bool isPodium;

  @override
  Widget build(BuildContext context) {
    if (!isPodium) {
      return SizedBox(
        width: 32,
        child: Text(
          rank != null ? '#$rank' : '—',
          style: AppTypography.titleSmall.copyWith(color: color),
        ),
      );
    }

    return SizedBox(
      width: 32,
      child: Container(
        height: 28,
        width: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.65)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$rank',
          style: AppTypography.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({
    required this.avatarUrl,
    required this.displayName,
    required this.size,
    this.ringColor,
  });

  final String? avatarUrl;
  final String displayName;
  final double size;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final Widget avatar = ClipOval(
      child: SizedBox(
        height: size,
        width: size,
        child: AvatarFace(
          avatarUrl: avatarUrl,
          initials: StringUtils.initials(displayName),
        ),
      ),
    );

    final Color? ring = ringColor;
    if (ring == null) return avatar;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [ring, ring.withValues(alpha: 0.35)]),
      ),
      child: avatar,
    );
  }
}
