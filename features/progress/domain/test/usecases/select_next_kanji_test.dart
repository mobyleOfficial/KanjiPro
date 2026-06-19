import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

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
  test('only mastered + learning are eligible, never locked', () {
    final pool = [
      p('L', ProgressStatus.locked, 0),
      p('A', ProgressStatus.learning, 2),
    ];
    final picks = {
      for (var i = 0; i < 50; i++)
        SelectNextKanji()(
          SelectParams(pool: pool, lastShown: null, random: Random(i)),
        ),
    };
    expect(picks, isNot(contains('L')));
    expect(picks, contains('A'));
  });

  test('lower hitCount is favored over higher across many draws', () {
    final pool = [
      p('LOW', ProgressStatus.learning, 0),
      p('HIGH', ProgressStatus.learning, kMasteryTarget - 1),
    ];
    var low = 0;
    for (var i = 0; i < 400; i++) {
      if (SelectNextKanji()(
            SelectParams(pool: pool, lastShown: null, random: Random(i)),
          ) ==
          'LOW') {
        low++;
      }
    }
    expect(low, greaterThan(200)); // weighted toward LOW
  });

  test('returns null for empty/all-locked pool', () {
    expect(
      SelectNextKanji()(
        SelectParams(
          pool: [p('L', ProgressStatus.locked, 0)],
          lastShown: null,
          random: Random(1),
        ),
      ),
      isNull,
    );
  });
}
