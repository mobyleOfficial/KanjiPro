import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';

class _MockRepo extends Mock implements ProgressRepository {}

KanjiProgress _p(String literal, ProgressStatus status, {int hitCount = 0}) =>
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
  test('GetLevelProgress aggregates counts and cumulative percent', () async {
    final repo = _MockRepo();
    // 2 mastered (10 hits each = 20) + 3 learning (5 hits each = 15) + 5 locked.
    // totalHits = 35; total = 10; percent = 35 / (10 * kMasteryTarget=10) = 0.35.
    final records = [
      _p('A', ProgressStatus.mastered, hitCount: 10),
      _p('B', ProgressStatus.mastered, hitCount: 10),
      _p('C', ProgressStatus.learning, hitCount: 5),
      _p('D', ProgressStatus.learning, hitCount: 5),
      _p('E', ProgressStatus.learning, hitCount: 5),
      _p('F', ProgressStatus.locked),
      _p('G', ProgressStatus.locked),
      _p('H', ProgressStatus.locked),
      _p('I', ProgressStatus.locked),
      _p('J', ProgressStatus.locked),
    ];
    when(() => repo.forLevel(JlptLevel.n5)).thenAnswer((_) async => records);

    final result = await GetLevelProgress(repo)(JlptLevel.n5);

    expect(result.mastered, 2);
    expect(result.learning, 3);
    expect(result.locked, 5);
    expect(result.total, 10);
    expect(result.totalHits, 35);
    expect(result.percent, closeTo(0.35, 1e-9));
  });

  test('partial progress (no full mastery) still yields non-zero percent',
      () async {
    final repo = _MockRepo();
    final records = [
      _p('A', ProgressStatus.learning, hitCount: 3),
      _p('B', ProgressStatus.learning, hitCount: 2),
      _p('C', ProgressStatus.locked),
    ];
    when(() => repo.forLevel(JlptLevel.n5)).thenAnswer((_) async => records);

    final result = await GetLevelProgress(repo)(JlptLevel.n5);

    expect(result.mastered, 0);
    expect(result.totalHits, 5);
    expect(result.percent, greaterThan(0));
  });

  test('GetLevelProgress returns percent 0 for empty list', () async {
    final repo = _MockRepo();
    when(() => repo.forLevel(JlptLevel.n5)).thenAnswer((_) async => []);

    final result = await GetLevelProgress(repo)(JlptLevel.n5);

    expect(result.mastered, 0);
    expect(result.learning, 0);
    expect(result.locked, 0);
    expect(result.total, 0);
    expect(result.percent, 0.0);
  });
}
