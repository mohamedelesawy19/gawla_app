// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Feature imports:
import '/features/auth/domain/entities/auth_user_entity.dart';
import '/features/auth/domain/usecases/watch_auth_state_usecase.dart';

// Part imports:
part 'session_event.dart';
part 'session_state.dart';

/// Watches the id of the room the user with [uid] is currently in, or
/// `null` if they're not in any room.
///
/// Implemented later by the Room feature (e.g. a Firestore listener on
/// `rooms` where the `players` array contains `uid`). Leaving this `null`
/// in [SessionBloc]'s constructor makes room-tracking a safe no-op —
/// useful before the Room feature exists.
typedef WatchRoomId = Stream<String?> Function(String uid);

/// Watches the id of the currently active match for [roomId], or `null` if
/// that room has no match in progress. Implemented later by the Match
/// feature.
typedef WatchMatchId = Stream<String?> Function(String roomId);

/// The single global bloc for app-wide navigation state.
///
/// [SessionBloc] does NOT own or store profile data (name, coins, gems,
/// level, ...) — that stays `ProfileBloc`'s job, loaded lazily by whichever
/// screen actually needs it. This bloc only tracks *identity + navigation*:
/// `uid`, `roomId`, `matchId`, and the derived [SessionStatus]. Keeping it
/// this thin is what stops it turning into a "God Bloc".
///
/// It never receives events from the UI. It is entirely self-driven: it
/// subscribes directly to the underlying repository streams (auth, room,
/// match — the same pattern `AuthBloc`'s doc comment already points at:
/// "the SessionBloc will observe login success through the stream") and
/// reduces them into one [SessionState] that the router reads.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required this._watchAuthState,
    WatchRoomId? watchRoomId,
    WatchMatchId? watchMatchId,
  }) : _watchRoomId = watchRoomId ?? ((_) => Stream<String?>.value(null)),
       _watchMatchId = watchMatchId ?? ((_) => Stream<String?>.value(null)),
       super(const SessionState.unknown()) {
    on<_AuthChanged>(_onAuthChanged);
    on<_RoomChanged>(_onRoomChanged);
    on<_MatchChanged>(_onMatchChanged);

    _authSubscription = _watchAuthState().listen(
      (user) => add(_AuthChanged(user)),
    );
  }

  final WatchAuthStateUseCase _watchAuthState;
  final WatchRoomId _watchRoomId;
  final WatchMatchId _watchMatchId;

  late final StreamSubscription<AuthUserEntity?> _authSubscription;
  StreamSubscription<String?>? _roomSubscription;
  StreamSubscription<String?>? _matchSubscription;

  // ── Auth → drives the room subscription ────────────────────────────────────

  Future<void> _onAuthChanged(
    _AuthChanged event,
    Emitter<SessionState> emit,
  ) async {
    // Identity changed (login / logout / account switch) — whatever room or
    // match we were watching belonged to the *previous* uid, so it must be
    // torn down before we react to the new one.
    await _roomSubscription?.cancel();
    await _matchSubscription?.cancel();
    _roomSubscription = null;
    _matchSubscription = null;

    final user = event.user;
    if (user == null) {
      emit(const SessionState.unauthenticated());
      return;
    }

    emit(SessionState.authenticated(uid: user.uid));

    _roomSubscription = _watchRoomId(
      user.uid,
    ).listen((roomId) => add(_RoomChanged(roomId)));
  }

  // ── Room → drives the match subscription ───────────────────────────────────

  void _onRoomChanged(_RoomChanged event, Emitter<SessionState> emit) {
    final uid = state.uid;
    if (uid == null) return; // Stale event racing a logout — ignore.

    final roomId = event.roomId;

    if (roomId == null) {
      _matchSubscription?.cancel();
      _matchSubscription = null;
      emit(SessionState.authenticated(uid: uid));
      return;
    }

    emit(SessionState.inRoom(uid: uid, roomId: roomId));

    _matchSubscription?.cancel();
    _matchSubscription = _watchMatchId(
      roomId,
    ).listen((matchId) => add(_MatchChanged(matchId)));
  }

  // ── Match ──────────────────────────────────────────────────────────────────

  void _onMatchChanged(_MatchChanged event, Emitter<SessionState> emit) {
    final uid = state.uid;
    final roomId = state.roomId;
    if (uid == null || roomId == null) return;

    final matchId = event.matchId;
    emit(
      matchId == null
          ? SessionState.inRoom(uid: uid, roomId: roomId)
          : SessionState.inMatch(uid: uid, roomId: roomId, matchId: matchId),
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    await _roomSubscription?.cancel();
    await _matchSubscription?.cancel();
    return super.close();
  }
}
