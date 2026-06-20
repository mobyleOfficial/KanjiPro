// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// This file is hand-maintained. The AppRouter block is kept in sync with
// injectable_generator output; feature module registrations are added here
// manually because injectable_generator does not scan across packages.

// ignore_for_file: type=lint
// coverage:ignore-file

import 'dart:async';

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:kanji_data/kanji_data.dart' as _i_kanji_data;
import 'package:kanji_domain/kanji_domain.dart' as _i_kanji_domain;
import 'package:kanji_pro/routes/app_router.dart' as _i427;
import 'package:objectbox/objectbox.dart' as _i_obx;
import 'package:progress_data/progress_data.dart' as _i_progress_data;
import 'package:progress_domain/progress_domain.dart' as _i_progress_domain;
import 'package:quiz_domain/quiz_domain.dart' as _i_quiz_domain;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);

    // ── AppRouter ────────────────────────────────────────────────────────────
    gh.lazySingleton<_i427.AppRouter>(() => _i427.AppRouter());

    // ── Kanji feature ────────────────────────────────────────────────────────
    gh.lazySingleton<_i_kanji_data.KanjiLocalDataSource>(
      () => const _i_kanji_data.KanjiLocalDataSource(),
    );
    gh.lazySingleton<_i_kanji_domain.KanjiRepository>(
      () => _i_kanji_data.KanjiRepositoryImpl(
        get<_i_kanji_data.KanjiLocalDataSource>(),
      ),
    );

    // Use cases — factories (never singleton)
    gh.factory<_i_kanji_domain.GetAllLevels>(
      () => _i_kanji_domain.GetAllLevels(
        get<_i_kanji_domain.KanjiRepository>(),
      ),
    );
    gh.factory<_i_kanji_domain.GetKanjiByLevel>(
      () => _i_kanji_domain.GetKanjiByLevel(
        get<_i_kanji_domain.KanjiRepository>(),
      ),
    );

    // ── Progress feature ─────────────────────────────────────────────────────
    // Store is async/preResolve — must be awaited before dependents register.
    await gh.lazySingletonAsync<_i_obx.Store>(
      () => _i_progress_data.openStore(),
      preResolve: true,
    );
    gh.lazySingleton<_i_obx.Box<_i_progress_data.KanjiProgressEntity>>(
      () =>
          get<_i_obx.Store>().box<_i_progress_data.KanjiProgressEntity>(),
    );
    gh.lazySingleton<_i_progress_data.ProgressLocalDataSource>(
      () => _i_progress_data.ProgressLocalDataSource(
        get<_i_obx.Box<_i_progress_data.KanjiProgressEntity>>(),
      ),
    );
    gh.lazySingleton<_i_progress_domain.ProgressRepository>(
      () => _i_progress_data.ProgressRepositoryImpl(
        get<_i_progress_data.ProgressLocalDataSource>(),
      ),
    );

    // Use cases — factories
    gh.factory<_i_progress_domain.EnsurePoolInitialized>(
      () => _i_progress_domain.EnsurePoolInitialized(
        get<_i_progress_domain.ProgressRepository>(),
      ),
    );
    gh.factory<_i_progress_domain.GetLevelProgress>(
      () => _i_progress_domain.GetLevelProgress(
        get<_i_progress_domain.ProgressRepository>(),
      ),
    );
    gh.factory<_i_progress_domain.RecordAnswer>(
      () => _i_progress_domain.RecordAnswer(
        get<_i_progress_domain.ProgressRepository>(),
      ),
    );
    gh.factory<_i_progress_domain.SelectNextKanji>(
      () => _i_progress_domain.SelectNextKanji(),
    );

    // ── Quiz feature ─────────────────────────────────────────────────────────
    gh.factory<_i_quiz_domain.GenerateQuiz>(
      () => _i_quiz_domain.GenerateQuiz(
        get<_i_progress_domain.SelectNextKanji>(),
      ),
    );
    gh.factory<_i_quiz_domain.GradeAnswer>(
      () => _i_quiz_domain.GradeAnswer(),
    );

    return this;
  }
}
