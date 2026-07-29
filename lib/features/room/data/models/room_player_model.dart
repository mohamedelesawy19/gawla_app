// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/room/domain/entities/room_player_entity.dart';

class RoomPlayerModel extends Equatable {
  const RoomPlayerModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.joinedAt,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final DateTime joinedAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory RoomPlayerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return RoomPlayerModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Player',
      avatarUrl: data['avatarUrl'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) {
    return RoomPlayerModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory RoomPlayerModel.fromEntity(RoomPlayerEntity entity) {
    return RoomPlayerModel(
      uid: entity.uid,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      joinedAt: entity.joinedAt,
    );
  }

  RoomPlayerEntity toEntity() {
    return RoomPlayerEntity(
      uid: uid,
      displayName: displayName,
      avatarUrl: avatarUrl,
      joinedAt: joinedAt,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, avatarUrl, joinedAt];
}
