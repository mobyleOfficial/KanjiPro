import 'package:get_it/get_it.dart';

import 'injection_registry.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() =>
    registerCrossPackageDependencies(getIt);
