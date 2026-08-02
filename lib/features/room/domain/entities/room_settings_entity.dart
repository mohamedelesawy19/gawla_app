import 'package:equatable/equatable.dart';

/// Host-configurable rules for a room, set on the "Room Settings" step
/// and editable by the host until the tournament starts.
class RoomSettingsEntity extends Equatable {
  const RoomSettingsEntity({required this.miniGameRotation});

  /// Ordered list of mini-game ids to play, one per round. Stored as
  /// plain ids (not a mini-games domain type) so the Room feature has
  /// no compile-time dependency on the future Mini Games feature.
  final List<String> miniGameRotation;

  RoomSettingsEntity copyWith({List<String>? miniGameRotation}) {
    return RoomSettingsEntity(
      miniGameRotation: miniGameRotation ?? this.miniGameRotation,
    );
  }

  @override
  List<Object?> get props => [miniGameRotation];
}
