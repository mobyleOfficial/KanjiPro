import 'package:quiz_domain/quiz_domain.dart';

sealed class QuizState {
  const QuizState();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizQuestionState extends QuizState {
  const QuizQuestionState({
    required this.question,
    required this.answered,
    required this.currentKanjiHits,
    required this.masteryTarget,
    required this.justMastered,
    this.lastCorrect,
    this.selectedIndex,
  });

  final QuizQuestion question;
  final bool answered;

  /// Current kanji's hitCount from the progress pool.
  final int currentKanjiHits;

  /// The mastery target (= kMasteryTarget).
  final int masteryTarget;

  /// True when this answer brought the kanji from below target to exactly target.
  final bool justMastered;

  final bool? lastCorrect;

  /// The option index the user tapped, or null if not yet answered.
  final int? selectedIndex;
}

class QuizError extends QuizState {
  const QuizError(this.message);

  final String message;
}
