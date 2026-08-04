// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/services/current_player/current_player_service.dart';

// Features imports:
import '/features/room/data/datasources/room_remote_data_source.dart';
import '/features/room/data/repositories/room_repository_impl.dart';
import '/features/room/domain/repositories/room_repository.dart';
import '/features/room/domain/usecases/create_room_usecase.dart';
import '/features/room/domain/usecases/join_room_by_code_usecase.dart';
import '/features/room/domain/usecases/join_room_usecase.dart';
import '/features/room/domain/usecases/kick_player_usecase.dart';
import '/features/room/domain/usecases/leave_room_usecase.dart';
import '/features/room/domain/usecases/quick_join_usecase.dart';
import '/features/room/domain/usecases/update_room_settings_usecase.dart';
import '/features/room/domain/usecases/watch_room_id_for_user_usecase.dart';
import '/features/room/domain/usecases/watch_room_usecase.dart';
import '/features/room/domain/validators/join_room_by_code_validator.dart';
import '/features/room/domain/validators/join_room_validator.dart';
import '/features/room/domain/validators/kick_player_validator.dart';
import '/features/room/domain/validators/room_settings_validator.dart';
import '/features/room/presentation/blocs/room_bloc.dart';
import '/features/tournament/domain/usecases/start_tournament_usecase.dart';

class RoomModule {
  RoomModule._();

  static void register() {
    // Data Sources
    ServiceLocator.registerLazySingleton<RoomRemoteDataSource>(
      () => RoomRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
    );

    // Repositories
    ServiceLocator.registerLazySingleton<RoomRepository>(
      () => RoomRepositoryImpl(
        remoteDataSource: ServiceLocator.get<RoomRemoteDataSource>(),
      ),
    );

    // Validators
    ServiceLocator.registerLazySingleton<JoinRoomByCodeValidator>(
      () => const JoinRoomByCodeValidator(),
    );

    ServiceLocator.registerLazySingleton<JoinRoomValidator>(
      () => const JoinRoomValidator(),
    );

    ServiceLocator.registerLazySingleton<KickPlayerValidator>(
      () => const KickPlayerValidator(),
    );

    ServiceLocator.registerLazySingleton<RoomSettingsValidator>(
      () => const RoomSettingsValidator(),
    );

    // Use Cases
    ServiceLocator.registerFactory<CreateRoomUseCase>(
      () => CreateRoomUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
        validator: ServiceLocator.get<RoomSettingsValidator>(),
      ),
    );

    ServiceLocator.registerFactory<JoinRoomByCodeUseCase>(
      () => JoinRoomByCodeUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
        validator: ServiceLocator.get<JoinRoomByCodeValidator>(),
      ),
    );

    ServiceLocator.registerFactory<JoinRoomUseCase>(
      () => JoinRoomUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
        validator: ServiceLocator.get<JoinRoomValidator>(),
      ),
    );

    ServiceLocator.registerFactory<KickPlayerUseCase>(
      () => KickPlayerUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
        validator: ServiceLocator.get<KickPlayerValidator>(),
      ),
    );

    ServiceLocator.registerFactory<LeaveRoomUseCase>(
      () => LeaveRoomUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
      ),
    );

    ServiceLocator.registerFactory<QuickJoinUseCase>(
      () => QuickJoinUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
      ),
    );

    ServiceLocator.registerFactory<UpdateRoomSettingsUseCase>(
      () => UpdateRoomSettingsUseCase(
        repository: ServiceLocator.get<RoomRepository>(),
        currentPlayer: ServiceLocator.get<CurrentPlayerService>(),
        validator: ServiceLocator.get<RoomSettingsValidator>(),
      ),
    );

    ServiceLocator.registerFactory<WatchRoomIdForUserUseCase>(
      () => WatchRoomIdForUserUseCase(ServiceLocator.get<RoomRepository>()),
    );

    ServiceLocator.registerFactory<WatchRoomUseCase>(
      () => WatchRoomUseCase(ServiceLocator.get<RoomRepository>()),
    );

    // Presentation BLoCs
    ServiceLocator.registerFactory<RoomBloc>(
      () => RoomBloc(
        createRoom: ServiceLocator.get<CreateRoomUseCase>(),
        joinRoom: ServiceLocator.get<JoinRoomUseCase>(),
        joinRoomByCode: ServiceLocator.get<JoinRoomByCodeUseCase>(),
        quickJoin: ServiceLocator.get<QuickJoinUseCase>(),
        leaveRoom: ServiceLocator.get<LeaveRoomUseCase>(),
        kickPlayer: ServiceLocator.get<KickPlayerUseCase>(),
        updateRoomSettings: ServiceLocator.get<UpdateRoomSettingsUseCase>(),
        startTournament: ServiceLocator.get<StartTournamentUseCase>(),
        watchRoom: ServiceLocator.get<WatchRoomUseCase>(),
      ),
    );
  }
}
