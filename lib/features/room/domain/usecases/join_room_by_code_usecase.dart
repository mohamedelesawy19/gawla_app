// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
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
    required this._validator,
  });

  final RoomRepository _repository;
  final JoinRoomByCodeValidator _validator;

  @override
  Future<Either<Failure, RoomEntity>> call(JoinRoomByCodeParams params) {
    final normalizedCode = params.inviteCode.trim().toUpperCase();

    final errors = _validator.validate(normalizedCode);

    if (errors.isNotEmpty) {
      return Future.value(Left(ValidationFailure(errors: errors)));
    }

    return _repository.joinRoomByInviteCode(
      inviteCode: normalizedCode,
      uid: params.uid,
      displayName: params.displayName,
      avatarUrl: params.avatarUrl,
    );
  }
}

class JoinRoomByCodeParams extends Equatable {
  const JoinRoomByCodeParams({
    required this.inviteCode,
    required this.uid,
    required this.displayName,
    this.avatarUrl,
  });

  final String inviteCode;
  final String uid;
  final String displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [inviteCode, uid, displayName, avatarUrl];
}
