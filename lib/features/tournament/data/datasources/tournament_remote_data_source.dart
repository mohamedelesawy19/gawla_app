// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/errors/exceptions.dart';

// Feature imports:
import '/features/tournament/data/models/tournament_model.dart';

/// Contract for all direct Firestore + Cloud Functions access for the
/// Tournament feature.
///
/// Mirrors `TournamentRepository` method-for-method, but:
/// - works with [TournamentModel], never `TournamentEntity`
/// - throws [BaseException] subtypes instead of returning `Either`
///
/// `TournamentRepositoryImpl` is the only caller; it's responsible for
/// mapping Models to Entities and Exceptions to Failures.
///
/// Unlike `RoomRemoteDataSource`, the two mutating methods here
/// (`startTournament`, `submitRoundResult`) never touch Firestore
/// directly — they call Cloud Functions and let the server own every
/// write. That's not a style choice, it's the whole point of this
/// feature's anti-cheat model (see `TournamentRepository`'s doc comment
/// and the project overview's Anti-Cheat table): a Flutter client is
/// inherently inspectable, so scoring, eliminations, and round
/// advancement can never be trusted from a client write.
abstract interface class TournamentRemoteDataSource {
  /// Realtime id of the tournament that belongs to [roomId], or `null`
  /// before one has been created. A room gets at most one tournament
  /// for its whole lifetime (`RoomStatus.inProgress` is a one-way flip
  /// — see `room_enums.dart`), so this is a plain existence lookup,
  /// not a "currently active" filter.
  Stream<String?> watchTournamentIdForRoom(String roomId);

  /// Realtime stream of [tournamentId]'s full document, or `null` if it
  /// doesn't exist (yet, or anymore).
  Stream<TournamentModel?> watchTournament(String tournamentId);

  /// Calls the `startTournament` Cloud Function and returns the new
  /// tournament's id. Host verification, the player/rotation snapshot,
  /// and the room-status flip all happen inside that function — this
  /// method is just the round trip.
  Future<String> startTournament(String roomId);

  /// Calls the `submitRoundResult` Cloud Function with this player's
  /// raw payload. Throws if the server rejects the submission (wrong
  /// round, already submitted, implausible result, ...); a successful
  /// return only means the submission was accepted, never what it
  /// scored to.
  Future<void> submitRoundResult({
    required String tournamentId,
    required int roundIndex,
    required Map<String, dynamic> payload,
  });
}

class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  const TournamentRemoteDataSourceImpl({
    required this._firestore,
    required this._functions,
  });

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _tournaments =>
      _firestore.collection(FirestoreConstants.tournamentsCollection);

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<String?> watchTournamentIdForRoom(String roomId) async* {
    try {
      // Single-field equality on `roomId` — no composite index needed,
      // unlike Room's multi-field queries.
      yield* _tournaments
          .where('roomId', isEqualTo: roomId)
          .limit(1)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.isEmpty ? null : snapshot.docs.first.id,
          );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to watch tournament for room.',
        code: e.code,
      );
    }
  }

  @override
  Stream<TournamentModel?> watchTournament(String tournamentId) async* {
    try {
      yield* _tournaments
          .doc(tournamentId)
          .snapshots()
          .map((doc) => doc.exists ? TournamentModel.fromFirestore(doc) : null);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to watch tournament.',
        code: e.code,
      );
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse tournament data.',
        code: e.toString(),
      );
    }
  }

  // ── Server-authoritative mutations ──────────────────────────────────────

  @override
  Future<String> startTournament(String roomId) async {
    try {
      final result = await _functions
          .httpsCallable(_TournamentFunctions.startTournament)
          .call(<String, dynamic>{'roomId': roomId});

      final data = Map<String, dynamic>.from(result.data as Map);
      final tournamentId = data['tournamentId'] as String?;

      if (tournamentId == null || tournamentId.isEmpty) {
        throw const ParsingException(
          message: 'Server did not return a tournament id.',
        );
      }

      return tournamentId;
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse server response.',
        code: e.toString(),
      );
    }
  }

  @override
  Future<void> submitRoundResult({
    required String tournamentId,
    required int roundIndex,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _functions
          .httpsCallable(_TournamentFunctions.submitRoundResult)
          .call(<String, dynamic>{
            'tournamentId': tournamentId,
            'roundIndex': roundIndex,
            'payload': payload,
          });
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to submit round result.',
        code: e.toString(),
      );
    }
  }

  // ── Error mapping ────────────────────────────────────────────────────────

  BaseException _mapFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
      case 'permission-denied':
        return AuthException(
          message: e.message ?? 'You are not allowed to perform this action.',
          code: e.code,
        );
      default:
        // invalid-argument, failed-precondition, not-found,
        // already-exists, resource-exhausted, deadline-exceeded,
        // internal, unavailable, ... — all surfaced as a plain server
        // rejection. `Failure`s built from this keep `e.code` so the
        // presentation layer can special-case specific codes later
        // (e.g. showing "round already closed" for
        // failed-precondition) without this data source needing to
        // know about UI copy.
        return ServerException(
          message: e.message ?? 'Something went wrong. Please try again.',
          code: e.code,
        );
    }
  }
}

/// Cloud Function names for the Tournament feature. Kept private to
/// this file for now since it's the only caller; promote to a shared
/// constants file if a second caller shows up.
abstract class _TournamentFunctions {
  static const startTournament = 'startTournament';
  static const submitRoundResult = 'submitRoundResult';
}
