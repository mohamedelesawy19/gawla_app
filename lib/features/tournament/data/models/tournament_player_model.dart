// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/entities/tournament_player_entity.dart';

class TournamentPlayerModel extends Equatable {
  const TournamentPlayerModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.status,
    this.eliminatedAtRoundIndex,
    this.finalPlacement,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final TournamentPlayerStatus status;
  final int? eliminatedAtRoundIndex;
  final int? finalPlacement;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory TournamentPlayerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return TournamentPlayerModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Player',
      avatarUrl: data['avatarUrl'] as String?,
      status: TournamentPlayerStatus.values.byName(
        data['status'] as String? ?? TournamentPlayerStatus.active.name,
      ),
      eliminatedAtRoundIndex: (data['eliminatedAtRoundIndex'] as num?)?.toInt(),
      finalPlacement: (data['finalPlacement'] as num?)?.toInt(),
    );
  }

  factory TournamentPlayerModel.fromFirestoreMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return TournamentPlayerModel(
      uid: uid,
      displayName: data['displayName'] as String? ?? 'Player',
      avatarUrl: data['avatarUrl'] as String?,
      status: TournamentPlayerStatus.values.byName(
        data['status'] as String? ?? TournamentPlayerStatus.active.name,
      ),
      eliminatedAtRoundIndex: (data['eliminatedAtRoundIndex'] as num?)?.toInt(),
      finalPlacement: (data['finalPlacement'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'eliminatedAtRoundIndex': eliminatedAtRoundIndex,
      'finalPlacement': finalPlacement,
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory TournamentPlayerModel.fromJson(Map<String, dynamic> json) {
    return TournamentPlayerModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      status: TournamentPlayerStatus.values.byName(json['status'] as String),
      eliminatedAtRoundIndex: json['eliminatedAtRoundIndex'] as int?,
      finalPlacement: json['finalPlacement'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'eliminatedAtRoundIndex': eliminatedAtRoundIndex,
      'finalPlacement': finalPlacement,
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory TournamentPlayerModel.fromEntity(TournamentPlayerEntity entity) {
    return TournamentPlayerModel(
      uid: entity.uid,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      status: entity.status,
      eliminatedAtRoundIndex: entity.eliminatedAtRoundIndex,
      finalPlacement: entity.finalPlacement,
    );
  }

  TournamentPlayerEntity toEntity() {
    return TournamentPlayerEntity(
      uid: uid,
      displayName: displayName,
      avatarUrl: avatarUrl,
      status: status,
      eliminatedAtRoundIndex: eliminatedAtRoundIndex,
      finalPlacement: finalPlacement,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    avatarUrl,
    status,
    eliminatedAtRoundIndex,
    finalPlacement,
  ];
}
