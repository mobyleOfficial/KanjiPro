import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';

class _MockRepo extends Mock implements ProgressRepository {}

Kanji kanji(String literal) => Kanji(
  literal: literal,
  onReadings: [],
  kunReadings: [],
  meanings: [],
  jlptLevel: JlptLevel.n5,
  strokeCount: 1,
);

KanjiProgress locked(String literal) => KanjiProgress(
  literal: literal,
  level: JlptLevel.n5,
  status: ProgressStatus.locked,
  hitCount: 0,
  timesSeen: 0,
  timesCorrect: 0,
  timesWrong: 0,
  lastSeenAt: null,
);

void main() {
  setUpAll(() => registerFallbackValue(locked('x')));

  test('empty repo + 15 kanji → first 10 learning, rest locked', () async {
    final repo = _MockRepo();
    when(() => repo.forLevel(JlptLevel.n5)).thenAnswer((_) async => []);
    when(() => repo.upsertAll(any())).thenAnswer((_) async {});

    final levelKanji = List.generate(
      15,
      (i) => kanji(String.fromCharCode(0x4E00 + i)),
    );

    final pool = await EnsurePoolInitialized(repo)(
      EnsureParams(level: JlptLevel.n5, levelKanji: levelKanji),
    );

    expect(pool.length, 15);
    final learningCount = pool
        .where((p) => p.status == ProgressStatus.learning)
        .length;
    final lockedCount = pool
        .where((p) => p.status == ProgressStatus.locked)
        .length;
    expect(learningCount, kActivePoolSize); // first 10
    expect(lockedCount, 5); // remaining 5
    // First 10 are learning, last 5 are locked (level order preserved).
    for (var i = 0; i < 10; i++) {
      expect(pool[i].status, ProgressStatus.learning);
    }
    for (var i = 10; i < 15; i++) {
      expect(pool[i].status, ProgressStatus.locked);
    }
  });
}
