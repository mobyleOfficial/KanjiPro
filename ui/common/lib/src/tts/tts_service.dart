import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<bool> isJapaneseAvailable();
  Future<void> speak(String text);
}

class FlutterTtsService implements TtsService {
  FlutterTtsService(this._tts);
  final FlutterTts _tts;
  static const _lang = 'ja-JP';

  @override
  Future<bool> isJapaneseAvailable() async {
    final available = await _tts.isLanguageAvailable(_lang);
    return available == true || available == 1;
  }

  @override
  Future<void> speak(String text) async {
    await _tts.setLanguage(_lang);
    await _tts.speak(text);
  }
}
