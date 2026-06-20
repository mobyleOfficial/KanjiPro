import 'package:kanji_domain/kanji_domain.dart';

sealed class StudyState {
  const StudyState();
}

class StudyLoading extends StudyState {
  const StudyLoading();
}

class StudySuccess extends StudyState {
  const StudySuccess(this.kanji);
  final List<Kanji> kanji;
}

class StudyError extends StudyState {
  const StudyError(this.message);
  final String message;
}
