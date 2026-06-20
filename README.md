# KanjiPro

KanjiPro is an offline kanji learning app for JLPT levels N5 through N1. It uses a reinforcement
scheduler to surface kanji that need more practice, and supports three quiz modes (On'yomi reading,
Kun'yomi reading, and Meaning). Flashcard-style study sessions include text-to-speech (TTS) for
pronunciation guidance.

**Platforms:** Android, iOS

---

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The `build_runner` step regenerates auto_route route files (`*.gr.dart`). Run it whenever routes change.

---

## Running Tests

Tests live in each package's own `test/` directory. Run them from the package root:

```bash
# Root app
cd kanjipro && flutter test

# Feature packages
cd kanjipro/features/kanji/domain && flutter test
cd kanjipro/features/progress/domain && flutter test
cd kanjipro/features/progress/data && flutter test

# UI packages
cd kanjipro/ui/home_ui && flutter test
cd kanjipro/ui/study_ui && flutter test
cd kanjipro/ui/quiz_ui && flutter test
```

The `progress/data` integration test (`test/store_integration_test.dart`) opens a real ObjectBox Store.
It requires `lib/libobjectbox.dylib` to be present (installed by `objectbox-dart`'s `install.sh`).

---

## Dependency Injection

DI is wired manually in `lib/di/injection_registry.dart`. Injectable codegen is disabled via
`build.yaml` because `injectable_generator` only scans the root package and cannot discover
cross-package registrations. Add new feature registrations in dependency order:
data source → repository → use cases → UI cubits.

---

## Architecture

KanjiPro is a multimodule Flutter project:

```
kanjipro/
├── core/                       # Result<T>, Failure, UseCase base
├── features/
│   ├── kanji/
│   │   ├── domain/             # Kanji model, JlptLevel, KanjiRepository contract, use cases
│   │   └── data/               # KanjiLocalDataSource (bundled JSON asset)
│   ├── progress/
│   │   ├── domain/             # KanjiProgress model, ProgressRepository, scheduler use cases
│   │   └── data/               # ObjectBox persistence, KanjiProgressEntity, hand-written .g.dart
│   └── quiz/
│       └── domain/             # QuizQuestion, QuizMode, GenerateQuiz, GradeAnswer
├── ui/
│   ├── common/                 # AppTheme, AppLocalizations (ARB), TtsService
│   ├── home_ui/                # HomeCubit, HomeView (level list with progress)
│   ├── study_ui/               # StudyCubit, StudyScreen (flashcard + TTS)
│   └── quiz_ui/                # QuizCubit, QuizView, QuizModeSelectView, QuizResultView
└── lib/
    ├── app.dart                # KanjiProApp (MaterialApp.router)
    ├── di/                     # injection.dart + injection_registry.dart
    └── routes/                 # AppRouter (auto_route)
```

Dependency direction: `ui` → `features/<x>/domain`. The `data` layer is never imported by UI.
Cross-feature communication goes through domain contracts only.

---

## Data & Attribution

The kanji data bundled in `assets/data/kanji.json` is derived from **KANJIDIC2**, provided via the
[kanjiapi.dev](https://kanjiapi.dev) API. KANJIDIC2 is the property of the
[Electronic Dictionary Research and Development Group (EDRDG)](https://www.edrdg.org/)
and is used in accordance with the Group's licence.

**License:** [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/)

Sources: [edrdg.org](https://www.edrdg.org/) · [kanjiapi.dev](https://kanjiapi.dev)

---

## License

[MIT](LICENSE)
