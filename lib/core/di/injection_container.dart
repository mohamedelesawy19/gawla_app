// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/di_modules/auth_module.dart';
import '/core/di/di_modules/core_module.dart';
import '/core/di/di_modules/home_module.dart';
import '/core/di/di_modules/mini_games_module.dart';
import '/core/di/di_modules/profile_module.dart';
import '/core/di/di_modules/room_module.dart';
import '/core/di/di_modules/session_module.dart';
import '/core/di/di_modules/tournament_module.dart';
import '/core/di/service_locator.dart';
import '/core/services/crash_reporting/crash_reporting.dart';

/// Main dependency injection container that orchestrates the registration
/// of all application dependencies.
///
/// This class follows the modular approach where each logical group of
/// dependencies is registered in separate modules for better organization
/// and maintainability.
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize all dependencies
///   await InjectionContainer.init();
///
///   runApp(GawlaApp());
/// }
/// ```
class InjectionContainer {
  InjectionContainer._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      await CoreModule.register();

      AuthModule.register();

      ProfileModule.register();

      SessionModule.register();

      HomeModule.register();

      RoomModule.register();

      TournamentModule.register();

      MiniGamesModule.register();

      await ServiceLocator.allReady(timeout: const Duration(seconds: 30));

      _isInitialized = true;
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to initialize dependencies: $error');
      debugPrint('Stack trace: $stackTrace');

      // Dependency injection failure should be reported to the crash reporting
      // service if available
      unawaited(
        ServiceLocator.getOrNull<CrashReportingService>()?.recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'DI init failure',
        ),
      );

      rethrow;
    }
  }

  static Future<void> reset() async {
    await ServiceLocator.reset();
    _isInitialized = false;
  }

  static Future<void> reinit() async {
    await reset();
    await init();
  }
}
