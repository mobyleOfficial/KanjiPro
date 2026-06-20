import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';

import 'quiz_cubit.dart';
import 'quiz_state.dart';

/// Root widget for the quiz screen. Provides [QuizCubit] from GetIt and
/// immediately starts a session for [level] and [mode].
class QuizView extends StatelessWidget {
  const QuizView({required this.level, required this.mode, super.key});

  final JlptLevel level;
  final QuizMode mode;

  @override
  Widget build(BuildContext context) => BlocProvider<QuizCubit>(
    create: (_) => GetIt.instance<QuizCubit>()..start(level, mode),
    child: _QuizContent(mode: mode),
  );
}

class _QuizContent extends StatefulWidget {
  const _QuizContent({required this.mode});

  final QuizMode mode;

  @override
  State<_QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<_QuizContent> {
  // Track the previous state so the BlocListener can diff properly.
  QuizState _previous = const QuizLoading();

  /// Returns the reading to speak on question appear in meaning mode:
  /// first kun'yomi if available, else first on'yomi, else null.
  String? _meaningModeReading(Kanji kanji) {
    if (kanji.kunReadings.isNotEmpty) return kanji.kunReadings.first;
    if (kanji.onReadings.isNotEmpty) return kanji.onReadings.first;
    return null;
  }

  Future<void> _handleAudio(
    QuizState previous,
    QuizState current,
    TtsService tts,
    SoundEffectService sfx,
  ) async {
    if (current is! QuizQuestionState) return;

    final isNewQuestion =
        previous is! QuizQuestionState ||
        previous.question.kanji.literal != current.question.kanji.literal ||
        (previous.answered && !current.answered);

    final justAnswered =
        current.answered &&
        (previous is! QuizQuestionState || !previous.answered);

    try {
      if (!current.answered && isNewQuestion) {
        // New question appeared (unanswered state).
        if (widget.mode == QuizMode.meaning) {
          // Meaning mode: speak the kanji's main kun/on reading as a cue.
          final reading = _meaningModeReading(current.question.kanji);
          if (reading != null) {
            final available = await tts.isJapaneseAvailable();
            if (available) await tts.speak(reading);
          }
        }
        // Reading modes: no audio on appear.
      } else if (justAnswered) {
        // Answer just submitted — play SFX in all modes.
        final isCorrect = current.lastCorrect ?? false;
        if (isCorrect) {
          await sfx.playCorrect();
        } else {
          await sfx.playWrong();
        }

        // Reading modes only: speak the correct answer reading for reinforcement.
        if (widget.mode == QuizMode.onReading ||
            widget.mode == QuizMode.kunReading) {
          final correctReading =
              current.question.options[current.question.correctIndex];
          final available = await tts.isJapaneseAvailable();
          if (available) await tts.speak(correctReading);
        }
      }
    } catch (_) {
      // Audio failures must never crash the UI — swallow silently.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tts = GetIt.instance<TtsService>();
    final sfx = GetIt.instance<SoundEffectService>();

    return BlocListener<QuizCubit, QuizState>(
      listener: (context, current) {
        final previous = _previous;
        _previous = current;
        // Intentionally not awaited — audio is a fire-and-forget side-effect.
        _handleAudio(previous, current, tts, sfx);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.quiz)),
        body: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) => switch (state) {
            QuizLoading() => const Center(child: CircularProgressIndicator()),
            QuizError(:final message) => Center(child: Text(message)),
            QuizQuestionState() => _QuizQuestionWidget(
              state: state,
              l10n: l10n,
            ),
          },
        ),
      ),
    );
  }
}

class _QuizQuestionWidget extends StatelessWidget {
  const _QuizQuestionWidget({required this.state, required this.l10n});

  final QuizQuestionState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final question = state.question;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Per-kanji mastery progress
          _MasteryProgress(
            hits: state.currentKanjiHits,
            target: state.masteryTarget,
            colorScheme: colorScheme,
            l10n: l10n,
          ),
          const SizedBox(height: 24),

          // Kanji literal display
          Semantics(
            label: 'Kanji: ${question.kanji.literal}',
            child: Center(
              child: Text(
                question.kanji.literal,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 96,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Feedback banner (correct/wrong) — visible only after answering
          if (state.answered) ...[
            if (state.justMastered)
              _MasteredBanner(l10n: l10n, colorScheme: colorScheme)
            else
              _FeedbackBanner(
                isCorrect: state.lastCorrect ?? false,
                l10n: l10n,
                colorScheme: colorScheme,
              ),
            const SizedBox(height: 16),
          ],

          // Option buttons
          ...List.generate(question.options.length, (index) {
            final option = question.options[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionButton(
                label: option,
                index: index,
                state: state,
                l10n: l10n,
                colorScheme: colorScheme,
              ),
            );
          }),

          const Spacer(),

          // Next button — visible only after answering
          if (state.answered)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.read<QuizCubit>().next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(l10n.next),
              ),
            ),
        ],
      ),
    );
  }
}

class _MasteryProgress extends StatelessWidget {
  const _MasteryProgress({
    required this.hits,
    required this.target,
    required this.colorScheme,
    required this.l10n,
  });

  final int hits;
  final int target;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final clampedHits = hits.clamp(0, target);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.mastery}: $clampedHits / $target',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: '${l10n.mastery}: $clampedHits / $target',
          child: Row(
            children: List.generate(target, (index) {
              final filled = index < clampedHits;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: filled
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MasteredBanner extends StatelessWidget {
  const _MasteredBanner({required this.l10n, required this.colorScheme});

  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => Semantics(
    label: l10n.mastered,
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.mastered,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.isCorrect,
    required this.l10n,
    required this.colorScheme,
  });

  final bool isCorrect;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final label = isCorrect ? l10n.correct : l10n.wrong;
    final backgroundColor = isCorrect
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foregroundColor = isCorrect
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;

    return Semantics(
      label: label,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.index,
    required this.state,
    required this.l10n,
    required this.colorScheme,
  });

  final String label;
  final int index;
  final QuizQuestionState state;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  Color _backgroundColor() {
    if (!state.answered) return colorScheme.surfaceContainerHighest;
    if (index == state.question.correctIndex) {
      return colorScheme.tertiaryContainer;
    }
    if (index == state.selectedIndex) return colorScheme.errorContainer;
    return colorScheme.surfaceContainerHighest;
  }

  Color _foregroundColor() {
    if (!state.answered) return colorScheme.onSurface;
    if (index == state.question.correctIndex) {
      return colorScheme.onTertiaryContainer;
    }
    if (index == state.selectedIndex) return colorScheme.onErrorContainer;
    return colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor();
    final foregroundColor = _foregroundColor();
    final isAnswered = state.answered;
    final semanticHint = isAnswered
        ? (index == state.question.correctIndex
              ? l10n.correct
              : index == state.selectedIndex
              ? l10n.wrong
              : label)
        : label;

    return Semantics(
      button: true,
      label: semanticHint,
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: backgroundColor,
            disabledForegroundColor: foregroundColor,
          ),
          onPressed: isAnswered
              ? null
              : () => context.read<QuizCubit>().answer(index),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
