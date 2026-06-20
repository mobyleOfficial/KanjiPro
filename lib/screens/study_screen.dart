import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:study_ui/study_ui.dart';

@RoutePage()
class StudyScreen extends StatelessWidget {
  const StudyScreen({required this.level, super.key});

  final JlptLevel level;

  @override
  Widget build(BuildContext context) => StudyView(level: level);
}
