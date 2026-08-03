// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/errors/exceptions.dart';

// Feature imports:
import '/features/profile/data/models/player_model.dart';

abstract class ProfileRemoteDataSource {
  Future<PlayerModel> getProfile(
    String uid, {
    int maxAttempts = 10,
    Duration retryDelay = const Duration(milliseconds: 500),
  });
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarUrl,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this._firestore});

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _players =>
      _firestore.collection(FirestoreConstants.playersCollection);

  // ── Fetch ──────────────────────────────────────────────────────────────────

  @override
  Future<PlayerModel> getProfile(
    String uid, {
    int maxAttempts = 10,
    Duration retryDelay = const Duration(milliseconds: 500),
  }) async {
    try {
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        final snapshot = await _players.doc(uid).get();

        if (snapshot.exists && snapshot.data() != null) {
          return PlayerModel.fromFirestore(snapshot);
        }

        if (attempt < maxAttempts) {
          await Future.delayed(retryDelay);
        }
      }

      throw const ServerException(message: 'Player profile not found');
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch profile');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Update profile ─────────────────────────────────────────────────────────

  @override
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'displayName': ?displayName,
        'avatarUrl': ?avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _players.doc(uid).update(payload);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update profile');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
