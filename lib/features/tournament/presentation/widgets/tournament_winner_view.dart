// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/extensions/media_query_extention.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/buttons/primary_button.dart';
import '/core/widgets/common/avatar_face.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/entities/tournament_player_entity.dart';
import '/features/tournament/presentation/widgets/tournament_ranked_row.dart';

class TournamentWinnerView extends StatefulWidget {
  const TournamentWinnerView({
    super.key,
    required this.tournament,
    required this.viewerUid,
    required this.onContinue,
  });

  final TournamentEntity tournament;
  final String? viewerUid;
  final VoidCallback onContinue;

  @override
  State<TournamentWinnerView> createState() => _TournamentWinnerViewState();
}

class _TournamentWinnerViewState extends State<TournamentWinnerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  bool get _viewerIsWinner =>
      widget.viewerUid != null &&
      widget.tournament.winnerUid == widget.viewerUid;

  static Color _rankColor(int? placement) => switch (placement) {
    1 => AppColors.rankFirst,
    2 => AppColors.rankSecond,
    3 => AppColors.rankThird,
    _ => AppColors.rankDefault,
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();
    widget.onContinue();
  }

  String _resultTitle(BuildContext context) => _viewerIsWinner
      ? context.l10n.tournamentVictoryTitle
      : context.l10n.tournamentEndedTitle;

  @override
  Widget build(BuildContext context) {
    final tournament = widget.tournament;
    final isCancelled = tournament.status == TournamentStatus.cancelled;
    final compact = context.height < 700;

    final ranked = [...tournament.players]
      ..sort(
        (a, b) => (a.finalPlacement ?? 999).compareTo(b.finalPlacement ?? 999),
      );
    // A podium only makes sense as a celebration — skip it for cancelled
    // tournaments and for rosters too small to fill three spots.
    final hasPodium = !isCancelled && ranked.length >= 3;
    final List<TournamentPlayerEntity> podium = hasPodium
        ? ranked.take(3).toList()
        : const <TournamentPlayerEntity>[];
    final List<TournamentPlayerEntity> rest = hasPodium
        ? ranked.skip(3).toList()
        : ranked;

    final heroStageSize = compact ? 124.0 : 172.0;
    final heroExpandedHeight = heroStageSize + kToolbarHeight;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: heroExpandedHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      expandedTitleScale: 1.4,
                      titlePadding: EdgeInsetsDirectional.only(
                        start: AppSpacing.lg,
                        end: AppSpacing.lg,
                        bottom: compact ? AppSpacing.md : AppSpacing.lg,
                      ),
                      title: _FadeSlideIn(
                        controller: _controller,
                        interval: const Interval(
                          0.15,
                          0.6,
                          curve: Curves.easeOut,
                        ),
                        slideDistance: 12,
                        child: Text(_resultTitle(context)),
                      ),
                      background: _FadeSlideIn(
                        controller: _controller,
                        interval: const Interval(
                          0.0,
                          0.5,
                          curve: Curves.easeOut,
                        ),
                        child: _ResultHero(
                          isWinner: _viewerIsWinner,
                          controller: _controller,
                          compact: compact,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (hasPodium)
                          _FadeSlideIn(
                            controller: _controller,
                            interval: const Interval(
                              0.25,
                              0.75,
                              curve: Curves.easeOut,
                            ),
                            child: _PodiumRow(
                              top3: podium,
                              viewerUid: widget.viewerUid,
                              compact: compact,
                            ),
                          ),
                        if (hasPodium && rest.isNotEmpty)
                          _FadeSlideIn(
                            controller: _controller,
                            interval: const Interval(
                              0.30,
                              0.60,
                              curve: Curves.easeOut,
                            ),
                            slideDistance: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppSpacing.verticalSpaceXl,
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    context.l10n.tournamentFinalStandings,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                AppSpacing.verticalSpaceSm,
                              ],
                            ),
                          ),
                        for (var i = 0; i < rest.length; i++) ...[
                          if (i > 0) AppSpacing.verticalSpaceXs,
                          _FadeSlideIn(
                            controller: _controller,
                            interval: _staggerInterval(
                              index: i,
                              base: hasPodium ? 0.35 : 0.15,
                            ),
                            slideDistance: 14,
                            child: TournamentRankedRow(
                              rank: rest[i].finalPlacement,
                              uid: rest[i].uid,
                              displayName: rest[i].displayName,
                              avatarUrl: rest[i].avatarUrl,
                              isViewer: rest[i].uid == widget.viewerUid,
                              rankColor: _rankColor(rest[i].finalPlacement),
                              trailing: rest[i].isWinner
                                  ? const Icon(
                                      Icons.emoji_events_rounded,
                                      size: 18,
                                      color: AppColors.rankFirst,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceLg,
            _FadeSlideIn(
              controller: _controller,
              interval: const Interval(0.7, 1.0, curve: Curves.easeOut),
              slideDistance: 16,
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: _handleContinue,
                  label: context.l10n.continueLabel,
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Interval _staggerInterval({required int index, required double base}) {
    final start = (base + index * 0.05).clamp(0.0, 0.85);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Interval(start, end, curve: Curves.easeOut);
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.controller,
    required this.interval,
    required this.child,
    this.slideDistance = 20,
  });

  final AnimationController controller;
  final Interval interval;
  final Widget child;
  final double slideDistance;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: controller, curve: interval);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, slideDistance * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.isWinner,
    required this.controller,
    required this.compact,
  });

  final bool isWinner;
  final AnimationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final stageSize = compact ? 124.0 : 172.0;
    final trophySize = compact ? 54.0 : 74.0;
    final accent = isWinner ? AppColors.rankFirst : AppColors.rankDefault;

    return Center(
      child: SizedBox(
        height: stageSize,
        width: stageSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: stageSize,
              height: stageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            if (isWinner) ..._sparkles(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                isWinner ? Icons.emoji_events_rounded : Icons.flag_rounded,
                size: trophySize,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sparkles() {
    const specs = [
      _SparkleSpec(dx: -0.75, dy: -0.55, size: 16, start: .15, end: .45),
      _SparkleSpec(dx: 0.75, dy: -0.75, size: 12, start: .25, end: .60),
      _SparkleSpec(dx: 0.65, dy: 0.45, size: 14, start: .35, end: .75),
    ];

    return [
      for (final spec in specs)
        Align(
          alignment: Alignment(spec.dx, spec.dy),
          child: _SparkleIcon(controller: controller, spec: spec),
        ),
    ];
  }
}

class _SparkleSpec {
  const _SparkleSpec({
    required this.dx,
    required this.dy,
    required this.size,
    required this.start,
    required this.end,
  });

  final double dx;
  final double dy;
  final double size;
  final double start;
  final double end;
}

class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({required this.controller, required this.spec});

  final AnimationController controller;
  final _SparkleSpec spec;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(spec.start, spec.end, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) => Opacity(
        opacity: curved.value,
        child: Transform.scale(
          scale: 0.4 + curved.value * 0.6,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: spec.size,
            color: AppColors.rankFirst,
          ),
        ),
      ),
    );
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({
    required this.top3,
    required this.viewerUid,
    required this.compact,
  });

  final List<TournamentPlayerEntity> top3;
  final String? viewerUid;
  final bool compact;

  static const _medalColors = [
    AppColors.rankFirst,
    AppColors.rankSecond,
    AppColors.rankThird,
  ];
  static const _pedestalHeights = [104.0, 76.0, 60.0];
  static const _pedestalHeightsCompact = [78.0, 58.0, 46.0];

  @override
  Widget build(BuildContext context) {
    final heights = compact ? _pedestalHeightsCompact : _pedestalHeights;
    // Left-to-right display order: 2nd, 1st, 3rd. `place` below is
    // still derived from the original index, so labels stay correct
    // regardless of where a column sits visually.
    const displayOrder = [1, 0, 2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in displayOrder)
          if (i < top3.length)
            Expanded(
              child: _PodiumColumn(
                player: top3[i],
                place: i + 1,
                pedestalHeight: heights[i],
                medalColor: _medalColors[i],
                isViewer: top3[i].uid == viewerUid,
                compact: compact,
              ),
            ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.player,
    required this.place,
    required this.pedestalHeight,
    required this.medalColor,
    required this.isViewer,
    required this.compact,
  });

  final TournamentPlayerEntity player;
  final int place;
  final double pedestalHeight;
  final Color medalColor;
  final bool isViewer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = compact ? 0.82 : 1.0;
    final avatarSize = (place == 1 ? 64.0 : 52.0) * scale;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: medalColor, width: 2.5),
                ),
                child: ClipOval(
                  child: SizedBox(
                    height: avatarSize,
                    width: avatarSize,
                    child: AvatarFace(
                      avatarUrl: player.avatarUrl,
                      initials: player.displayName,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$place',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.ticketTextPrimary,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            player.displayName,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: isViewer ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.verticalSpaceSm,
          Container(
            height: pedestalHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  medalColor.withValues(alpha: 0.85),
                  medalColor.withValues(alpha: 0.45),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: isViewer
                  ? Border.all(color: AppColors.borderSelected, width: 2)
                  : null,
            ),
            child: Icon(
              place == 1
                  ? Icons.emoji_events_rounded
                  : Icons.military_tech_rounded,
              color: AppColors.textPrimary.withValues(alpha: 0.9),
              size: place == 1 ? 28 : 22,
            ),
          ),
        ],
      ),
    );
  }
}
