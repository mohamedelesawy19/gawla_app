// Dart imports:
import 'dart:math';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/constants/room_constants.dart';
import '/core/errors/exceptions.dart';

// Feature imports:
import '/features/room/data/models/room_model.dart';
import '/features/room/data/models/room_player_model.dart';
import '/features/room/data/models/room_settings_model.dart';
import '/features/room/domain/entities/room_enums.dart';

/// Contract for all direct Firestore access for the Room feature.
///
/// Mirrors [RoomRepository] method-for-method, but:
/// - works with [RoomModel] (and friends), never [RoomEntity]
/// - throws [BaseException] subtypes instead of returning [Either]
///
/// [RoomRepositoryImpl] is the only caller; it's responsible for mapping
/// Models to Entities and Exceptions to Failures.
///
/// `leaveRoom` and `kickPlayer` accept a `computeNextState` callback
/// rather than hard-coding the "who gets removed / who becomes host"
/// rule here. That rule (`RoomEntity.withPlayerRemoved`) is domain
/// logic and lives in the domain layer; the repository supplies it as
/// a function operating on [RoomModel] so this data source can execute
/// it atomically inside a Firestore transaction without knowing what
/// the rule actually does.
abstract class RoomRemoteDataSource {
  /// Realtime stream of a single room. Emits `null` if the room does
  /// not exist (or was deleted/closed).
  Stream<RoomModel?> watchRoom(String roomId);

  /// Realtime stream of the id of the room [uid] currently belongs to
  /// (any non-closed room), or `null` if they're not in one.
  Stream<String?> watchRoomIdForUser(String uid);

  /// Creates a room, seeding it with the host as its first player.
  /// Generates and reserves a unique invite code when [visibility] is
  /// [RoomVisibility.private].
  Future<RoomModel> createRoom({
    required String hostUid,
    required String hostDisplayName,
    String? hostAvatarUrl,
    required RoomVisibility visibility,
    required RoomSettingsModel settings,
  });

  /// Looks at a small batch of the oldest waiting public rooms and
  /// returns the first one with a free slot. Firestore can't filter
  /// on "players.length < RoomConstants.maxPlayersPerRoom".
  Future<RoomModel?> findOpenPublicRoom();

  /// Joins [roomId]. Capacity/status are re-checked inside a Firestore
  /// transaction (not just relying on a prior read) so two players
  /// can't both take the last slot.
  Future<RoomModel> joinRoom({
    required String roomId,
    required String uid,
    required String displayName,
    String? avatarUrl,
  });

  /// Resolves [inviteCode] to a room, then joins it with the same
  /// transactional guarantees as [joinRoom].
  Future<RoomModel> joinRoomByInviteCode({
    required String inviteCode,
    required String uid,
    required String displayName,
    String? avatarUrl,
  });

  /// Applies [computeNextState] to the current room inside a
  /// transaction. A `null` result deletes the room document; otherwise
  /// the room's `hostUid`/`players` are persisted from the result.
  /// No-ops if the room no longer exists.
  Future<void> leaveRoom({
    required String roomId,
    required RoomModel? Function(RoomModel current) computeNextState,
  });

  /// Same persistence mechanics as [leaveRoom], with an additional
  /// authorization check that [hostUid] is really the room's current
  /// host before [computeNextState] (which should remove [targetUid])
  /// is applied.
  Future<void> kickPlayer({
    required String roomId,
    required String hostUid,
    required String targetUid,
    required RoomModel? Function(RoomModel current) computeNextState,
  });

  /// Updates a room's settings. Only [hostUid] may do this, and only
  /// while the room is still [RoomStatus.waiting].
  Future<void> updateRoomSettings({
    required String roomId,
    required String hostUid,
    required RoomSettingsModel settings,
  });
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  const RoomRemoteDataSourceImpl({required this._firestore});

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(FirestoreConstants.roomsCollection);

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<RoomModel?> watchRoom(String roomId) async* {
    try {
      yield* _rooms
          .doc(roomId)
          .snapshots()
          .map((doc) => doc.exists ? RoomModel.fromFirestore(doc) : null);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to watch room.');
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  @override
  Stream<String?> watchRoomIdForUser(String uid) async* {
    try {
      yield* _rooms
          .where('playerUids', arrayContains: uid)
          .limit(1)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.isEmpty ? null : snapshot.docs.first.id,
          );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to watch room membership.',
      );
    }
  }

  // ── Create / discover ────────────────────────────────────────────────────

  @override
  Future<RoomModel> createRoom({
    required String hostUid,
    required String hostDisplayName,
    String? hostAvatarUrl,
    required RoomVisibility visibility,
    required RoomSettingsModel settings,
  }) async {
    try {
      final docRef = _rooms.doc();
      final now = DateTime.now();

      final inviteCode = visibility == RoomVisibility.private
          ? await _generateUniqueInviteCode()
          : null;

      final host = RoomPlayerModel(
        uid: hostUid,
        displayName: hostDisplayName,
        avatarUrl: hostAvatarUrl,
        joinedAt: now,
      );

      final model = RoomModel(
        roomId: docRef.id,
        hostUid: hostUid,
        visibility: visibility,
        inviteCode: inviteCode,
        status: RoomStatus.waiting,
        settings: settings,
        players: [host],
        createdAt: now,
      );

      await docRef.set({
        ...model.toFirestore(),
        'playerUids': [hostUid],
      });

      return model;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create room.');
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  @override
  Future<RoomModel?> findOpenPublicRoom() async {
    try {
      // Requires a composite index on (visibility ASC, status ASC,
      // createdAt ASC).
      final snapshot = await _rooms
          .where('visibility', isEqualTo: RoomVisibility.public.name)
          .where('status', isEqualTo: RoomStatus.waiting.name)
          .orderBy('createdAt')
          .limit(RoomConstants.openRoomSearchBatchSize)
          .get();

      for (final doc in snapshot.docs) {
        final model = RoomModel.fromFirestore(doc);
        if (model.players.length < RoomConstants.maxPlayersPerRoom) {
          return model;
        }
      }

      return null;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to find an open room.',
      );
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  // ── Join ─────────────────────────────────────────────────────────────────

  @override
  Future<RoomModel> joinRoom({
    required String roomId,
    required String uid,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      return await _joinRoomTransaction(
        roomId: roomId,
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to join room.');
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  @override
  Future<RoomModel> joinRoomByInviteCode({
    required String inviteCode,
    required String uid,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      final query = await _rooms
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw const ServerException(
          message: 'Invalid invite code.',
          code: 'invalid-invite-code',
        );
      }

      return await _joinRoomTransaction(
        roomId: query.docs.first.id,
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to join room by invite code.',
        code: e.code,
      );
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  /// Shared transactional join logic for [joinRoom] and
  /// [joinRoomByInviteCode]. Re-joining a room you're already in is a
  /// no-op (idempotent) rather than an error, since that's a normal
  /// reconnect path.
  Future<RoomModel> _joinRoomTransaction({
    required String roomId,
    required String uid,
    required String displayName,
    String? avatarUrl,
  }) {
    final docRef = _rooms.doc(roomId);

    return _firestore.runTransaction<RoomModel>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Room not found.',
          code: 'room-not-found',
        );
      }

      final model = RoomModel.fromFirestore(snapshot);

      if (model.status != RoomStatus.waiting) {
        throw const ServerException(
          message: 'Room is no longer joinable.',
          code: 'room-not-joinable',
        );
      }

      if (model.players.any((player) => player.uid == uid)) {
        return model;
      }

      if (model.players.length >= RoomConstants.maxPlayersPerRoom) {
        throw const ServerException(
          message: 'Room is full.',
          code: 'room-full',
        );
      }

      final newPlayer = RoomPlayerModel(
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
        joinedAt: DateTime.now(),
      );

      // Partial update: only the new player's own map entry is
      // written, so concurrent writes to other players' entries (e.g.
      // a kick happening in a different transaction) aren't clobbered.
      transaction.update(docRef, {
        'players.$uid': newPlayer.toFirestore(),
        'playerUids': FieldValue.arrayUnion([uid]),
      });

      return RoomModel(
        roomId: model.roomId,
        hostUid: model.hostUid,
        visibility: model.visibility,
        inviteCode: model.inviteCode,
        status: model.status,
        settings: model.settings,
        players: [...model.players, newPlayer],
        createdAt: model.createdAt,
      );
    });
  }

  // ── Leave / kick ─────────────────────────────────────────────────────────

  @override
  Future<void> leaveRoom({
    required String roomId,
    required RoomModel? Function(RoomModel current) computeNextState,
  }) async {
    try {
      final docRef = _rooms.doc(roomId);

      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return; // Already gone — nothing to do.

        final model = RoomModel.fromFirestore(snapshot);
        _applyPlayerListChange(
          transaction,
          docRef,
          model,
          computeNextState(model),
        );
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to leave room.',
        code: e.code,
      );
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  @override
  Future<void> kickPlayer({
    required String roomId,
    required String hostUid,
    required String targetUid,
    required RoomModel? Function(RoomModel current) computeNextState,
  }) async {
    try {
      final docRef = _rooms.doc(roomId);

      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw const ServerException(
            message: 'Room not found.',
            code: 'room-not-found',
          );
        }

        final model = RoomModel.fromFirestore(snapshot);

        if (model.hostUid != hostUid) {
          throw const AuthException(
            message: 'Only the host can remove players.',
            code: 'not-host',
          );
        }

        _applyPlayerListChange(
          transaction,
          docRef,
          model,
          computeNextState(model),
        );
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to remove player.',
        code: e.code,
      );
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  /// Shared write logic for [leaveRoom] and [kickPlayer]. `nextModel ==
  /// null` means the room has no players left and should be deleted.
  /// Otherwise, only the player(s) present in [currentModel] but absent
  /// from [nextModel] are removed — via a partial `players.$uid`
  /// delete rather than rewriting the whole `players` map — plus a
  /// `hostUid` write if [RoomEntity.withPlayerRemoved] reassigned it.
  void _applyPlayerListChange(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> docRef,
    RoomModel currentModel,
    RoomModel? nextModel,
  ) {
    if (nextModel == null) {
      transaction.delete(docRef);
      return;
    }

    final nextUids = nextModel.players.map((player) => player.uid).toSet();
    final removedUids = currentModel.players
        .map((player) => player.uid)
        .where((uid) => !nextUids.contains(uid))
        .toList();

    final update = <String, dynamic>{
      if (currentModel.hostUid != nextModel.hostUid)
        'hostUid': nextModel.hostUid,
      for (final uid in removedUids) 'players.$uid': FieldValue.delete(),
      if (removedUids.isNotEmpty)
        'playerUids': FieldValue.arrayRemove(removedUids),
    };

    if (update.isNotEmpty) transaction.update(docRef, update);
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  @override
  Future<void> updateRoomSettings({
    required String roomId,
    required String hostUid,
    required RoomSettingsModel settings,
  }) async {
    try {
      final docRef = _rooms.doc(roomId);

      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw const ServerException(
            message: 'Room not found.',
            code: 'room-not-found',
          );
        }

        final model = RoomModel.fromFirestore(snapshot);

        if (model.hostUid != hostUid) {
          throw const AuthException(
            message: 'Only the host can update room settings.',
            code: 'not-host',
          );
        }

        if (model.status != RoomStatus.waiting) {
          throw const ServerException(
            message:
                'Room settings can only be changed'
                ' before the tournament starts.',
            code: 'room-not-editable',
          );
        }

        transaction.update(docRef, {'settings': settings.toJson()});
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update room settings.',
        code: e.code,
      );
    } on BaseException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse room data.',
        code: e.toString(),
      );
    }
  }

  // ── Invite codes ─────────────────────────────────────────────────────────

  /// Generates a random code and checks it's not already taken,
  /// retrying up to [RoomConstants.maxCodeGenerationRetries] times.
  /// The uniqueness check is a plain query rather than part of a
  /// transaction (Firestore transactions can't run arbitrary queries),
  /// so there's a theoretical race between two concurrent room
  /// creations picking the same code — negligible in practice given
  /// the codespace size, but worth knowing about.
  Future<String> _generateUniqueInviteCode() async {
    for (
      var attempt = 0;
      attempt < RoomConstants.maxCodeGenerationRetries;
      attempt++
    ) {
      final candidate = _randomCode();
      final existing = await _rooms
          .where('inviteCode', isEqualTo: candidate)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return candidate;
    }

    throw const ServerException(
      message: 'Could not generate a unique invite code. Please try again.',
      code: 'invite-code-generation-failed',
    );
  }

  String _randomCode() {
    final random = Random.secure();
    return List.generate(
      RoomConstants.codeLength,
      (_) =>
          RoomConstants.codeCharset[random.nextInt(
            RoomConstants.codeCharset.length,
          )],
    ).join();
  }
}
