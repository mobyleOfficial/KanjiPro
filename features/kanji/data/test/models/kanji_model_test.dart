import 'package:kanji_data/kanji_data.dart';
import 'package:kanji_domain/kanji_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses json and maps to domain', () {
    final model = KanjiModel.fromJson(const {
      'literal': '日',
      'jlpt': 'n5',
      'on_readings': ['ニチ'],
      'kun_readings': ['ひ'],
      'meanings': ['day'],
      'stroke_count': 4,
    });
    final kanji = model.toDomain();
    expect(kanji.literal, '日');
    expect(kanji.jlptLevel, JlptLevel.n5);
    expect(kanji.onReadings, ['ニチ']);
  });

  test('toDomain maps jlpt string to JlptLevel via fromId', () {
    final model = KanjiModel.fromJson(const {
      'literal': '一',
      'jlpt': 'n5',
      'on_readings': ['イチ', 'イツ'],
      'kun_readings': ['ひと-', 'ひと.つ'],
      'meanings': ['one'],
      'stroke_count': 1,
    });
    expect(model.toDomain().jlptLevel, JlptLevel.n5);
  });
}
