import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui/quiz_ui.dart';

import '../routes/app_router.gr.dart';

@RoutePage()
class QuizModeSelectScreen extends StatelessWidget {
  const QuizModeSelectScreen({required this.level, super.key});

  final JlptLevel level;

  @override
  Widget build(BuildContext context) => QuizModeSelectView(
        level: level,
        onModeSelected: (JlptLevel selectedLevel, QuizMode mode) =>
            AutoRouter.of(context).push(
          QuizRoute(level: selectedLevel, mode: mode),
        ),
      );
}
