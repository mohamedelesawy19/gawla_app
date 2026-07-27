// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/errors/exceptions.dart';

// Feature imports:
import '/features/home/data/models/home_dashboard_model.dart';
import '/features/home/data/models/mini_game_preview_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDashboardModel> getHomeDashboard();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this._firestore});

  final FirebaseFirestore _firestore;

  @override
  Future<HomeDashboardModel> getHomeDashboard() async {
    try {
      final (tournamentPreview, gameLibrary) = await (
        _fetchTournamentPreview(),
        _fetchGameLibrary(),
      ).wait;

      return HomeDashboardModel(
        tournamentPlayerCount: tournamentPreview.playerCount,
        tournamentRoundCount: tournamentPreview.roundCount,
        todaysRotation: tournamentPreview.rotation,
        gameLibrary: gameLibrary,
      );
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(
        message:
            e.message ?? 'Firestore error while loading the home dashboard.',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to load home dashboard: $e');
    }
  }

  Future<_TournamentPreviewData> _fetchTournamentPreview() async {
    final snapshot = await _firestore
        .collection(FirestoreConstants.configCollection)
        .doc(FirestoreConstants.homeDashboardDocId)
        .get();

    final data = snapshot.data();
    if (data == null) {
      throw const ServerException(
        message: 'Home dashboard configuration was not found.',
      );
    }

    final rotationJson =
        (data['todaysRotation'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();

    final playerCount = (data['tournamentPlayerCount'] as num?)?.toInt() ?? 0;

    final roundCount = (data['tournamentRoundCount'] as num?)?.toInt() ?? 0;

    return _TournamentPreviewData(
      playerCount: playerCount,
      roundCount: roundCount,
      rotation: rotationJson.map(MiniGamePreviewModel.fromJson).toList(),
    );
  }

  Future<List<MiniGamePreviewModel>> _fetchGameLibrary() async {
    final snapshot = await _firestore
        .collection(FirestoreConstants.miniGamesCollection)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => MiniGamePreviewModel.fromFirestore(doc))
        .toList();
  }
}

class _TournamentPreviewData {
  const _TournamentPreviewData({
    required this.playerCount,
    required this.roundCount,
    required this.rotation,
  });

  final int playerCount;
  final int roundCount;
  final List<MiniGamePreviewModel> rotation;
}
