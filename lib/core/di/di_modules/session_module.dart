// Core imports:
import '/core/di/service_locator.dart';
import '/core/session/bloc/session_bloc.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import '/features/room/domain/usecases/watch_room_id_for_user_usecase.dart';

class SessionModule {
  SessionModule._();

  static void register() {
    ServiceLocator.registerSingleton<SessionBloc>(
      SessionBloc(
        watchAuthState: ServiceLocator.get<WatchAuthStateUseCase>(),
        watchRoomId: (uid) =>
            ServiceLocator.get<WatchRoomIdForUserUseCase>()(SingleParam(uid)),
      ),
    );
  }
}
