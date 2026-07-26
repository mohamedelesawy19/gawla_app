part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.profile});
  final PlayerEntity profile;

  @override
  List<Object?> get props => [profile];
}

/// Emitted while a profile update is in flight. Carries the last known
/// [profile] (if any) so the UI can keep showing data instead of a blank
/// loading screen while saving.
final class ProfileUpdating extends ProfileState {
  const ProfileUpdating({this.profile});
  final PlayerEntity? profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileError extends ProfileState {
  const ProfileError({required this.failure, this.profile});
  final Failure failure;
  final PlayerEntity? profile;

  @override
  List<Object?> get props => [failure, profile];
}
