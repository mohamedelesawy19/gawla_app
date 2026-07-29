// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player_service.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/repositories/room_repository.dart';
import '/features/room/domain/validators/kick_player_validator.dart';

/// Removes a player from the room. Only the host can do this, and a
/// host can't kick themselves — they should use [LeaveRoomUseCase]
/// instead, which also hands off the host role appropriately.
class KickPlayerUseCase implements UseCase<void, KickPlayerParams> {
  const KickPlayerUseCase({
    required this._repository,
    required this._currentPlayer,
    required this._validator,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;
  final KickPlayerValidator _validator;

  @override
  Future<Either<Failure, void>> call(KickPlayerParams params) async {
    final uidResult = await _currentPlayer.getCurrentUid();

    return uidResult.fold(Left.new, (hostUid) {
      final errors = _validator.validate(
        KickPlayerValidationInput(
          hostUid: hostUid,
          targetUid: params.targetUid,
        ),
      );

      if (errors.isNotEmpty) {
        return Future.value(Left(ValidationFailure(errors: errors)));
      }

      return _repository.kickPlayer(
        roomId: params.roomId,
        hostUid: hostUid,
        targetUid: params.targetUid,
      );
    });
  }
}

class KickPlayerParams extends Equatable {
  const KickPlayerParams({required this.roomId, required this.targetUid});

  final String roomId;
  final String targetUid;

  @override
  List<Object?> get props => [roomId, targetUid];
}
