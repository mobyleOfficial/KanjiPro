import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

import 'home_cubit.dart';
import 'home_state.dart';

/// Root widget for the home feature. Provides [HomeCubit] from GetIt and
/// renders the level-selection UI.
///
/// Annotate with `@RoutePage()` in the shell app or wrap in a shell
/// `HomeScreen` that delegates to this widget.
///
/// [onLevelTap] — invoked when the user taps the Study action for a level.
/// [onQuizTap]  — invoked when the user taps the Quiz action for a level.
/// Provide these from the root app to trigger navigation without creating
/// a circular dependency on generated route types.
class HomeView extends StatelessWidget {
  const HomeView({
    this.onLevelTap,
    this.onQuizTap,
    super.key,
  });

  final void Function(JlptLevel level)? onLevelTap;
  final void Function(JlptLevel level)? onQuizTap;

  @override
  Widget build(BuildContext context) => BlocProvider<HomeCubit>(
        create: (_) => GetIt.instance<HomeCubit>()..load(),
        child: _HomeContent(onLevelTap: onLevelTap, onQuizTap: onQuizTap),
      );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({this.onLevelTap, this.onQuizTap});

  final void Function(JlptLevel level)? onLevelTap;
  final void Function(JlptLevel level)? onQuizTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.chooseLevel)),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const Center(child: CircularProgressIndicator()),
          HomeError(:final message) => Center(child: Text(message)),
          HomeSuccess(:final levels) => _LevelList(
              levels: levels,
              localizations: localizations,
              onLevelTap: onLevelTap,
              onQuizTap: onQuizTap,
            ),
        },
      ),
    );
  }
}

class _LevelList extends StatelessWidget {
  const _LevelList({
    required this.levels,
    required this.localizations,
    this.onLevelTap,
    this.onQuizTap,
  });

  final List<LevelProgress> levels;
  final AppLocalizations localizations;
  final void Function(JlptLevel level)? onLevelTap;
  final void Function(JlptLevel level)? onQuizTap;

  String _levelLabel(AppLocalizations l10n, JlptLevel level) => switch (level) {
        JlptLevel.n5 => l10n.levelN5,
        JlptLevel.n4 => l10n.levelN4,
        JlptLevel.n3 => l10n.levelN3,
        JlptLevel.n2 => l10n.levelN2,
        JlptLevel.n1 => l10n.levelN1,
      };

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final levelProgress = levels[index];
          final label = _levelLabel(localizations, levelProgress.level);
          final percent = (levelProgress.percent * 100).round();

          return _LevelCard(
            label: label,
            percent: percent,
            progressValue: levelProgress.percent,
            localizations: localizations,
            onStudyTap: () => onLevelTap?.call(levelProgress.level),
            onQuizTap: () => onQuizTap?.call(levelProgress.level),
          );
        },
      );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.label,
    required this.percent,
    required this.progressValue,
    required this.localizations,
    required this.onStudyTap,
    required this.onQuizTap,
  });

  final String label;
  final int percent;
  final double progressValue;
  final AppLocalizations localizations;
  final VoidCallback onStudyTap;
  final VoidCallback onQuizTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level title + mastery percentage
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32),
              child: Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '$percent%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              color: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 12),
            // Action row: Study + Quiz
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: '${localizations.study} $label',
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onStudyTap,
                        child: Text(localizations.study),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: '${localizations.quiz} $label',
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                        onPressed: onQuizTap,
                        child: Text(localizations.quiz),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
