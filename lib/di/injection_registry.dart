// Hand-maintained DI registry.
// injectable_generator only scans the root package, so cross-package
// registrations (kanji, progress, quiz, home_ui, study_ui, quiz_ui) are wired
// here manually. Add new feature registrations in dependency order:
//   data source → repository → use cases → UI cubits.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart' as _i_audioplayers;
import 'package:common/common.dart' as _i_common;
import 'package:flutter_tts/flutter_tts.dart' as _i_flutter_tts;
import 'package:get_it/get_it.dart' as _i174;
import 'package:home_ui/home_ui.dart' as _i_home_ui;
import 'package:kanji_data/kanji_data.dart' as _i_kanji_data;
import 'package:kanji_domain/kanji_domain.dart' as _i_kanji_domain;
import 'package:kanji_pro/routes/app_router.dart' as _i_router;
import 'package:objectbox/objectbox.dart' as _i_obx;
import 'package:progress_data/progress_data.dart' as _i_progress_data;
import 'package:progress_domain/progress_domain.dart' as _i_progress_domain;
import 'package:quiz_domain/quiz_domain.dart' as _i_quiz_domain;
import 'package:quiz_ui/quiz_ui.dart' as _i_quiz_ui;
import 'package:study_ui/study_ui.dart' as _i_study_ui;

Future<void> registerCrossPackageDependencies(_i174.GetIt getIt) async {
  // ── AppRouter ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<_i_router.AppRouter>(() => _i_router.AppRouter());

  // ── Kanji feature ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<_i_kanji_data.KanjiLocalDataSource>(
    () => const _i_kanji_data.KanjiLocalDataSource(),
  );
  getIt.registerLazySingleton<_i_kanji_domain.KanjiRepository>(
    () => _i_kanji_data.KanjiRepositoryImpl(
      getIt<_i_kanji_data.KanjiLocalDataSource>(),
    ),
  );

  // Use cases — factories (never singleton)
  getIt.registerFactory<_i_kanji_domain.GetAllLevels>(
    () =>
        _i_kanji_domain.GetAllLevels(getIt<_i_kanji_domain.KanjiRepository>()),
  );
  getIt.registerFactory<_i_kanji_domain.GetKanjiByLevel>(
    () => _i_kanji_domain.GetKanjiByLevel(
      getIt<_i_kanji_domain.KanjiRepository>(),
    ),
  );

  // ── Progress feature ───────────────────────────────────────────────────────
  // Store is async — must be awaited before dependents register.
  final store = await _i_progress_data.openStore();
  getIt.registerSingleton<_i_obx.Store>(store);
  getIt.registerLazySingleton<_i_obx.Box<_i_progress_data.KanjiProgressEntity>>(
    () => getIt<_i_obx.Store>().box<_i_progress_data.KanjiProgressEntity>(),
  );
  getIt.registerLazySingleton<_i_progress_data.ProgressLocalDataSource>(
    () => _i_progress_data.ProgressLocalDataSource(
      getIt<_i_obx.Box<_i_progress_data.KanjiProgressEntity>>(),
    ),
  );
  getIt.registerLazySingleton<_i_progress_domain.ProgressRepository>(
    () => _i_progress_data.ProgressRepositoryImpl(
      getIt<_i_progress_data.ProgressLocalDataSource>(),
    ),
  );

  // Use cases — factories
  getIt.registerFactory<_i_progress_domain.EnsurePoolInitialized>(
    () => _i_progress_domain.EnsurePoolInitialized(
      getIt<_i_progress_domain.ProgressRepository>(),
    ),
  );
  getIt.registerFactory<_i_progress_domain.GetLevelProgress>(
    () => _i_progress_domain.GetLevelProgress(
      getIt<_i_progress_domain.ProgressRepository>(),
    ),
  );
  getIt.registerFactory<_i_progress_domain.RecordAnswer>(
    () => _i_progress_domain.RecordAnswer(
      getIt<_i_progress_domain.ProgressRepository>(),
    ),
  );
  getIt.registerFactory<_i_progress_domain.SelectNextKanji>(
    () => _i_progress_domain.SelectNextKanji(),
  );
  getIt.registerFactory<_i_progress_domain.ResetKanjiProgress>(
    () => _i_progress_domain.ResetKanjiProgress(
      getIt<_i_progress_domain.ProgressRepository>(),
    ),
  );

  // ── Quiz feature ───────────────────────────────────────────────────────────
  getIt.registerFactory<_i_quiz_domain.GenerateQuiz>(
    () => _i_quiz_domain.GenerateQuiz(
      getIt<_i_progress_domain.SelectNextKanji>(),
    ),
  );
  getIt.registerFactory<_i_quiz_domain.GradeAnswer>(
    () => _i_quiz_domain.GradeAnswer(),
  );

  // ── Home UI ────────────────────────────────────────────────────────────────
  getIt.registerFactory<_i_home_ui.HomeCubit>(
    () => _i_home_ui.HomeCubit(
      getAllLevels: getIt<_i_kanji_domain.GetAllLevels>(),
      getLevelProgress: getIt<_i_progress_domain.GetLevelProgress>(),
    ),
  );

  // ── Study UI ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<_i_common.TtsService>(
    () => _i_common.FlutterTtsService(_i_flutter_tts.FlutterTts()),
  );
  getIt.registerLazySingleton<_i_common.SoundEffectService>(
    () =>
        _i_common.AudioPlayersSoundEffectService(_i_audioplayers.AudioPlayer()),
  );
  getIt.registerFactory<_i_study_ui.StudyCubit>(
    () => _i_study_ui.StudyCubit(
      getKanjiByLevel: getIt<_i_kanji_domain.GetKanjiByLevel>(),
      ttsService: getIt<_i_common.TtsService>(),
      progressRepository: getIt<_i_progress_domain.ProgressRepository>(),
      resetKanjiProgress: getIt<_i_progress_domain.ResetKanjiProgress>(),
    ),
  );

  // ── Quiz UI ────────────────────────────────────────────────────────────────
  // Random is shared across quiz sessions for deterministic testability when
  // replaced via GetIt in tests.
  getIt.registerLazySingleton<Random>(() => Random());
  getIt.registerFactory<_i_quiz_ui.QuizCubit>(
    () => _i_quiz_ui.QuizCubit(
      ensurePoolInitialized: getIt<_i_progress_domain.EnsurePoolInitialized>(),
      getKanjiByLevel: getIt<_i_kanji_domain.GetKanjiByLevel>(),
      generateQuiz: getIt<_i_quiz_domain.GenerateQuiz>(),
      gradeAnswer: getIt<_i_quiz_domain.GradeAnswer>(),
      recordAnswer: getIt<_i_progress_domain.RecordAnswer>(),
      random: getIt<Random>(),
    ),
  );
}
