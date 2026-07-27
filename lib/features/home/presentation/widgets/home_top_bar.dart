// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/theme/theme_extensions.dart';
import '/core/widgets/common/image_widget.dart';
import '/core/widgets/design_system/borders.dart';
import '/core/widgets/design_system/spacing.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/domain/services/level_system.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.player,
    required this.onAvatarTap,
    required this.onWalletTap,
  });

  final PlayerEntity player;
  final VoidCallback onAvatarTap;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          _LevelRingAvatar(
            emoji: player.avatarUrl,
            progress: player.levelProgress,
            level: player.level,
            onTap: onAvatarTap,
          ),
          AppSpacing.horizontalSpaceMd,
          const Spacer(),
          _CurrencyChip(
            icon: '🪙',
            value: player.coins,
            color: colorScheme.secondary,
            onTap: onWalletTap,
          ),
          AppSpacing.horizontalSpaceSm,
          _CurrencyChip(
            icon: '💎',
            value: player.gems,
            color: colorScheme.tertiary,
            onTap: onWalletTap,
          ),
        ],
      ),
    );
  }
}

class _LevelRingAvatar extends StatelessWidget {
  final String? emoji;
  final double progress;
  final int level;
  final VoidCallback onTap;

  const _LevelRingAvatar({
    this.emoji,
    required this.progress,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: colorScheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation(colorScheme.secondary),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: ImageWidget(src: emoji ?? '', height: 48, width: 48),
              ),
            ),
            Positioned(
              bottom: -1.5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: AppBorders.borderRadiusFull,
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
                child: Text(
                  '$level',
                  style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.surface,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final int value;
  final Color color;
  final VoidCallback onTap;

  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppBorders.borderRadiusFull,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: textTheme.labelLarge!.copyWith(fontSize: 13)),
            AppSpacing.horizontalSpaceXs,
            Text(
              '$value',
              style: textTheme.labelMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
