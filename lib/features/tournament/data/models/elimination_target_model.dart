// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/elimination_target_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';

class EliminationTargetModel extends Equatable {
  const EliminationTargetModel({required this.kind, required this.value});

  final EliminationTargetKind kind;
  final num value;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory EliminationTargetModel.fromMap(Map<String, dynamic> data) {
    return EliminationTargetModel(
      kind: EliminationTargetKind.values.byName(data['kind'] as String),
      value: data['value'] as num,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'kind': kind.name, 'value': value};
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory EliminationTargetModel.fromJson(Map<String, dynamic> json) {
    return EliminationTargetModel(
      kind: EliminationTargetKind.values.byName(json['kind'] as String),
      value: json['value'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {'kind': kind.name, 'value': value};
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory EliminationTargetModel.fromEntity(EliminationTargetEntity entity) {
    return EliminationTargetModel(kind: entity.kind, value: entity.value);
  }

  EliminationTargetEntity toEntity() {
    return EliminationTargetEntity(kind: kind, value: value);
  }

  @override
  List<Object?> get props => [kind, value];
}
