// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/constants/room_constants.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/buttons/app_icon_button.dart';
import '/core/widgets/common/section_eyebrow.dart';
import '/core/widgets/feedback/loading_indicator.dart';

// Feature imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/presentation/widgets/room_hero_background.dart';
import '/features/room/presentation/widgets/room_player_sliver_list.dart';
import '/features/room/presentation/widgets/tournament_progress_bar.dart';
import '/features/room/presentation/widgets/tournament_starting_banner.dart';

class RoomContent extends StatelessWidget {
  const RoomContent({
    super.key,
    required this.room,
    required this.viewerUid,
    required this.isPerformingAction,
    required this.onLeave,
    required this.onKick,
    required this.onEditSettings,
  });

  final RoomEntity room;
  final String? viewerUid;
  final bool isPerformingAction;
  final VoidCallback onLeave;
  final ValueChanged<String> onKick;
  final VoidCallback onEditSettings;

  bool get _viewerIsHost => viewerUid != null && room.isHost(viewerUid!);

  @override
  Widget build(BuildContext context) {
    // `num.clamp` returns `num`, not `int` — using `math.max`/`math.min`
    // (which are generic over the numeric type) keeps this an `int`
    // without an explicit cast.
    final remainingSeats = math.max(
      0,
      RoomConstants.maxPlayersPerRoom - room.players.length,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 168,
          title: Text(context.l10n.waitingRoom),
          centerTitle: false,
          flexibleSpace: FlexibleSpaceBar(
            background: RoomHeroBackground(
              visibility: room.visibility,
              inviteCode: room.inviteCode,
            ),
          ),
          actions: [
            if (_viewerIsHost)
              AppIconButton(
                icon: Icons.tune_rounded,
                onTap: onEditSettings,
                iconSize: 20,
              ),
            AppSpacing.horizontalSpaceMd,
            AppIconButton(
              icon: Icons.logout_rounded,
              onTap: onLeave,
              iconSize: 20,
            ),
            AppSpacing.horizontalSpaceLg,
          ],
        ),
        if (room.status == RoomStatus.starting)
          const SliverToBoxAdapter(child: TournamentStartingBanner()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TournamentProgressBar(
                  currentPlayers: room.players.length,
                  requiredPlayers: RoomConstants.minPlayersToStart,
                  maxPlayers: RoomConstants.maxPlayersPerRoom,
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionEyebrow(label: context.l10n.players),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: RoomPlayerSliverList(
            players: room.players,
            hostUid: room.hostUid,
            viewerUid: viewerUid,
            onKick: _viewerIsHost ? onKick : null,
            emptySeatCount: remainingSeats,
            neededSeatCount: math.max(
              0,
              RoomConstants.minPlayersToStart - room.players.length,
            ),
          ),
        ),
        if (isPerformingAction)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: LoadingIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
