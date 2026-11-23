import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../common/speech.dart';
import '../../ui/ui.dart';

/// "Read aloud" next to the announcement CTA: speaks [text] in the app's
/// language; while speaking it turns into a stop button. Speech stops when
/// the screen goes away.
class ReadAloudButton extends ConsumerStatefulWidget {
  const ReadAloudButton({super.key, required this.text});

  final String text;

  @override
  ConsumerState<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends ConsumerState<ReadAloudButton> {
  // Kept so dispose() can stop speech without touching ref.
  late final Speaker _speaker = ref.read(speakerProvider);

  @override
  void dispose() {
    if (_speaker.speaking.value) _speaker.stop().catchError((Object _) {});
    super.dispose();
  }

  void _toggle() {
    Haptics.light();
    // Best effort: a missing voice never interrupts the game.
    final call = _speaker.speaking.value
        ? _speaker.stop()
        : _speaker.speak(widget.text, Localizations.localeOf(context));
    call.catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ValueListenableBuilder<bool>(
      valueListenable: _speaker.speaking,
      builder: (context, speaking, _) => IconCircleButton.large(
        key: const Key('readAloud'),
        glyph: speaking ? MafiaGlyphs.stop : MafiaGlyphs.speaker,
        semanticLabel: speaking ? l.stopReading : l.readAloud,
        filled: true,
        onPressed: widget.text.isEmpty ? null : _toggle,
      ),
    );
  }
}
