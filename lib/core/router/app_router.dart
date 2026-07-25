// Package imports:
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';
import '/core/router/routes/auth_routes.dart';
import '/core/router/routes/main_routes.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [...MainRoutes.routes, ...AuthRoutes.routes],
  );

  static GoRouter get router => _router;
}
