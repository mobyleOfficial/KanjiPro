// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanji_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KanjiExampleModel _$KanjiExampleModelFromJson(Map<String, dynamic> json) =>
    KanjiExampleModel(
      word: json['word'] as String,
      reading: json['reading'] as String,
      meaning: json['meaning'] as String,
    );

Map<String, dynamic> _$KanjiExampleModelToJson(KanjiExampleModel instance) =>
    <String, dynamic>{
      'word': instance.word,
      'reading': instance.reading,
      'meaning': instance.meaning,
    };

KanjiModel _$KanjiModelFromJson(Map<String, dynamic> json) => KanjiModel(
  literal: json['literal'] as String,
  jlpt: json['jlpt'] as String,
  onReadings: (json['on_readings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  kunReadings: (json['kun_readings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  meanings: (json['meanings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  strokeCount: (json['stroke_count'] as num).toInt(),
  examples:
      (json['examples'] as List<dynamic>?)
          ?.map((e) => KanjiExampleModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$KanjiModelToJson(KanjiModel instance) =>
    <String, dynamic>{
      'literal': instance.literal,
      'jlpt': instance.jlpt,
      'on_readings': instance.onReadings,
      'kun_readings': instance.kunReadings,
      'meanings': instance.meanings,
      'stroke_count': instance.strokeCount,
      'examples': instance.examples,
    };
