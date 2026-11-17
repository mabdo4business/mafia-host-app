import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/providers.dart';

/// Sound cues. Each maps to `assets/sounds/<name>.wav`.
enum GameSound {
  /// "Everyone, close your eyes."
  night,

  /// "Everyone, wake up."
  morning,
}

/// Plays a cue. Behind an interface so tests can record instead of play.
abstract interface class SoundPlayer {
  Future<void> play(GameSound sound);
}

class _AudioSoundPlayer implements SoundPlayer {
  _AudioSoundPlayer() {
    // Party-friendly: mix with music already playing (don't pause or duck it)
    // and stay quiet when the phone is on silent.
    _player.setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
        respectSilence: true,
      ).build(),
    );
  }

  final _player = AudioPlayer();

  @override
  Future<void> play(GameSound sound) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/${sound.name}.wav'));
  }

  void dispose() => _player.dispose();
}

final soundPlayerProvider = Provider<SoundPlayer>((ref) {
  final player = _AudioSoundPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Plays [sound] if the host has sound effects on. Best effort: a playback
/// failure never interrupts the game.
void playGameSound(WidgetRef ref, GameSound sound) {
  final enabled = ref.read(preferencesProvider).value?.soundEnabled ?? true;
  if (!enabled) return;
  ref.read(soundPlayerProvider).play(sound).catchError((Object _) {});
}
