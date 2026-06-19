import 'package:core/core.dart';

import '../models/jlpt_level.dart';
import '../models/kanji.dart';

abstract class KanjiRepository {
  Future<Result<List<Kanji>>> getByLevel(JlptLevel level);
  Future<Result<List<JlptLevel>>> getLevels();
}
