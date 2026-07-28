// Package imports:
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/services/crash_reporting/crash_reporting.dart';
import '/core/services/crash_reporting/firebase_crash_reporting.dart';

class CoreModule {
  CoreModule._();

  static Future<void> register() async {
    if (kIsWeb) return;

    const crashReporting = FirebaseCrashReportingService();
    await crashReporting.initialize(enabled: kReleaseMode);

    ServiceLocator.registerSingleton<CrashReportingService>(crashReporting);
  }
}
