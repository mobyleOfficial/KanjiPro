import 'package:kanji_domain/kanji_domain.dart';

import 'progress_status.dart';

class KanjiProgress {
  const KanjiProgress({
    required this.literal,
    required this.level,
    required this.status,
    required this.hitCount,
    required this.timesSeen,
    required this.timesCorrect,
    required this.timesWrong,
    required this.lastSeenAt,
  });

  final String literal;
  final JlptLevel level;
  final ProgressStatus status;
  final int hitCount;
  final int timesSeen;
  final int timesCorrect;
  final int timesWrong;
  final DateTime? lastSeenAt;

  KanjiProgress copyWith({
    String? literal,
    JlptLevel? level,
    ProgressStatus? status,
    int? hitCount,
    int? timesSeen,
    int? timesCorrect,
    int? timesWrong,
    DateTime? lastSeenAt,
  }) => KanjiProgress(
    literal: literal ?? this.literal,
    level: level ?? this.level,
    status: status ?? this.status,
    hitCount: hitCount ?? this.hitCount,
    timesSeen: timesSeen ?? this.timesSeen,
    timesCorrect: timesCorrect ?? this.timesCorrect,
    timesWrong: timesWrong ?? this.timesWrong,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
}
