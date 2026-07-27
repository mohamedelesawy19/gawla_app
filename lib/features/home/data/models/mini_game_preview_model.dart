// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/home/domain/entities/mini_game_preview_entity.dart';

class MiniGamePreviewModel extends Equatable {
  const MiniGamePreviewModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.skillTag,
  });

  final String id;
  final String name;
  final String emoji;
  final String skillTag;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory MiniGamePreviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return MiniGamePreviewModel(
      id: doc.id,
      name: data['name'] as String,
      emoji: data['emoji'] as String,
      skillTag: data['skillTag'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'emoji': emoji, 'skillTag': skillTag};
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory MiniGamePreviewModel.fromJson(Map<String, dynamic> json) {
    return MiniGamePreviewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      skillTag: json['skillTag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'emoji': emoji, 'skillTag': skillTag};
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory MiniGamePreviewModel.fromEntity(MiniGamePreviewEntity entity) {
    return MiniGamePreviewModel(
      id: entity.id,
      name: entity.name,
      emoji: entity.emoji,
      skillTag: entity.skillTag,
    );
  }

  MiniGamePreviewEntity toEntity() {
    return MiniGamePreviewEntity(
      id: id,
      name: name,
      emoji: emoji,
      skillTag: skillTag,
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, skillTag];
}
