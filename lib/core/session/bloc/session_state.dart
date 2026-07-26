part of 'session_bloc.dart';

/// Drives top-level routing. See [SessionBloc]'s doc comment for why this
/// is a single flat class rather than a sealed hierarchy like `AuthState`:
/// the router needs `status` *and* whichever ids are relevant at the same
/// time (e.g. `roomId` is still meaningful while `inMatch`, since a match
/// belongs to a room) — awkward to read back out of a sealed hierarchy on
/// every rebuild, trivial to read off a flat class.
enum SessionStatus { unknown, unauthenticated, authenticated, inRoom, inMatch }

class SessionState extends Equatable {
  const SessionState._({
    required this.status,
    this.uid,
    this.roomId,
    this.matchId,
  });

  const SessionState.unknown() : this._(status: SessionStatus.unknown);

  const SessionState.unauthenticated()
    : this._(status: SessionStatus.unauthenticated);

  const SessionState.authenticated({required String uid})
    : this._(status: SessionStatus.authenticated, uid: uid);

  const SessionState.inRoom({required String uid, required String roomId})
    : this._(status: SessionStatus.inRoom, uid: uid, roomId: roomId);

  const SessionState.inMatch({
    required String uid,
    required String roomId,
    required String matchId,
  }) : this._(
         status: SessionStatus.inMatch,
         uid: uid,
         roomId: roomId,
         matchId: matchId,
       );

  final SessionStatus status;
  final String? uid;
  final String? roomId;
  final String? matchId;

  @override
  List<Object?> get props => [status, uid, roomId, matchId];
}
