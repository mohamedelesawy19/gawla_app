import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) debugPrint('\nonCreate -- ${bloc.runtimeType}\n');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) debugPrint('\nonEvent -- ${bloc.runtimeType}, $event\n');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) debugPrint('\nonChange -- ${bloc.runtimeType}, $change\n');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('\nonTransition -- ${bloc.runtimeType}, $transition\n');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint(
        '\n❌ BlocError -- ${bloc.runtimeType}\n'
        'Error: $error\n'
        'Stack: $stackTrace\n',
      );
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    if (kDebugMode) debugPrint('\nonClose -- ${bloc.runtimeType}\n');
  }
}
