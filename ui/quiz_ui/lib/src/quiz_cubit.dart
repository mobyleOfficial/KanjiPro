import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';

import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required EnsurePoolInitialized ensurePoolInitialized,
    required GetKanjiByLevel getKanjiByLevel,
    required GenerateQuiz generateQuiz,
    required GradeAnswer gradeAnswer,
    required RecordAnswer recordAnswer,
    required Random random,
    int sessionLength = 10,
  })  : _ensurePoolInitialized = ensurePoolInitialized,
        _getKanjiByLevel = getKanjiByLevel,
        _generateQuiz = generateQuiz,
        _gradeAnswer = gradeAnswer,
        _recordAnswer = recordAnswer,
        _random = random,
        _sessionLength = sessionLength,
        super(const QuizLoading());

  final EnsurePoolInitialized _ensurePoolInitialized;
  final GetKanjiByLevel _getKanjiByLevel;
  final GenerateQuiz _generateQuiz;
  final GradeAnswer _gradeAnswer;
  final RecordAnswer _recordAnswer;
  final Random _random;
  final int _sessionLength;

  List<Kanji> _levelKanji = [];
  List<KanjiProgress> _pool = [];
  QuizMode _mode = QuizMode.meaning;
  String? _lastShown;
  int _total = 0;
  int _correct = 0;
  final List<String> _requeue = [];

  // The current question, stored so answer() can reference it.
  QuizQuestion? _currentQuestion;
  bool _answered = false;

  Future<void> start(JlptLevel level, QuizMode mode) async {
    emit(const QuizLoading());
    _mode = mode;
    _total = 0;
    _correct = 0;
    _lastShown = null;
    _requeue.clear();
    _answered = false;
    _currentQuestion = null;

    final result = await _getKanjiByLevel(level);
    switch (result) {
      case FailureResult<List<Kanji>>(:final failure):
        emit(QuizError(failure.message));
        return;
      case Success<List<Kanji>>(:final data):
        _levelKanji = data;
    }

    _pool = await _ensurePoolInitialized(
      EnsureParams(level: level, levelKanji: _levelKanji),
    );

    await _emitNext();
  }

  Future<void> _emitNext() async {
    if (_total >= _sessionLength) {
      emit(QuizFinished(total: _total, correct: _correct));
      return;
    }

    QuizQuestion? question;

    if (_requeue.isNotEmpty) {
      // Pop the first missed literal and build a forced question for it.
      final missedLiteral = _requeue.removeAt(0);
      final kanjiByLiteral = <String, Kanji>{
        for (final kanji in _levelKanji) kanji.literal: kanji,
      };
      final target = kanjiByLiteral[missedLiteral];
      if (target != null) {
        final correctAnswer = _mode.answersOf(target).isNotEmpty
            ? _mode.answersOf(target).first
            : target.literal;

        final distractorCandidates = _levelKanji
            .where((kanji) => kanji.literal != target.literal)
            .map((kanji) {
              final answers = _mode.answersOf(kanji);
              return answers.isNotEmpty ? answers.first : null;
            })
            .whereType<String>()
            .where((answer) => answer != correctAnswer)
            .toSet()
            .toList();

        distractorCandidates.shuffle(_random);
        final distractors = distractorCandidates.take(3).toList();
        final options = [correctAnswer, ...distractors];
        options.shuffle(_random);
        final correctIndex = options.indexOf(correctAnswer);

        question = QuizQuestion(
          kanji: target,
          mode: _mode,
          options: options,
          correctIndex: correctIndex,
        );
      }
    }

    question ??= _generateQuiz(
      GenerateParams(
        levelKanji: _levelKanji,
        pool: _pool,
        mode: _mode,
        lastShown: _lastShown,
        random: _random,
      ),
    );

    if (question == null) {
      emit(QuizFinished(total: _total, correct: _correct));
      return;
    }

    _currentQuestion = question;
    _lastShown = question.kanji.literal;
    _answered = false;

    emit(
      QuizQuestionState(
        question: question,
        answered: false,
        answeredCount: _total,
        sessionLength: _sessionLength,
      ),
    );
  }

  Future<void> answer(int selectedIndex) async {
    if (_answered || _currentQuestion == null) return;
    _answered = true;

    final question = _currentQuestion!;
    final isCorrect = _gradeAnswer(
      GradeParams(question: question, selectedIndex: selectedIndex),
    );

    _pool = await _recordAnswer(
      RecordParams(
        pool: _pool,
        literal: question.kanji.literal,
        correct: isCorrect,
      ),
    );

    _total++;
    if (isCorrect) {
      _correct++;
    } else {
      // Push the missed literal into the requeue so it reappears this session.
      _requeue.add(question.kanji.literal);
    }

    emit(
      QuizQuestionState(
        question: question,
        answered: true,
        lastCorrect: isCorrect,
        answeredCount: _total,
        sessionLength: _sessionLength,
      ),
    );
  }

  Future<void> next() => _emitNext();
}
