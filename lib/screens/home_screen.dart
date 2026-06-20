import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:home_ui/home_ui.dart';
import 'package:kanji_domain/kanji_domain.dart';

import '../routes/app_router.gr.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => HomeView(
        onLevelTap: (JlptLevel level) =>
            AutoRouter.of(context).push(StudyRoute(level: level)),
      );
}
