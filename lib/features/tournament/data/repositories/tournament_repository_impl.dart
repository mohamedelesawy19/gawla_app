// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Feature imports:
import '/features/tournament/data/datasources/tournament_remote_data_source.dart';
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/repositories/tournament_repository.dart';

/// [TournamentRepository] implementation.
///
/// Pure orchestration, per the project's layering rules: no business
/// logic lives here. The two mutating methods do exactly one thing —
/// call the data source and turn whatever it throws into a [Failure] —
/// because every real decision (host checks, scoring, elimination,
/// round advancement) already happened server-side by the time this
/// code runs. See `TournamentRemoteDataSource`'s doc comment for why.
class TournamentRepositoryImpl implements TournamentRepository {
  const TournamentRepositoryImpl(this._remoteDataSource);

  final TournamentRemoteDataSource _remoteDataSource;

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<String?> watchTournamentIdForRoom(String roomId) {
    return _remoteDataSource.watchTournamentIdForRoom(roomId);
  }

  @override
  Stream<TournamentEntity?> watchTournament(String tournamentId) {
    return _remoteDataSource
        .watchTournament(tournamentId)
        .map((model) => model?.toEntity());
  }

  // ── Server-authoritative mutations ──────────────────────────────────────

  @override
  Future<Either<Failure, String>> startTournament(String roomId) {
    return _run(() => _remoteDataSource.startTournament(roomId));
  }

  @override
  Future<Either<Failure, Unit>> submitRoundResult({
    required String tournamentId,
    required int roundIndex,
    required Map<String, dynamic> payload,
  }) {
    return _run(() async {
      await _remoteDataSource.submitRoundResult(
        tournamentId: tournamentId,
        roundIndex: roundIndex,
        payload: payload,
      );
      return unit;
    });
  }

  // ── Exception → Failure mapping ─────────────────────────────────────────

  /// Shared try/catch for both mutating methods, so the exception→
  /// Failure mapping lives in exactly one place.
  ///
  /// ASSUMPTION: `AuthFailure`/`ServerFailure` constructors taking a
  /// named `message` are inferred from this project's naming
  /// conventions (`ServerException`, `AuthException`,
  /// `ValidationFailure` already follow this shape) — adjust to match
  /// whatever `core/errors/failures.dart` actually declares if it
  /// differs.
  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ParsingException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
