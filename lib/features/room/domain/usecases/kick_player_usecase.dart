// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
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
    required this._validator,
  });

  final RoomRepository _repository;
  final KickPlayerValidator _validator;

  @override
  Future<Either<Failure, void>> call(KickPlayerParams params) {
    final errors = _validator.validate(params);

    if (errors.isNotEmpty) {
      return Future.value(Left(ValidationFailure(errors: errors)));
    }

    return _repository.kickPlayer(
      roomId: params.roomId,
      hostUid: params.hostUid,
      targetUid: params.targetUid,
    );
  }
}

class KickPlayerParams extends Equatable {
  const KickPlayerParams({
    required this.roomId,
    required this.hostUid,
    required this.targetUid,
  });

  final String roomId;
  final String hostUid;
  final String targetUid;

  @override
  List<Object?> get props => [roomId, hostUid, targetUid];
}
