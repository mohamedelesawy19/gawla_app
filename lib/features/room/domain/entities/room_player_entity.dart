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
    required this.isReady,
    required this.joinedAt,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;

  /// Whether the player has marked themselves ready in the waiting room.
  final bool isReady;
  final DateTime joinedAt;

  RoomPlayerEntity copyWith({
    String? displayName,
    String? avatarUrl,
    bool? isReady,
  }) {
    return RoomPlayerEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isReady: isReady ?? this.isReady,
      joinedAt: joinedAt,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, avatarUrl, isReady, joinedAt];
}
