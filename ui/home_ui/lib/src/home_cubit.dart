import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetAllLevels getAllLevels,
    required GetLevelProgress getLevelProgress,
  })  : _getAllLevels = getAllLevels,
        _getLevelProgress = getLevelProgress,
        super(const HomeLoading());

  final GetAllLevels _getAllLevels;
  final GetLevelProgress _getLevelProgress;

  Future<void> load() async {
    emit(const HomeLoading());

    final result = await _getAllLevels();

    switch (result) {
      case FailureResult<List<JlptLevel>>(:final failure):
        emit(HomeError(failure.message));
      case Success<List<JlptLevel>>(:final data):
        try {
          final levelProgressList = await Future.wait(
            data.map((level) => _getLevelProgress(level)),
          );
          emit(HomeSuccess(levelProgressList));
        } catch (error) {
          emit(HomeError(error.toString()));
        }
    }
  }
}
