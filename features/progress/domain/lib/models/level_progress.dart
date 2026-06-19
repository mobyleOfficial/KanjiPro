import 'package:kanji_domain/kanji_domain.dart';

class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.mastered,
    required this.learning,
    required this.locked,
    required this.total,
  });

  final JlptLevel level;
  final int mastered;
  final int learning;
  final int locked;
  final int total;

  double get percent => total == 0 ? 0 : mastered / total;
}
