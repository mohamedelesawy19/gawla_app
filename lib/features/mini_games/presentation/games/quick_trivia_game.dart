// Package imports:
import 'package:flutter/widgets.dart';

// Feature imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/domain/quiz_question_source.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';
import '/features/mini_games/presentation/shared/question_flow_game_widget.dart';

/// MINI_GAMES_LIBRARY.md §3.2 — fetches a rotating server-side pool.
/// Takes its [QuizQuestionSource] as a required constructor arg rather
/// than constructing a RemoteQuizQuestionSource itself, so this file
/// never needs to import package:cloud_functions — the composition
/// root (MiniGamesModule) owns picking which poolId to wire in.
class QuickTriviaDefinition implements MiniGameDefinition {
  const QuickTriviaDefinition({required this._questionSource});

  final QuizQuestionSource _questionSource;

  @override
  String get gameId => 'quick_trivia';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return QuestionFlowGameWidget(args: args, questionSource: _questionSource);
  }
}

/// MINI_GAMES_LIBRARY.md §3.9 — same shape as Quick Trivia (binary
/// options instead of four, faster pace). Takes its [QuizQuestionSource]
/// as a required constructor arg for the same reason as
/// QuickTriviaDefinition — the composition root wires in a
/// RemoteQuizQuestionSource against a different poolId, this file
/// doesn't construct one itself.
class TrueOrFalseDefinition implements MiniGameDefinition {
  const TrueOrFalseDefinition({required this._questionSource});

  final QuizQuestionSource _questionSource;

  @override
  String get gameId => 'true_or_false';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return QuestionFlowGameWidget(
      args: args,
      questionSource: _questionSource,
      perQuestionTimeLimit: const Duration(seconds: 6),
    );
  }
}
