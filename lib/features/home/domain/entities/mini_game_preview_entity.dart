import 'package:equatable/equatable.dart';

class MiniGamePreviewEntity extends Equatable {
  const MiniGamePreviewEntity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.skillTag,
  });

  final String id;
  final String name;
  final String emoji;
  final String skillTag;

  @override
  List<Object?> get props => [id, name, emoji, skillTag];
}
