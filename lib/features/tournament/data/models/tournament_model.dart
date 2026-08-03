// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/data/models/tournament_player_model.dart';
import '/features/tournament/data/models/tournament_round_model.dart';
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';

class TournamentModel extends Equatable {
  const TournamentModel({
    required this.tournamentId,
    required this.roomId,
    required this.hostUid,
    required this.status,
    required this.miniGameRotation,
    required this.currentRoundIndex,
    required this.rounds,
    required this.players,
    this.winnerUid,
    required this.createdAt,
    this.completedAt,
  });

  final String tournamentId;
  final String roomId;
  final String hostUid;
  final TournamentStatus status;
  final List<String> miniGameRotation;
  final int currentRoundIndex;
  final List<TournamentRoundModel> rounds;
  final List<TournamentPlayerModel> players;
  final String? winnerUid;
  final DateTime createdAt;
  final DateTime? completedAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory TournamentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return TournamentModel(
      tournamentId: doc.id,
      roomId: data['roomId'] as String,
      hostUid: data['hostUid'] as String,
      status: TournamentStatus.values.byName(
        data['status'] as String? ?? TournamentStatus.starting.name,
      ),
      miniGameRotation: List<String>.from(
        data['miniGameRotation'] as List? ?? const [],
      ),
      currentRoundIndex: (data['currentRoundIndex'] as num?)?.toInt() ?? 0,
      rounds: (data['rounds'] as List<dynamic>? ?? [])
          .map((e) => TournamentRoundModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      players: (data['players'] as Map<String, dynamic>? ?? {}).entries
          .map(
            (entry) => TournamentPlayerModel.fromFirestoreMap(
              entry.key,
              Map<String, dynamic>.from(entry.value as Map),
            ),
          )
          .toList(),
      winnerUid: data['winnerUid'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'hostUid': hostUid,
      'status': status.name,
      'miniGameRotation': miniGameRotation,
      'currentRoundIndex': currentRoundIndex,
      'rounds': rounds.map((e) => e.toFirestore()).toList(),
      'players': {
        for (final player in players) player.uid: player.toFirestore(),
      },
      'winnerUid': winnerUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      tournamentId: json['tournamentId'] as String,
      roomId: json['roomId'] as String,
      hostUid: json['hostUid'] as String,
      status: TournamentStatus.values.byName(json['status'] as String),
      miniGameRotation: List<String>.from(
        json['miniGameRotation'] as List? ?? const [],
      ),
      currentRoundIndex: json['currentRoundIndex'] as int? ?? 0,
      rounds: (json['rounds'] as List<dynamic>? ?? [])
          .map((e) => TournamentRoundModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      players: (json['players'] as List<dynamic>? ?? [])
          .map((e) => TournamentPlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      winnerUid: json['winnerUid'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'roomId': roomId,
      'hostUid': hostUid,
      'status': status.name,
      'miniGameRotation': miniGameRotation,
      'currentRoundIndex': currentRoundIndex,
      'rounds': rounds.map((e) => e.toJson()).toList(),
      'players': players.map((e) => e.toJson()).toList(),
      'winnerUid': winnerUid,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory TournamentModel.fromEntity(TournamentEntity entity) {
    return TournamentModel(
      tournamentId: entity.tournamentId,
      roomId: entity.roomId,
      hostUid: entity.hostUid,
      status: entity.status,
      miniGameRotation: entity.miniGameRotation,
      currentRoundIndex: entity.currentRoundIndex,
      rounds: entity.rounds.map(TournamentRoundModel.fromEntity).toList(),
      players: entity.players.map(TournamentPlayerModel.fromEntity).toList(),
      winnerUid: entity.winnerUid,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }

  TournamentEntity toEntity() {
    return TournamentEntity(
      tournamentId: tournamentId,
      roomId: roomId,
      hostUid: hostUid,
      status: status,
      miniGameRotation: miniGameRotation,
      currentRoundIndex: currentRoundIndex,
      rounds: rounds.map((e) => e.toEntity()).toList(),
      players: players.map((e) => e.toEntity()).toList(),
      winnerUid: winnerUid,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  @override
  List<Object?> get props => [
    tournamentId,
    roomId,
    hostUid,
    status,
    miniGameRotation,
    currentRoundIndex,
    rounds,
    players,
    winnerUid,
    createdAt,
    completedAt,
  ];
}
