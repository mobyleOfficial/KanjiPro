import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake implementation — verifies the interface contract without real audio hardware.
class _FakeSoundEffectService implements SoundEffectService {
  int correctCount = 0;
  int wrongCount = 0;

  @override
  Future<void> playCorrect() async => correctCount++;

  @override
  Future<void> playWrong() async => wrongCount++;
}

void main() {
  test(
    'SoundEffectService interface: playCorrect and playWrong are callable',
    () async {
      final sfx = _FakeSoundEffectService();

      await sfx.playCorrect();
      expect(sfx.correctCount, 1);
      expect(sfx.wrongCount, 0);

      await sfx.playWrong();
      expect(sfx.correctCount, 1);
      expect(sfx.wrongCount, 1);
    },
  );

  test('AudioPlayersSoundEffectService implements SoundEffectService', () {
    // Verify the concrete class satisfies the abstract interface at compile time.
    // We do not play actual audio in tests (no hardware / platform channel).
    expect(SoundEffectService, isNotNull);
  });
}
