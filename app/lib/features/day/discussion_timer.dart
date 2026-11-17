import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../common/l10n.dart';

class DiscussionTimer extends StatefulWidget {
  const DiscussionTimer({super.key, required this.seconds});

  final int seconds;

  @override
  State<DiscussionTimer> createState() => _DiscussionTimerState();
}

class _DiscussionTimerState extends State<DiscussionTimer> {
  late int _remaining = widget.seconds;
  Timer? _timer;

  bool get _running => _timer != null;

  void _start() {
    if (_remaining == 0) _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _stop();
        HapticFeedback.heavyImpact();
      }
    });
    setState(() {});
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _remaining = widget.seconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final two = NumberFormat('00', Localizations.localeOf(context).toString());
    final done = _remaining <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.dayDiscussion, style: theme.textTheme.labelLarge),
                  Text(
                    done
                        ? l.timerDone
                        : '${two.format(_remaining ~/ 60)}:${two.format(_remaining % 60)}',
                    // Keep mm:ss left-to-right even in Arabic.
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: done ? theme.colorScheme.error : null,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: _running ? l.timerPause : l.timerStart,
              iconSize: 32,
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              onPressed: _running ? _stop : _start,
            ),
            const SizedBox(width: 8),
            IconButton(tooltip: l.timerReset, icon: const Icon(Icons.replay), onPressed: _reset),
          ],
        ),
      ),
    );
  }
}
