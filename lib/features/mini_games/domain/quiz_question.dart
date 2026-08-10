import 'package:equatable/equatable.dart';

/// One question in the shared "answer N questions, correctness matters
/// most, speed is only the tiebreaker" flow behind Quick Trivia,
/// True/or/False, and Math Rush (MINI_GAMES_LIBRARY.md §3.2, §3.6,
/// §3.9). Matches scored_games.ts's accuracyDefinition, which reads
/// only {correctAnswers, totalTimeMs} regardless of which of the three
/// games produced them — so one widget can drive all three.
class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;

  @override
  List<Object?> get props => [prompt, options, correctIndex];
}
