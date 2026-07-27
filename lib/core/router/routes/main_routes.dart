// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';
import '/core/session/bloc/session_bloc.dart';

// Feature imports:
import '/features/main/presentation/screens/main_screen.dart';
import '/features/profile/presentation/blocs/profile_bloc.dart';
import '/features/splash/presentation/screens/splash_screen.dart';

class MainRoutes {
  const MainRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: AppRoutes.main,
      builder: (_, _) => BlocProvider(
        create: (context) {
          final uid = context.read<SessionBloc>().state.uid;
          assert(
            uid != null,
            'Reached main route without an authenticated uid',
          );
          return ServiceLocator.get<ProfileBloc>()
            ..add(GetProfileEvent(uid: uid!));
        },
        child: const MainScreen(),
      ),
    ),
  ];
}
