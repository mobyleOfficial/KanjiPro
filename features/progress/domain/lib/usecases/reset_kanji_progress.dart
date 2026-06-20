import 'package:core/core.dart';
import 'package:kanji_domain/kanji_domain.dart';

import '../models/kanji_progress.dart';
import '../models/progress_status.dart';
import '../repositories/progress_repository.dart';

class ResetParams {
  const ResetParams({required this.literal, required this.level});

  final String literal;
  final JlptLevel level;
}

class ResetKanjiProgress extends UseCase<ResetParams, void> {
  ResetKanjiProgress(this._repository);

  final ProgressRepository _repository;

  @override
  Future<void> call([ResetParams? params]) async {
    final resetParams = params!;
    await _repository.upsert(
      KanjiProgress(
        literal: resetParams.literal,
        level: resetParams.level,
        status: ProgressStatus.learning,
        hitCount: 0,
        timesSeen: 0,
        timesCorrect: 0,
        timesWrong: 0,
        lastSeenAt: null,
      ),
    );
  }
}
