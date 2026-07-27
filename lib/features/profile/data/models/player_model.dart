// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';

class PlayerModel extends Equatable {
  const PlayerModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.coins,
    required this.gems,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final int gems;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory PlayerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return PlayerModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Player',
      avatarUrl: data['avatarUrl'] as String?,
      level: (data['level'] as num?)?.toInt() ?? 1,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      coins: (data['coins'] as num?)?.toInt() ?? 0,
      gems: (data['gems'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'xp': xp,
      'coins': coins,
      'gems': gems,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'xp': xp,
      'coins': coins,
      'gems': gems,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      uid: entity.uid,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      level: entity.level,
      xp: entity.xp,
      coins: entity.coins,
      gems: entity.gems,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PlayerEntity toEntity() {
    return PlayerEntity(
      uid: uid,
      displayName: displayName,
      avatarUrl: avatarUrl,
      level: level,
      xp: xp,
      coins: coins,
      gems: gems,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    avatarUrl,
    level,
    xp,
    coins,
    gems,
    createdAt,
    updatedAt,
  ];
}
