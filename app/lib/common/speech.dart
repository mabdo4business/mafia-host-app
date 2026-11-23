import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads text aloud with the device's text-to-speech voice. Behind an
/// interface so tests and the gallery record instead of speak.
abstract interface class Speaker {
  /// True while text is being spoken.
  ValueListenable<bool> get speaking;

  /// Speaks [text] in [locale], interrupting anything already playing.
  Future<void> speak(String text, Locale locale);

  Future<void> stop();
}

/// The TTS language for an app locale. Full tags: iOS needs a region.
String ttsLanguage(Locale locale) => locale.languageCode == 'ar' ? 'ar-SA' : 'en-US';

class _TtsSpeaker implements Speaker {
  _TtsSpeaker() {
    void done() => _speaking.value = false;
    _tts
      ..setStartHandler(() => _speaking.value = true)
      ..setCompletionHandler(done)
      ..setCancelHandler(done)
      ..setErrorHandler((_) => done());
    // Same policy as the sound cues (see cueAudioContext): ambient mixes
    // with music already playing and never pauses it. iOS forbids setting
    // mixWithOthers explicitly on ambient, so no options.
    _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient, const []);
  }

  final _tts = FlutterTts();
  final _speaking = ValueNotifier(false);

  @override
  ValueListenable<bool> get speaking => _speaking;

  @override
  Future<void> speak(String text, Locale locale) async {
    await _tts.stop();
    await _tts.setLanguage(ttsLanguage(locale));
    _speaking.value = true;
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    _speaking.value = false;
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
    _speaking.dispose();
  }
}

/// Records what would be spoken. Used by tests and the component gallery.
class RecordingSpeaker implements Speaker {
  final List<(String, Locale)> spoken = [];
  final _speaking = ValueNotifier(false);

  @override
  ValueListenable<bool> get speaking => _speaking;

  @override
  Future<void> speak(String text, Locale locale) async {
    spoken.add((text, locale));
    _speaking.value = true;
  }

  @override
  Future<void> stop() async => _speaking.value = false;

  /// Simulates the voice reaching the end.
  void finish() => _speaking.value = false;
}

final speakerProvider = Provider<Speaker>((ref) {
  final speaker = _TtsSpeaker();
  ref.onDispose(speaker.dispose);
  return speaker;
});
