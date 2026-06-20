import 'package:progress_domain/progress_domain.dart';

sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  const HomeSuccess(this.levels);
  final List<LevelProgress> levels;
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}
