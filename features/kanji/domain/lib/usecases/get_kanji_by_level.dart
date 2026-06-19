import 'package:core/core.dart';

import '../models/jlpt_level.dart';
import '../models/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByLevel extends UseCase<JlptLevel, Result<List<Kanji>>> {
  GetKanjiByLevel(this._repository);

  final KanjiRepository _repository;

  @override
  Future<Result<List<Kanji>>> call([JlptLevel? params]) =>
      _repository.getByLevel(params!);
}
