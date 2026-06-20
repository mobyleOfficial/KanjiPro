import 'package:kanji_domain/kanji_domain.dart';
import 'package:objectbox/objectbox.dart';
import 'package:progress_domain/progress_domain.dart';

@Entity()
class KanjiProgressEntity {
  KanjiProgressEntity({
    this.id = 0,
    required this.literal,
    required this.levelId,
    required this.statusIndex,
    required this.hitCount,
    required this.timesSeen,
    required this.timesCorrect,
    required this.timesWrong,
    this.lastSeenMs,
  });

  @Id()
  int id;

  @Unique()
  String literal;

  String levelId;
  int statusIndex;
  int hitCount;
  int timesSeen;
  int timesCorrect;
  int timesWrong;
  int? lastSeenMs;

  factory KanjiProgressEntity.fromDomain(KanjiProgress progress) =>
      KanjiProgressEntity(
        literal: progress.literal,
        levelId: progress.level.id,
        statusIndex: progress.status.index,
        hitCount: progress.hitCount,
        timesSeen: progress.timesSeen,
        timesCorrect: progress.timesCorrect,
        timesWrong: progress.timesWrong,
        lastSeenMs: progress.lastSeenAt?.millisecondsSinceEpoch,
      );

  KanjiProgress toDomain() => KanjiProgress(
    literal: literal,
    level: JlptLevel.fromId(levelId),
    status: ProgressStatus.values[statusIndex],
    hitCount: hitCount,
    timesSeen: timesSeen,
    timesCorrect: timesCorrect,
    timesWrong: timesWrong,
    lastSeenAt: lastSeenMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastSeenMs!),
  );
}
