import 'package:core/core.dart';
import 'package:kanji_data/kanji_data.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockKanjiLocalDataSource extends Mock implements KanjiLocalDataSource {}

void main() {
  test('getByLevel returns only that level, mapped to domain', () async {
    final source = MockKanjiLocalDataSource();
    when(source.loadAll).thenAnswer(
      (_) async => [
        KanjiModel(
          literal: '日',
          jlpt: 'n5',
          onReadings: ['ニチ'],
          kunReadings: ['ひ'],
          meanings: ['day'],
          strokeCount: 4,
        ),
        KanjiModel(
          literal: '一',
          jlpt: 'n4',
          onReadings: ['イチ'],
          kunReadings: ['ひと'],
          meanings: ['one'],
          strokeCount: 1,
        ),
      ],
    );
    final repo = KanjiRepositoryImpl(source);
    final result = await repo.getByLevel(JlptLevel.n5);
    final data = (result as Success<List<Kanji>>).data;
    expect(data.length, 1);
    expect(data.single.literal, '日');
  });

  test('getLevels returns all JlptLevel values', () async {
    final source = MockKanjiLocalDataSource();
    final repo = KanjiRepositoryImpl(source);
    final result = await repo.getLevels();
    final levels = (result as Success<List<JlptLevel>>).data;
    expect(levels, JlptLevel.values);
  });

  test('caches loaded kanji on second call', () async {
    final source = MockKanjiLocalDataSource();
    when(source.loadAll).thenAnswer(
      (_) async => [
        KanjiModel(
          literal: '日',
          jlpt: 'n5',
          onReadings: ['ニチ'],
          kunReadings: ['ひ'],
          meanings: ['day'],
          strokeCount: 4,
        ),
      ],
    );
    final repo = KanjiRepositoryImpl(source);
    await repo.getByLevel(JlptLevel.n5);
    await repo.getByLevel(JlptLevel.n5);
    verify(source.loadAll).called(1);
  });
}
