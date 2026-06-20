import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:quiz_ui/quiz_ui.dart';

@RoutePage()
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({required this.total, required this.correct, super.key});

  final int total;
  final int correct;

  @override
  Widget build(BuildContext context) => QuizResultView(
        total: total,
        correct: correct,
        onRetry: () => AutoRouter.of(context).popUntilRouteWithName('QuizModeSelectRoute'),
        onHome: () => AutoRouter.of(context).popUntilRoot(),
      );
}
