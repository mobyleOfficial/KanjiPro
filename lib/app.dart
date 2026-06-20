import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'di/injection.dart';
import 'routes/app_router.dart';

class KanjiProApp extends StatelessWidget {
  const KanjiProApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: getIt<AppRouter>().config(),
      );
}
