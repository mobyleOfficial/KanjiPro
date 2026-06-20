import 'package:kanji_domain/kanji_domain.dart';

import '../constants.dart';

class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.mastered,
    required this.learning,
    required this.locked,
    required this.total,
    required this.totalHits,
  });

  final JlptLevel level;
  final int mastered;
  final int learning;
  final int locked;
  final int total;

  /// Sum of every kanji's hit count for this level. Each correct answer adds 1
  /// (up to [kMasteryTarget] per kanji), so this reflects partial progress.
  final int totalHits;

  /// Cumulative mastery fraction: how far the whole level is toward full
  /// mastery (every kanji at [kMasteryTarget]). Moves with every correct
  /// answer, not only on full mastery — so partial, persisted progress shows.
  double get percent =>
      total == 0 ? 0 : totalHits / (total * kMasteryTarget);
}
