import 'package:flutter/foundation.dart';

abstract interface class CrashReportingService {
  Future<void> initialize({required bool enabled});
  Future<void> recordFlutterFatalError(FlutterErrorDetails details);
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  });
  Future<void> log(String message);
  Future<void> setUserIdentifier(String id);
  Future<void> setCustomKey(String key, Object value);
}
