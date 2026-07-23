// Dart imports:
import 'dart:async';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Config imports:
import '/config/firebase/firebase_options.dart';

// Core imports:
import '/core/di/injection_container.dart';
import '/core/error_handling/global_error_handler.dart';
import '/core/observers/app_bloc_observer.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Setup DI
    await InjectionContainer.init();

    // 3. Setup BLoC observer
    Bloc.observer = const AppBlocObserver();

    // 4. Setup global error handler
    FlutterError.onError = GlobalErrorHandler.onFlutterError;
    PlatformDispatcher.instance.onError = GlobalErrorHandler.onPlatformError;

    runApp(await builder());
  }, GlobalErrorHandler.onZoneError);
}
