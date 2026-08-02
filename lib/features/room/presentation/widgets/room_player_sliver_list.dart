// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/localization/localization_helpers.dart';

// Feature imports:
import '/features/room/domain/entities/room_player_entity.dart';
import '/features/room/presentation/widgets/room_player_tile.dart';

class RoomPlayerSliverList extends StatelessWidget {
  const RoomPlayerSliverList({
    super.key,
    required this.players,
    required this.hostUid,
    required this.viewerUid,
    this.onKick,
    this.emptySeatCount = 0,
    this.neededSeatCount = 0,
  });

  final List<RoomPlayerEntity> players;
  final String hostUid;

  /// uid of whoever is looking at this screen — used to decide whether
  /// kick controls should render (viewer must be host; a host never
  /// sees a kick control on their own row) and to badge the viewer's
  /// own tile so they can find themselves in a crowded room.
  final String? viewerUid;

  final ValueChanged<String>? onKick;

  /// Total remaining capacity (`maxPlayers - players.length`); rendered
  /// as ghost "open seat" tiles after the real players.
  final int emptySeatCount;

  /// How many of [emptySeatCount] are still required to reach the
  /// minimum to start (as opposed to merely optional extra seats).
  /// Needed seats render with a slightly stronger, accent-tinted dashed
  /// outline than purely optional ones.
  final int neededSeatCount;

  static const int _maxGhostTilesShown = 4;

  @override
  Widget build(BuildContext context) {
    final viewerIsHost = viewerUid != null && viewerUid == hostUid;

    final overflowGhosts = emptySeatCount > _maxGhostTilesShown
        ? emptySeatCount - (_maxGhostTilesShown - 1)
        : 0;
    final visibleGhostSeats = overflowGhosts > 0
        ? _maxGhostTilesShown - 1
        : emptySeatCount;
    final itemCount =
        players.length + visibleGhostSeats + (overflowGhosts > 0 ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        Widget child;

        if (index < players.length) {
          final player = players[index];

          child = RepaintBoundary(
            child: RoomPlayerTile(
              player: player,
              isHost: player.uid == hostUid,
              isViewer: player.uid == viewerUid,
              canKick: viewerIsHost && player.uid != hostUid,
              onKick: onKick == null ? null : () => onKick!(player.uid),
            ),
          );
        } else {
          final ghostIndex = index - players.length;

          if (overflowGhosts > 0 && ghostIndex == visibleGhostSeats) {
            child = _MoreOpenSeatsTile(count: overflowGhosts);
          } else {
            child = _GhostSeatTile(isNeeded: ghostIndex < neededSeatCount);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SeatArrival(index: index, child: child),
        );
      }, childCount: itemCount),
    );
  }
}

/// Fades and settles each seat tile into place with a short, per-index
/// stagger — players "arriving" into the lobby one after another rather
/// than the whole grid popping in at once. Runs exactly once per tile
/// (keyed implicitly by its position in the widget tree), never repeats
/// on unrelated state changes.
class _SeatArrival extends StatefulWidget {
  const _SeatArrival({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_SeatArrival> createState() => _SeatArrivalState();
}

class _SeatArrivalState extends State<_SeatArrival> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 28 * math.min(widget.index, 8));
    Future.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.12),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A dashed, unfilled seat — an empty chair rather than a blank space.
/// [isNeeded] tints it toward the primary color when the room still
/// needs this seat to reach the minimum to start; otherwise it reads as
/// a quieter, purely optional opening.
class _GhostSeatTile extends StatelessWidget {
  const _GhostSeatTile({required this.isNeeded});

  final bool isNeeded;

  @override
  Widget build(BuildContext context) {
    final borderColor = isNeeded
        ? AppColors.brandPrimary.withValues(alpha: 0.45)
        : AppColors.borderSubtle;

    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _DashedRRectPainter(color: borderColor),
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_add_alt_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isNeeded
                      ? context.l10n.openPlace
                      : context.l10n.openPlaceOptional,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

/// Collapses a long tail of open seats into a single summary tile so a
/// large room's capacity doesn't read as a wall of identical dashed
/// placeholders.
class _MoreOpenSeatsTile extends StatelessWidget {
  const _MoreOpenSeatsTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: const _DashedRRectPainter(color: AppColors.borderSubtle),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            context.l10n.moreOpenPlaces(count),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a dashed rounded-rectangle outline. Ghost seats repaint only
/// when their color changes (host/needed-state flips are rare), so
/// building the dash path in [paint] rather than caching it ahead of
/// time is not the per-frame cost the architecture guide warns against.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});

  final Color color;

  static const double _dashLength = 5;
  static const double _gapLength = 4;
  static const double _cornerRadius = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(_cornerRadius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + _dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
