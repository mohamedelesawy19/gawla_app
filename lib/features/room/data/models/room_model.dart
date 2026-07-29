// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/room/data/models/room_player_model.dart';
import '/features/room/data/models/room_settings_model.dart';
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/entities/room_enums.dart';

class RoomModel extends Equatable {
  const RoomModel({
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
  final String? inviteCode;
  final RoomStatus status;
  final RoomSettingsModel settings;
  final List<RoomPlayerModel> players;
  final DateTime createdAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory RoomModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return RoomModel(
      roomId: doc.id,
      hostUid: data['hostUid'] as String,
      visibility: RoomVisibility.values.byName(data['visibility'] as String),
      inviteCode: data['inviteCode'] as String?,
      status: RoomStatus.values.byName(data['status'] as String),
      settings: RoomSettingsModel.fromJson(
        data['settings'] as Map<String, dynamic>,
      ),
      players: (data['players'] as List<dynamic>? ?? [])
          .map(
            (player) => RoomPlayerModel.fromJson(
              Map<String, dynamic>.from(player as Map),
            ),
          )
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hostUid': hostUid,
      'visibility': visibility.name,
      'inviteCode': inviteCode,
      'status': status.name,
      'settings': settings.toJson(),
      'players': players.map((player) => player.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'] as String,
      hostUid: json['hostUid'] as String,
      visibility: RoomVisibility.values.byName(json['visibility'] as String),
      inviteCode: json['inviteCode'] as String?,
      status: RoomStatus.values.byName(json['status'] as String),
      settings: RoomSettingsModel.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      players: (json['players'] as List<dynamic>)
          .map(
            (player) => RoomPlayerModel.fromJson(
              Map<String, dynamic>.from(player as Map),
            ),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'hostUid': hostUid,
      'visibility': visibility.name,
      'inviteCode': inviteCode,
      'status': status.name,
      'settings': settings.toJson(),
      'players': players.map((player) => player.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      roomId: entity.roomId,
      hostUid: entity.hostUid,
      visibility: entity.visibility,
      inviteCode: entity.inviteCode,
      status: entity.status,
      settings: RoomSettingsModel.fromEntity(entity.settings),
      players: entity.players.map(RoomPlayerModel.fromEntity).toList(),
      createdAt: entity.createdAt,
    );
  }

  RoomEntity toEntity() {
    return RoomEntity(
      roomId: roomId,
      hostUid: hostUid,
      visibility: visibility,
      inviteCode: inviteCode,
      status: status,
      settings: settings.toEntity(),
      players: players.map((player) => player.toEntity()).toList(),
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
