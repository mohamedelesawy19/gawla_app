// Package imports:
import 'package:get_it/get_it.dart';

/// Service Locator for accessing dependencies throughout the application.
///
/// This class provides a clean abstraction over the GetIt service locator,
/// making dependency retrieval type-safe and easy to test.
///
/// Usage:
/// ```dart
/// final authService = ServiceLocator.get<AuthService>();
/// final userRepository = ServiceLocator.get<UserRepository>();
/// ```
class ServiceLocator {
  ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;

  static T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    return _getIt.get<T>(
      instanceName: instanceName,
      param1: param1,
      param2: param2,
    );
  }

  static T? getOrNull<T extends Object>({String? instanceName}) {
    if (_getIt.isRegistered<T>(instanceName: instanceName)) {
      return _getIt.get<T>(instanceName: instanceName);
    }
    return null;
  }

  static bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }

  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
  }) {
    _getIt.registerSingleton<T>(
      instance,
      instanceName: instanceName,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }

  static void registerLazySingleton<T extends Object>(
    FactoryFunc<T> factoryFunc, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  }) {
    _getIt.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
      dispose: dispose,
    );
  }

  static void registerFactory<T extends Object>(
    FactoryFunc<T> factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }

  static void registerFactoryParam<T extends Object, P1, P2>(
    FactoryFuncParam<T, P1, P2> factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerFactoryParam<T, P1, P2>(
      factoryFunc,
      instanceName: instanceName,
    );
  }

  static void registerSingletonAsync<T extends Object>(
    FactoryFuncAsync<T> factoryFunc, {
    String? instanceName,
    Iterable<Type>? dependsOn,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
  }) {
    _getIt.registerSingletonAsync<T>(
      factoryFunc,
      instanceName: instanceName,
      dependsOn: dependsOn,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }

  static Future<void> unregister<T extends Object>({
    String? instanceName,
  }) async {
    await _getIt.unregister<T>(instanceName: instanceName);
  }

  static Future<void> allReady({
    Duration? timeout,
    bool ignorePendingAsyncCreation = false,
  }) {
    return _getIt.allReady(
      timeout: timeout,
      ignorePendingAsyncCreation: ignorePendingAsyncCreation,
    );
  }

  static Future<void> reset({bool dispose = true}) {
    return _getIt.reset(dispose: dispose);
  }
}
