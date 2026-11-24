import 'package:material_ui/material_ui.dart';

import '../common/l10n.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
import 'mafia_icon.dart';

enum Phase { night, day }

/// The pale moon / sun glyph color, derived from the phase glow.
Color celestialColor(MafiaColors c) => Color.lerp(c.glow.withValues(alpha: 1), c.text, 0.6)!;

/// "☾ Night 3" or "☀ Day 3" with a trailing "Game log" pill.
class PhaseHeader extends StatelessWidget {
  const PhaseHeader({
    super.key,
    required this.phase,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final Phase phase;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Extra widgets after the pill (an overflow menu).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    return Row(
      children: [
        MafiaIcon(
          phase == Phase.night ? MafiaGlyphs.moon : MafiaGlyphs.sun,
          size: 26,
          color: phase == Phase.night ? celestialColor(c) : c.primaryCta,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: context.type.headlineSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null) GlassPillButton(label: actionLabel!, onPressed: onAction),
        ?trailing,
      ],
    );
  }
}

/// The night's steps as N equal segments: 4 px bars with 11 px labels.
/// Done = `stepDone`, current = gold and bold, upcoming = white 10%.
class StepRail extends StatelessWidget {
  const StepRail({super.key, required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final base = context.type.labelSmall!.copyWith(fontSize: TextSizes.caption, letterSpacing: 0);
    return Semantics(
      label: context.l10n.nightStepCounter(current + 1, steps.length),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, s) in steps.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: Motion.base,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < current
                          ? c.stepDone
                          : i == current
                          ? c.civilian
                          : c.veil(0.10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      s,
                      maxLines: 1,
                      style: base.copyWith(
                        color: i == current
                            ? c.civilianSoft
                            : i < current
                            ? c.textMuted
                            : c.textMuted.withValues(alpha: 0.75),
                        fontWeight: i == current ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Wake the Doctor" card: 52 px tinted icon box, title, and the quoted line
/// the host reads aloud.
class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.glyph,
    required this.title,
    this.line,
    this.accent,
    this.footer,
  });

  final MafiaGlyph glyph;
  final String title;

  /// What the host says to the table; shown in quotes.
  final String? line;

  /// Defaults to `civilian` gold; Mafia steps pass `mafia`.
  final Color? accent;

  /// Extra content under the line (a "Blocked tonight" warning).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final a = accent ?? c.civilian;
    final soft = a == c.mafia ? c.mafiaSoft : (a == c.civilian ? c.civilianSoft : a);
    return AnimatedContainer(
      duration: Motion.base,
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: c.tint(a, 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.tint(a, 0.16),
              borderRadius: BorderRadius.circular(Radii.iconBoxLg),
            ),
            child: MafiaIcon(glyph, size: 26, color: soft),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.type.titleLarge),
                if (line != null) ...[
                  const SizedBox(height: Space.xs),
                  Text(
                    context.l10n.quoted(line!),
                    style: context.type.bodyMedium!.copyWith(
                      color: Color.lerp(c.textMuted, c.text, 0.55),
                    ),
                  ),
                ],
                if (footer != null) ...[const SizedBox(height: Space.sm), footer!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 76 px countdown ring, 6 px stroke, time in the display face.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.remaining,
    required this.total,
    required this.label,
    this.onTap,
    this.semanticLabel,
  });

  final Duration remaining;
  final Duration total;

  /// Under the time ("left", "paused").
  final String label;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final secs = remaining.inSeconds.clamp(0, 359999);
    final mm = context.number(secs ~/ 60);
    final ss = context.twoDigits(secs % 60);
    final fraction = total.inMilliseconds == 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? '$mm:$ss $label',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 76,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: fraction,
              track: c.veil(0.10),
              color: remaining == Duration.zero ? c.mafia : c.primaryCta,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '$mm:$ss',
                      style: context.type.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: context.type.bodySmall!.copyWith(fontSize: TextSizes.note, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.track, required this.color});

  final double fraction;
  final Color track, color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 6.2832, false, p..color = track);
    if (fraction > 0) {
      canvas.drawArc(rect, -1.5708, 6.2832 * fraction, false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}
