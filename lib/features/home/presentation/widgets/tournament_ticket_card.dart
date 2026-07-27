// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/design_system/borders.dart';
import '/core/widgets/design_system/colors.dart';
import '/core/widgets/design_system/spacing.dart';

// Feature imports:
import '/features/home/domain/entities/mini_game_preview_entity.dart';
import '/features/home/presentation/widgets/punch_in_button.dart';

class TournamentTicketCard extends StatelessWidget {
  const TournamentTicketCard({
    super.key,
    required this.playerCount,
    required this.roundCount,
    required this.rotation,
    required this.onPunchIn,
  });

  final int playerCount;
  final int roundCount;
  final List<MiniGamePreview> rotation;
  final VoidCallback onPunchIn;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipPath(
          clipper: const _TicketEdgeClipper(notchOnBottom: true),
          child: Container(
            width: double.infinity,
            color: context.onWarningContainer,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.todaysTournament,
                  style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  context.l10n.tournamentSlogan,
                  style: textTheme.titleLarge!.copyWith(
                    color: colorScheme.surface,
                    fontSize: 22,
                  ),
                ),
                AppSpacing.verticalSpaceMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoPill(
                      icon: Icons.groups_rounded,
                      label: context.l10n.numPlayers(playerCount),
                    ),
                    AppSpacing.horizontalSpaceSm,
                    _InfoPill(
                      icon: Icons.layers_rounded,
                      label: context.l10n.numRounds(roundCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 22,
          child: LayoutBuilder(
            builder: (context, constraints) => CustomPaint(
              size: Size(constraints.maxWidth, 22),
              painter: _DashedLinePainter(),
            ),
          ),
        ),
        ClipPath(
          clipper: const _TicketEdgeClipper(notchOnBottom: false),
          child: Container(
            width: double.infinity,
            color: context.onWarningContainer,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RotationRow(rotation: rotation),
                AppSpacing.verticalSpaceXxl,
                PunchInButton(onTap: onPunchIn),
                AppSpacing.verticalSpaceSm,
                Text(
                  context.l10n.tapToFindMatch,
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant,
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.outline),
          AppSpacing.horizontalSpaceXs,
          Text(
            label,
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.outline,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationRow extends StatelessWidget {
  const _RotationRow({required this.rotation});

  final List<MiniGamePreview> rotation;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < rotation.length; i++) {
      items.add(_StopIcon(order: i + 1, game: rotation[i]));
      if (i != rotation.length - 1) {
        items.add(
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.only(bottom: 14),
              color: context.colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
        );
      }
    }
    return Row(children: items);
  }
}

class _StopIcon extends StatelessWidget {
  const _StopIcon({required this.order, required this.game});

  final int order;
  final MiniGamePreview game;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            game.emoji,
            style: textTheme.titleMedium!.copyWith(fontSize: 16),
          ),
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          '$order',
          style: textTheme.labelSmall!.copyWith(
            color: colorScheme.outline,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onSurfaceVariant.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    const dashWidth = 6.0;
    const gap = 5.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketEdgeClipper extends CustomClipper<Path> {
  const _TicketEdgeClipper({required this.notchOnBottom});

  final bool notchOnBottom;
  static const double _notchRadius = 11;

  @override
  Path getClip(Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const radius = Radius.circular(AppBorders.radiusXxxl);
    final body = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: notchOnBottom ? radius : Radius.zero,
          topRight: notchOnBottom ? radius : Radius.zero,
          bottomLeft: notchOnBottom ? Radius.zero : radius,
          bottomRight: notchOnBottom ? Radius.zero : radius,
        ),
      );

    final notchY = notchOnBottom ? size.height : 0.0;
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, notchY), radius: _notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, notchY),
          radius: _notchRadius,
        ),
      );

    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(covariant _TicketEdgeClipper oldClipper) =>
      oldClipper.notchOnBottom != notchOnBottom;
}
