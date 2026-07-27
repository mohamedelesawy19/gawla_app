import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  const PlayerEntity({
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

  PlayerEntity copyWith({
    String? displayName,
    String? avatarUrl,
    int? level,
    int? xp,
    int? coins,
    int? gems,
    DateTime? updatedAt,
  }) {
    return PlayerEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
