// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player_service.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';
import '/features/room/domain/validators/join_room_by_code_validator.dart';

/// Joins a private room by invite code.
class JoinRoomByCodeUseCase
    implements UseCase<RoomEntity, JoinRoomByCodeParams> {
  const JoinRoomByCodeUseCase({
    required this._repository,
    required this._currentPlayer,
    required this._validator,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;
  final JoinRoomByCodeValidator _validator;

  @override
  Future<Either<Failure, RoomEntity>> call(JoinRoomByCodeParams params) async {
    final normalizedCode = params.inviteCode.trim().toUpperCase();

    final errors = _validator.validate(normalizedCode);
    if (errors.isNotEmpty) return Left(ValidationFailure(errors: errors));

    final playerResult = await _currentPlayer.getCurrentPlayer();

    return playerResult.fold(
      Left.new,
      (player) => _repository.joinRoomByInviteCode(
        inviteCode: normalizedCode,
        uid: player.uid,
        displayName: player.displayName,
        avatarUrl: player.avatarUrl,
      ),
    );
  }
}

class JoinRoomByCodeParams extends Equatable {
  const JoinRoomByCodeParams({required this.inviteCode});

  final String inviteCode;

  @override
  List<Object?> get props => [inviteCode];
}
