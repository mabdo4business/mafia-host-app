import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../theme/app_theme.dart';
import 'haptics.dart';
import 'mafia_icon.dart';

/// The emblem for each role.
MafiaGlyph roleGlyph(Role r) => switch (r) {
  Role.godfather => MafiaGlyphs.godfather,
  Role.mafia => MafiaGlyphs.mafia,
  Role.putana => MafiaGlyphs.putana,
  Role.lawyer => MafiaGlyphs.lawyer,
  Role.witch => MafiaGlyphs.witch,
  Role.detective => MafiaGlyphs.detective,
  Role.doctor => MafiaGlyphs.doctor,
  Role.joker => MafiaGlyphs.joker,
  Role.switchman => MafiaGlyphs.switchman,
  Role.silencer => MafiaGlyphs.silencer,
  Role.bomb => MafiaGlyphs.bomb,
  Role.shapeshifter => MafiaGlyphs.shapeshifter,
  Role.chameleon => MafiaGlyphs.chameleon,
  Role.tnt => MafiaGlyphs.tnt,
  Role.civilian => MafiaGlyphs.civilian,
};

/// Team accent and its light text tone.
(Color, Color) teamColors(MafiaColors c, Team t) =>
    t == Team.mafia ? (c.mafia, c.mafiaSoft) : (c.civilian, c.civilianSoft);

/// The secret role card: 270×390, radius 28, 3D flip.
///
/// Face down it shows the gold crest and "TAP TO REVEAL". Face up: team pill,
/// 104 px emblem, role name, ability text and, for the Mafia, "Your family".
/// Flipping face up triggers a medium haptic.
class RoleCard extends StatefulWidget {
  const RoleCard({
    super.key,
    required this.revealed,
    required this.onTap,
    required this.team,
    required this.teamLabel,
    required this.roleName,
    required this.ability,
    required this.glyph,
    required this.backTitle,
    required this.backHint,
    required this.semanticLabel,
    this.familyLabel,
    this.family = const [],
  });

  final bool revealed;
  final VoidCallback? onTap;
  final Team team;
  final String teamLabel;
  final String roleName;
  final String ability;
  final MafiaGlyph glyph;
  final String backTitle;
  final String backHint;

  /// "Reveal role" / "Hide role".
  final String semanticLabel;
  final String? familyLabel;

  /// "Omar · Putana" chips (Mafia only).
  final List<String> family;

  static const size = Size(270, 390);

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: Motion.cardFlip,
    value: widget.revealed ? 1 : 0,
  );

  @override
  void didUpdateWidget(RoleCard old) {
    super.didUpdateWidget(old);
    if (old.revealed == widget.revealed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _flip.value = widget.revealed ? 1 : 0;
    } else if (widget.revealed) {
      _flip.animateTo(1, curve: Motion.flip);
    } else {
      _flip.animateBack(0, curve: Motion.flip);
    }
    if (widget.revealed) Haptics.medium();
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.semanticLabel,
    child: GestureDetector(
      onTap: widget.onTap,
      child: SizedBox.fromSize(
        size: RoleCard.size,
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            final angle = _flip.value * math.pi;
            final showFront = angle > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: ExcludeSemantics(excluding: !widget.revealed, child: _front(context)),
                    )
                  : ExcludeSemantics(child: _back(context)),
            );
          },
        ),
      ),
    ),
  );

  Widget _back(BuildContext context) {
    final c = context.mafia;
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.veil(0.05), c.bg),
        borderRadius: BorderRadius.circular(Radii.hero),
        border: Border.all(color: c.veil(0.12)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsetsDirectional.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.button),
                border: Border.all(color: c.tint(c.civilian, 0.30)),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(size: const Size.square(96), painter: _CrestPainter(c.civilian)),
                const SizedBox(height: 20),
                Text(
                  widget.backTitle.toUpperCase(),
                  style: context.type.titleMedium!.copyWith(color: c.civilian, letterSpacing: 3),
                ),
                const SizedBox(height: 20),
                Text(widget.backHint, style: context.type.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _front(BuildContext context) {
    final c = context.mafia;
    final (accent, soft) = teamColors(c, widget.team);
    final surface = Color.alphaBlend(c.veil(0.05), c.bg);
    final withFamily = widget.family.isNotEmpty;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(Space.xl, 28, Space.xl, Space.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.hero),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color.alphaBlend(c.tint(accent, 0.16), c.bg), surface],
          stops: const [0, 0.6],
        ),
        border: Border.all(color: c.tint(accent, 0.45)),
        boxShadow: [
          BoxShadow(color: c.tint(accent, 0.25), blurRadius: 80, offset: const Offset(0, 30)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.md, vertical: 6),
            decoration: BoxDecoration(
              color: c.tint(accent, 0.18),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Text(
              widget.teamLabel.toUpperCase(),
              style: context.type.labelSmall!.copyWith(
                color: soft,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Container(
            // Smaller emblem when the family row needs the room.
            width: withFamily ? 84 : 104,
            height: withFamily ? 84 : 104,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.tint(accent, 0.14),
              border: Border.all(color: c.tint(accent, 0.4)),
            ),
            child: MafiaIcon(
              widget.glyph,
              size: withFamily ? 46 : 56,
              color: soft,
              strokeWidth: 1.4,
            ),
          ),
          const SizedBox(height: Space.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.roleName,
              maxLines: 1,
              style: context.type.displayMedium!.copyWith(color: context.mafia.veil(1)),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            // As many lines as fit; the card never grows.
            child: LayoutBuilder(
              builder: (context, box) {
                final style = context.type.bodyMedium!.copyWith(color: c.onAvatar, height: 1.5);
                final line = style.fontSize! * style.height!;
                return Text(
                  widget.ability,
                  textAlign: TextAlign.center,
                  maxLines: (box.maxHeight / line).floor().clamp(1, 8),
                  overflow: TextOverflow.ellipsis,
                  style: style,
                );
              },
            ),
          ),
          if (widget.family.isNotEmpty)
            Container(
              padding: const EdgeInsetsDirectional.only(top: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.veil(0.08))),
              ),
              child: Column(
                children: [
                  if (widget.familyLabel != null)
                    Text(
                      widget.familyLabel!.toUpperCase(),
                      style: context.type.labelSmall!.copyWith(letterSpacing: 0.8),
                    ),
                  const SizedBox(height: Space.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        for (final (i, f) in widget.family.indexed) ...[
                          if (i > 0) const SizedBox(width: Space.sm),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: c.veil(0.06),
                              borderRadius: BorderRadius.circular(Radii.chip),
                            ),
                            child: Text(f, style: context.type.bodySmall!.copyWith(color: c.text)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Gold crest on the card back: ring, dashed ring and the hat.
class _CrestPainter extends CustomPainter {
  _CrestPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 96);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const center = Offset(48, 48);
    canvas.drawCircle(center, 40, p);
    // Dashed inner ring: 3 on, 5 off.
    const r = 30.0;
    const circumference = 2 * math.pi * r;
    for (var d = 0.0; d < circumference; d += 8) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), d / r, 3 / r, false, p);
    }
    final hat = parseSvgPath('M30 58h36M36 58l3-18h18l3 18M40 50h16');
    canvas.drawPath(hat, p);
  }

  @override
  bool shouldRepaint(_CrestPainter old) => old.color != color;
}
