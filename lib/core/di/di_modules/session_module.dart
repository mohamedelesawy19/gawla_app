// Core imports:
import '/core/di/service_locator.dart';
import '/core/session/bloc/session_bloc.dart';

// Features imports:
import '/features/auth/domain/usecases/watch_auth_state_usecase.dart';

class SessionModule {
  SessionModule._();

  static void register() {
    ServiceLocator.registerSingleton<SessionBloc>(
      SessionBloc(watchAuthState: ServiceLocator.get<WatchAuthStateUseCase>()),
    );
  }
}
