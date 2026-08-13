// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/domain/entities/room_player_entity.dart';
import '/features/room/domain/entities/room_settings_entity.dart';

/// A lobby that players join before a tournament starts.
///
/// Mirrors the `rooms` collection described in the project overview.
/// The Room feature owns everything up to "Waiting Room" in the tournament
/// flow; once a tournament is created, `SessionBloc`'s tournament subscription
/// takes over and this room becomes read-only history.
class RoomEntity extends Equatable {
  const RoomEntity({
    required this.roomId,
    required this.hostUid,
    required this.visibility,
    this.inviteCode,
    required this.status,
    required this.settings,
    required this.players,
    required this.createdAt,
  });

  final String roomId;
  final String hostUid;
  final RoomVisibility visibility;

  /// Only set when [visibility] is [RoomVisibility.private].
  final String? inviteCode;
  final RoomStatus status;
  final RoomSettingsEntity settings;
  final List<RoomPlayerEntity> players;
  final DateTime createdAt;

  bool isHost(String uid) => hostUid == uid;

  bool hasPlayer(String uid) => players.any((player) => player.uid == uid);

  bool get canStartTournament =>
      players.length >= 2 && settings.miniGameRotation.isNotEmpty;

  /// Business rule for what happens to the room when [uid] leaves
  /// (voluntarily or via kick):
  ///
  /// - Returns `null` when no human players remain — bots never keep
  ///   the room alive on their own.
  /// - Otherwise returns a new [RoomEntity] with [uid] removed.
  /// - The host is always a human:
  ///   - If the current host is still a human, keep them.
  ///   - If the host left, or is somehow a bot, promote the longest-waiting
  ///     remaining human (the first human in the existing player order).
  ///
  /// Lives here (not in the data source) so this business rule remains
  /// backend-agnostic and independently testable.
  RoomEntity? withPlayerRemoved(String uid) {
    final remaining = players.where((player) => player.uid != uid).toList();

    // Bots must never keep a room alive by themselves.
    final remainingHumans = remaining
        .where((player) => !_isBotUid(player.uid))
        .toList();

    // No human remains => close/delete the room.
    if (remainingHumans.isEmpty) return null;

    // Keep the current host only if they are still present AND human.
    final currentHostIsHuman = remainingHumans.any(
      (player) => player.uid == hostUid,
    );

    final nextHostUid = currentHostIsHuman
        ? hostUid
        : remainingHumans.first.uid;

    return RoomEntity(
      roomId: roomId,
      hostUid: nextHostUid,
      visibility: visibility,
      inviteCode: inviteCode,
      status: status,
      settings: settings,
      players: remaining,
      createdAt: createdAt,
    );
  }

  /// Must stay consistent with the backend's `BOT_UID_PREFIX`.
  bool _isBotUid(String uid) => uid.startsWith('bot_');

  RoomEntity copyWith({
    RoomStatus? status,
    RoomSettingsEntity? settings,
    List<RoomPlayerEntity>? players,
  }) {
    return RoomEntity(
      roomId: roomId,
      hostUid: hostUid,
      visibility: visibility,
      inviteCode: inviteCode,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      players: players ?? this.players,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    roomId,
    hostUid,
    visibility,
    inviteCode,
    status,
    settings,
    players,
    createdAt,
  ];
}
