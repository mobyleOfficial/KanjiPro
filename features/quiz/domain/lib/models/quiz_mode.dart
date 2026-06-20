import 'package:kanji_domain/kanji_domain.dart';

enum QuizMode {
  onReading,
  kunReading,
  meaning;

  List<String> answersOf(Kanji kanji) => switch (this) {
    QuizMode.onReading => kanji.onReadings,
    QuizMode.kunReading => kanji.kunReadings,
    QuizMode.meaning => kanji.meanings,
  };
}
