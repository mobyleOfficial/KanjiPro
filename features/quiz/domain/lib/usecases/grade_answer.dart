import '../models/quiz_question.dart';

class GradeParams {
  const GradeParams({required this.question, required this.selectedIndex});

  final QuizQuestion question;
  final int selectedIndex;
}

class GradeAnswer {
  bool call(GradeParams params) =>
      params.selectedIndex == params.question.correctIndex;
}
