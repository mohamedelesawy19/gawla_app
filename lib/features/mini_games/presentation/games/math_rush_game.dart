// Package imports:
import 'package:flutter/widgets.dart';

// Feature imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/domain/quiz_question_source.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';
import '/features/mini_games/presentation/shared/question_flow_game_widget.dart';

/// Takes its [QuizQuestionSource] as a required constructor arg — this
/// file has no idea a Firebase-free ProceduralMathQuestionSource exists;
/// that wiring belongs to the composition root (MiniGamesModule), the
/// same way TugOfPowerDefinition/FreezeFrenzyDefinition are handed their
/// channel instead of constructing one.
class MathRushDefinition implements MiniGameDefinition {
  const MathRushDefinition({required this._questionSource});

  final QuizQuestionSource _questionSource;

  @override
  String get gameId => 'math_rush';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return QuestionFlowGameWidget(
      args: args,
      questionSource: _questionSource,
      questionCount: 5,
      perQuestionTimeLimit: const Duration(seconds: 6),
    );
  }
}
