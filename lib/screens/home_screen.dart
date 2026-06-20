import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:home_ui/home_ui.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeView();
}
