import 'package:flutter/widgets.dart';

import 'app.dart';
import 'di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const KanjiProApp());
}
