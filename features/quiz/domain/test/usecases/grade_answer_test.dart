import 'package:kanji_domain/kanji_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const kanji = Kanji(
    literal: '日',
    onReadings: ['ニチ'],
    kunReadings: ['ひ'],
    meanings: ['day'],
    jlptLevel: JlptLevel.n5,
    strokeCount: 4,
  );

  test('answersOf returns mode-specific answers', () {
    expect(QuizMode.onReading.answersOf(kanji), ['ニチ']);
    expect(QuizMode.kunReading.answersOf(kanji), ['ひ']);
    expect(QuizMode.meaning.answersOf(kanji), ['day']);
  });

  test('GradeAnswer compares selected vs correct index', () {
    final question = QuizQuestion(
      kanji: kanji,
      mode: QuizMode.meaning,
      options: const ['day', 'one', 'water', 'fire'],
      correctIndex: 0,
    );
    expect(
      GradeAnswer()(GradeParams(question: question, selectedIndex: 0)),
      true,
    );
    expect(
      GradeAnswer()(GradeParams(question: question, selectedIndex: 2)),
      false,
    );
  });
}
