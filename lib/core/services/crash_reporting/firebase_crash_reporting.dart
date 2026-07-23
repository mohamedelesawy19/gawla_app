// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/services/crash_reporting/crash_reporting.dart';

final class FirebaseCrashReportingService implements CrashReportingService {
  const FirebaseCrashReportingService();

  FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  @override
  Future<void> initialize({required bool enabled}) {
    return _instance.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) {
    return _instance.recordFlutterFatalError(details);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) {
    return _instance.recordError(error, stack, fatal: fatal, reason: reason);
  }

  @override
  Future<void> log(String message) => _instance.log(message);

  @override
  Future<void> setUserIdentifier(String id) => _instance.setUserIdentifier(id);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _instance.setCustomKey(key, value);
}
