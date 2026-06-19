import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';

class _MockRepo extends Mock implements ProgressRepository {}

KanjiProgress p(String literal, ProgressStatus status, int hitCount) =>
    KanjiProgress(
      literal: literal,
      level: JlptLevel.n5,
      status: status,
      hitCount: hitCount,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
      lastSeenAt: null,
    );

void main() {
  setUpAll(() => registerFallbackValue(p('x', ProgressStatus.locked, 0)));

  test('correct at target-1 masters kanji and promotes a locked one', () async {
    final repo = _MockRepo();
    when(() => repo.upsertAll(any())).thenAnswer((_) async {});
    final pool = [
      p('A', ProgressStatus.learning, kMasteryTarget - 1),
      p('B', ProgressStatus.locked, 0),
    ];
    final out = await RecordAnswer(repo)(
      RecordParams(pool: pool, literal: 'A', correct: true),
    );
    final a = out.firstWhere((e) => e.literal == 'A');
    final b = out.firstWhere((e) => e.literal == 'B');
    expect(a.status, ProgressStatus.mastered);
    expect(a.hitCount, kMasteryTarget);
    expect(b.status, ProgressStatus.learning); // refilled
  });

  test('incorrect on mastered demotes and clamps, increments wrong', () async {
    final repo = _MockRepo();
    when(() => repo.upsertAll(any())).thenAnswer((_) async {});
    final pool = [p('A', ProgressStatus.mastered, kMasteryTarget)];
    final out = await RecordAnswer(repo)(
      RecordParams(pool: pool, literal: 'A', correct: false),
    );
    final a = out.single;
    expect(a.status, ProgressStatus.learning);
    expect(a.hitCount, kMasteryTarget - 1);
    expect(a.timesWrong, 1);
  });

  test('incorrect floors hitCount at 0', () async {
    final repo = _MockRepo();
    when(() => repo.upsertAll(any())).thenAnswer((_) async {});
    final pool = [p('A', ProgressStatus.learning, 0)];
    final out = await RecordAnswer(repo)(
      RecordParams(pool: pool, literal: 'A', correct: false),
    );
    expect(out.single.hitCount, 0);
  });
}
