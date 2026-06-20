import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ui/home_ui.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progress_domain/progress_domain.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockKanjiRepository extends Mock implements KanjiRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockKanjiRepository kanjiRepository;
  late MockProgressRepository progressRepository;
  late GetAllLevels getAllLevels;
  late GetLevelProgress getLevelProgress;

  const levels = JlptLevel.values;

  setUp(() {
    kanjiRepository = MockKanjiRepository();
    progressRepository = MockProgressRepository();
    getAllLevels = GetAllLevels(kanjiRepository);
    getLevelProgress = GetLevelProgress(progressRepository);

    // GetAllLevels returns all 5 levels
    when(() => kanjiRepository.getLevels()).thenAnswer(
      (_) async => const Success(JlptLevel.values),
    );

    // GetLevelProgress: returns empty progress for each level
    for (final level in levels) {
      when(() => progressRepository.forLevel(level)).thenAnswer(
        (_) async => [],
      );
    }
  });

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeSuccess] when load() succeeds',
      build: () => HomeCubit(
        getAllLevels: getAllLevels,
        getLevelProgress: getLevelProgress,
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeSuccess>().having(
          (state) => state.levels.length,
          'levels count',
          JlptLevel.values.length,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeSuccess] with correct percent when mastery data present',
      setUp: () {
        // n5: 5 of 10 mastered → 50%
        when(() => progressRepository.forLevel(JlptLevel.n5)).thenAnswer(
          (_) async => List.generate(
            10,
            (i) => KanjiProgress(
              literal: '字$i',
              level: JlptLevel.n5,
              status: i < 5 ? ProgressStatus.mastered : ProgressStatus.locked,
              hitCount: i < 5 ? 10 : 0,
              timesSeen: i < 5 ? 10 : 0,
              timesCorrect: i < 5 ? 10 : 0,
              timesWrong: 0,
              lastSeenAt: null,
            ),
          ),
        );
      },
      build: () => HomeCubit(
        getAllLevels: getAllLevels,
        getLevelProgress: getLevelProgress,
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeSuccess>().having(
          (state) =>
              state.levels.firstWhere((l) => l.level == JlptLevel.n5).percent,
          'n5 percent',
          0.5,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when GetAllLevels fails',
      setUp: () {
        when(() => kanjiRepository.getLevels()).thenAnswer(
          (_) async => const FailureResult(DataFailure('load error')),
        );
      },
      build: () => HomeCubit(
        getAllLevels: getAllLevels,
        getLevelProgress: getLevelProgress,
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>().having((e) => e.message, 'message', 'load error'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when GetLevelProgress throws',
      setUp: () {
        when(() => progressRepository.forLevel(JlptLevel.n5))
            .thenThrow(Exception('db error'));
      },
      build: () => HomeCubit(
        getAllLevels: getAllLevels,
        getLevelProgress: getLevelProgress,
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>(),
      ],
    );
  });
}
