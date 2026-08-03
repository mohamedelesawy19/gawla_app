part of 'session_bloc.dart';

/// Drives top-level routing. See [SessionBloc]'s doc comment for why this
/// is a single flat class rather than a sealed hierarchy like `AuthState`:
/// the router needs `status` *and* whichever ids are relevant at the same
/// time (e.g. `roomId` is still meaningful while `inTournament`, since a
/// tournament belongs to a room) — awkward to read back out of a sealed
/// hierarchy on every rebuild, trivial to read off a flat class.
enum SessionStatus {
  unknown,
  unauthenticated,
  authenticated,
  inRoom,
  inTournament,
}

class SessionState extends Equatable {
  const SessionState._({
    required this.status,
    this.uid,
    this.roomId,
    this.tournamentId,
  });

  const SessionState.unknown() : this._(status: SessionStatus.unknown);

  const SessionState.unauthenticated()
    : this._(status: SessionStatus.unauthenticated);

  const SessionState.authenticated({required String uid})
    : this._(status: SessionStatus.authenticated, uid: uid);

  const SessionState.inRoom({required String uid, required String roomId})
    : this._(status: SessionStatus.inRoom, uid: uid, roomId: roomId);

  const SessionState.inTournament({
    required String uid,
    required String roomId,
    required String tournamentId,
  }) : this._(
         status: SessionStatus.inTournament,
         uid: uid,
         roomId: roomId,
         tournamentId: tournamentId,
       );

  final SessionStatus status;
  final String? uid;
  final String? roomId;
  final String? tournamentId;

  @override
  List<Object?> get props => [status, uid, roomId, tournamentId];
}
