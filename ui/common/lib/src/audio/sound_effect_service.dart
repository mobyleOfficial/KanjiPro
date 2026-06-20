import 'package:audioplayers/audioplayers.dart';

abstract class SoundEffectService {
  Future<void> playCorrect();
  Future<void> playWrong();
}

class AudioPlayersSoundEffectService implements SoundEffectService {
  AudioPlayersSoundEffectService(this._player);

  final AudioPlayer _player;

  @override
  Future<void> playCorrect() async {
    await _player.play(AssetSource('packages/common/audio/correct.wav'));
  }

  @override
  Future<void> playWrong() async {
    await _player.play(AssetSource('packages/common/audio/wrong.wav'));
  }
}
