// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Features imports:
import '/features/auth/data/datasources/auth_remote_datasource.dart';
import '/features/auth/data/repositories/auth_repository_impl.dart';
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_out_usecase.dart';
import '/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import '/features/auth/presentation/bloc/auth_bloc.dart';

class AuthModule {
  AuthModule._();

  static void register() {
    // Data Sources
    ServiceLocator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
        googleSignIn: GoogleSignIn.instance,
      ),
    );

    // Repositories
    ServiceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(ServiceLocator.get<AuthRemoteDataSource>()),
    );

    // Use Cases
    ServiceLocator.registerFactory<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(ServiceLocator.get<AuthRepository>()),
    );

    ServiceLocator.registerFactory<SignInAnonymouslyUseCase>(
      () => SignInAnonymouslyUseCase(ServiceLocator.get<AuthRepository>()),
    );

    ServiceLocator.registerFactory<SignOutUseCase>(
      () => SignOutUseCase(ServiceLocator.get<AuthRepository>()),
    );

    ServiceLocator.registerFactory<WatchAuthStateUseCase>(
      () => WatchAuthStateUseCase(ServiceLocator.get<AuthRepository>()),
    );

    // Presentation BLoCs
    ServiceLocator.registerFactory<AuthBloc>(
      () => AuthBloc(
        signInWithGoogle: ServiceLocator.get<SignInWithGoogleUseCase>(),
        signInAnonymously: ServiceLocator.get<SignInAnonymouslyUseCase>(),
        signOut: ServiceLocator.get<SignOutUseCase>(),
      ),
    );
  }
}
