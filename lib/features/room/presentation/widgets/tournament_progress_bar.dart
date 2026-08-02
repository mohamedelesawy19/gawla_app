// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/localization/localization_helpers.dart';

class TournamentProgressBar extends StatelessWidget {
  const TournamentProgressBar({
    super.key,
    required this.currentPlayers,
    required this.requiredPlayers,
    required this.maxPlayers,
  });

  final int currentPlayers;
  final int requiredPlayers;
  final int maxPlayers;

  bool get _ready => currentPlayers >= requiredPlayers;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$currentPlayers',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: _ready ? AppColors.brandPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              context.l10n.seatsSuffix(maxPlayers),
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Icon(
              _ready ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
              size: 16,
              color: _ready ? AppColors.brandPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _ready
                  ? context.l10n.readyToStart
                  : context.l10n.waitingForMorePlayers(
                      requiredPlayers - currentPlayers,
                    ),
              style: textTheme.labelLarge?.copyWith(
                color: _ready
                    ? AppColors.brandPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SeatPipRow(
          currentPlayers: currentPlayers,
          requiredPlayers: requiredPlayers,
          maxPlayers: maxPlayers,
        ),
      ],
    );
  }
}

class _SeatPipRow extends StatelessWidget {
  const _SeatPipRow({
    required this.currentPlayers,
    required this.requiredPlayers,
    required this.maxPlayers,
  });

  final int currentPlayers;
  final int requiredPlayers;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    if (maxPlayers <= 0) return const SizedBox.shrink();

    return Row(
      children: List.generate(maxPlayers, (index) {
        final filled = index < currentPlayers;
        final isThreshold = requiredPlayers > 0 && index == requiredPlayers - 1;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  height: filled ? 10 : 8,
                  decoration: BoxDecoration(
                    color: filled
                        ? AppColors.brandPrimary
                        : AppColors.brandPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 3,
                  width: 3,
                  child: isThreshold
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.brandAccentCyan,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
