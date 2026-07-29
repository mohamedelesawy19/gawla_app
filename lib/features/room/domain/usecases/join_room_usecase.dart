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
import '/features/room/domain/validators/join_room_validator.dart';

/// Joins a specific, already-known room (e.g. selected from a public
/// room browser, or a deep link) — as opposed to [QuickMatchUseCase],
/// which finds one automatically.
class JoinRoomUseCase implements UseCase<RoomEntity, JoinRoomParams> {
  const JoinRoomUseCase({
    required this._repository,
    required this._currentPlayer,
    required this._validator,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;
  final JoinRoomValidator _validator;

  @override
  Future<Either<Failure, RoomEntity>> call(JoinRoomParams params) async {
    final errors = _validator.validate(params);
    if (errors.isNotEmpty) return Left(ValidationFailure(errors: errors));

    final playerResult = await _currentPlayer.getCurrentPlayer();

    return playerResult.fold(
      Left.new,
      (player) => _repository.joinRoom(
        roomId: params.roomId,
        uid: player.uid,
        displayName: player.displayName,
        avatarUrl: player.avatarUrl,
      ),
    );
  }
}

class JoinRoomParams extends Equatable {
  const JoinRoomParams({required this.roomId});

  final String roomId;

  @override
  List<Object?> get props => [roomId];
}
