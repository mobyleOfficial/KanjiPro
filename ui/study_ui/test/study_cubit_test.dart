import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_ui/study_ui.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockKanjiRepository extends Mock implements KanjiRepository {}

class MockTtsService extends Mock implements TtsService {}

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

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  late MockKanjiRepository kanjiRepository;
  late MockTtsService ttsService;
  late GetKanjiByLevel getKanjiByLevel;

  setUpAll(() {
    registerFallbackValue(JlptLevel.n5);
  });

  setUp(() {
    kanjiRepository = MockKanjiRepository();
    ttsService = MockTtsService();
    getKanjiByLevel = GetKanjiByLevel(kanjiRepository);
  });

  group('StudyCubit', () {
    blocTest<StudyCubit, StudyState>(
      'emits [StudyLoading, StudySuccess] when load() succeeds',
      setUp: () {
        when(() => kanjiRepository.getByLevel(JlptLevel.n5)).thenAnswer(
          (_) async => const Success(_sampleKanji),
        );
      },
      build: () => StudyCubit(
        getKanjiByLevel: getKanjiByLevel,
        ttsService: ttsService,
      ),
      act: (cubit) => cubit.load(JlptLevel.n5),
      expect: () => [
        isA<StudyLoading>(),
        isA<StudySuccess>().having(
          (state) => state.kanji,
          'kanji list',
          _sampleKanji,
        ),
      ],
    );

    blocTest<StudyCubit, StudyState>(
      'emits [StudyLoading, StudyError] when load() fails',
      setUp: () {
        when(() => kanjiRepository.getByLevel(JlptLevel.n5)).thenAnswer(
          (_) async =>
              const FailureResult(DataFailure('failed to load kanji')),
        );
      },
      build: () => StudyCubit(
        getKanjiByLevel: getKanjiByLevel,
        ttsService: ttsService,
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

    test('speak() delegates to TtsService', () async {
      when(() => kanjiRepository.getByLevel(any())).thenAnswer(
        (_) async => const Success(_sampleKanji),
      );
      when(() => ttsService.speak(any())).thenAnswer((_) async {});

      final cubit = StudyCubit(
        getKanjiByLevel: getKanjiByLevel,
        ttsService: ttsService,
      );

      await cubit.speak('ニチ');

      verify(() => ttsService.speak('ニチ')).called(1);
      cubit.close();
    });

    test('ttsAvailable() reflects TtsService.isJapaneseAvailable()', () async {
      when(() => ttsService.isJapaneseAvailable()).thenAnswer((_) async => true);

      final cubit = StudyCubit(
        getKanjiByLevel: getKanjiByLevel,
        ttsService: ttsService,
      );

      final result = await cubit.ttsAvailable();

      expect(result, isTrue);
      verify(() => ttsService.isJapaneseAvailable()).called(1);
      cubit.close();
    });

    test(
        'ttsAvailable() returns false when TtsService.isJapaneseAvailable() returns false',
        () async {
      when(() => ttsService.isJapaneseAvailable())
          .thenAnswer((_) async => false);

      final cubit = StudyCubit(
        getKanjiByLevel: getKanjiByLevel,
        ttsService: ttsService,
      );

      final result = await cubit.ttsAvailable();

      expect(result, isFalse);
      cubit.close();
    });
  });
}
