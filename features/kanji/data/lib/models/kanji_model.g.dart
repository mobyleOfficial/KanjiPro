// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanji_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
);

Map<String, dynamic> _$KanjiModelToJson(KanjiModel instance) =>
    <String, dynamic>{
      'literal': instance.literal,
      'jlpt': instance.jlpt,
      'on_readings': instance.onReadings,
      'kun_readings': instance.kunReadings,
      'meanings': instance.meanings,
      'stroke_count': instance.strokeCount,
    };
