import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_domain/kanji_domain.dart';

import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  StudyCubit({
    required GetKanjiByLevel getKanjiByLevel,
    required TtsService ttsService,
  })  : _getKanjiByLevel = getKanjiByLevel,
        _ttsService = ttsService,
        super(const StudyLoading());

  final GetKanjiByLevel _getKanjiByLevel;
  final TtsService _ttsService;

  Future<void> load(JlptLevel level) async {
    emit(const StudyLoading());

    final result = await _getKanjiByLevel(level);

    switch (result) {
      case FailureResult<List<Kanji>>(:final failure):
        emit(StudyError(failure.message));
      case Success<List<Kanji>>(:final data):
        emit(StudySuccess(data));
    }
  }

  Future<void> speak(String reading) => _ttsService.speak(reading);

  Future<bool> ttsAvailable() => _ttsService.isJapaneseAvailable();
}
