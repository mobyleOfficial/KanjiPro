import 'package:auto_route/auto_route.dart';

// ignore: unused_import — required for auto_route_generator to discover @RoutePage() annotations
import '../screens/home_screen.dart';
// ignore: unused_import — required for auto_route_generator to discover @RoutePage() annotations
import '../screens/study_screen.dart';
// ignore: unused_import — required for auto_route_generator to discover @RoutePage() annotations
import '../screens/quiz_mode_select_screen.dart';
// ignore: unused_import — required for auto_route_generator to discover @RoutePage() annotations
import '../screens/quiz_screen.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: StudyRoute.page),
    AutoRoute(page: QuizModeSelectRoute.page),
    AutoRoute(page: QuizRoute.page),
  ];
}
