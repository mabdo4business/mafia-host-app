import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Glass card: surface fill, 1 px border, radius 24, padding 18.
/// With [tintColor] it becomes a team/event card (tinted fill and border).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.tintColor,
    this.padding = const EdgeInsetsDirectional.all(18),
    this.radius = Radii.card,
    this.fillOpacity = 0.10,
    this.borderOpacity = 0.30,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final Color? tintColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double fillOpacity;
  final double borderOpacity;

  /// Replaces the fill (hero cards).
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final tint = tintColor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: tint == null ? c.surfaceBorder : c.tint(tint, borderOpacity)),
    );
    final content = Padding(padding: padding, child: child);
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: ShapeDecoration(
          shape: shape,
          color: gradient != null ? null : (tint == null ? c.surface : c.tint(tint, fillOpacity)),
          gradient: gradient,
        ),
        child: onTap == null ? content : InkWell(customBorder: shape, onTap: onTap, child: content),
      ),
    );
  }
}

/// A soft radial glow placed off-screen at a corner, behind content.
/// One per screen.
class Glow {
  const Glow({
    required this.color,
    this.top = -140,
    this.end = -120,
    this.start,
    this.size = 380,
    this.fade = 0.70,
  });

  final Color color;
  final double top;
  final double? end;

  /// Set to anchor to the start side instead of [end].
  final double? start;
  final double size;

  /// Where the gradient reaches zero, as a fraction of the radius.
  final double fade;
}

class _GlowLayer extends StatelessWidget {
  const _GlowLayer(this.glow);

  final Glow glow;

  @override
  Widget build(BuildContext context) => PositionedDirectional(
    top: glow.top,
    start: glow.start,
    end: glow.start == null ? glow.end : null,
    width: glow.size,
    height: glow.size,
    child: IgnorePointer(
      child: AnimatedContainer(
        duration: Motion.phaseChange,
        curve: Motion.ease,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [glow.color, glow.color.withValues(alpha: 0)],
            // The mockups' CSS `radial-gradient(circle, … fade%)` measures
            // stops against the corner distance (radius × √2), Flutter
            // against the radius: scale so glows match the mockup size.
            stops: [0, math.min(1, glow.fade * math.sqrt2)],
          ),
        ),
      ),
    ),
  );
}

/// Page frame for every screen: phase background (optionally the dawn
/// gradient), one glow, safe-area body and a bottom-anchored action area.
class PhaseScaffold extends StatelessWidget {
  const PhaseScaffold({
    super.key,
    required this.body,
    this.glow,
    this.dawn = false,
    this.backdrop,
    this.bottom,
    this.bottomPadding,
    this.transparent = false,
  });

  final Widget body;

  /// Paints no background or glow: the page sits on a shared sky (the game
  /// flow's [PhaseSky]).
  final bool transparent;
  final Glow? glow;

  /// Paints `bgTop → bg` (Morning).
  final bool dawn;

  /// Decorative layer behind content (e.g. the rising sun).
  final Widget? backdrop;

  /// Primary action area, pinned to the bottom with thumb-reach padding.
  final Widget? bottom;
  final EdgeInsetsGeometry? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      backgroundColor: transparent ? Colors.transparent : c.bg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: transparent ? null : c.bg,
          gradient: dawn
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.bgTop, Color.lerp(c.bgTop, c.bg, 0.55)!, c.bg],
                  stops: const [0, 0.38, 1],
                )
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (glow != null && !transparent) _GlowLayer(glow!),
            ?backdrop,
            Column(
              children: [
                Expanded(
                  // Ink (list tiles, splashes) paints on this, above the
                  // background, instead of the Scaffold's Material below it.
                  child: Material(
                    type: MaterialType.transparency,
                    child: SafeArea(bottom: false, child: body),
                  ),
                ),
                if (bottom != null)
                  Padding(
                    padding:
                        bottomPadding ??
                        EdgeInsetsDirectional.fromSTEB(
                          Space.page,
                          Space.md,
                          Space.page,
                          safeBottom > 0 ? Space.bottomAction : Space.xl,
                        ),
                    child: bottom,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Uppercase, letter-spaced label above a title ("MORNING 3", "DEALING ROLES").
class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color, this.wide = false});

  final String text;
  final Color? color;

  /// Wider tracking for phase overlines (0.14em).
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final style = context.type.labelSmall!;
    return Text(
      text.toUpperCase(),
      style: style.copyWith(
        color: color ?? style.color,
        fontSize: TextSizes.overline,
        letterSpacing: wide ? 1.8 : 0.8,
      ),
    );
  }
}

/// Section title ("Your table", "Roles") with an optional trailing link.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(text, style: context.type.titleMedium)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: c.civilian,
              minimumSize: const Size(48, 40),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.sm),
              textStyle: context.type.labelMedium!.copyWith(fontWeight: FontWeight.w500),
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

/// Small rounded pill: "● TONIGHT", "MAFIA TEAM".
class TagPill extends StatelessWidget {
  const TagPill(this.text, {super.key, required this.color, this.textColor, this.dot = false});

  final String text;
  final Color color;
  final Color? textColor;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.md, vertical: 6),
      decoration: BoxDecoration(
        color: c.tint(color, 0.16),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text.toUpperCase(),
            style: context.type.labelSmall!.copyWith(
              color: textColor ?? color,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// A rounded rectangle border drawn with dashes.
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({required this.color, required this.radius, this.dash = 4, this.gap = 4});

  final Color color;
  final double radius;
  final double dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) => old.color != color || old.radius != radius;
}
