import 'package:core/core.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements KanjiRepository {}

void main() {
  test('GetAllLevels delegates to repository and returns all levels', () async {
    final repo = _MockRepo();
    when(
      () => repo.getLevels(),
    ).thenAnswer((_) async => Success(JlptLevel.values));
    final result = await GetAllLevels(repo)();
    expect((result as Success<List<JlptLevel>>).data, JlptLevel.values);
  });
}
