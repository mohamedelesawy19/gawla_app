// Package imports:
import 'package:cloud_functions/cloud_functions.dart';

// Feature imports:
import '/features/mini_games/domain/quiz_question.dart';
import '/features/mini_games/domain/quiz_question_source.dart';

/// Fetches this round's trivia questions from a Cloud Functions callable
/// rather than shipping any pool in the client build, per
/// MINI_GAMES_LIBRARY.md §3.2's anti-cheat note ("Pool must rotate per
/// season to prevent players sharing/memorizing answers").
///
/// fetchQuizPool is a small NEW callable this feature depends on — it
/// wasn't part of the Tournament Cloud Functions reviewed for this
/// refactor. It only reads a rotating question pool (no scoring, no
/// elimination), so it's safe to add without touching anything in
/// functions/src/tournament/*; flagged explicitly in ARCHITECTURE.md's
/// backend follow-ups rather than assumed to already exist.
class RemoteQuizQuestionSource implements QuizQuestionSource {
  RemoteQuizQuestionSource({required this.poolId, FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west6');

  /// Which rotating pool to draw from — 'quick_trivia', 'true_or_false',
  /// etc. Lets both games share this one source implementation.
  final String poolId;
  final FirebaseFunctions _functions;

  @override
  Future<List<QuizQuestion>> nextBatch(int count) async {
    final callable = _functions.httpsCallable('fetchQuizPool');
    final result = await callable.call<Map<String, dynamic>>({
      'poolId': poolId,
      'count': count,
    });
    final raw = (result.data['questions'] as List).cast<Map<String, dynamic>>();
    return raw
        .map(
          (q) => QuizQuestion(
            prompt: q['prompt'] as String,
            options: (q['options'] as List).cast<String>(),
            correctIndex: q['correctIndex'] as int,
          ),
        )
        .toList(growable: false);
  }
}
