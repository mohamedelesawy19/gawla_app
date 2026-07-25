// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/auth/presentation/screens/login_screen.dart';

class AuthRoutes {
  const AuthRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => BlocProvider(
        create: (context) => ServiceLocator.get<AuthBloc>(),
        child: const LoginScreen(),
      ),
    ),
  ];
}
