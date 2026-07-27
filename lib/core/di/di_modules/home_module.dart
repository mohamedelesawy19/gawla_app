// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Features imports:
import '/features/home/data/datasources/home_remote_data_source.dart';
import '/features/home/data/repositories/home_repository_impl.dart';
import '/features/home/domain/repositories/home_repository.dart';
import '/features/home/domain/usecases/get_home_dashboard_usecase.dart';
import '/features/home/presentation/blocs/home_cubit.dart';

class HomeModule {
  HomeModule._();

  static void register() {
    // Data Sources
    ServiceLocator.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
    );

    // Repositories
    ServiceLocator.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(ServiceLocator.get<HomeRemoteDataSource>()),
    );

    // Use Cases
    ServiceLocator.registerFactory<GetHomeDashboardUsecase>(
      () => GetHomeDashboardUsecase(ServiceLocator.get<HomeRepository>()),
    );

    // Presentation BLoCs
    ServiceLocator.registerFactory<HomeCubit>(
      () => HomeCubit(
        getHomeDashboard: ServiceLocator.get<GetHomeDashboardUsecase>(),
      ),
    );
  }
}
