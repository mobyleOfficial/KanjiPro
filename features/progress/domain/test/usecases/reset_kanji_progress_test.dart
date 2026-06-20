import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';

class _MockRepo extends Mock implements ProgressRepository {}

void main() {
  late _MockRepo repository;

  setUpAll(() {
    registerFallbackValue(
      const KanjiProgress(
        literal: 'x',
        level: JlptLevel.n5,
        status: ProgressStatus.learning,
        hitCount: 0,
        timesSeen: 0,
        timesCorrect: 0,
        timesWrong: 0,
        lastSeenAt: null,
      ),
    );
  });

  setUp(() {
    repository = _MockRepo();
    when(() => repository.upsert(any())).thenAnswer((_) async {});
  });

  test('upserts a reset learning record with hitCount 0', () async {
    final useCase = ResetKanjiProgress(repository);

    await useCase(const ResetParams(literal: '日', level: JlptLevel.n5));

    final captured =
        verify(() => repository.upsert(captureAny())).captured.single
            as KanjiProgress;

    expect(captured.literal, '日');
    expect(captured.level, JlptLevel.n5);
    expect(captured.status, ProgressStatus.learning);
    expect(captured.hitCount, 0);
    expect(captured.timesSeen, 0);
    expect(captured.timesCorrect, 0);
    expect(captured.timesWrong, 0);
    expect(captured.lastSeenAt, isNull);
  });

  test('upserts only once per call', () async {
    final useCase = ResetKanjiProgress(repository);

    await useCase(const ResetParams(literal: '月', level: JlptLevel.n4));

    verify(() => repository.upsert(any())).called(1);
  });
}
