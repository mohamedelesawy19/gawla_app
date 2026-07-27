// Package imports:
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';
import '/core/router/router_refresh_stream.dart';
import '/core/router/routes/auth_routes.dart';
import '/core/router/routes/main_routes.dart';
import '/core/session/bloc/session_bloc.dart';

class AppRouter {
  const AppRouter._();

  static final SessionBloc _sessionBloc = ServiceLocator.get<SessionBloc>();

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(_sessionBloc.stream),
    redirect: (context, state) => _redirect(_sessionBloc.state, state),
    routes: [...MainRoutes.routes, ...AuthRoutes.routes],
  );

  /// Maps [session] to the location it *requires*, then decides whether the
  /// currently requested [routerState] location needs to be redirected
  /// there.
  ///
  /// `authenticated` is a free-roam zone — home, profile, leaderboard,
  /// settings, etc. are all valid; we only bounce the user out of the
  /// pre-auth screens. `inRoom` / `inMatch` are exclusive locks, matching
  /// this game's actual design (5–8 min elimination tournaments): you cannot
  /// be anywhere else in the app while one is active, so *any* other
  /// location gets redirected there.
  static String? _redirect(SessionState session, GoRouterState routerState) {
    final location = routerState.matchedLocation;

    switch (session.status) {
      case SessionStatus.unknown:
        return location == AppRoutes.splash ? null : AppRoutes.splash;

      case SessionStatus.unauthenticated:
        return location == AppRoutes.login ? null : AppRoutes.login;

      case SessionStatus.authenticated:
        final onPreAuthScreen =
            location == AppRoutes.splash || location == AppRoutes.login;
        return onPreAuthScreen ? AppRoutes.main : null;

      case SessionStatus.inRoom:
        final target = '${AppRoutes.room}/${session.roomId}';
        return _isAt(location, target) ? null : target;

      case SessionStatus.inMatch:
        final target = '${AppRoutes.match}/${session.matchId}';
        return _isAt(location, target) ? null : target;
    }
  }

  static bool _isAt(String location, String target) =>
      location == target || location.startsWith('$target/');

  static GoRouter get router => _router;
}
