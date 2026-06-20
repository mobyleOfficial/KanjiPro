import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';
import 'package:study_ui/study_ui.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockKanjiRepository extends Mock implements KanjiRepository {}

class MockTtsService extends Mock implements TtsService {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockResetKanjiProgress extends Mock implements ResetKanjiProgress {}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _sampleKanji = [
  Kanji(
    literal: '日',
    onReadings: ['ニチ', 'ジツ'],
    kunReadings: ['ひ', 'か'],
    meanings: ['sun', 'day'],
    jlptLevel: JlptLevel.n5,
    strokeCount: 4,
  ),
  Kanji(
    literal: '月',
    onReadings: ['ゲツ', 'ガツ'],
    kunReadings: ['つき'],
    meanings: ['moon', 'month'],
    jlptLevel: JlptLevel.n5,
    strokeCount: 4,
  ),
];

KanjiProgress _progress(String literal) => KanjiProgress(
  literal: literal,
  level: JlptLevel.n5,
  status: ProgressStatus.learning,
  hitCount: 3,
  timesSeen: 5,
  timesCorrect: 3,
  timesWrong: 2,
  lastSeenAt: null,
);

StudyCubit _buildCubit({
  required KanjiRepository kanjiRepository,
  required MockTtsService ttsService,
  required MockProgressRepository progressRepository,
  required MockResetKanjiProgress resetKanjiProgress,
}) => StudyCubit(
  getKanjiByLevel: GetKanjiByLevel(kanjiRepository),
  ttsService: ttsService,
  progressRepository: progressRepository,
  resetKanjiProgress: resetKanjiProgress,
);

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  late MockKanjiRepository kanjiRepository;
  late MockTtsService ttsService;
  late MockProgressRepository progressRepository;
  late MockResetKanjiProgress resetKanjiProgress;

  setUpAll(() {
    registerFallbackValue(JlptLevel.n5);
    registerFallbackValue(const ResetParams(literal: 'x', level: JlptLevel.n5));
  });

  setUp(() {
    kanjiRepository = MockKanjiRepository();
    ttsService = MockTtsService();
    progressRepository = MockProgressRepository();
    resetKanjiProgress = MockResetKanjiProgress();
  });

  group('StudyCubit.load', () {
    blocTest<StudyCubit, StudyState>(
      'emits [StudyLoading, StudySuccess] with progressByLiteral when load() succeeds',
      setUp: () {
        when(
          () => kanjiRepository.getByLevel(JlptLevel.n5),
        ).thenAnswer((_) async => const Success(_sampleKanji));
        when(
          () => progressRepository.forLevel(JlptLevel.n5),
        ).thenAnswer((_) async => [_progress('日')]);
      },
      build: () => _buildCubit(
        kanjiRepository: kanjiRepository,
        ttsService: ttsService,
        progressRepository: progressRepository,
        resetKanjiProgress: resetKanjiProgress,
      ),
      act: (cubit) => cubit.load(JlptLevel.n5),
      expect: () => [
        isA<StudyLoading>(),
        isA<StudySuccess>()
            .having((state) => state.kanji, 'kanji list', _sampleKanji)
            .having(
              (state) => state.progressByLiteral.containsKey('日'),
              'has progress for 日',
              isTrue,
            )
            .having(
              (state) => state.progressByLiteral.containsKey('月'),
              'no progress for 月',
              isFalse,
            ),
      ],
    );

    blocTest<StudyCubit, StudyState>(
      'emits [StudyLoading, StudyError] when load() fails',
      setUp: () {
        when(() => kanjiRepository.getByLevel(JlptLevel.n5)).thenAnswer(
          (_) async => const FailureResult(DataFailure('failed to load kanji')),
        );
      },
      build: () => _buildCubit(
        kanjiRepository: kanjiRepository,
        ttsService: ttsService,
        progressRepository: progressRepository,
        resetKanjiProgress: resetKanjiProgress,
      ),
      act: (cubit) => cubit.load(JlptLevel.n5),
      expect: () => [
        isA<StudyLoading>(),
        isA<StudyError>().having(
          (state) => state.message,
          'error message',
          'failed to load kanji',
        ),
      ],
    );
  });

  group('StudyCubit.resetKanji', () {
    blocTest<StudyCubit, StudyState>(
      'calls ResetKanjiProgress and re-emits StudySuccess with refreshed progress',
      setUp: () {
        when(
          () => kanjiRepository.getByLevel(JlptLevel.n5),
        ).thenAnswer((_) async => const Success(_sampleKanji));
        // First forLevel call (during load) returns a record with hitCount 3.
        // Second forLevel call (after reset) returns a record with hitCount 0.
        var callCount = 0;
        when(() => progressRepository.forLevel(JlptLevel.n5)).thenAnswer((
          _,
        ) async {
          callCount++;
          if (callCount == 1) return [_progress('日')];
          return [
            KanjiProgress(
              literal: '日',
              level: JlptLevel.n5,
              status: ProgressStatus.learning,
              hitCount: 0,
              timesSeen: 0,
              timesCorrect: 0,
              timesWrong: 0,
              lastSeenAt: null,
            ),
          ];
        });
        when(() => resetKanjiProgress(any())).thenAnswer((_) async {});
      },
      build: () => _buildCubit(
        kanjiRepository: kanjiRepository,
        ttsService: ttsService,
        progressRepository: progressRepository,
        resetKanjiProgress: resetKanjiProgress,
      ),
      act: (cubit) async {
        await cubit.load(JlptLevel.n5);
        await cubit.resetKanji('日');
      },
      expect: () => [
        isA<StudyLoading>(),
        // After load — hitCount 3
        isA<StudySuccess>().having(
          (state) => state.progressByLiteral['日']?.hitCount,
          'hitCount after load',
          3,
        ),
        // After reset — hitCount 0
        isA<StudySuccess>().having(
          (state) => state.progressByLiteral['日']?.hitCount,
          'hitCount after reset',
          0,
        ),
      ],
      verify: (_) {
        verify(() => resetKanjiProgress(any())).called(1);
      },
    );

    test('resetKanji is a no-op when called before load', () async {
      // No mocks needed — load() was never called, so _currentLevel is null.
      final cubit = _buildCubit(
        kanjiRepository: kanjiRepository,
        ttsService: ttsService,
        progressRepository: progressRepository,
        resetKanjiProgress: resetKanjiProgress,
      );

      await cubit.resetKanji('日');

      verifyNever(() => resetKanjiProgress(any()));
      cubit.close();
    });
  });

  group('StudyCubit TTS', () {
    test('speak() delegates to TtsService', () async {
      when(
        () => kanjiRepository.getByLevel(any()),
      ).thenAnswer((_) async => const Success(_sampleKanji));
      when(() => ttsService.speak(any())).thenAnswer((_) async {});

      final cubit = _buildCubit(
        kanjiRepository: kanjiRepository,
        ttsService: ttsService,
        progressRepository: progressRepository,
        resetKanjiProgress: resetKanjiProgress,
      );

      await cubit.speak('ニチ');

      verify(() => ttsService.speak('ニチ')).called(1);
      cubit.close();
    });

    test('ttsAvailable() reflects TtsService.isJapaneseAvailable()', () async {
      when(
        () => ttsService.isJapaneseAvailable(),
      ).thenAnswer((_) async => true);

      final cubit = _buildCubit(
        kanjiRepository: kanjiRepository,
        ttsService: ttsService,
        progressRepository: progressRepository,
        resetKanjiProgress: resetKanjiProgress,
      );

      final result = await cubit.ttsAvailable();

      expect(result, isTrue);
      verify(() => ttsService.isJapaneseAvailable()).called(1);
      cubit.close();
    });

    test(
      'ttsAvailable() returns false when TtsService.isJapaneseAvailable() returns false',
      () async {
        when(
          () => ttsService.isJapaneseAvailable(),
        ).thenAnswer((_) async => false);

        final cubit = _buildCubit(
          kanjiRepository: kanjiRepository,
          ttsService: ttsService,
          progressRepository: progressRepository,
          resetKanjiProgress: resetKanjiProgress,
        );

        final result = await cubit.ttsAvailable();

        expect(result, isFalse);
        cubit.close();
      },
    );
  });
}
