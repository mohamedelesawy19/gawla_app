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

  /// Business rule for what happens to the room when [uid] leaves
  /// (voluntarily or via kick):
  /// - Returns `null` when the room should be closed/deleted — no
  ///   players are left to keep it alive.
  /// - Otherwise returns a new [RoomEntity] with [uid] removed and, if
  ///   they were the host, the longest-waiting remaining player promoted
  ///   to host.
  ///
  /// Lives here (not in the data source) so it's a plain, testable
  /// domain rule regardless of which backend persists it.
  RoomEntity? withPlayerRemoved(String uid) {
    final remaining = players.where((player) => player.uid != uid).toList();
    if (remaining.isEmpty) return null;

    return RoomEntity(
      roomId: roomId,
      hostUid: hostUid == uid ? remaining.first.uid : hostUid,
      visibility: visibility,
      inviteCode: inviteCode,
      status: status,
      settings: settings,
      players: remaining,
      createdAt: createdAt,
    );
  }

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
