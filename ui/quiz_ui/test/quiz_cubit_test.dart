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

KanjiProgress _progress(String literal, {int hitCount = 0}) => KanjiProgress(
  literal: literal,
  level: JlptLevel.n5,
  status: ProgressStatus.learning,
  hitCount: hitCount,
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
    when(
      () => mockGetKanji(any()),
    ).thenAnswer((_) async => Success<List<Kanji>>(levelKanjiList));
    when(() => mockEnsure(any())).thenAnswer((_) async => poolList);
    when(() => mockRecordAnswer(any())).thenAnswer((_) async => poolList);
  });

  QuizCubit makeCubit() => QuizCubit(
    ensurePoolInitialized: mockEnsure,
    getKanjiByLevel: mockGetKanji,
    generateQuiz: mockGenerateQuiz,
    gradeAnswer: mockGradeAnswer,
    recordAnswer: mockRecordAnswer,
    random: Random(42),
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
    expect: () => [isA<QuizLoading>(), isA<QuizQuestionState>()],
  );

  // ── answering correctly advances + currentKanjiHits reflects hitCount ───

  blocTest<QuizCubit, QuizState>(
    'answer correct shows answered state with lastCorrect=true and reflects currentKanjiHits',
    build: () {
      final question = _question(levelKanjiList[0], correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(true);
      // Pool updated: 一 now has hitCount=1
      final updatedPool = [
        _progress('一', hitCount: 1),
        _progress('二'),
        _progress('三'),
      ];
      when(() => mockRecordAnswer(any())).thenAnswer((_) async => updatedPool);
      return makeCubit();
    },
    act: (cubit) async {
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      await cubit.answer(0); // correct
    },
    expect: () => [
      isA<QuizLoading>(),
      isA<QuizQuestionState>()
          .having((s) => s.answered, 'answered', false)
          .having((s) => s.currentKanjiHits, 'currentKanjiHits', 0),
      isA<QuizQuestionState>()
          .having((s) => s.answered, 'answered', true)
          .having((s) => s.lastCorrect, 'lastCorrect', true)
          .having((s) => s.currentKanjiHits, 'currentKanjiHits', 1),
    ],
  );

  // ── wrong answer requeues; missed kanji reappears ────────────────────────

  blocTest<QuizCubit, QuizState>(
    'wrong answer pushes literal to requeue; it reappears on next() call',
    build: () {
      final firstKanji = levelKanjiList[0]; // 一
      final question = _question(firstKanji, correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(false); // always wrong
      return makeCubit();
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

  // ── quiz is INFINITE — never emits a terminal state after many answers ───

  test(
    'quiz is infinite: answering 15 times always stays on QuizQuestionState',
    () async {
      final question = _question(levelKanjiList[0], correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(true);
      when(() => mockRecordAnswer(any())).thenAnswer((_) async => poolList);

      final cubit = makeCubit();
      await cubit.start(JlptLevel.n5, QuizMode.meaning);

      for (var iteration = 0; iteration < 15; iteration++) {
        expect(
          cubit.state,
          isA<QuizQuestionState>(),
          reason: 'Should be in QuizQuestionState before answer $iteration',
        );
        await cubit.answer(0);
        expect(
          cubit.state,
          isA<QuizQuestionState>(),
          reason: 'Should stay QuizQuestionState after answer $iteration',
        );
        await cubit.next();
      }

      expect(
        cubit.state,
        isA<QuizQuestionState>(),
        reason: 'After 15 rounds, quiz must still be active (no finish state)',
      );

      await cubit.close();
    },
  );

  // ── justMastered is true when the 10th correct answer lands ─────────────

  test(
    'justMastered is true when kanji hitCount reaches kMasteryTarget',
    () async {
      final targetKanji = levelKanjiList[0]; // 一
      final question = _question(targetKanji, correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(true);

      // Simulate pool where 一 is at hitCount = kMasteryTarget - 1 before this answer,
      // and RecordAnswer bumps it to kMasteryTarget.
      final poolBeforeFinalHit = [
        _progress('一', hitCount: kMasteryTarget - 1),
        _progress('二'),
        _progress('三'),
      ];
      final poolAfterFinalHit = [
        _progress('一', hitCount: kMasteryTarget),
        _progress('二'),
        _progress('三'),
      ];

      // First start: pool has hitCount = kMasteryTarget - 1 for 一
      when(() => mockEnsure(any())).thenAnswer((_) async => poolBeforeFinalHit);
      // RecordAnswer returns the mastered pool
      when(
        () => mockRecordAnswer(any()),
      ).thenAnswer((_) async => poolAfterFinalHit);

      final cubit = makeCubit();
      await cubit.start(JlptLevel.n5, QuizMode.meaning);

      // Pre-answer state: currentKanjiHits should be kMasteryTarget - 1
      final preAnswerState = cubit.state as QuizQuestionState;
      expect(preAnswerState.currentKanjiHits, equals(kMasteryTarget - 1));
      expect(preAnswerState.justMastered, isFalse);

      await cubit.answer(0);

      final postAnswerState = cubit.state as QuizQuestionState;
      expect(postAnswerState.currentKanjiHits, equals(kMasteryTarget));
      expect(
        postAnswerState.justMastered,
        isTrue,
        reason:
            'justMastered must be true when hitCount reaches kMasteryTarget',
      );

      await cubit.close();
    },
  );

  // ── justMastered is false when already mastered ──────────────────────────

  test(
    'justMastered is false when kanji was already at kMasteryTarget',
    () async {
      final targetKanji = levelKanjiList[0];
      final question = _question(targetKanji, correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(true);

      // Already mastered before this answer
      final alreadyMasteredPool = [
        _progress('一', hitCount: kMasteryTarget),
        _progress('二'),
        _progress('三'),
      ];
      when(
        () => mockEnsure(any()),
      ).thenAnswer((_) async => alreadyMasteredPool);
      when(
        () => mockRecordAnswer(any()),
      ).thenAnswer((_) async => alreadyMasteredPool);

      final cubit = makeCubit();
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      await cubit.answer(0);

      final postAnswerState = cubit.state as QuizQuestionState;
      expect(
        postAnswerState.justMastered,
        isFalse,
        reason:
            'justMastered must be false when already at target before answering',
      );

      await cubit.close();
    },
  );

  // ── selectedIndex is set after answering ────────────────────────────────

  blocTest<QuizCubit, QuizState>(
    'answer sets selectedIndex to the tapped option index',
    build: () {
      final question = _question(levelKanjiList[0], correctIndex: 0);
      when(() => mockGenerateQuiz(any())).thenReturn(question);
      when(() => mockGradeAnswer(any())).thenReturn(false); // wrong
      return makeCubit();
    },
    act: (cubit) async {
      await cubit.start(JlptLevel.n5, QuizMode.meaning);
      await cubit.answer(2); // tap option 2 (wrong)
    },
    expect: () => [
      isA<QuizLoading>(),
      isA<QuizQuestionState>()
          .having((s) => s.answered, 'answered', false)
          .having((s) => s.selectedIndex, 'selectedIndex', isNull),
      isA<QuizQuestionState>()
          .having((s) => s.answered, 'answered', true)
          .having((s) => s.selectedIndex, 'selectedIndex', 2)
          .having((s) => s.lastCorrect, 'lastCorrect', false),
    ],
  );
}
