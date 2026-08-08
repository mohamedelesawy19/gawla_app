// Package imports:
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/tournament/presentation/screens/tournament_screen.dart';

/// Route definitions for the Tournament feature.
///
/// `AppRouter._redirect`'s `SessionStatus.inTournament` branch already
/// targets `'${AppRoutes.tournament}/${session.tournamentId}'`
/// (see `app_router.dart`), so this simply gives that path somewhere to
/// land — mirroring the `GoRoute(path: '${AppRoutes.room}/:id', ...)`
/// shape that same redirect logic implies `RoomRoutes` uses.
///
/// NOT YET WIRED IN: `RoomRoutes`'s actual source wasn't provided
/// alongside the other core files handed to this task, so this couldn't
/// be cross-checked against its exact pattern, and `AppRouter._router`'s
/// `routes:` list (currently `[...MainRoutes.routes, ...AuthRoutes.routes,
/// ...RoomRoutes.routes]`) still needs `...TournamentRoutes.routes` added
/// alongside it for this screen to actually be reachable.
abstract final class TournamentRoutes {
  const TournamentRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: '${AppRoutes.tournament}/:tournamentId',
      builder: (context, state) =>
          TournamentScreen(tournamentId: state.pathParameters['tournamentId']!),
    ),
  ];
}
