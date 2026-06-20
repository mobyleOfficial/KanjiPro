// Verifies progress survives a Store close + reopen on the SAME directory
// (i.e. app relaunch). Mirrors the real path: ProgressRepositoryImpl over a
// real ObjectBox Store, write hitCounts, close, reopen the same dir, read back.
//
//   cd kanjipro/features/progress/data && flutter test test/persistence_reopen_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_data/progress_data.dart';
import 'package:progress_domain/progress_domain.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('objectbox_persist_');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test(
    'hitCount + status survive close and reopen on the same directory',
    () async {
      // First "launch": write some progress.
      var store = Store(getObjectBoxModel(), directory: dir.path);
      var repo = ProgressRepositoryImpl(
        ProgressLocalDataSource(store.box<KanjiProgressEntity>()),
      );
      await repo.upsertAll([
        KanjiProgress(
          literal: '日',
          level: JlptLevel.n5,
          status: ProgressStatus.learning,
          hitCount: 4,
          timesSeen: 6,
          timesCorrect: 4,
          timesWrong: 2,
          lastSeenAt: null,
        ),
        KanjiProgress(
          literal: '一',
          level: JlptLevel.n5,
          status: ProgressStatus.mastered,
          hitCount: 10,
          timesSeen: 12,
          timesCorrect: 10,
          timesWrong: 2,
          lastSeenAt: null,
        ),
      ]);
      store.close();

      // Second "launch": reopen the SAME directory, read back.
      store = Store(getObjectBoxModel(), directory: dir.path);
      repo = ProgressRepositoryImpl(
        ProgressLocalDataSource(store.box<KanjiProgressEntity>()),
      );
      final reloaded = await repo.forLevel(JlptLevel.n5);
      store.close();

      expect(reloaded.length, 2);
      final nichi = reloaded.firstWhere((p) => p.literal == '日');
      expect(nichi.hitCount, 4);
      expect(nichi.status, ProgressStatus.learning);
      final ichi = reloaded.firstWhere((p) => p.literal == '一');
      expect(ichi.hitCount, 10);
      expect(ichi.status, ProgressStatus.mastered);
    },
  );
}
