import 'package:kanji_domain/kanji_domain.dart';

import '../models/kanji_progress.dart';

abstract class ProgressRepository {
  Future<List<KanjiProgress>> forLevel(JlptLevel level);
  Future<void> upsert(KanjiProgress progress);
  Future<void> upsertAll(List<KanjiProgress> progressList);
}
