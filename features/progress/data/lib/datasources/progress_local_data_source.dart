import '../entities/kanji_progress_entity.dart';
import '../objectbox.g.dart';

class ProgressLocalDataSource {
  ProgressLocalDataSource(this._box);

  final Box<KanjiProgressEntity> _box;

  List<KanjiProgressEntity> forLevel(String levelId) {
    final query = _box
        .query(KanjiProgressEntity_.levelId.equals(levelId))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  void put(KanjiProgressEntity entity) {
    final query = _box
        .query(KanjiProgressEntity_.literal.equals(entity.literal))
        .build();
    final existing = query.findFirst();
    query.close();
    if (existing != null) {
      entity.id = existing.id;
    }
    _box.put(entity);
  }

  void putAll(List<KanjiProgressEntity> entities) {
    for (final entity in entities) {
      put(entity);
    }
  }
}
