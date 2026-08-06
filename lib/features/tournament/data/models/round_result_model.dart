// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/round_result_entity.dart';

class RoundResultModel extends Equatable {
  const RoundResultModel({
    required this.uid,
    this.score,
    this.passed,
    this.rank,
    required this.eliminated,
    this.submittedAt,
    this.groupId,
    this.metadata,
  });

  final String uid;
  final double? score;
  final bool? passed;
  final int? rank;
  final bool eliminated;
  final DateTime? submittedAt;
  final String? groupId;
  final Map<String, dynamic>? metadata;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory RoundResultModel.fromMap(Map<String, dynamic> data) {
    return RoundResultModel(
      uid: data['uid'] as String,
      score: (data['score'] as num?)?.toDouble(),
      passed: data['passed'] as bool?,
      rank: (data['rank'] as num?)?.toInt(),
      eliminated: data['eliminated'] as bool? ?? false,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      groupId: data['groupId'] as String?,
      metadata: (data['metadata'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'score': score,
      'passed': passed,
      'rank': rank,
      'eliminated': eliminated,
      'submittedAt': submittedAt != null
          ? Timestamp.fromDate(submittedAt!)
          : null,
      'groupId': groupId,
      'metadata': metadata,
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory RoundResultModel.fromJson(Map<String, dynamic> json) {
    return RoundResultModel(
      uid: json['uid'] as String,
      score: (json['score'] as num?)?.toDouble(),
      passed: json['passed'] as bool?,
      rank: json['rank'] as int?,
      eliminated: json['eliminated'] as bool? ?? false,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      groupId: json['groupId'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'score': score,
      'passed': passed,
      'rank': rank,
      'eliminated': eliminated,
      'submittedAt': submittedAt?.toIso8601String(),
      'groupId': groupId,
      'metadata': metadata,
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory RoundResultModel.fromEntity(RoundResultEntity entity) {
    return RoundResultModel(
      uid: entity.uid,
      score: entity.score,
      passed: entity.passed,
      rank: entity.rank,
      eliminated: entity.eliminated,
      submittedAt: entity.submittedAt,
      groupId: entity.groupId,
      metadata: entity.metadata,
    );
  }

  RoundResultEntity toEntity() {
    return RoundResultEntity(
      uid: uid,
      score: score,
      passed: passed,
      rank: rank,
      eliminated: eliminated,
      submittedAt: submittedAt,
      groupId: groupId,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    score,
    passed,
    rank,
    eliminated,
    submittedAt,
    groupId,
    metadata,
  ];
}
