// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player.dart';
import '/core/services/current_player/current_player_service.dart';

// Feature imports (Just interface, no implementation):
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/profile/domain/repositories/profile_repository.dart';

class CurrentPlayerServiceImpl implements CurrentPlayerService {
  const CurrentPlayerServiceImpl({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _auth = authRepository,
       _profile = profileRepository;

  final AuthRepository _auth;
  final ProfileRepository _profile;

  @override
  Future<Either<Failure, CurrentPlayer>> getCurrentPlayer() async {
    final authResult = await _auth.getCurrentUser();

    return authResult.fold(Left.new, (user) async {
      final profileResult = await _profile.getProfile(user.uid);

      return profileResult.map(
        (profile) => CurrentPlayer(
          uid: profile.uid,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, String>> getCurrentUid() async {
    final authResult = await _auth.getCurrentUser();

    return authResult.map((user) => user.uid);
  }
}
