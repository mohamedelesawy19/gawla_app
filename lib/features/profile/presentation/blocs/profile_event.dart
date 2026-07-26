part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

final class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

final class UpdateProfileEvent extends ProfileEvent {
  const UpdateProfileEvent({
    required this.uid,
    this.displayName,
    this.avatarUrl,
  });

  final String uid;
  final String? displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [uid, displayName, avatarUrl];
}
