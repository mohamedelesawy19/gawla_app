// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/room/domain/entities/room_settings_entity.dart';

class RoomSettingsModel extends Equatable {
  const RoomSettingsModel({
    required this.maxPlayers,
    required this.tournamentSize,
    required this.miniGameRotation,
  });

  final int maxPlayers;
  final int tournamentSize;
  final List<String> miniGameRotation;

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory RoomSettingsModel.fromJson(Map<String, dynamic> json) {
    return RoomSettingsModel(
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 2,
      tournamentSize: (json['tournamentSize'] as num?)?.toInt() ?? 2,
      miniGameRotation: List<String>.from(
        json['miniGameRotation'] as List? ?? const [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxPlayers': maxPlayers,
      'tournamentSize': tournamentSize,
      'miniGameRotation': miniGameRotation,
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory RoomSettingsModel.fromEntity(RoomSettingsEntity entity) {
    return RoomSettingsModel(
      maxPlayers: entity.maxPlayers,
      tournamentSize: entity.tournamentSize,
      miniGameRotation: List<String>.from(entity.miniGameRotation),
    );
  }

  RoomSettingsEntity toEntity() {
    return RoomSettingsEntity(
      maxPlayers: maxPlayers,
      tournamentSize: tournamentSize,
      miniGameRotation: List<String>.from(miniGameRotation),
    );
  }

  @override
  List<Object?> get props => [maxPlayers, tournamentSize, miniGameRotation];
}
