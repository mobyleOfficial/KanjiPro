import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';

/// View for choosing a quiz mode (On'yomi / Kun'yomi / Meaning).
///
/// This widget has no cubit — it is purely presentational. Navigation is
/// handled by the root app via [onModeSelected].
class QuizModeSelectView extends StatelessWidget {
  const QuizModeSelectView({
    required this.level,
    required this.onModeSelected,
    super.key,
  });

  final JlptLevel level;
  final void Function(JlptLevel level, QuizMode mode) onModeSelected;

  String _levelLabel(AppLocalizations l10n, JlptLevel jlptLevel) =>
      switch (jlptLevel) {
        JlptLevel.n5 => l10n.levelN5,
        JlptLevel.n4 => l10n.levelN4,
        JlptLevel.n3 => l10n.levelN3,
        JlptLevel.n2 => l10n.levelN2,
        JlptLevel.n1 => l10n.levelN1,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final levelLabel = _levelLabel(l10n, level);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.quiz} — $levelLabel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ModeButton(
              label: l10n.modeOnReading,
              colorScheme: colorScheme,
              onTap: () => onModeSelected(level, QuizMode.onReading),
            ),
            const SizedBox(height: 16),
            _ModeButton(
              label: l10n.modeKunReading,
              colorScheme: colorScheme,
              onTap: () => onModeSelected(level, QuizMode.kunReading),
            ),
            const SizedBox(height: 16),
            _ModeButton(
              label: l10n.modeMeaning,
              colorScheme: colorScheme,
              onTap: () => onModeSelected(level, QuizMode.meaning),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            onPressed: onTap,
            child: Text(label, style: const TextStyle(fontSize: 18)),
          ),
        ),
      );
}
