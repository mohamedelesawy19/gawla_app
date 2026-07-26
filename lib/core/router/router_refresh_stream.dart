import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges any [Stream] — here, `SessionBloc`'s state stream — into the
/// [Listenable] that go_router's `refreshListenable` expects, so a
/// redirect is re-evaluated the instant the session changes. No polling,
/// no rebuilding the router itself.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
