import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui/quiz_ui.dart';

import '../routes/app_router.gr.dart';

@RoutePage()
class QuizScreen extends StatelessWidget {
  const QuizScreen({required this.level, required this.mode, super.key});

  final JlptLevel level;
  final QuizMode mode;

  @override
  Widget build(BuildContext context) => QuizView(
        level: level,
        mode: mode,
        onFinished: (int total, int correct) =>
            AutoRouter.of(context).push(ResultsRoute(total: total, correct: correct)),
      );
}
