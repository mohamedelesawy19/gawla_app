// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/animations/pulse.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';
import '/features/tournament/presentation/widgets/tournament_round_timer.dart';
import '/features/tournament/presentation/widgets/tournament_spectator_banner.dart';

/// Chrome shown while the current round is pending or active — bracket
/// position, the round's live timer once it's actually running, and the
/// surface the mini-game itself mounts into.
///
/// The mini-game's gameplay UI (Drawing Guess, Bluff Game, ...) is
/// deliberately *not* built here: per `TournamentRoundEntity.miniGameId`'s
/// doc comment, this feature stays decoupled from the Mini Games feature
/// and never interprets a mini-game's specifics. [miniGameHost] is this
/// view's one seam for that other feature to plug its gameplay widget in
/// — whichever screen owns that composition is also where a mini-game
/// would call back into `TournamentBloc` with
/// `TournamentSubmitRoundResultEvent` once the player finishes. Until
/// that's wired at the composition root, a plain placeholder keeps this
/// screen honest about what round is live without inventing gameplay UI
/// this layer has no business owning.
///
/// Motion is intentionally restrained: the round header cross-fades its
/// "LIVE" state, the body cross-fades between "get ready" and the active
/// mini-game surface, and the timer's color drifts continuously rather
/// than snapping between thresholds. None of it touches round logic —
/// it's purely there to make waiting and urgency *feel* like what they
/// are, while the server document remains the single source of truth.
class TournamentActiveRoundView extends StatelessWidget {
  const TournamentActiveRoundView({
    super.key,
    required this.tournament,
    required this.round,
    required this.viewerUid,
    required this.isPerformingAction,
    this.miniGameHost,
  });

  final TournamentEntity tournament;
  final TournamentRoundEntity? round;
  final String? viewerUid;
  final bool isPerformingAction;

  /// Builds the actual mini-game widget for [round]'s `miniGameId` once a
  /// round is active. Left `null` renders a generic placeholder instead.
  final Widget Function(BuildContext context, TournamentRoundEntity round)?
  miniGameHost;

  bool get _viewerIsEliminated =>
      viewerUid != null && tournament.isPlayerEliminated(viewerUid!);

  @override
  Widget build(BuildContext context) {
    final currentRound = round;
    final isActive = currentRound?.status == RoundStatus.active;
    final displayRoundNumber =
        (currentRound?.roundIndex ?? tournament.currentRoundIndex) + 1;

    final hasTimer =
        isActive &&
        currentRound?.startedAt != null &&
        currentRound?.endsAt != null;

    return Column(
      children: [
        _RoundHeader(
          roundLabel: context.l10n.tournamentRoundLabel(
            displayRoundNumber,
            tournament.totalRounds,
          ),
          isActive: isActive,
          timer: hasTimer
              ? TournamentRoundTimer(
                  key: ValueKey('timer-${currentRound!.roundIndex}'),
                  startedAt: currentRound.startedAt!,
                  endsAt: currentRound.endsAt!,
                )
              : null,
          viewerIsEliminated: _viewerIsEliminated,
        ),
        AppSpacing.verticalSpaceXl,
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: isActive && currentRound != null
                ? KeyedSubtree(
                    key: ValueKey('active-${currentRound.roundIndex}'),
                    child:
                        miniGameHost?.call(context, currentRound) ??
                        _MiniGamePlaceholder(
                          miniGameId: currentRound.miniGameId,
                        ),
                  )
                : KeyedSubtree(
                    key: ValueKey('get-ready-${tournament.currentRoundIndex}'),
                    child: _GetReadyPlaceholder(
                      miniGameId: currentRound?.miniGameId,
                      activePlayerCount: tournament.activePlayers.length,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// The round label + live timer, dressed as a single cohesive "status
/// chip" rather than two unrelated pieces of text floating in a row.
/// Picks up the same accent tint and corner radius as the arena surface
/// below it, so header and body read as one composition.
class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.roundLabel,
    required this.isActive,
    this.timer,
    required this.viewerIsEliminated,
  });

  final String roundLabel;
  final bool isActive;
  final Widget? timer;
  final bool viewerIsEliminated;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandPrimaryDark,
                  AppColors.backgroundPrimary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -44,
                  right: -28,
                  child: _AmbientBlob(
                    color: AppColors.brandPrimary.withValues(alpha: 0.06),
                    size: 158,
                  ),
                ),
                Positioned(
                  top: -56,
                  left: -24,
                  child: _AmbientBlob(
                    color: AppColors.brandPrimary.withValues(alpha: 0.1),
                    size: 148,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: AppSpacing.paddingXl,
          child: Column(
            children: [
              if (viewerIsEliminated) const TournamentSpectatorBanner(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          roundLabel,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSpaceXs,
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isActive
                              ? Padding(
                                  key: const ValueKey('live'),
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const _LivePulseDot(),
                                      const SizedBox(width: 6),
                                      Text(
                                        context.l10n.live,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.tournamentLive,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(key: ValueKey('idle')),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child:
                        timer ??
                        const SizedBox.shrink(key: ValueKey('no-timer')),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceLg,
            ],
          ),
        ),
      ],
    );
  }
}

class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _LivePulseDot extends StatefulWidget {
  const _LivePulseDot();

  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pulse(
      controller: _controller,
      minOpacity: 0.35, // maxOpacity: 1.0 and curve: easeInOut are defaults
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.tournamentLive,
          shape: BoxShape.circle,
        ),
        child: SizedBox(width: 6, height: 6),
      ),
    );
  }
}

class _MiniGamePlaceholder extends StatelessWidget {
  const _MiniGamePlaceholder({required this.miniGameId});

  final String miniGameId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundArena,
        borderRadius: AppBorders.borderRadiusXxl,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sports_esports_rounded,
              size: 36,
              color: AppColors.textTertiary,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              miniGameId,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GetReadyPlaceholder extends StatelessWidget {
  const _GetReadyPlaceholder({
    required this.miniGameId,
    required this.activePlayerCount,
  });

  final String? miniGameId;
  final int activePlayerCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandAccentCyan.withValues(alpha: 0.12),
            ),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.sports_esports_rounded,
                size: 28,
                color: AppColors.brandAccentCyan,
              ),
            ),
          ),
          AppSpacing.verticalSpaceLg,
          Text(
            context.l10n.tournamentGetReady,
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (miniGameId != null) ...[
            AppSpacing.verticalSpaceSm,
            Text(
              miniGameId!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          AppSpacing.verticalSpaceSm,
          Text(
            context.l10n.tournamentPlayersRemaining(activePlayerCount),
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
