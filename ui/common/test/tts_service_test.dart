import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTts implements TtsService {
  _FakeTts(this._available);
  final bool _available;
  String? spoken;
  @override
  Future<bool> isJapaneseAvailable() async => _available;
  @override
  Future<void> speak(String text) async => spoken = text;
}

void main() {
  test('reports availability and records spoken text', () async {
    final tts = _FakeTts(true);
    expect(await tts.isJapaneseAvailable(), true);
    await tts.speak('にち');
    expect(tts.spoken, 'にち');
  });
}
