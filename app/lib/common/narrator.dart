import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:material_ui/material_ui.dart';

/// Reads announcements aloud with the device's text-to-speech. Behind an
/// interface so tests can record instead of speak.
abstract interface class Narrator {
  /// True while lines are being read.
  ValueListenable<bool> get speaking;

  /// Reads [lines] in order in [locale]'s language, replacing anything
  /// already being read.
  Future<void> speak(List<String> lines, Locale locale);

  Future<void> stop();
}

class _TtsNarrator implements Narrator {
  _TtsNarrator() {
    // Best effort: without a TTS engine the button just does nothing.
    _tts.awaitSpeakCompletion(true).catchError((Object _) {});
    // The host chose to read aloud: play through the silent switch, and
    // duck (not stop) any party music while speaking.
    _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      IosTextToSpeechAudioCategoryOptions.duckOthers,
    ], IosTextToSpeechAudioMode.spokenAudio);
  }

  final _tts = FlutterTts();

  @override
  final ValueNotifier<bool> speaking = ValueNotifier(false);

  /// Bumped on every speak/stop so an older reading stops between lines.
  int _run = 0;

  @override
  Future<void> speak(List<String> lines, Locale locale) async {
    await stop();
    final run = ++_run;
    speaking.value = true;
    try {
      await _tts.setLanguage(locale.languageCode == 'ar' ? 'ar-SA' : 'en-US');
      await _tts.setSpeechRate(0.45); // slower: read to a room
      for (final line in lines) {
        if (run != _run) return;
        await _tts.speak(line);
      }
    } catch (_) {
      // Best effort: no voice for the language, or TTS unavailable.
    } finally {
      if (run == _run) speaking.value = false;
    }
  }

  @override
  Future<void> stop() async {
    _run++;
    speaking.value = false;
    await _tts.stop().catchError((Object _) {});
  }

  void dispose() {
    _tts.stop().catchError((Object _) {});
    speaking.dispose();
  }
}

final narratorProvider = Provider<Narrator>((ref) {
  final narrator = _TtsNarrator();
  ref.onDispose(narrator.dispose);
  return narrator;
});
