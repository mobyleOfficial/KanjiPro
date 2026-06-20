import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_data/progress_data.dart';
import 'package:progress_domain/progress_domain.dart';

class MockProgressLocalDataSource extends Mock
    implements ProgressLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      KanjiProgressEntity(
        literal: '',
        levelId: '',
        statusIndex: 0,
        hitCount: 0,
        timesSeen: 0,
        timesCorrect: 0,
        timesWrong: 0,
      ),
    );
    registerFallbackValue(<KanjiProgressEntity>[]);
  });

  late MockProgressLocalDataSource source;
  late ProgressRepositoryImpl repository;

  setUp(() {
    source = MockProgressLocalDataSource();
    repository = ProgressRepositoryImpl(source);
  });

  test('forLevel maps entities to domain objects', () async {
    final entity = KanjiProgressEntity(
      id: 1,
      literal: '日',
      levelId: 'n5',
      statusIndex: ProgressStatus.learning.index,
      hitCount: 3,
      timesSeen: 5,
      timesCorrect: 4,
      timesWrong: 1,
    );
    when(() => source.forLevel('n5')).thenReturn([entity]);

    final result = await repository.forLevel(JlptLevel.n5);

    expect(result.length, 1);
    expect(result.single.literal, '日');
    expect(result.single.level, JlptLevel.n5);
    expect(result.single.status, ProgressStatus.learning);
    expect(result.single.hitCount, 3);
  });

  test('upsert delegates to source.put with entity from domain', () async {
    final domain = KanjiProgress(
      literal: '水',
      level: JlptLevel.n4,
      status: ProgressStatus.locked,
      hitCount: 0,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
      lastSeenAt: null,
    );
    when(() => source.put(any())).thenReturn(null);

    await repository.upsert(domain);

    final captured =
        verify(() => source.put(captureAny())).captured.single
            as KanjiProgressEntity;
    expect(captured.literal, '水');
    expect(captured.levelId, 'n4');
  });

  test('upsertAll delegates to source.putAll', () async {
    final domainList = [
      KanjiProgress(
        literal: '火',
        level: JlptLevel.n3,
        status: ProgressStatus.mastered,
        hitCount: 10,
        timesSeen: 12,
        timesCorrect: 11,
        timesWrong: 1,
        lastSeenAt: null,
      ),
    ];
    when(() => source.putAll(any())).thenReturn(null);

    await repository.upsertAll(domainList);

    final captured =
        verify(() => source.putAll(captureAny())).captured.single
            as List<KanjiProgressEntity>;
    expect(captured.single.literal, '火');
    expect(captured.single.statusIndex, ProgressStatus.mastered.index);
  });
}
