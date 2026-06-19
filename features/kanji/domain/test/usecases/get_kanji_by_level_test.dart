import 'package:core/core.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements KanjiRepository {}

void main() {
  test('fromId maps strings to levels', () {
    expect(JlptLevel.fromId('n5'), JlptLevel.n5);
    expect(JlptLevel.n1.id, 'n1');
  });

  test('GetKanjiByLevel delegates to repository', () async {
    final repo = _MockRepo();
    final kanji = [
      const Kanji(
        literal: '日',
        onReadings: ['ニチ'],
        kunReadings: ['ひ'],
        meanings: ['day'],
        jlptLevel: JlptLevel.n5,
        strokeCount: 4,
      ),
    ];
    when(
      () => repo.getByLevel(JlptLevel.n5),
    ).thenAnswer((_) async => Success(kanji));
    final result = await GetKanjiByLevel(repo)(JlptLevel.n5);
    expect((result as Success<List<Kanji>>).data.single.literal, '日');
  });
}
