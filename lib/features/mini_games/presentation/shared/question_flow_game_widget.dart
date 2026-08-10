// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/widgets/feedback/loading_indicator.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/domain/quiz_question.dart';
import '/features/mini_games/domain/quiz_question_source.dart';

/// Drives N questions in sequence with a per-question timer, then submits
/// the aggregate {correctAnswers, totalTimeMs}. Reused as-is by every
/// concrete MiniGameDefinition in this category (Math Rush, Quick
/// Trivia, True/or/False) — each just supplies a different
/// [QuizQuestionSource] implementation from the data layer, so this
/// widget never talks to Firebase or generates questions itself.
class QuestionFlowGameWidget extends StatefulWidget {
  const QuestionFlowGameWidget({
    super.key,
    required this.args,
    required this.questionSource,
    this.questionCount = 3,
    this.perQuestionTimeLimit = const Duration(seconds: 10),
  });

  final MiniGamePlayArgs args;
  final QuizQuestionSource questionSource;
  final int questionCount;
  final Duration perQuestionTimeLimit;

  @override
  State<QuestionFlowGameWidget> createState() => _QuestionFlowGameWidgetState();
}

class _QuestionFlowGameWidgetState extends State<QuestionFlowGameWidget> {
  List<QuizQuestion>? _questions;
  int _index = 0;
  int _correct = 0;
  final _stopwatch = Stopwatch();
  Timer? _questionTimer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    widget.questionSource.nextBatch(widget.questionCount).then((qs) {
      if (!mounted) return;
      setState(() => _questions = qs);
      _armTimer();
    });
  }

  void _armTimer() {
    _questionTimer?.cancel();
    // A question the player never answers in time counts as wrong (no
    // credit) rather than blocking the round — matches every other
    // mini-game's "a round timing out never leaves someone ambiguously
    // un-scored" principle.
    _questionTimer = Timer(widget.perQuestionTimeLimit, () => _answer(null));
  }

  void _answer(int? optionIndex) {
    if (_submitted) return;
    final questions = _questions;
    if (questions == null) return;

    if (optionIndex != null && optionIndex == questions[_index].correctIndex) {
      _correct++;
    }

    final isLast = _index == questions.length - 1;
    if (isLast) {
      _finish();
      return;
    }
    setState(() => _index++);
    _armTimer();
  }

  void _finish() {
    _submitted = true;
    _questionTimer?.cancel();
    _stopwatch.stop();
    widget.args.onSubmit({
      'correctAnswers': _correct,
      'totalTimeMs': _stopwatch.elapsedMilliseconds,
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questions;
    if (questions == null) {
      return const Center(child: LoadingIndicator());
    }
    if (_submitted) {
      return Center(
        child: Text(context.l10n.answerSubmittedWaitingForRoundToClose),
      );
    }

    final q = questions[_index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Question ${_index + 1}/${questions.length}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        Text(
          q.prompt,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(
          q.options.length,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.args.isPerformingAction
                    ? null
                    : () => _answer(i),
                child: Text(q.options[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
