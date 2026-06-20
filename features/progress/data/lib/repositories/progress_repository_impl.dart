import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

import '../datasources/progress_local_data_source.dart';
import '../entities/kanji_progress_entity.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._source);

  final ProgressLocalDataSource _source;

  @override
  Future<List<KanjiProgress>> forLevel(JlptLevel level) async =>
      _source.forLevel(level.id).map((entity) => entity.toDomain()).toList();

  @override
  Future<void> upsert(KanjiProgress progress) async =>
      _source.put(KanjiProgressEntity.fromDomain(progress));

  @override
  Future<void> upsertAll(List<KanjiProgress> progressList) async =>
      _source.putAll(progressList.map(KanjiProgressEntity.fromDomain).toList());
}
