import 'package:core/core.dart';
import 'package:kanji_domain/kanji_domain.dart';

import '../models/level_progress.dart';
import '../models/progress_status.dart';
import '../repositories/progress_repository.dart';

class GetLevelProgress extends UseCase<JlptLevel, LevelProgress> {
  GetLevelProgress(this._repository);

  final ProgressRepository _repository;

  @override
  Future<LevelProgress> call([JlptLevel? params]) async {
    final level = params!;
    final records = await _repository.forLevel(level);
    final mastered = records
        .where((p) => p.status == ProgressStatus.mastered)
        .length;
    final learning = records
        .where((p) => p.status == ProgressStatus.learning)
        .length;
    final locked = records
        .where((p) => p.status == ProgressStatus.locked)
        .length;
    final totalHits = records.fold<int>(0, (sum, p) => sum + p.hitCount);
    return LevelProgress(
      level: level,
      mastered: mastered,
      learning: learning,
      locked: locked,
      total: records.length,
      totalHits: totalHits,
    );
  }
}
