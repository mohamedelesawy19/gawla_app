import 'package:equatable/equatable.dart';

class CurrentPlayer extends Equatable {
  const CurrentPlayer({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [uid, displayName, avatarUrl];
}
