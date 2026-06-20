import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui/quiz_ui.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockEnsurePoolInitialized extends Mock implements EnsurePoolInitialized {}

class MockGetKanjiByLevel extends Mock implements GetKanjiByLevel {}

class MockGenerateQuiz extends Mock implements GenerateQuiz {}

class MockGradeAnswer extends Mock implements GradeAnswer {}

class MockRecordAnswer extends Mock implements RecordAnswer {}

// ── Fakes / fallback values ────────────────────────────────────────────────

class FakeEnsureParams extends Fake implements EnsureParams {}

class FakeGenerateParams extends Fake implements GenerateParams {}

class FakeGradeParams extends Fake implements GradeParams {}

class FakeRecordParams extends Fake implements RecordParams {}

// ── Helpers ────────────────────────────────────────────────────────────────

Kanji _kanji(String literal, {String meaning = ''}) => Kanji(
      literal: literal,
      onReadings: const [],
      kunReadings: const [],
      meanings: [if (meaning.isEmpty) literal else meaning],
      jlptLevel: JlptLevel.n5,
      strokeCount: 1,
    );

KanjiProgress _progress(String literal) => KanjiProgress(
      literal: literal,
      level: JlptLevel.n5,
      status: ProgressStatus.learning,
      hitCount: 0,
      timesSeen: 0,
      timesCorrect: 0,
      timesWrong: 0,
      lastSeenAt: null,
    );

QuizQuestion _question(Kanji kanji, {int correctIndex = 0}) => QuizQuestion(
      kanji: kanji,
      mode: QuizMode.meaning,
      options: const ['a', 'b', 'c', 'd'],
      correctIndex: correctIndex,
    );

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEnsureParams());
    registerFallbackValue(FakeGenerateParams());
    registerFallbackValue(FakeGradeParams());
    registerFallbackValue(FakeRecordParams());
    registerFallbackValue(JlptLevel.n5);
  });

  late MockEnsurePoolInitialized mockEnsure;
  late MockGetKanjiByLevel mockGetKanji;
  late MockGenerateQuiz mockGenerateQuiz;
  late MockGradeAnswer mockGradeAnswer;
  late MockRecordAnswer mockRecordAnswer;

  final levelKanjiList = [
    _kanji('一', meaning: 'one'),
    _kanji('二', meaning: 'two'),
    _kanji('三', meaning: 'three'),
  ];
  final poolList = levelKanjiList.map((k) => _progress(k.literal)).toList();

  setUp(() {
    mockEnsure = MockEnsurePoolInitialized();
    mockGetKanji = MockGetKanjiByLevel();
    mockGenerateQuiz = MockGenerateQuiz();
    mockGradeAnswer = MockGradeAnswer();
    mockRecordAnswer = MockRecordAnswer();

    // Default stubs
    when(() => mockGetKanji(any())).thenAnswer(
      (_) async => Success<List<Kanji>>(levelKanjiList),
    );
    when(() => mockEnsure(any())).thenAnswer((_) async => poolList);
    when(() => mockRecordAnswer(any())).thenAnswer((_) async => poolList);
  });

  QuizCubit makeCubit({int sessionLength = 3}) => QuizCubit(
        ensurePoolInitialized: mockEnsure,
        getKanjiByLevel: mockGetKanji,
        generateQuiz: mockGenerateQuiz,
        gradeAnswer: mockGradeAnswer,
        recordAnswer: mockRecordAnswer,
        random: Random(42),
        sessionLength: sessionLength,
      );

  // ── start → emits Loading then a QuizQuestionState ──────────────────────

  blocTest<QuizCubit, QuizState>(
    'start emits QuizLoading then QuizQuestionState',
    build: () {
      final question = _question(levelKanjiList[0]);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      return makeCubit();
    },
    act: (cubit) => cubit.start(JlptLevel.n5, QuizMode.meaning),
    expect: () => [
      isA<QuizLoading>(),
      isA<QuizQuestionState>(),
    ],
  );

  // ── answering correctly increments correct + advances ────────────────────

  blocTest<QuizCubit, QuizState>(
    'answer correct increments correct count and shows answered state',
    build: () {
      final question = _question(levelKanjiList[0], correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(true);
      return makeCubit();
    },
    act: (cubit) async {
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      await cubit.answer(0); // correct
    },
    expect: () => [
      isA<QuizLoading>(),
      isA<QuizQuestionState>()
          .having((s) => s.answered, 'answered', false),
      isA<QuizQuestionState>()
          .having((s) => s.answered, 'answered', true)
          .having((s) => s.lastCorrect, 'lastCorrect', true),
    ],
  );

  // ── answering wrong pushes to requeue; missed kanji reappears ────────────

  blocTest<QuizCubit, QuizState>(
    'wrong answer pushes literal to requeue; it reappears on next() call',
    build: () {
      final firstKanji = levelKanjiList[0]; // 一
      final question = _question(firstKanji, correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(false); // always wrong
      return makeCubit(sessionLength: 10);
    },
    act: (cubit) async {
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      // answer wrong — 一 should be requeued
      await cubit.answer(1);
      // advance to next question
      await cubit.next();
    },
    verify: (cubit) {
      // After next(), the state should show a question for 一 again
      // (forced via requeue, so literal matches original)
      final state = cubit.state;
      expect(state, isA<QuizQuestionState>());
      final questionState = state as QuizQuestionState;
      expect(
        questionState.question.kanji.literal,
        equals('一'),
        reason: 'Missed kanji 一 should reappear in same session via requeue',
      );
    },
  );

  // ── session ends with QuizFinished after sessionLength answers ───────────

  blocTest<QuizCubit, QuizState>(
    'session emits QuizFinished after sessionLength answers',
    build: () {
      final question = _question(levelKanjiList[0], correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(true);
      return makeCubit(sessionLength: 2);
    },
    act: (cubit) async {
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      // answer 1
      await cubit.answer(0);
      await cubit.next();
      // answer 2
      await cubit.answer(0);
      await cubit.next(); // should emit QuizFinished
    },
    expect: () => [
      isA<QuizLoading>(),
      // Q1 shown
      isA<QuizQuestionState>().having((s) => s.answered, 'answered', false),
      // Q1 answered
      isA<QuizQuestionState>().having((s) => s.answered, 'answered', true),
      // Q2 shown
      isA<QuizQuestionState>().having((s) => s.answered, 'answered', false),
      // Q2 answered
      isA<QuizQuestionState>().having((s) => s.answered, 'answered', true),
      // Session done
      isA<QuizFinished>()
          .having((s) => s.total, 'total', 2)
          .having((s) => s.correct, 'correct', 2),
    ],
  );

  // ── QuizFinished carries correct count ───────────────────────────────────

  blocTest<QuizCubit, QuizState>(
    'QuizFinished reports correct count accurately',
    build: () {
      final question = _question(levelKanjiList[0], correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      // First call correct, second call wrong
      var callCount = 0;
      when(() => mockGradeAnswer(any())).thenAnswer((_) {
        callCount++;
        return callCount == 1; // first correct, subsequent wrong
      });
      return makeCubit(sessionLength: 2);
    },
    act: (cubit) async {
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      await cubit.answer(0); // correct
      await cubit.next();
      await cubit.answer(1); // wrong (and this requeues, but session ends anyway at 2)
      // The requeue only matters if sessionLength > 2; here next() triggers finish
      await cubit.next();
    },
    expect: () => [
      isA<QuizLoading>(),
      isA<QuizQuestionState>(),
      isA<QuizQuestionState>()
          .having((s) => s.lastCorrect, 'lastCorrect', true),
      isA<QuizQuestionState>(),
      isA<QuizQuestionState>()
          .having((s) => s.lastCorrect, 'lastCorrect', false),
      isA<QuizFinished>()
          .having((s) => s.total, 'total', 2)
          .having((s) => s.correct, 'correct', 1),
    ],
  );
}
