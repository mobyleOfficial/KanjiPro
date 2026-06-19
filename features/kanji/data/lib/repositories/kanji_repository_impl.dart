import 'package:core/core.dart';
import 'package:kanji_domain/kanji_domain.dart';

import '../datasources/kanji_local_data_source.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  KanjiRepositoryImpl(this._source);

  final KanjiLocalDataSource _source;
  List<Kanji>? _cache;

  Future<List<Kanji>> _all() async => _cache ??= (await _source.loadAll())
      .map((model) => model.toDomain())
      .toList();

  @override
  Future<Result<List<Kanji>>> getByLevel(JlptLevel level) async {
    final all = await _all();
    return Success(all.where((kanji) => kanji.jlptLevel == level).toList());
  }

  @override
  Future<Result<List<JlptLevel>>> getLevels() async =>
      const Success(JlptLevel.values);
}
