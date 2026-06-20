import 'package:injectable/injectable.dart';
import 'package:progress_domain/progress_domain.dart';

import '../datasources/progress_local_data_source.dart';
import '../entities/kanji_progress_entity.dart';
import '../objectbox.g.dart';
import '../repositories/progress_repository_impl.dart';

@module
abstract class ProgressDataModule {
  @preResolve
  @lazySingleton
  Future<Store> get store => openStore();

  @lazySingleton
  Box<KanjiProgressEntity> box(Store store) => store.box<KanjiProgressEntity>();

  @lazySingleton
  ProgressLocalDataSource progressLocalDataSource(
    Box<KanjiProgressEntity> box,
  ) => ProgressLocalDataSource(box);

  @lazySingleton
  ProgressRepository progressRepository(ProgressLocalDataSource source) =>
      ProgressRepositoryImpl(source);
}
