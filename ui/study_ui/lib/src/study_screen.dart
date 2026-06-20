import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

import 'study_cubit.dart';
import 'study_state.dart';

// Minimum touch target size per accessibility rules (48 dp).
const double _kMinTouchTarget = 48.0;

/// Root widget for the study feature. Provides [StudyCubit] from GetIt and
/// renders the flashcard browser for the given [level].
class StudyView extends StatelessWidget {
  const StudyView({required this.level, super.key});

  final JlptLevel level;

  @override
  Widget build(BuildContext context) => BlocProvider<StudyCubit>(
    create: (_) => GetIt.instance<StudyCubit>()..load(level),
    child: _StudyContent(level: level),
  );
}

class _StudyContent extends StatelessWidget {
  const _StudyContent({required this.level});

  final JlptLevel level;

  String _levelLabel(AppLocalizations localizations, JlptLevel jlptLevel) =>
      switch (jlptLevel) {
        JlptLevel.n5 => localizations.levelN5,
        JlptLevel.n4 => localizations.levelN4,
        JlptLevel.n3 => localizations.levelN3,
        JlptLevel.n2 => localizations.levelN2,
        JlptLevel.n1 => localizations.levelN1,
      };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.study} — ${_levelLabel(localizations, level)}',
        ),
      ),
      body: BlocBuilder<StudyCubit, StudyState>(
        builder: (context, state) => switch (state) {
          StudyLoading() => const Center(child: CircularProgressIndicator()),
          StudyError(:final message) => Center(child: Text(message)),
          StudySuccess(:final kanji) when kanji.isEmpty => const Center(
            child: Icon(Icons.inbox_outlined, size: 64),
          ),
          StudySuccess(:final kanji, :final progressByLiteral) =>
            _FlashcardPageView(
              kanjiList: kanji,
              progressByLiteral: progressByLiteral,
              localizations: localizations,
            ),
        },
      ),
    );
  }
}

class _FlashcardPageView extends StatefulWidget {
  const _FlashcardPageView({
    required this.kanjiList,
    required this.progressByLiteral,
    required this.localizations,
  });

  final List<Kanji> kanjiList;
  final Map<String, KanjiProgress> progressByLiteral;
  final AppLocalizations localizations;

  @override
  State<_FlashcardPageView> createState() => _FlashcardPageViewState();
}

class _FlashcardPageViewState extends State<_FlashcardPageView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.kanjiList.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => _KanjiCard(
              kanji: widget.kanjiList[index],
              progress:
                  widget.progressByLiteral[widget.kanjiList[index].literal],
              localizations: widget.localizations,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${_currentIndex + 1} / ${widget.kanjiList.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _KanjiCard extends StatelessWidget {
  const _KanjiCard({
    required this.kanji,
    required this.localizations,
    this.progress,
  });

  final Kanji kanji;
  final KanjiProgress? progress;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kanji literal — large display
              Semantics(
                label: 'Kanji: ${kanji.literal}',
                child: Text(
                  kanji.literal,
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 96,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // On readings — each tappable to hear pronunciation
              _TappableReadingRow(
                label: localizations.modeOnReading,
                values: kanji.onReadings,
                colorScheme: colorScheme,
                textTheme: textTheme,
                localizations: localizations,
              ),
              const SizedBox(height: 12),

              // Kun readings — each tappable to hear pronunciation
              _TappableReadingRow(
                label: localizations.modeKunReading,
                values: kanji.kunReadings,
                colorScheme: colorScheme,
                textTheme: textTheme,
                localizations: localizations,
              ),
              const SizedBox(height: 12),

              // Meaning row — English, plain text (not tappable)
              _ReadingRow(
                label: localizations.modeMeaning,
                values: kanji.meanings,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),

              // Mastery block — only shown when a progress record exists
              if (progress != null) ...[
                const SizedBox(height: 20),
                _MasteryBlock(
                  kanji: kanji,
                  progress: progress!,
                  localizations: localizations,
                ),
              ],

              // Examples section — only shown when examples are available
              if (kanji.examples.isNotEmpty) ...[
                const SizedBox(height: 20),
                _ExamplesSection(
                  examples: kanji.examples,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  localizations: localizations,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows mastery badge, N/10 streak bar, and a Reset button for a kanji
/// that has at least one progress record.
class _MasteryBlock extends StatelessWidget {
  const _MasteryBlock({
    required this.kanji,
    required this.progress,
    required this.localizations,
  });

  final Kanji kanji;
  final KanjiProgress progress;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMastered = progress.status == ProgressStatus.mastered;

    final badgeBackground = isMastered
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final badgeForeground = isMastered
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final badgeLabel = isMastered
        ? localizations.masteryMastered
        : localizations.masteryInProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mastery label row: badge on the left, Reset button on the right.
        Row(
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeLabel,
                style: textTheme.labelMedium?.copyWith(color: badgeForeground),
              ),
            ),
            const Spacer(),
            // Reset button — ≥48dp touch target via SizedBox
            Semantics(
              button: true,
              label: localizations.resetMastery,
              child: SizedBox(
                height: _kMinTouchTarget,
                child: TextButton(
                  onPressed: () => _confirmReset(context),
                  child: Text(localizations.resetMastery),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // N / 10 label
        Text(
          '${progress.hitCount} / $kMasteryTarget',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        // 10-segment streak bar
        _StreakBar(hitCount: progress.hitCount, colorScheme: colorScheme),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final cubit = context.read<StudyCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.resetMasteryTitle),
        content: Text(localizations.resetMasteryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.resetMastery),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.resetKanji(kanji.literal);
    }
  }
}

/// 10-segment horizontal bar reflecting the kanji's current [hitCount].
/// Filled segments use [ColorScheme.primary]; empty segments use
/// [ColorScheme.surfaceContainerHighest] for WCAG-safe contrast.
class _StreakBar extends StatelessWidget {
  const _StreakBar({required this.hitCount, required this.colorScheme});

  final int hitCount;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(kMasteryTarget, (index) {
        final filled = index < hitCount;
        return Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: filled
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

/// Plain (non-tappable) row for values that should not be spoken aloud via
/// TTS (e.g. English meanings).
class _ReadingRow extends StatelessWidget {
  const _ReadingRow({
    required this.label,
    required this.values,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final List<String> values;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final displayText = values.isEmpty ? '—' : values.join('、');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            displayText,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

/// Row that renders Japanese readings as individual tappable items.
///
/// Each reading is rendered as underlined text wrapped in an [InkWell] so the
/// user can tap a specific reading to hear it via TTS. When TTS is unavailable,
/// the underlines are hidden and a small guidance note is shown instead.
///
/// TTS availability is checked once on mount (same pattern as the removed
/// `_SpeakButton`). While the async check is in-flight (`_ttsAvailable == null`)
/// the readings render as plain (non-tappable) text to avoid a flash of
/// incorrectly-enabled controls.
class _TappableReadingRow extends StatefulWidget {
  const _TappableReadingRow({
    required this.label,
    required this.values,
    required this.colorScheme,
    required this.textTheme,
    required this.localizations,
  });

  final String label;
  final List<String> values;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations localizations;

  @override
  State<_TappableReadingRow> createState() => _TappableReadingRowState();
}

class _TappableReadingRowState extends State<_TappableReadingRow> {
  bool? _ttsAvailable;

  @override
  void initState() {
    super.initState();
    _checkTtsAvailability();
  }

  Future<void> _checkTtsAvailability() async {
    final available = await context.read<StudyCubit>().ttsAvailable();
    if (mounted) {
      setState(() => _ttsAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _ttsAvailable ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            widget.label,
            style: widget.textTheme.labelMedium?.copyWith(
              color: widget.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: widget.values.isEmpty
              ? Text(
                  '—',
                  style: widget.textTheme.bodyLarge?.copyWith(
                    color: widget.colorScheme.onSurface,
                  ),
                )
              : _ReadingChips(
                  readings: widget.values,
                  isAvailable: isAvailable,
                  colorScheme: widget.colorScheme,
                  textTheme: widget.textTheme,
                  localizations: widget.localizations,
                ),
        ),
      ],
    );
  }
}

/// Lays out individual reading chips in a [Wrap] so they reflow naturally on
/// narrow screens. Each chip is either tappable (TTS available) or plain text
/// (TTS unavailable).
class _ReadingChips extends StatelessWidget {
  const _ReadingChips({
    required this.readings,
    required this.isAvailable,
    required this.colorScheme,
    required this.textTheme,
    required this.localizations,
  });

  final List<String> readings;
  final bool isAvailable;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: readings
          .map(
            (reading) => _ReadingChip(
              reading: reading,
              isAvailable: isAvailable,
              colorScheme: colorScheme,
              textTheme: textTheme,
              localizations: localizations,
            ),
          )
          .toList(),
    );
  }
}

/// A single tappable reading item with an underline affordance and a ≥48 dp
/// touch target.
class _ReadingChip extends StatelessWidget {
  const _ReadingChip({
    required this.reading,
    required this.isAvailable,
    required this.colorScheme,
    required this.textTheme,
    required this.localizations,
  });

  final String reading;
  final bool isAvailable;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      reading,
      style: textTheme.bodyLarge?.copyWith(
        color: isAvailable ? colorScheme.primary : colorScheme.onSurface,
        decoration: isAvailable
            ? TextDecoration.underline
            : TextDecoration.none,
        decorationColor: isAvailable ? colorScheme.primary : null,
      ),
    );

    if (!isAvailable) {
      // TTS unavailable: render as plain text, no tap affordance.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: textWidget,
      );
    }

    return Semantics(
      label: '${localizations.speakAloud}: $reading',
      button: true,
      child: InkWell(
        onTap: () => context.read<StudyCubit>().speak(reading),
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          // Enforce ≥48 dp touch target height (accessibility rule).
          constraints: const BoxConstraints(minHeight: _kMinTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Align(alignment: Alignment.centerLeft, child: textWidget),
          ),
        ),
      ),
    );
  }
}

/// Section that lists [KanjiExample]s with a labelled header. Only rendered
/// when [examples] is non-empty (callers must guard on this condition).
///
/// Each example row shows:
/// - The [KanjiExample.word] (Japanese, tappable-to-speak when TTS is on)
/// - The [KanjiExample.reading] (kana, secondary colour)
/// - The [KanjiExample.meaning] (English, tertiary colour)
///
/// TTS availability is checked once on mount using the same pattern as
/// [_TappableReadingRow] so behaviour is consistent across the card.
class _ExamplesSection extends StatefulWidget {
  const _ExamplesSection({
    required this.examples,
    required this.colorScheme,
    required this.textTheme,
    required this.localizations,
  });

  final List<KanjiExample> examples;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations localizations;

  @override
  State<_ExamplesSection> createState() => _ExamplesSectionState();
}

class _ExamplesSectionState extends State<_ExamplesSection> {
  bool? _ttsAvailable;

  @override
  void initState() {
    super.initState();
    _checkTtsAvailability();
  }

  Future<void> _checkTtsAvailability() async {
    final available = await context.read<StudyCubit>().ttsAvailable();
    if (mounted) {
      setState(() => _ttsAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _ttsAvailable ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Text(
          widget.localizations.examples,
          style: widget.textTheme.labelMedium?.copyWith(
            color: widget.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // One row per example
        ...widget.examples.map(
          (example) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ExampleRow(
              example: example,
              isAvailable: isAvailable,
              colorScheme: widget.colorScheme,
              textTheme: widget.textTheme,
              localizations: widget.localizations,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single example row: word (tappable) | reading | meaning.
class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.example,
    required this.isAvailable,
    required this.colorScheme,
    required this.textTheme,
    required this.localizations,
  });

  final KanjiExample example;
  final bool isAvailable;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Word — tappable to speak when TTS is available
        Flexible(
          child: _ExampleWordChip(
            word: example.word,
            isAvailable: isAvailable,
            colorScheme: colorScheme,
            textTheme: textTheme,
            localizations: localizations,
          ),
        ),
        const SizedBox(width: 8),
        // Reading (kana) — secondary colour, plain text
        Flexible(
          child: Text(
            example.reading,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Meaning — tertiary colour, plain text
        Flexible(
          child: Text(
            example.meaning,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
        ),
      ],
    );
  }
}

/// A single example word, rendered as tappable underlined text when TTS is
/// available or as plain text otherwise. Enforces a ≥48 dp touch target.
class _ExampleWordChip extends StatelessWidget {
  const _ExampleWordChip({
    required this.word,
    required this.isAvailable,
    required this.colorScheme,
    required this.textTheme,
    required this.localizations,
  });

  final String word;
  final bool isAvailable;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final wordText = Text(
      word,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyLarge?.copyWith(
        color: isAvailable ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        decoration: isAvailable
            ? TextDecoration.underline
            : TextDecoration.none,
        decorationColor: isAvailable ? colorScheme.primary : null,
      ),
    );

    if (!isAvailable) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: wordText,
      );
    }

    return Semantics(
      label: '${localizations.speakAloud}: $word',
      button: true,
      child: InkWell(
        onTap: () => context.read<StudyCubit>().speak(word),
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          // Enforce ≥48 dp touch target height (accessibility rule).
          constraints: const BoxConstraints(minHeight: _kMinTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Align(alignment: Alignment.centerLeft, child: wordText),
          ),
        ),
      ),
    );
  }
}
