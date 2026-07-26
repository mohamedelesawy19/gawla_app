// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Features imports:
import '/features/profile/data/datasources/profile_remote_datasource.dart';
import '/features/profile/data/repositories/profile_repository_impl.dart';
import '/features/profile/domain/repositories/profile_repository.dart';
import '/features/profile/domain/usecases/get_profile_usecase.dart';
import '/features/profile/domain/usecases/update_profile_usecase.dart';
import '/features/profile/presentation/blocs/profile_bloc.dart';

class ProfileModule {
  ProfileModule._();

  static void register() {
    // Data Sources
    ServiceLocator.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
    );

    // Repositories
    ServiceLocator.registerLazySingleton<ProfileRepository>(
      () =>
          ProfileRepositoryImpl(ServiceLocator.get<ProfileRemoteDataSource>()),
    );

    // Use Cases
    ServiceLocator.registerFactory<GetProfileUseCase>(
      () => GetProfileUseCase(ServiceLocator.get<ProfileRepository>()),
    );

    ServiceLocator.registerFactory<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(ServiceLocator.get<ProfileRepository>()),
    );

    // Presentation BLoCs
    ServiceLocator.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getProfile: ServiceLocator.get<GetProfileUseCase>(),
        updateProfile: ServiceLocator.get<UpdateProfileUseCase>(),
      ),
    );
  }
}
