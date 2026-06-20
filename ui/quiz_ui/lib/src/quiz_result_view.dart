import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Displays the quiz results (correct / total) and provides actions to
/// go back to home or retry. Callbacks are optional — the root app wires
/// navigation via the @RoutePage wrapper.
class QuizResultView extends StatelessWidget {
  const QuizResultView({
    required this.total,
    required this.correct,
    required this.onHome,
    required this.onRetry,
    super.key,
  });

  final int total;
  final int correct;
  final VoidCallback? onHome;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.results,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              label: l10n.quizScore(correct, total),
              child: Text(
                l10n.quizScore(correct, total),
                textAlign: TextAlign.center,
                style: textTheme.displayMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (onRetry != null)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  child: Text(l10n.retry),
                ),
              ),
            if (onRetry != null && onHome != null)
              const SizedBox(height: 12),
            if (onHome != null)
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: onHome,
                  child: Text(l10n.backToHome),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
