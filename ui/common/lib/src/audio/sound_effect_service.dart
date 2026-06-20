import 'package:audioplayers/audioplayers.dart';

abstract class SoundEffectService {
  Future<void> playCorrect();
  Future<void> playWrong();
}

class AudioPlayersSoundEffectService implements SoundEffectService {
  AudioPlayersSoundEffectService(this._player) {
    // Use the literal Flutter asset key (no implicit 'assets/' prefix), since
    // these are package-bundled assets keyed as packages/common/assets/audio/*.
    _player.audioCache = AudioCache(prefix: '');
  }

  final AudioPlayer _player;

  // Package-asset key as bundled by Flutter (declared under common's assets/audio/).
  static const _correct = 'packages/common/assets/audio/correct.wav';
  static const _wrong = 'packages/common/assets/audio/wrong.wav';

  @override
  Future<void> playCorrect() async {
    await _player.play(AssetSource(_correct));
  }

  @override
  Future<void> playWrong() async {
    await _player.play(AssetSource(_wrong));
  }
}
