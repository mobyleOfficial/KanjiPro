// Regression test for the UI-freeze root cause: ProgressLocalDataSource.putAll
// must persist a large batch in a single transaction. The old implementation
// looped a separate query + box.put() (one implicit write transaction) per
// entity, so EnsurePoolInitialized writing a full JLPT level (up to ~1232 rows)
// blocked the UI isolate for seconds. putAll must be O(1) transactions.
//
// Run from the package dir so ObjectBox finds lib/libobjectbox.dylib:
//   cd kanjipro/features/progress/data && flutter test test/putall_batch_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:progress_data/progress_data.dart';

KanjiProgressEntity entity(int i, {int hit = 0}) => KanjiProgressEntity(
      literal: 'k$i',
      levelId: 'n1',
      statusIndex: 0,
      hitCount: hit,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
    );

void main() {
  late Store store;
  late Directory tempDir;
  late ProgressLocalDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('objectbox_putall_');
    store = Store(getObjectBoxModel(), directory: tempDir.path);
    dataSource = ProgressLocalDataSource(store.box<KanjiProgressEntity>());
  });

  tearDown(() {
    store.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('putAll persists a large batch quickly (single transaction)', () {
    final batch = List.generate(1232, entity); // N1-sized

    final sw = Stopwatch()..start();
    dataSource.putAll(batch);
    sw.stop();

    expect(dataSource.forLevel('n1').length, 1232);
    // Per-record transactions take seconds for ~1.2k rows; a single batched
    // transaction is milliseconds. Generous bound that still catches the
    // O(N)-transaction regression that froze the UI.
    expect(
      sw.elapsedMilliseconds,
      lessThan(1500),
      reason: 'putAll must batch writes; ${sw.elapsedMilliseconds}ms for 1232 '
          'rows indicates per-record transactions (the freeze bug)',
    );
  });

  test('putAll upserts by literal without duplicating', () {
    dataSource.putAll(List.generate(50, entity));
    // Re-run with updated hitCounts on the same literals.
    dataSource.putAll(List.generate(50, (i) => entity(i, hit: 7)));

    final all = dataSource.forLevel('n1');
    expect(all.length, 50, reason: 'upsert must not duplicate by literal');
    expect(all.every((e) => e.hitCount == 7), isTrue);
  });
}
