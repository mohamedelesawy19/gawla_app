// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Features imports:
import '/features/room/domain/usecases/leave_room_usecase.dart';
import '/features/tournament/data/datasources/tournament_remote_data_source.dart';
import '/features/tournament/data/repositories/tournament_repository_impl.dart';
import '/features/tournament/domain/repositories/tournament_repository.dart';
import '/features/tournament/domain/usecases/start_tournament_usecase.dart';
import '/features/tournament/domain/usecases/submit_round_result_usecase.dart';
import '/features/tournament/domain/usecases/watch_tournament_id_for_room_usecase.dart';
import '/features/tournament/domain/usecases/watch_tournament_usecase.dart';
import '/features/tournament/domain/validators/round_submission_validator.dart';
import '/features/tournament/presentation/blocs/tournament_bloc.dart';

class TournamentModule {
  TournamentModule._();

  static void register() {
    // Data Sources
    ServiceLocator.registerLazySingleton<TournamentRemoteDataSource>(
      () => TournamentRemoteDataSourceImpl(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instanceFor(region: 'europe-west6'),
      ),
    );

    // Repositories
    ServiceLocator.registerLazySingleton<TournamentRepository>(
      () => TournamentRepositoryImpl(
        ServiceLocator.get<TournamentRemoteDataSource>(),
      ),
    );

    // Validators
    ServiceLocator.registerLazySingleton<RoundSubmissionValidator>(
      () => const RoundSubmissionValidator(),
    );

    // Use Cases
    ServiceLocator.registerFactory<StartTournamentUseCase>(
      () => StartTournamentUseCase(ServiceLocator.get<TournamentRepository>()),
    );

    ServiceLocator.registerFactory<WatchTournamentUseCase>(
      () => WatchTournamentUseCase(ServiceLocator.get<TournamentRepository>()),
    );

    ServiceLocator.registerFactory<WatchTournamentIdForRoomUseCase>(
      () => WatchTournamentIdForRoomUseCase(
        ServiceLocator.get<TournamentRepository>(),
      ),
    );

    ServiceLocator.registerFactory<SubmitRoundResultUseCase>(
      () => SubmitRoundResultUseCase(
        repository: ServiceLocator.get<TournamentRepository>(),
        validator: ServiceLocator.get<RoundSubmissionValidator>(),
      ),
    );

    // Presentation BLoCs
    ServiceLocator.registerFactory<TournamentBloc>(
      () => TournamentBloc(
        watchTournament: ServiceLocator.get<WatchTournamentUseCase>(),
        submitRoundResult: ServiceLocator.get<SubmitRoundResultUseCase>(),
        leaveRoom: ServiceLocator.get<LeaveRoomUseCase>(),
      ),
    );
  }
}
