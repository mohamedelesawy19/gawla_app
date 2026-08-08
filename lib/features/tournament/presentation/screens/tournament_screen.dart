// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/session/bloc/session_bloc.dart';
import '/core/widgets/feedback/error_widget.dart';
import '/core/widgets/feedback/loading_indicator.dart';
import '/core/widgets/feedback/snackbar.dart';

// Feature imports:
import '/features/tournament/presentation/blocs/tournament_bloc.dart';
import '/features/tournament/presentation/widgets/tournament_content.dart';

/// Entry point for the Tournament flow — everything from the "starting"
/// beat right after `RoomScreen` hands off, through live rounds, to the
/// Winner screen.
///
/// Mirrors `RoomScreen`'s shape deliberately: both are the single
/// BLoC-wired screen for their feature, both guard against re-issuing a
/// watch subscription that's already live, and both let `AppRouter`'s
/// `SessionStatus`-driven redirect (rather than this widget) own
/// navigating the player *into* this screen in the first place.
class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.get<TournamentBloc>(),
      child: _TournamentView(tournamentId: tournamentId),
    );
  }
}

class _TournamentView extends StatefulWidget {
  const _TournamentView({required this.tournamentId});

  final String tournamentId;

  @override
  State<_TournamentView> createState() => _TournamentViewState();
}

class _TournamentViewState extends State<_TournamentView> {
  @override
  void initState() {
    super.initState();
    // Same rehydration guard as `RoomScreen`: TournamentBloc is already
    // watching this tournament if we arrived here right after a
    // successful `TournamentStartEvent` on the previous screen — but on a
    // cold start or app rehydration nothing has kicked off a watch yet.
    // Guarding on the id avoids needlessly restarting an already-live
    // subscription.
    final bloc = context.read<TournamentBloc>();
    if (bloc.state.tournament?.tournamentId != widget.tournamentId) {
      bloc.add(TournamentWatchEvent(tournamentId: widget.tournamentId));
    }
  }

  // Read once rather than watched: a user's own uid is stable for the
  // life of this screen, so there's no reactive-rebuild need here.
  String? get _viewerUid => context.read<SessionBloc>().state.uid;

  void _onSubmit(Map<String, dynamic> result) {
    context.read<TournamentBloc>().add(
      TournamentSubmitRoundResultEvent(
        roundIndex: context
            .read<TournamentBloc>()
            .state
            .tournament!
            .currentRoundIndex,
        payload: result,
      ),
    );
  }

  void _leaveTournament() {
    context.read<TournamentBloc>().add(const TournamentLeaveEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<TournamentBloc, TournamentState>(
          listenWhen: (previous, current) =>
              current.hasFailure && current.failure != previous.failure,
          listener: (context, state) {
            // A failure while a tournament is already loaded (e.g. a
            // transient submit-result error) surfaces as a toast so the
            // player never loses the round they're mid-way through; a
            // failure with nothing loaded yet falls through to the full
            // error state in the builder instead.
            if (state.hasFailure && state.isInTournament) {
              CustomSnackbar.error(context, state.failure!.message);
            }
          },
          builder: (context, state) {
            if (state.hasFailure && !state.isInTournament) {
              return ErrorStateWidget(
                message: state.failure!.message,
                onRetry: () => context.read<TournamentBloc>().add(
                  TournamentWatchEvent(tournamentId: widget.tournamentId),
                ),
              );
            }

            if (!state.isInTournament) {
              return const Center(child: LoadingIndicator());
            }

            return TournamentContent(
              tournament: state.tournament!,
              viewerUid: _viewerUid,
              isPerformingAction: state.isPerformingAction,
              onSubmit: _onSubmit,
              onContinue: _leaveTournament,
            );
          },
        ),
      ),
    );
  }
}
