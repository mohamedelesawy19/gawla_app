// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';

/// The single-beat "you're out" moment: [AppColors.eliminationFlash]
/// flashes across the whole screen and fades — exactly as that color's
/// doc comment describes, animated rather than used as a static fill —
/// before settling into a rank card that stays up over
/// [AppColors.eliminationOverlayScrim] until the results view underneath
/// takes over.
class TournamentEliminationOverlay extends StatefulWidget {
  const TournamentEliminationOverlay({super.key, required this.rank});

  final int rank;

  @override
  State<TournamentEliminationOverlay> createState() =>
      _TournamentEliminationOverlayState();
}

class _TournamentEliminationOverlayState
    extends State<TournamentEliminationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flashOpacity;
  late final Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _flashOpacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _cardScale = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: AppColors.eliminationFlash.withValues(
                    alpha: _flashOpacity.value * 0.6,
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: AppColors.eliminationOverlayScrim),
              ),
            ),
            Center(
              child: Transform.scale(scale: _cardScale.value, child: child),
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.eliminationBadgeBackground,
          borderRadius: AppBorders.borderRadiusXl,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.tournamentEliminated,
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              context.l10n.tournamentRankLabel(widget.rank),
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.eliminationRankText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
