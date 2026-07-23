// Dart imports:
import 'dart:async';
import 'dart:developer';

// Package imports:
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/services/crash_reporting/crash_reporting.dart';

/// Centralized application error handling.
///
/// Captures errors from three different sources:
/// - FlutterError: Flutter framework/UI errors.
/// - PlatformDispatcher: uncaught engine/platform errors.
/// - Zone: uncaught async errors outside Flutter's framework.
///
/// Together they provide near-complete error coverage across the app.
final class GlobalErrorHandler {
  const GlobalErrorHandler._();
  static CrashReportingService? get _crashReporting =>
      ServiceLocator.getOrNull<CrashReportingService>();

  static void onFlutterError(FlutterErrorDetails details) {
    if (kReleaseMode) {
      unawaited(_crashReporting?.recordFlutterFatalError(details));
      return;
    }

    FlutterError.presentError(details);

    _report(
      details.exception,
      details.stack ?? StackTrace.current,
      source: 'FlutterError',
    );
  }

  static bool onPlatformError(Object error, StackTrace stackTrace) {
    if (kReleaseMode) {
      unawaited(
        _crashReporting?.recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'PlatformDispatcher',
        ),
      );
      return true;
    }

    _report(error, stackTrace, source: 'PlatformDispatcher');

    return true;
  }

  static void onZoneError(Object error, StackTrace stackTrace) {
    if (kReleaseMode) {
      unawaited(
        _crashReporting?.recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'Zone',
        ),
      );
      return;
    }

    _report(error, stackTrace, source: 'Zone');
  }

  static void _report(
    Object error,
    StackTrace stack, {
    required String source,
  }) {
    log(
      '❌ [$source]\n'
      'Error: $error\n\n'
      'StackTrace:\n$stack',
      name: 'GlobalErrorHandler',
      error: error,
      stackTrace: stack,
    );
  }
}
