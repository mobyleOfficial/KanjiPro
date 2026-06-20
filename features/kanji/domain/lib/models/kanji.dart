import 'jlpt_level.dart';
import 'kanji_example.dart';

class Kanji {
  const Kanji({
    required this.literal,
    required this.onReadings,
    required this.kunReadings,
    required this.meanings,
    required this.jlptLevel,
    required this.strokeCount,
    this.examples = const [],
  });

  final String literal;
  final List<String> onReadings;
  final List<String> kunReadings;
  final List<String> meanings;
  final JlptLevel jlptLevel;
  final int strokeCount;
  final List<KanjiExample> examples;
}
