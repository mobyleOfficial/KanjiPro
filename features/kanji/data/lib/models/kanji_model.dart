import 'package:json_annotation/json_annotation.dart';
import 'package:kanji_domain/kanji_domain.dart';

part 'kanji_model.g.dart';

@JsonSerializable()
class KanjiModel {
  KanjiModel({
    required this.literal,
    required this.jlpt,
    required this.onReadings,
    required this.kunReadings,
    required this.meanings,
    required this.strokeCount,
  });

  final String literal;
  final String jlpt;
  @JsonKey(name: 'on_readings')
  final List<String> onReadings;
  @JsonKey(name: 'kun_readings')
  final List<String> kunReadings;
  final List<String> meanings;
  @JsonKey(name: 'stroke_count')
  final int strokeCount;

  factory KanjiModel.fromJson(Map<String, dynamic> json) =>
      _$KanjiModelFromJson(json);

  Map<String, dynamic> toJson() => _$KanjiModelToJson(this);

  Kanji toDomain() => Kanji(
    literal: literal,
    onReadings: onReadings,
    kunReadings: kunReadings,
    meanings: meanings,
    jlptLevel: JlptLevel.fromId(jlpt),
    strokeCount: strokeCount,
  );
}
