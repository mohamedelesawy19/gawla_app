// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/room/domain/entities/room_settings_entity.dart';

class RoomSettingsModel extends Equatable {
  const RoomSettingsModel({required this.miniGameRotation});

  final List<String> miniGameRotation;

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory RoomSettingsModel.fromJson(Map<String, dynamic> json) {
    return RoomSettingsModel(
      miniGameRotation: List<String>.from(
        json['miniGameRotation'] as List? ?? const [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'miniGameRotation': miniGameRotation};
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory RoomSettingsModel.fromEntity(RoomSettingsEntity entity) {
    return RoomSettingsModel(
      miniGameRotation: List<String>.from(entity.miniGameRotation),
    );
  }

  RoomSettingsEntity toEntity() {
    return RoomSettingsEntity(
      miniGameRotation: List<String>.from(miniGameRotation),
    );
  }

  @override
  List<Object?> get props => [miniGameRotation];
}
