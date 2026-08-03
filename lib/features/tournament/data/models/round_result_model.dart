// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/round_result_entity.dart';

class RoundResultModel extends Equatable {
  const RoundResultModel({
    required this.uid,
    this.score,
    this.rank,
    required this.eliminated,
    this.submittedAt,
  });

  final String uid;
  final double? score;
  final int? rank;
  final bool eliminated;
  final DateTime? submittedAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory RoundResultModel.fromMap(Map<String, dynamic> data) {
    return RoundResultModel(
      uid: data['uid'] as String,
      score: (data['score'] as num?)?.toDouble(),
      rank: (data['rank'] as num?)?.toInt(),
      eliminated: data['eliminated'] as bool? ?? false,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'score': score,
      'rank': rank,
      'eliminated': eliminated,
      'submittedAt': submittedAt != null
          ? Timestamp.fromDate(submittedAt!)
          : null,
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory RoundResultModel.fromJson(Map<String, dynamic> json) {
    return RoundResultModel(
      uid: json['uid'] as String,
      score: (json['score'] as num?)?.toDouble(),
      rank: json['rank'] as int?,
      eliminated: json['eliminated'] as bool? ?? false,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'score': score,
      'rank': rank,
      'eliminated': eliminated,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory RoundResultModel.fromEntity(RoundResultEntity entity) {
    return RoundResultModel(
      uid: entity.uid,
      score: entity.score,
      rank: entity.rank,
      eliminated: entity.eliminated,
      submittedAt: entity.submittedAt,
    );
  }

  RoundResultEntity toEntity() {
    return RoundResultEntity(
      uid: uid,
      score: score,
      rank: rank,
      eliminated: eliminated,
      submittedAt: submittedAt,
    );
  }

  @override
  List<Object?> get props => [uid, score, rank, eliminated, submittedAt];
}
