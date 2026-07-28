// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

// Feature imports:
import '/features/home/domain/entities/mini_game_preview_entity.dart';

class MiniGameLibraryStrip extends StatelessWidget {
  const MiniGameLibraryStrip({super.key, required this.games, this.onTapGame});

  final List<MiniGamePreviewEntity> games;
  final ValueChanged<MiniGamePreviewEntity>? onTapGame;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            context.l10n.moreWaysToPlay,
            style: textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        AppSpacing.verticalSpaceMd,
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: games.length,
            separatorBuilder: (_, _) => AppSpacing.horizontalSpaceMd,
            itemBuilder: (context, i) {
              final game = games[i];
              return _GameCard(
                game: game,
                onTap: onTapGame == null ? null : () => onTapGame!(game),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final MiniGamePreviewEntity game;
  final VoidCallback? onTap;
  const _GameCard({required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.borderRadiusXl,
        child: Container(
          width: 108,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.cardDefault,
            borderRadius: AppBorders.borderRadiusXl,
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.emoji,
                style: textTheme.titleLarge!.copyWith(fontSize: 22),
              ),
              Text(
                game.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall!.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: Text(
                  game.skillTag,
                  style: textTheme.labelSmall!.copyWith(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
