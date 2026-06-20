import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  StudyCubit({
    required GetKanjiByLevel getKanjiByLevel,
    required TtsService ttsService,
    required ProgressRepository progressRepository,
    required ResetKanjiProgress resetKanjiProgress,
  }) : _getKanjiByLevel = getKanjiByLevel,
       _ttsService = ttsService,
       _progressRepository = progressRepository,
       _resetKanjiProgress = resetKanjiProgress,
       super(const StudyLoading());

  final GetKanjiByLevel _getKanjiByLevel;
  final TtsService _ttsService;
  final ProgressRepository _progressRepository;
  final ResetKanjiProgress _resetKanjiProgress;

  JlptLevel? _currentLevel;

  Future<void> load(JlptLevel level) async {
    _currentLevel = level;
    emit(const StudyLoading());

    final result = await _getKanjiByLevel(level);

    switch (result) {
      case FailureResult<List<Kanji>>(:final failure):
        emit(StudyError(failure.message));
      case Success<List<Kanji>>(:final data):
        final progressRecords = await _progressRepository.forLevel(level);
        final progressByLiteral = {
          for (final record in progressRecords) record.literal: record,
        };
        emit(StudySuccess(data, progressByLiteral: progressByLiteral));
    }
  }

  Future<void> resetKanji(String literal) async {
    final level = _currentLevel;
    if (level == null) return;

    await _resetKanjiProgress(ResetParams(literal: literal, level: level));

    final progressRecords = await _progressRepository.forLevel(level);
    final progressByLiteral = {
      for (final record in progressRecords) record.literal: record,
    };

    final currentState = state;
    if (currentState is StudySuccess) {
      emit(
        StudySuccess(currentState.kanji, progressByLiteral: progressByLiteral),
      );
    }
  }

  Future<void> speak(String reading) => _ttsService.speak(reading);

  Future<bool> ttsAvailable() => _ttsService.isJapaneseAvailable();
}
