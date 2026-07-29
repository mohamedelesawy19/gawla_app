// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player_service.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/repositories/room_repository.dart';

class LeaveRoomUseCase implements UseCase<void, LeaveRoomParams> {
  const LeaveRoomUseCase({
    required this._repository,
    required this._currentPlayer,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;

  @override
  Future<Either<Failure, void>> call(LeaveRoomParams params) async {
    final uidResult = await _currentPlayer.getCurrentUid();

    return uidResult.fold(
      Left.new,
      (uid) => _repository.leaveRoom(roomId: params.roomId, uid: uid),
    );
  }
}

class LeaveRoomParams extends Equatable {
  const LeaveRoomParams({required this.roomId});

  final String roomId;

  @override
  List<Object?> get props => [roomId];
}
