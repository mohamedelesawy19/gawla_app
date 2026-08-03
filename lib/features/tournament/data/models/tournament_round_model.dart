// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/data/models/round_result_model.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';

class TournamentRoundModel extends Equatable {
  const TournamentRoundModel({
    required this.roundIndex,
    required this.miniGameId,
    required this.status,
    this.startedAt,
    this.endsAt,
    this.results = const [],
  });

  final int roundIndex;
  final String miniGameId;
  final RoundStatus status;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final List<RoundResultModel> results;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory TournamentRoundModel.fromMap(Map<String, dynamic> data) {
    return TournamentRoundModel(
      roundIndex: (data['roundIndex'] as num).toInt(),
      miniGameId: data['miniGameId'] as String,
      status: RoundStatus.values.byName(
        data['status'] as String? ?? RoundStatus.pending.name,
      ),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      endsAt: (data['endsAt'] as Timestamp?)?.toDate(),
      results: (data['results'] as List<dynamic>? ?? [])
          .map((e) => RoundResultModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roundIndex': roundIndex,
      'miniGameId': miniGameId,
      'status': status.name,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endsAt': endsAt != null ? Timestamp.fromDate(endsAt!) : null,
      'results': results.map((e) => e.toFirestore()).toList(),
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory TournamentRoundModel.fromJson(Map<String, dynamic> json) {
    return TournamentRoundModel(
      roundIndex: json['roundIndex'] as int,
      miniGameId: json['miniGameId'] as String,
      status: RoundStatus.values.byName(json['status'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => RoundResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundIndex': roundIndex,
      'miniGameId': miniGameId,
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory TournamentRoundModel.fromEntity(TournamentRoundEntity entity) {
    return TournamentRoundModel(
      roundIndex: entity.roundIndex,
      miniGameId: entity.miniGameId,
      status: entity.status,
      startedAt: entity.startedAt,
      endsAt: entity.endsAt,
      results: entity.results.map(RoundResultModel.fromEntity).toList(),
    );
  }

  TournamentRoundEntity toEntity() {
    return TournamentRoundEntity(
      roundIndex: roundIndex,
      miniGameId: miniGameId,
      status: status,
      startedAt: startedAt,
      endsAt: endsAt,
      results: results.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [
    roundIndex,
    miniGameId,
    status,
    startedAt,
    endsAt,
    results,
  ];
}
