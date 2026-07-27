import 'package:equatable/equatable.dart';

class MiniGamePreview extends Equatable {
  const MiniGamePreview({
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
