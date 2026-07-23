import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isAnonymous];
}
