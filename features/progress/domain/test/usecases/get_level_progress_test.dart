import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';

class _MockRepo extends Mock implements ProgressRepository {}

KanjiProgress _p(String literal, ProgressStatus status) => KanjiProgress(
  literal: literal,
  level: JlptLevel.n5,
  status: status,
  hitCount: 0,
  timesSeen: 0,
  timesCorrect: 0,
  timesWrong: 0,
  lastSeenAt: null,
);

void main() {
  test('GetLevelProgress aggregates counts and percent correctly', () async {
    final repo = _MockRepo();
    final records = [
      _p('A', ProgressStatus.mastered),
      _p('B', ProgressStatus.mastered),
      _p('C', ProgressStatus.learning),
      _p('D', ProgressStatus.learning),
      _p('E', ProgressStatus.learning),
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
    expect(result.percent, 0.2);
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
