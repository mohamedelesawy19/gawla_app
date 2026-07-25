// Package imports:
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Features imports:
import '/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends Equatable {
  const AuthUserModel({
    required this.uid,
    this.email,
    required this.isAnonymous,
  });

  final String uid;
  final String? email;
  final bool isAnonymous;

  factory AuthUserModel.fromFirebaseUser(fb.User user) => AuthUserModel(
    uid: user.uid,
    email: user.email,
    isAnonymous: user.isAnonymous,
  );

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'isAnonymous': isAnonymous};
  }

  factory AuthUserModel.fromEntity(AuthUserEntity entity) {
    return AuthUserModel(
      uid: entity.uid,
      email: entity.email,
      isAnonymous: entity.isAnonymous,
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(uid: uid, email: email, isAnonymous: isAnonymous);
  }

  @override
  List<Object?> get props => [uid, email, isAnonymous];
}
