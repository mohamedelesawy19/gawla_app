// Package imports:
import 'package:firebase_database/firebase_database.dart';

// Feature imports:
import '/features/mini_games/domain/realtime_game_channel.dart';

/// Firebase Realtime Database-backed implementation. Kept deliberately
/// dumb — no game-specific parsing here — each widget interprets the
/// decoded map itself, the same "opaque until interpreted" boundary
/// `RoundResultDoc.metadata` already uses on the Tournament side.
class FirebaseRealtimeGameChannel implements RealtimeGameChannel {
  const FirebaseRealtimeGameChannel(this._database);

  final FirebaseDatabase _database;

  @override
  Stream<Map<String, dynamic>> watch(String channelPath) {
    return _database.ref(channelPath).onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is Map) {
        return raw.map((key, value) => MapEntry(key.toString(), value));
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> pushEvent(String channelPath, Map<String, dynamic> event) {
    return _database.ref('$channelPath/events').push().set({
      ...event,
      // Client clock is advisory only, same rationale as every other
      // anti-cheat boundary in this project — the driving Cloud Function
      // re-timestamps server-side and is the only version that counts
      // for scoring.
      'clientSentAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
