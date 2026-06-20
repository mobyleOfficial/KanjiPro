import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kanji_domain/kanji_domain.dart';

import 'study_cubit.dart';
import 'study_state.dart';

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
          StudyLoading() =>
            const Center(child: CircularProgressIndicator()),
          StudyError(:final message) => Center(child: Text(message)),
          StudySuccess(:final kanji) when kanji.isEmpty =>
            const Center(child: Icon(Icons.inbox_outlined, size: 64)),
          StudySuccess(:final kanji) => _FlashcardPageView(
              kanjiList: kanji,
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
    required this.localizations,
  });

  final List<Kanji> kanjiList;
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
  });

  final Kanji kanji;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        child: Padding(
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

              // On readings row
              _ReadingRow(
                label: localizations.modeOnReading,
                values: kanji.onReadings,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              // Kun readings row
              _ReadingRow(
                label: localizations.modeKunReading,
                values: kanji.kunReadings,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              // Meaning row
              _ReadingRow(
                label: localizations.modeMeaning,
                values: kanji.meanings,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 24),

              // TTS speak button
              _SpeakButton(
                kanji: kanji,
                localizations: localizations,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeakButton extends StatefulWidget {
  const _SpeakButton({
    required this.kanji,
    required this.localizations,
    required this.colorScheme,
  });

  final Kanji kanji;
  final AppLocalizations localizations;
  final ColorScheme colorScheme;

  @override
  State<_SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<_SpeakButton> {
  bool? _ttsAvailable;

  @override
  void initState() {
    super.initState();
    _checkTtsAvailability();
  }

  Future<void> _checkTtsAvailability() async {
    final cubit = context.read<StudyCubit>();
    final available = await cubit.ttsAvailable();
    if (mounted) {
      setState(() => _ttsAvailable = available);
    }
  }

  String? _firstAvailableReading() {
    if (widget.kanji.onReadings.isNotEmpty) {
      return widget.kanji.onReadings.first;
    }
    if (widget.kanji.kunReadings.isNotEmpty) {
      return widget.kanji.kunReadings.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _ttsAvailable ?? false;
    final reading = _firstAvailableReading();

    return Center(
      child: SizedBox(
        width: 56,
        height: 56,
        child: Semantics(
          label: isAvailable
              ? widget.localizations.speakAloud
              : widget.localizations.ttsUnavailable,
          button: true,
          child: IconButton(
            onPressed: (isAvailable && reading != null)
                ? () => context.read<StudyCubit>().speak(reading)
                : null,
            icon: Icon(
              Icons.volume_up_outlined,
              color: isAvailable
                  ? widget.colorScheme.primary
                  : widget.colorScheme.onSurfaceVariant,
              semanticLabel: null,
            ),
            tooltip: isAvailable ? null : widget.localizations.ttsUnavailable,
          ),
        ),
      ),
    );
  }
}
