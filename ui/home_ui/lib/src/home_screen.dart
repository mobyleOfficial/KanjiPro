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
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<HomeCubit>(
        create: (_) => GetIt.instance<HomeCubit>()..load(),
        child: const _HomeContent(),
      );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

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
  });

  final List<LevelProgress> levels;
  final AppLocalizations localizations;

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
          final semanticLabel =
              '$label — ${localizations.levelProgress(percent)}';

          return Semantics(
            label: semanticLabel,
            button: true,
            child: _LevelCard(
              label: label,
              percent: percent,
              progressValue: levelProgress.percent,
              onTap: () {
                // TODO(T11/T12): navigate to study/quiz when routes are available
              },
            ),
          );
        },
      );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.label,
    required this.percent,
    required this.progressValue,
    required this.onTap,
  });

  final String label;
  final int percent;
  final double progressValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
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
            ],
          ),
        ),
      ),
    );
  }
}
