// Package imports:
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/splash/presentation/screens/splash_screen.dart';

class MainRoutes {
  const MainRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
  ];
}
