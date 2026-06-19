import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/kanji_model.dart';

class KanjiLocalDataSource {
  const KanjiLocalDataSource();

  static const _assetPath = 'assets/data/kanji.json';

  Future<List<KanjiModel>> loadAll() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => KanjiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
