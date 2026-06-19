import 'package:core/core.dart';
import 'package:kanji_domain/kanji_domain.dart';

import '../constants.dart';
import '../models/kanji_progress.dart';
import '../models/progress_status.dart';
import '../repositories/progress_repository.dart';

class EnsureParams {
  const EnsureParams({required this.level, required this.levelKanji});

  final JlptLevel level;
  final List<Kanji> levelKanji;
}

class EnsurePoolInitialized extends UseCase<EnsureParams, List<KanjiProgress>> {
  EnsurePoolInitialized(this._repository);

  final ProgressRepository _repository;

  @override
  Future<List<KanjiProgress>> call([EnsureParams? params]) async {
    final ensureParams = params!;
    final existing = await _repository.forLevel(ensureParams.level);
    final existingByLiteral = {for (final p in existing) p.literal: p};

    // Build the full pool in level order, creating locked records for new kanji.
    final pool = ensureParams.levelKanji.map((kanji) {
      return existingByLiteral[kanji.literal] ??
          KanjiProgress(
            literal: kanji.literal,
            level: ensureParams.level,
            status: ProgressStatus.locked,
            hitCount: 0,
            timesSeen: 0,
            timesCorrect: 0,
            timesWrong: 0,
            lastSeenAt: null,
          );
    }).toList();

    // Count currently active (learning + mastered).
    var activeCount = pool
        .where((p) => p.status != ProgressStatus.locked)
        .length;

    // Promote locked kanji in order until we reach kActivePoolSize.
    final updated = <KanjiProgress>[];
    for (var i = 0; i < pool.length; i++) {
      var entry = pool[i];
      if (entry.status == ProgressStatus.locked &&
          activeCount < kActivePoolSize) {
        entry = entry.copyWith(status: ProgressStatus.learning);
        activeCount++;
      }
      updated.add(entry);
    }

    await _repository.upsertAll(updated);
    return updated;
  }
}
