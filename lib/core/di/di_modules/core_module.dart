// Package imports:
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/services/crash_reporting/crash_reporting.dart';
import '/core/services/crash_reporting/firebase_crash_reporting.dart';
import '/core/services/current_player/current_player_service.dart';
import '/core/services/current_player/current_player_service_impl.dart';

// Feature imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/profile/domain/repositories/profile_repository.dart';

class CoreModule {
  CoreModule._();

  static Future<void> register() async {
    if (!kIsWeb) {
      const crashReporting = FirebaseCrashReportingService();
      await crashReporting.initialize(enabled: kReleaseMode);

      ServiceLocator.registerSingleton<CrashReportingService>(crashReporting);
    }

    // Current player
    ServiceLocator.registerLazySingleton<CurrentPlayerService>(
      () => CurrentPlayerServiceImpl(
        authRepository: ServiceLocator.get<AuthRepository>(),
        profileRepository: ServiceLocator.get<ProfileRepository>(),
      ),
    );
  }
}
