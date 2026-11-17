import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the display from sleeping. Behind an interface so tests can fake it.
abstract interface class ScreenAwake {
  Future<void> keepOn(bool on);
}

class _WakelockScreenAwake implements ScreenAwake {
  @override
  Future<void> keepOn(bool on) => WakelockPlus.toggle(enable: on);
}

final screenAwakeProvider = Provider<ScreenAwake>((ref) => _WakelockScreenAwake());

/// Keeps the screen on while [enabled], and releases it when disabled or
/// removed from the tree.
class KeepScreenOn extends ConsumerStatefulWidget {
  const KeepScreenOn({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  ConsumerState<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends ConsumerState<KeepScreenOn> {
  // Read once: `ref` can't be used in dispose().
  late final ScreenAwake _awake = ref.read(screenAwakeProvider);

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _set(true);
  }

  @override
  void didUpdateWidget(KeepScreenOn old) {
    super.didUpdateWidget(old);
    if (old.enabled != widget.enabled) _set(widget.enabled);
  }

  @override
  void dispose() {
    if (widget.enabled) _set(false);
    super.dispose();
  }

  // Best effort: a platform without wakelock support must not break the game.
  void _set(bool on) => _awake.keepOn(on).catchError((Object _) {});

  @override
  Widget build(BuildContext context) => widget.child;
}
