// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

// Feature imports:
import '/features/home/domain/entities/mini_game_preview_entity.dart';

class MiniGameLibraryStrip extends StatelessWidget {
  const MiniGameLibraryStrip({super.key, required this.games, this.onTapGame});

  final List<MiniGamePreview> games;
  final ValueChanged<MiniGamePreview>? onTapGame;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

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
              color: colorScheme.onSurfaceVariant,
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
  final MiniGamePreview game;
  final VoidCallback? onTap;
  const _GameCard({required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.borderRadiusXl,
        child: Container(
          width: 108,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: AppBorders.borderRadiusXl,
            border: Border.all(color: colorScheme.outlineVariant),
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
                  color: colorScheme.onSurface,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.15),
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: Text(
                  game.skillTag,
                  style: textTheme.labelSmall!.copyWith(
                    fontSize: 9.5,
                    color: colorScheme.tertiary,
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
