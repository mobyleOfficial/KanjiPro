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

  /// Upserts a batch in a SINGLE transaction. Resolves existing ids with one
  /// query (by literal) and writes all rows via [Box.putMany]. The previous
  /// per-entity query + put ran one implicit write transaction per row, which
  /// blocked the UI isolate for seconds when initializing a full JLPT level
  /// (~1232 rows).
  void putAll(List<KanjiProgressEntity> entities) {
    if (entities.isEmpty) return;
    final literals = entities.map((entity) => entity.literal).toList();
    final query =
        _box.query(KanjiProgressEntity_.literal.oneOf(literals)).build();
    final existingIdByLiteral = {
      for (final existing in query.find()) existing.literal: existing.id,
    };
    query.close();
    for (final entity in entities) {
      final existingId = existingIdByLiteral[entity.literal];
      if (existingId != null) {
        entity.id = existingId;
      }
    }
    _box.putMany(entities);
  }
}
