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

/// How cues play. Party-friendly: they mix with music already playing
/// (never pause or duck it).
/// - iOS: ambient category, which always mixes with other audio and is muted
///   by the silent switch.
/// - Android: media stream (the media volume controls them) without
///   requesting audio focus.
///
/// Built explicitly: audioplayers' generic AudioContextConfig can't express
/// this combination and asserts on iOS.
AudioContext cueAudioContext() => AudioContext(
  android: const AudioContextAndroid(
    usageType: AndroidUsageType.media,
    contentType: AndroidContentType.sonification,
    audioFocus: AndroidAudioFocus.none,
  ),
  iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
);

class _AudioSoundPlayer implements SoundPlayer {
  _AudioSoundPlayer() {
    _player.setAudioContext(cueAudioContext());
  }

  final _player = AudioPlayer();

  @override
  Future<void> play(GameSound sound) async {
    // Re-applied on every cue: Read aloud switches the app's single iOS
    // audio session to playback, and cues must stay ambient (silent switch).
    await _player.setAudioContext(cueAudioContext());
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
