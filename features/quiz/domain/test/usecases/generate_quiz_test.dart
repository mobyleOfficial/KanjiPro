import 'dart:math';

import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Kanji k(String literal, String meaning) => Kanji(
  literal: literal,
  onReadings: ['オ$literal'],
  kunReadings: ['ku$literal'],
  meanings: [meaning],
  jlptLevel: JlptLevel.n5,
  strokeCount: 1,
);

KanjiProgress prog(String literal) => KanjiProgress(
  literal: literal,
  level: JlptLevel.n5,
  status: ProgressStatus.learning,
  hitCount: 0,
  timesSeen: 0,
  timesCorrect: 0,
  timesWrong: 0,
  lastSeenAt: null,
);

void main() {
  test(
    'builds a 4-option meaning question with the correct answer present',
    () {
      final kanji = [
        k('日', 'day'),
        k('一', 'one'),
        k('水', 'water'),
        k('火', 'fire'),
        k('木', 'tree'),
      ];
      final pool = kanji.map((e) => prog(e.literal)).toList();
      final question = GenerateQuiz(SelectNextKanji())(
        GenerateParams(
          levelKanji: kanji,
          pool: pool,
          mode: QuizMode.meaning,
          lastShown: null,
          random: Random(7),
        ),
      )!;
      expect(question.options.length, 4);
      expect(question.options.toSet().length, 4); // unique
      expect(
        question.options[question.correctIndex],
        question.kanji.meanings.first,
      );
    },
  );
}
