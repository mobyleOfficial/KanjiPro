import 'package:injectable/injectable.dart';
import 'package:kanji_domain/kanji_domain.dart';

import '../datasources/kanji_local_data_source.dart';
import '../repositories/kanji_repository_impl.dart';

@module
abstract class KanjiDataModule {
  @lazySingleton
  KanjiLocalDataSource get kanjiLocalDataSource => const KanjiLocalDataSource();

  @lazySingleton
  KanjiRepository kanjiRepository(KanjiLocalDataSource source) =>
      KanjiRepositoryImpl(source);
}
