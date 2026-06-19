import 'package:core/core.dart';

import '../models/jlpt_level.dart';
import '../repositories/kanji_repository.dart';

class GetAllLevels extends UseCase<void, Result<List<JlptLevel>>> {
  GetAllLevels(this._repository);

  final KanjiRepository _repository;

  @override
  Future<Result<List<JlptLevel>>> call([void params]) =>
      _repository.getLevels();
}
