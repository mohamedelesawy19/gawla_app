part of 'room_bloc.dart';

sealed class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

/// Creates a new room with the given [visibility] and [settings].
final class RoomCreateEvent extends RoomEvent {
  const RoomCreateEvent({required this.visibility, required this.settings});

  final RoomVisibility visibility;
  final RoomSettingsEntity settings;

  @override
  List<Object?> get props => [visibility, settings];
}

/// Joins a specific, already-known room (e.g. selected from a public
/// room browser, or a deep link).
final class RoomJoinEvent extends RoomEvent {
  const RoomJoinEvent({required this.roomId});

  final String roomId;

  @override
  List<Object?> get props => [roomId];
}

/// Joins a private room by invite code.
final class RoomJoinByCodeEvent extends RoomEvent {
  const RoomJoinByCodeEvent({required this.inviteCode});

  final String inviteCode;

  @override
  List<Object?> get props => [inviteCode];
}

/// Finds (or creates) an open public room automatically.
final class RoomQuickMatchEvent extends RoomEvent {
  const RoomQuickMatchEvent({this.defaultSettings});

  /// Used only if no open public room is found and a new one has to be
  /// created; falls back to [QuickMatchParams]'s own default when
  /// omitted.
  final RoomSettingsEntity? defaultSettings;

  @override
  List<Object?> get props => [defaultSettings];
}

/// Leaves the room currently reflected in [RoomState.room].
final class RoomLeaveEvent extends RoomEvent {
  const RoomLeaveEvent();
}

/// Host-only: removes [targetUid] from the current room.
final class RoomKickPlayerEvent extends RoomEvent {
  const RoomKickPlayerEvent({required this.targetUid});

  final String targetUid;

  @override
  List<Object?> get props => [targetUid];
}

/// Host-only: updates the current room's settings.
final class RoomUpdateSettingsEvent extends RoomEvent {
  const RoomUpdateSettingsEvent({required this.settings});

  final RoomSettingsEntity settings;

  @override
  List<Object?> get props => [settings];
}

/// Starts streaming realtime updates for [roomId], or — when [roomId]
/// is `null` — stops watching and resets to [RoomState]'s initial value.
///
/// Dispatched internally after a successful create/join/quick-match,
/// and dispatched by the app shell once it learns (via `SessionBloc`
/// and `WatchRoomIdForUserUseCase`) that the current user already
/// belongs to a room on app start or rehydration.
final class RoomWatchEvent extends RoomEvent {
  const RoomWatchEvent({this.roomId});

  final String? roomId;

  @override
  List<Object?> get props => [roomId];
}
