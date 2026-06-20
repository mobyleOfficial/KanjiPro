import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

// ignore: unused_import — required for auto_route_generator to discover @RoutePage() annotations
import '../screens/home_screen.dart';
import 'app_router.gr.dart';

@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
      ];
}
