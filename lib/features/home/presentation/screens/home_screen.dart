// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';
import '/core/widgets/feedback/error_widget.dart';
import '/core/widgets/feedback/loading_indicator.dart';
import '/core/widgets/feedback/snackbar.dart';

// Feature imports:
import '/features/home/domain/entities/mini_game_preview_entity.dart';
import '/features/home/presentation/blocs/home_cubit.dart';
import '/features/home/presentation/widgets/home_top_bar.dart';
import '/features/home/presentation/widgets/mini_game_library_strip.dart';
import '/features/home/presentation/widgets/quick_action_chips.dart';
import '/features/home/presentation/widgets/tournament_ticket_card.dart';
import '/features/main/presentation/bloc/navigation_cubit.dart';
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/presentation/blocs/profile_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.get<HomeCubit>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  void _notifyComingSoon(String feature) {
    CustomSnackbar.success(context, '$feature — coming soon');
  }

  static bool _profileSettled(ProfileState state) =>
      state is! ProfileInitial && state is! ProfileLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            return BlocSelector<ProfileBloc, ProfileState, bool>(
              selector: _profileSettled,
              builder: (context, profileReady) {
                final failure = homeState.failure;

                if (failure != null) {
                  return ErrorStateWidget(
                    onRetry: () => context.read<HomeCubit>().refresh(),
                    message: failure.message,
                  );
                }

                final ready =
                    homeState.status == HomeStatus.loaded && profileReady;

                if (!ready) {
                  return const Center(child: LoadingIndicator());
                }

                return _LoadedContent(
                  state: homeState,
                  onPunchIn: () => _notifyComingSoon('Matchmaking'),
                  // Room feature entry points — pushed on top of the
                  // main shell (not a NavigationCubit tab switch, since
                  // Create/Join Room aren't part of the persistent
                  // bottom-nav destinations). A successful create/join
                  // then lands the user on `/room/:roomId` on its own,
                  // via SessionBloc + the router's redirect — see
                  // CreateRoomScreen/JoinRoomScreen's doc comments.
                  onCreateRoom: () => context.push(AppRoutes.createRoom),
                  onJoinRoom: () => context.push(AppRoutes.joinRoom),
                  onWalletTap: () => _notifyComingSoon('Shop'),
                  onAvatarTap: () =>
                      context.read<NavigationCubit>().goProfile(),
                  onGameTap: (g) => _notifyComingSoon(g.name),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LoadedContent extends StatefulWidget {
  final HomeState state;
  final VoidCallback onPunchIn;
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;
  final VoidCallback onWalletTap;
  final VoidCallback onAvatarTap;
  final ValueChanged<MiniGamePreviewEntity> onGameTap;

  const _LoadedContent({
    required this.state,
    required this.onPunchIn,
    required this.onCreateRoom,
    required this.onJoinRoom,
    required this.onWalletTap,
    required this.onAvatarTap,
    required this.onGameTap,
  });

  @override
  State<_LoadedContent> createState() => _LoadedContentState();
}

/// One orchestrated entrance: the whole dashboard fades and rises together
/// the first time data is ready, rather than each widget animating on its own.
class _LoadedContentState extends State<_LoadedContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: _ProfileTopBar(
                    onAvatarTap: widget.onAvatarTap,
                    onWalletTap: widget.onWalletTap,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: TournamentTicketCard(
                    playerCount: state.tournamentPlayerCount,
                    roundCount: state.tournamentRoundCount,
                    rotation: state.todaysRotation,
                    onPunchIn: widget.onPunchIn,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: QuickActionChips(
                    onCreateRoom: widget.onCreateRoom,
                    onJoinRoom: widget.onJoinRoom,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.verticalSpaceXxl),
              SliverToBoxAdapter(
                child: MiniGameLibraryStrip(
                  games: state.gameLibrary,
                  onTapGame: widget.onGameTap,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onAvatarTap, required this.onWalletTap});

  final VoidCallback onAvatarTap;
  final VoidCallback onWalletTap;

  static PlayerEntity? _selectPlayer(ProfileState state) => switch (state) {
    ProfileLoaded(profile: final p) => p,
    ProfileUpdating(profile: final p) => p,
    ProfileError(profile: final p) => p,
    ProfileInitial() || ProfileLoading() => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, PlayerEntity?>(
      selector: _selectPlayer,
      builder: (context, player) {
        if (player == null) {
          return const SizedBox.shrink();
        }
        return HomeTopBar(
          player: player,
          onAvatarTap: onAvatarTap,
          onWalletTap: onWalletTap,
        );
      },
    );
  }
}
