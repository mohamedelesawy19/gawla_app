import 'package:equatable/equatable.dart';

/// A player's presence inside a single [RoomEntity].
///
/// This is intentionally a *slice* of the player's full profile (see
/// `PlayerEntity`) — a room only needs enough to render the waiting-room
/// list. Profile data (coins, gems, level, xp, ...) is never duplicated
/// here; the Profile feature stays the single source of truth for that.
class RoomPlayerEntity extends Equatable {
  const RoomPlayerEntity({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.joinedAt,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final DateTime joinedAt;

  RoomPlayerEntity copyWith({String? displayName, String? avatarUrl}) {
    return RoomPlayerEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, avatarUrl, joinedAt];
}
