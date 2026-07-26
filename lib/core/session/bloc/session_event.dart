part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();
  @override
  List<Object?> get props => [];
}

/// Internal — fired whenever [WatchAuthStateUseCase]'s stream emits.
final class _AuthChanged extends SessionEvent {
  const _AuthChanged(this.user);
  final AuthUserEntity? user;

  @override
  List<Object?> get props => [user];
}

/// Internal — fired whenever the current room id changes for the signed-in
/// user.
final class _RoomChanged extends SessionEvent {
  const _RoomChanged(this.roomId);
  final String? roomId;

  @override
  List<Object?> get props => [roomId];
}

/// Internal — fired whenever the active match id changes for the current
/// room.
final class _MatchChanged extends SessionEvent {
  const _MatchChanged(this.matchId);
  final String? matchId;

  @override
  List<Object?> get props => [matchId];
}
