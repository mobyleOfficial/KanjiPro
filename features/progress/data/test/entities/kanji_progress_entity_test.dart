import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_data/progress_data.dart';
import 'package:progress_domain/progress_domain.dart';

void main() {
  test('round-trips domain <-> entity with null lastSeenAt', () {
    final domain = KanjiProgress(
      literal: '日',
      level: JlptLevel.n5,
      status: ProgressStatus.learning,
      hitCount: 3,
      timesSeen: 5,
      timesCorrect: 4,
      timesWrong: 1,
      lastSeenAt: null,
    );
    final entity = KanjiProgressEntity.fromDomain(domain);
    final back = entity.toDomain();

    expect(back.literal, '日');
    expect(back.level, JlptLevel.n5);
    expect(back.status, ProgressStatus.learning);
    expect(back.hitCount, 3);
    expect(back.timesSeen, 5);
    expect(back.timesCorrect, 4);
    expect(back.timesWrong, 1);
    expect(back.lastSeenAt, isNull);
  });

  test('round-trips domain <-> entity with non-null lastSeenAt', () {
    final lastSeen = DateTime.utc(2024, 6, 1, 12);
    final domain = KanjiProgress(
      literal: '水',
      level: JlptLevel.n4,
      status: ProgressStatus.mastered,
      hitCount: 10,
      timesSeen: 12,
      timesCorrect: 11,
      timesWrong: 1,
      lastSeenAt: lastSeen,
    );
    final entity = KanjiProgressEntity.fromDomain(domain);

    expect(entity.lastSeenMs, lastSeen.millisecondsSinceEpoch);

    final back = entity.toDomain();
    expect(back.level, JlptLevel.n4);
    expect(back.status, ProgressStatus.mastered);
    expect(
      back.lastSeenAt?.millisecondsSinceEpoch,
      lastSeen.millisecondsSinceEpoch,
    );
  });

  test('fromDomain preserves id=0 by default', () {
    final domain = KanjiProgress(
      literal: '火',
      level: JlptLevel.n3,
      status: ProgressStatus.locked,
      hitCount: 0,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
      lastSeenAt: null,
    );
    final entity = KanjiProgressEntity.fromDomain(domain);
    expect(entity.id, 0);
    expect(entity.statusIndex, ProgressStatus.locked.index);
  });
}
