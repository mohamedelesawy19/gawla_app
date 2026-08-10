// Dart imports:
import 'dart:math';

// Feature imports:
import '/features/mini_games/domain/quiz_question.dart';
import '/features/mini_games/domain/quiz_question_source.dart';

/// Generates each player's arithmetic problems entirely on-device, per
/// MINI_GAMES_LIBRARY.md §3.6's "per-player unique problem sets" note.
/// Unlike Quick Trivia, Math Rush needs no server secrecy — there's no
/// fixed "correct answer" to leak — only per-player unpredictability, so
/// a Random seeded per instance is sufficient and avoids a network
/// round trip mid-round.
class ProceduralMathQuestionSource implements QuizQuestionSource {
  ProceduralMathQuestionSource({int? seed}) : _random = Random(seed);

  final Random _random;

  @override
  Future<List<QuizQuestion>> nextBatch(int count) async {
    return List.generate(count, (_) {
      final a = _random.nextInt(20) + 1;
      final b = _random.nextInt(20) + 1;
      final correct = a + b;

      final options = <int>{correct};
      while (options.length < 4) {
        options.add(correct + _random.nextInt(9) - 4);
      }
      final shuffled = options.toList()..shuffle(_random);

      return QuizQuestion(
        prompt: '$a + $b = ?',
        options: shuffled.map((n) => '$n').toList(growable: false),
        correctIndex: shuffled.indexOf(correct),
      );
    }, growable: false);
  }
}
