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
    this.lastCorrect,
    required this.answeredCount,
    required this.sessionLength,
  });

  final QuizQuestion question;
  final bool answered;
  final bool? lastCorrect;
  final int answeredCount;
  final int sessionLength;
}

class QuizFinished extends QuizState {
  const QuizFinished({required this.total, required this.correct});

  final int total;
  final int correct;
}

class QuizError extends QuizState {
  const QuizError(this.message);

  final String message;
}
