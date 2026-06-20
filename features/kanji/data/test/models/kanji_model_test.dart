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

  test('examples absent → defaults to empty list', () {
    final model = KanjiModel.fromJson(const {
      'literal': '山',
      'jlpt': 'n5',
      'on_readings': ['サン'],
      'kun_readings': ['やま'],
      'meanings': ['mountain'],
      'stroke_count': 3,
    });
    final kanji = model.toDomain();
    expect(kanji.examples, isEmpty);
  });

  test('examples parse and map to domain KanjiExample list', () {
    final model = KanjiModel.fromJson(const {
      'literal': '一',
      'jlpt': 'n5',
      'on_readings': ['イチ', 'イツ'],
      'kun_readings': ['ひと-', 'ひと.つ'],
      'meanings': ['one'],
      'stroke_count': 1,
      'examples': [
        {'word': '一日', 'reading': 'いちにち', 'meaning': 'one day'},
        {'word': '一番', 'reading': 'いちばん', 'meaning': 'number one'},
      ],
    });
    final kanji = model.toDomain();
    expect(kanji.examples.length, 2);
    expect(kanji.examples[0].word, '一日');
    expect(kanji.examples[0].reading, 'いちにち');
    expect(kanji.examples[0].meaning, 'one day');
    expect(kanji.examples[1].word, '一番');
  });

  test('KanjiExampleModel roundtrips fromJson/toJson', () {
    const exampleJson = {
      'word': '日本',
      'reading': 'にほん',
      'meaning': 'Japan',
    };
    final exampleModel = KanjiExampleModel.fromJson(exampleJson);
    expect(exampleModel.word, '日本');
    expect(exampleModel.reading, 'にほん');
    expect(exampleModel.meaning, 'Japan');
    final domain = exampleModel.toDomain();
    expect(domain, isA<KanjiExample>());
    expect(domain.word, '日本');
    expect(domain.reading, 'にほん');
    expect(domain.meaning, 'Japan');
  });
}
