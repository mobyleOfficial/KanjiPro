import 'dart:math';

import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

import '../models/quiz_mode.dart';
import '../models/quiz_question.dart';

class GenerateParams {
  const GenerateParams({
    required this.levelKanji,
    required this.pool,
    required this.mode,
    required this.lastShown,
    required this.random,
  });

  final List<Kanji> levelKanji;
  final List<KanjiProgress> pool;
  final QuizMode mode;
  final String? lastShown;
  final Random random;
}

class GenerateQuiz {
  GenerateQuiz(this._selectNextKanji);

  final SelectNextKanji _selectNextKanji;

  QuizQuestion? call(GenerateParams params) {
    // Build a lookup from literal -> Kanji for fast access.
    final kanjiByLiteral = <String, Kanji>{
      for (final kanji in params.levelKanji) kanji.literal: kanji,
    };

    // Find a target kanji that has at least one answer for the requested mode.
    // Start with the SelectNextKanji pick, then iterate the pool if needed.
    final targetLiteral = _selectNextKanji(
      SelectParams(
        pool: params.pool,
        lastShown: params.lastShown,
        random: params.random,
      ),
    );

    if (targetLiteral == null) return null;

    Kanji? target = kanjiByLiteral[targetLiteral];
    if (target == null) return null;

    // If the initially selected target has no answers for this mode, look for
    // another eligible kanji in the pool that does.
    if (params.mode.answersOf(target).isEmpty) {
      final eligible = params.pool
          .map((progress) => kanjiByLiteral[progress.literal])
          .whereType<Kanji>()
          .where((kanji) => params.mode.answersOf(kanji).isNotEmpty)
          .toList();
      if (eligible.isEmpty) return null;
      target = eligible[params.random.nextInt(eligible.length)];
    }

    final correctAnswer = params.mode.answersOf(target).first;

    // Collect distractor candidates: first answer of every OTHER kanji in the
    // level that has answers for this mode, unique, and != correctAnswer.
    final distractorCandidates = params.levelKanji
        .where((kanji) => kanji.literal != target!.literal)
        .map((kanji) {
          final answers = params.mode.answersOf(kanji);
          return answers.isNotEmpty ? answers.first : null;
        })
        .whereType<String>()
        .where((answer) => answer != correctAnswer)
        .toSet()
        .toList();

    distractorCandidates.shuffle(params.random);
    final distractors = distractorCandidates.take(3).toList();

    // Build the final options list and shuffle.
    final options = [correctAnswer, ...distractors];
    options.shuffle(params.random);

    final correctIndex = options.indexOf(correctAnswer);

    return QuizQuestion(
      kanji: target,
      mode: params.mode,
      options: options,
      correctIndex: correctIndex,
    );
  }
}
