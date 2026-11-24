import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../common/l10n.dart';
import '../theme/app_theme.dart';
import 'haptics.dart';
import 'phase.dart';

/// A [CountdownRing] that runs: tap to start or pause, tap again at zero to
/// restart. Buzzes when time is up. Re-key it to start a new countdown
/// (the next speaker, a Foul).
class TalkTimer extends StatefulWidget {
  const TalkTimer({super.key, required this.seconds, this.onDone});

  final int seconds;
  final VoidCallback? onDone;

  @override
  State<TalkTimer> createState() => _TalkTimerState();
}

class _TalkTimerState extends State<TalkTimer> {
  late int _remaining = widget.seconds;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => _timer = null);
      return;
    }
    if (_remaining <= 0) _remaining = widget.seconds;
    Haptics.light();
    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _remaining--);
        if (_remaining > 0) return;
        t.cancel();
        setState(() => _timer = null);
        Haptics.heavy();
        widget.onDone?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final running = _timer != null;
    return CountdownRing(
      remaining: Duration(seconds: _remaining.clamp(0, widget.seconds)),
      total: Duration(seconds: widget.seconds),
      label: _remaining <= 0
          ? l.timerDone
          : running
          ? l.timeLeft
          : l.timerPaused,
      semanticLabel: running ? l.timerPause : l.timerStart,
      onTap: _toggle,
    );
  }
}

/// [TalkTimer] at the end of a glass row with a title and hint, for a
/// timed part of the game (Mafia talk, Free Chat, a Speech).
class TimedRow extends StatelessWidget {
  const TimedRow({super.key, required this.title, required this.timer, this.hint});

  final String title;
  final String? hint;
  final TalkTimer timer;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.type.titleMedium),
              if (hint != null) ...[
                const SizedBox(height: Space.xs),
                Text(hint!, style: context.type.bodySmall!.copyWith(color: c.textMuted)),
              ],
            ],
          ),
        ),
        const SizedBox(width: Space.md),
        timer,
      ],
    );
  }
}
