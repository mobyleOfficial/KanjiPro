import 'package:kanji_domain/kanji_domain.dart';

import 'quiz_mode.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.kanji,
    required this.mode,
    required this.options,
    required this.correctIndex,
  });

  final Kanji kanji;
  final QuizMode mode;
  final List<String> options;
  final int correctIndex;
}
