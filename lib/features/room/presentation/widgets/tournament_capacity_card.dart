// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/constants/room_constants.dart';
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/inputs/numeric_stepper_field.dart';

/// Card housing the bracket preview plus both capacity steppers, so the
/// "shape" of the tournament and the numbers that drive it read as one
/// connected idea instead of two disconnected fields.
class TournamentCapacityCard extends StatelessWidget {
  const TournamentCapacityCard({
    super.key,
    required this.maxPlayers,
    required this.onMaxPlayersChanged,
    required this.tournamentSize,
    required this.onTournamentSizeChanged,
  });

  final int maxPlayers;
  final ValueChanged<int> onMaxPlayersChanged;
  final int tournamentSize;
  final ValueChanged<int> onTournamentSizeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: AppBorders.borderRadiusXxl,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _TournamentBracketPreview(tournamentSize: tournamentSize),
          AppSpacing.verticalSpaceXxl,
          NumericStepperField(
            label: context.l10n.maxPlayers,
            value: maxPlayers,
            // Capacity can never drop below what's required to start.
            min: tournamentSize,
            max: RoomConstants.maxPlayersPerRoom,
            onChanged: onMaxPlayersChanged,
          ),
          AppSpacing.verticalSpaceXxxl,
          NumericStepperField(
            label: context.l10n.playersToStart,
            value: tournamentSize,
            min: RoomConstants.minPlayersToStart,
            // Can never require more players than the room's own capacity.
            max: maxPlayers,
            onChanged: onTournamentSizeChanged,
          ),
        ],
      ),
    );
  }
}

/// Visualizes the elimination shape implied by [tournamentSize] — a row
/// of shrinking nodes ending in a trophy — echoing the project's own
/// "24 → 18 → 12 → 8 → 4 → Winner" tournament flow so the abstract
/// numbers above it read as an actual bracket, not just two counters.
class _TournamentBracketPreview extends StatelessWidget {
  const _TournamentBracketPreview({required this.tournamentSize});

  final int tournamentSize;

  List<int> get _stages {
    final stages = <int>[tournamentSize];
    var current = tournamentSize;

    while (current > 2 && stages.length < 4) {
      final next = math.max(2, (current * 0.5).round());

      if (next >= current) break;

      stages.add(next);
      current = next;
    }

    if (stages.length > 1) {
      stages[stages.length - 1] = 2;
    }

    return stages;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stages = _stages;

    return SizedBox(
      height: 92,
      child: CustomPaint(
        painter: _FunnelConnectorPainter(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < stages.length; i++)
              _BracketNode(
                label: '${stages[i]}',
                sublabel: i == 0
                    ? context.l10n.roundNumber(1)
                    : context.l10n.roundNumber(i + 1),
                size: 46 - (i * 6.0),
                color: Color.lerp(
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                  i / math.max(1, stages.length - 1),
                )!,
              ),
            _BracketNode(
              label: '',
              icon: Icons.emoji_events_rounded,
              sublabel: context.l10n.winner,
              size: 40,
              color: AppColors.brandAccentBlazeStart,
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative dashed connector drawn behind the bracket nodes. Purely
/// cosmetic — geometry is static per paint, so it's cheap and only
/// repaints when its color actually changes.
class _FunnelConnectorPainter extends CustomPainter {
  const _FunnelConnectorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = size.height * 0.52;
    const dashWidth = 5.0;
    const dashGap = 4.0;
    var startX = 20.0;
    final endX = size.width - 20.0;

    while (startX < endX) {
      final segmentEnd = math.min(startX + dashWidth, endX);
      canvas.drawLine(Offset(startX, y), Offset(segmentEnd, y), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _FunnelConnectorPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BracketNode extends StatelessWidget {
  const _BracketNode({
    required this.label,
    required this.sublabel,
    required this.size,
    required this.color,
    this.icon,
  });

  final String label;
  final String sublabel;
  final double size;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: icon != null
              ? Icon(
                  icon,
                  color: theme.colorScheme.onPrimary,
                  size: size * 0.45,
                )
              : Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          sublabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
