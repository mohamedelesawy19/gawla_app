// Project imports:
import '/features/mini_games/domain/quiz_question.dart';

/// Supplies this round's questions. A separate interface (rather than a
/// hardcoded list) because where questions come from genuinely varies
/// by game: Quick Trivia's pool must live server-side and rotate per
/// season (§3.2's "never shipped in the client build"), while Math
/// Rush's arithmetic can be generated on-device per player (§3.6's
/// "per-player unique problem sets"), since it needs no secrecy, only
/// unpredictability.
///
/// Concrete implementations live in the data layer — see
/// `data/remote_quiz_question_source.dart` (Firebase, used by Quick
/// Trivia and True/or/False) and `data/procedural_math_question_source.dart`
/// (on-device, used by Math Rush).
abstract class QuizQuestionSource {
  Future<List<QuizQuestion>> nextBatch(int count);
}
