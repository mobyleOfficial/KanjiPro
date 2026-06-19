import 'package:core/core.dart';

import '../constants.dart';
import '../models/kanji_progress.dart';
import '../models/progress_status.dart';
import '../repositories/progress_repository.dart';

class RecordParams {
  const RecordParams({
    required this.pool,
    required this.literal,
    required this.correct,
  });

  final List<KanjiProgress> pool;
  final String literal;
  final bool correct;
}

class RecordAnswer extends UseCase<RecordParams, List<KanjiProgress>> {
  RecordAnswer(this._repository);

  final ProgressRepository _repository;

  @override
  Future<List<KanjiProgress>> call([RecordParams? params]) async {
    final recordParams = params!;
    final result = [...recordParams.pool];
    final index = result.indexWhere((e) => e.literal == recordParams.literal);
    var target = result[index];

    if (recordParams.correct) {
      final nextHitCount = (target.hitCount + 1).clamp(0, kMasteryTarget);
      target = target.copyWith(
        hitCount: nextHitCount,
        timesSeen: target.timesSeen + 1,
        timesCorrect: target.timesCorrect + 1,
        status: nextHitCount >= kMasteryTarget
            ? ProgressStatus.mastered
            : ProgressStatus.learning,
        lastSeenAt: DateTime.now(),
      );
      result[index] = target;
      if (target.status == ProgressStatus.mastered) {
        final lockedIndex = result.indexWhere(
          (e) => e.status == ProgressStatus.locked,
        );
        if (lockedIndex != -1) {
          result[lockedIndex] = result[lockedIndex].copyWith(
            status: ProgressStatus.learning,
          );
        }
      }
    } else {
      final nextHitCount = (target.hitCount - 1).clamp(0, kMasteryTarget);
      target = target.copyWith(
        hitCount: nextHitCount,
        timesSeen: target.timesSeen + 1,
        timesWrong: target.timesWrong + 1,
        status: ProgressStatus.learning,
        lastSeenAt: DateTime.now(),
      );
      result[index] = target;
    }

    await _repository.upsertAll(result);
    return result;
  }
}
