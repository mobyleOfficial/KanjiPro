// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i8;
import 'package:kanji_domain/kanji_domain.dart' as _i7;
import 'package:kanji_pro/screens/home_screen.dart' as _i1;
import 'package:kanji_pro/screens/quiz_mode_select_screen.dart' as _i2;
import 'package:kanji_pro/screens/quiz_screen.dart' as _i3;
import 'package:kanji_pro/screens/results_screen.dart' as _i4;
import 'package:kanji_pro/screens/study_screen.dart' as _i5;
import 'package:quiz_domain/quiz_domain.dart' as _i9;

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.QuizModeSelectScreen]
class QuizModeSelectRoute extends _i6.PageRouteInfo<QuizModeSelectRouteArgs> {
  QuizModeSelectRoute({
    required _i7.JlptLevel level,
    _i8.Key? key,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         QuizModeSelectRoute.name,
         args: QuizModeSelectRouteArgs(level: level, key: key),
         initialChildren: children,
       );

  static const String name = 'QuizModeSelectRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuizModeSelectRouteArgs>();
      return _i2.QuizModeSelectScreen(level: args.level, key: args.key);
    },
  );
}

class QuizModeSelectRouteArgs {
  const QuizModeSelectRouteArgs({required this.level, this.key});

  final _i7.JlptLevel level;

  final _i8.Key? key;

  @override
  String toString() {
    return 'QuizModeSelectRouteArgs{level: $level, key: $key}';
  }
}

/// generated route for
/// [_i3.QuizScreen]
class QuizRoute extends _i6.PageRouteInfo<QuizRouteArgs> {
  QuizRoute({
    required _i7.JlptLevel level,
    required _i9.QuizMode mode,
    _i8.Key? key,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         QuizRoute.name,
         args: QuizRouteArgs(level: level, mode: mode, key: key),
         initialChildren: children,
       );

  static const String name = 'QuizRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuizRouteArgs>();
      return _i3.QuizScreen(level: args.level, mode: args.mode, key: args.key);
    },
  );
}

class QuizRouteArgs {
  const QuizRouteArgs({required this.level, required this.mode, this.key});

  final _i7.JlptLevel level;

  final _i9.QuizMode mode;

  final _i8.Key? key;

  @override
  String toString() {
    return 'QuizRouteArgs{level: $level, mode: $mode, key: $key}';
  }
}

/// generated route for
/// [_i4.ResultsScreen]
class ResultsRoute extends _i6.PageRouteInfo<ResultsRouteArgs> {
  ResultsRoute({
    required int total,
    required int correct,
    _i8.Key? key,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ResultsRoute.name,
         args: ResultsRouteArgs(total: total, correct: correct, key: key),
         initialChildren: children,
       );

  static const String name = 'ResultsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultsRouteArgs>();
      return _i4.ResultsScreen(
        total: args.total,
        correct: args.correct,
        key: args.key,
      );
    },
  );
}

class ResultsRouteArgs {
  const ResultsRouteArgs({
    required this.total,
    required this.correct,
    this.key,
  });

  final int total;

  final int correct;

  final _i8.Key? key;

  @override
  String toString() {
    return 'ResultsRouteArgs{total: $total, correct: $correct, key: $key}';
  }
}

/// generated route for
/// [_i5.StudyScreen]
class StudyRoute extends _i6.PageRouteInfo<StudyRouteArgs> {
  StudyRoute({
    required _i7.JlptLevel level,
    _i8.Key? key,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         StudyRoute.name,
         args: StudyRouteArgs(level: level, key: key),
         initialChildren: children,
       );

  static const String name = 'StudyRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StudyRouteArgs>();
      return _i5.StudyScreen(level: args.level, key: args.key);
    },
  );
}

class StudyRouteArgs {
  const StudyRouteArgs({required this.level, this.key});

  final _i7.JlptLevel level;

  final _i8.Key? key;

  @override
  String toString() {
    return 'StudyRouteArgs{level: $level, key: $key}';
  }
}
