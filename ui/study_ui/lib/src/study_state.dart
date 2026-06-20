import 'package:kanji_domain/kanji_domain.dart';
import 'package:progress_domain/progress_domain.dart';

sealed class StudyState {
  const StudyState();
}

class StudyLoading extends StudyState {
  const StudyLoading();
}

class StudySuccess extends StudyState {
  const StudySuccess(this.kanji, {this.progressByLiteral = const {}});

  final List<Kanji> kanji;
  final Map<String, KanjiProgress> progressByLiteral;
}

class StudyError extends StudyState {
  const StudyError(this.message);
  final String message;
}
