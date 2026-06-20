// Integration test: validates that the hand-written objectbox.g.dart and
// objectbox-model.json are structurally correct by opening a real Store,
// performing round-trip put/get, and verifying the @Unique constraint on
// the `literal` field prevents duplicates (upsert path).
//
// Run from the progress/data package directory so ObjectBox can find
// lib/libobjectbox.dylib:
//   cd kanjipro/features/progress/data && flutter test test/store_integration_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:progress_data/progress_data.dart';

void main() {
  late Store store;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('objectbox_test_');
    store = Store(
      getObjectBoxModel(),
      directory: tempDir.path,
    );
  });

  tearDown(() {
    store.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Store opens and KanjiProgressEntity round-trips correctly', () {
    final box = store.box<KanjiProgressEntity>();

    final entity = KanjiProgressEntity(
      literal: '日',
      levelId: 'n5',
      statusIndex: 1,
      hitCount: 3,
      timesSeen: 5,
      timesCorrect: 4,
      timesWrong: 1,
      lastSeenMs: 1_700_000_000_000,
    );

    final id = box.put(entity);
    expect(id, greaterThan(0));

    final retrieved = box.get(id);
    expect(retrieved, isNotNull);
    expect(retrieved!.literal, equals('日'));
    expect(retrieved.levelId, equals('n5'));
    expect(retrieved.statusIndex, equals(1));
    expect(retrieved.hitCount, equals(3));
    expect(retrieved.timesSeen, equals(5));
    expect(retrieved.timesCorrect, equals(4));
    expect(retrieved.timesWrong, equals(1));
    expect(retrieved.lastSeenMs, equals(1_700_000_000_000));
  });

  test('forLevel query returns entities matching levelId', () {
    final dataSource = ProgressLocalDataSource(store.box<KanjiProgressEntity>());

    dataSource.put(KanjiProgressEntity(
      literal: '日',
      levelId: 'n5',
      statusIndex: 0,
      hitCount: 0,
      timesSeen: 1,
      timesCorrect: 1,
      timesWrong: 0,
    ));
    dataSource.put(KanjiProgressEntity(
      literal: '月',
      levelId: 'n5',
      statusIndex: 0,
      hitCount: 0,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
    ));
    dataSource.put(KanjiProgressEntity(
      literal: '山',
      levelId: 'n4',
      statusIndex: 0,
      hitCount: 0,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
    ));

    final n5Results = dataSource.forLevel('n5');
    expect(n5Results.length, equals(2));
    expect(n5Results.map((e) => e.literal), containsAll(['日', '月']));

    final n4Results = dataSource.forLevel('n4');
    expect(n4Results.length, equals(1));
    expect(n4Results.first.literal, equals('山'));
  });

  test('@Unique constraint: put upsert path does NOT duplicate on same literal',
      () {
    final dataSource = ProgressLocalDataSource(store.box<KanjiProgressEntity>());

    // First insert
    dataSource.put(KanjiProgressEntity(
      literal: '日',
      levelId: 'n5',
      statusIndex: 0,
      hitCount: 0,
      timesSeen: 1,
      timesCorrect: 1,
      timesWrong: 0,
    ));

    // Second insert with same literal — must upsert, not duplicate
    dataSource.put(KanjiProgressEntity(
      literal: '日',
      levelId: 'n5',
      statusIndex: 1,
      hitCount: 2,
      timesSeen: 3,
      timesCorrect: 2,
      timesWrong: 1,
    ));

    final box = store.box<KanjiProgressEntity>();
    final allEntities = box.getAll();

    // Should only have ONE entity with literal '日'
    final matching = allEntities.where((e) => e.literal == '日').toList();
    expect(
      matching.length,
      equals(1),
      reason: '@Unique + upsert must prevent duplicate entries for same literal',
    );

    // The updated values should be persisted
    expect(matching.first.hitCount, equals(2));
    expect(matching.first.timesSeen, equals(3));
    expect(matching.first.statusIndex, equals(1));
  });
}
