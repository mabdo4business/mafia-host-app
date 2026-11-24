import 'package:material_ui/material_ui.dart';

/// A thin-stroke icon drawn from SVG path data on a 24×24 grid (the mockups'
/// own icon paths), 1.8 px stroke with round caps and joins.
///
/// Set [mirrorInRtl] for directional glyphs (arrows, chevrons, the moon).
class MafiaIcon extends StatelessWidget {
  const MafiaIcon(
    this.glyph, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth,
    this.semanticLabel,
  });

  final MafiaGlyph glyph;
  final double size;
  final Color? color;

  /// Stroke width in 24-grid units; defaults to the glyph's own.
  final double? strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color!;
    final mirror = glyph.directional && Directionality.of(context) == TextDirection.rtl;
    Widget icon = CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(glyph, c, strokeWidth ?? glyph.strokeWidth),
    );
    if (mirror) icon = Transform.flip(flipX: true, child: icon);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(dimension: size, child: icon),
    );
  }
}

/// An icon shape: one or more SVG path strings on a 24×24 viewBox.
@immutable
class MafiaGlyph {
  const MafiaGlyph(
    this.paths, {
    this.filled = false,
    this.directional = false,
    this.strokeWidth = 1.8,
  });

  final List<String> paths;
  final bool filled;
  final bool directional;
  final double strokeWidth;
}

/// The app's icon set. Paths come from docs/design/mockups.
abstract final class MafiaGlyphs {
  // Navigation and actions.
  static const back = MafiaGlyph(['m15 6-6 6 6 6'], directional: true, strokeWidth: 2);
  static const forward = MafiaGlyph(['m9 6 6 6-6 6'], directional: true, strokeWidth: 2);
  static const arrow = MafiaGlyph(['M5 12h14', 'm13 6 6 6-6 6'], directional: true, strokeWidth: 2);
  static const shuffle = MafiaGlyph([
    'M16 3h5v5M4 20 21 3M21 16v5h-5M15 15l6 6M4 4l5 5',
  ], strokeWidth: 2);
  static const plus = MafiaGlyph(['M12 5v14M5 12h14'], strokeWidth: 2);
  static const minus = MafiaGlyph(['M5 12h14'], strokeWidth: 2);
  static const close = MafiaGlyph(['M6 6l12 12M18 6 6 18'], strokeWidth: 2);
  static const check = MafiaGlyph(['m5 12 5 5 9-10'], strokeWidth: 2);
  static const undo = MafiaGlyph(['M9 14 4 9l5-5', 'M4 9h11a5 5 0 0 1 0 10h-3'], directional: true);
  static const grip = MafiaGlyph(['M5 9h14M5 15h14'], strokeWidth: 2);
  static const more = MafiaGlyph(['M12 5h.01M12 12h.01M12 19h.01'], strokeWidth: 3);
  static const bell = MafiaGlyph([
    'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9',
    'M10.3 21a1.94 1.94 0 0 0 3.4 0',
  ]);
  static const lock = MafiaGlyph([
    'M6 11h12a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-6a2 2 0 0 1 2-2z',
    'M8 11V7a4 4 0 0 1 8 0v4',
  ]);
  static const speaker = MafiaGlyph([
    'M11 5 6 9H2v6h4l5 4z',
    'M15.5 8.5a5 5 0 0 1 0 7M19 5a10 10 0 0 1 0 14',
  ]);
  static const stop = MafiaGlyph([
    'M8 7h8a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H8a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1z',
  ]);
  static const log = MafiaGlyph(['M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01']);
  static const timer = MafiaGlyph([
    'M12 8v5l3 2',
    'M12 4a9 9 0 1 0 0 18 9 9 0 0 0 0-18z',
    'M10 2h4',
  ]);
  static const eyeOff = MafiaGlyph([
    'M3 3l18 18',
    'M10.6 6.1A10 10 0 0 1 12 6c6 0 9.5 6 9.5 6a17 17 0 0 1-2.6 3.3M6.6 6.6C3.9 8.3 2.5 12 2.5 12s3.5 6 9.5 6a9.7 9.7 0 0 0 5.4-1.6',
    'M9.9 9.9a3 3 0 0 0 4.2 4.2',
  ]);
  static const qr = MafiaGlyph([
    'M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4z',
    'M14 14h2v2h-2zM18 14h2M14 18h2M18 18h2v2M20 14v2',
  ]);
  static const vote = MafiaGlyph([
    'M9 12l2 2 4-4',
    'M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z',
  ]);
  static const skull = MafiaGlyph([
    'M12 3a8 8 0 0 0-8 8c0 2.6 1.3 4.5 3 5.6V20h10v-3.4c1.7-1.1 3-3 3-5.6a8 8 0 0 0-8-8z',
    'M9 12h.01M15 12h.01M10 20v-2M14 20v-2',
  ], strokeWidth: 1.8);
  static const shield = MafiaGlyph(['M12 3 5 6v6c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6z']);
  static const sparkle = MafiaGlyph(['M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z']);

  // Navigation bar.
  static const home = MafiaGlyph(['M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z']);
  static const calendar = MafiaGlyph([
    'M6 5h12a3 3 0 0 1 3 3v10a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3V8a3 3 0 0 1 3-3z',
    'M8 3v4M16 3v4M3 10h18',
  ]);
  static const players = MafiaGlyph([
    'M9 4a4 4 0 1 0 0 8 4 4 0 0 0 0-8z',
    'M2 21a7 7 0 0 1 14 0',
    'M16 4a4 4 0 0 1 0 8M22 21a7 7 0 0 0-4-6.3',
  ]);
  static const settings = MafiaGlyph([
    'M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z',
    'M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 0 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 0 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 0 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 0 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z',
  ]);
  static const trophy = MafiaGlyph([
    'M8 21h8M12 17v4',
    'M7 4h10v5a5 5 0 0 1-10 0z',
    'M17 6h3a3 3 0 0 1-3 4M7 6H4a3 3 0 0 0 3 4',
  ]);

  // Phases.
  static const moon = MafiaGlyph(
    ['M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5z'],
    filled: true,
    directional: true,
  );
  static const sun = MafiaGlyph([
    'M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z',
    'M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
  ]);

  // Results.
  static const mafiaWon = MafiaGlyph(['M3 10h18l-2-5H5z', 'M7 10v2a5 5 0 0 0 10 0v-2']);
  static const star = MafiaGlyph([
    'M12 3l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.4 6.8 19.1l1-5.8L3.5 9.2l5.9-.9z',
  ]);

  // Roles.
  static const godfather = MafiaGlyph(['M3 16h18M6 16l1.5-8h9L18 16M8 12h8']);
  static const putana = MafiaGlyph(['M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM5.6 5.6l12.8 12.8']);
  static const lawyer = MafiaGlyph([
    'M12 3v18M5 7h14M5 7l-3 6a3 3 0 0 0 6 0zM19 7l-3 6a3 3 0 0 0 6 0zM8 21h8',
  ]);
  static const mafia = MafiaGlyph(['M14 4l6 6-9 9-4 1 1-4z']);
  static const doctor = MafiaGlyph(['M9 3h6v6h6v6h-6v6H9v-6H3V9h6z']);
  static const detective = MafiaGlyph(['M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM21 21l-5-5']);
  static const bomb = MafiaGlyph(['M11 8a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM15 6l2-2M19 3v1M21 6h-1']);
  static const joker = MafiaGlyph([
    'M4 5h16v6a8 8 0 0 1-16 0zM8 14c1.5 1.5 6.5 1.5 8 0M8.5 9h.01M15.5 9h.01',
  ]);
  static const chameleon = MafiaGlyph([
    'M4 9a8 8 0 0 1 14-3l2 2M20 15a8 8 0 0 1-14 3l-2-2M20 4v4h-4M4 20v-4h4',
  ]);

  /// Two linked rings: the Witch's linked souls.
  static const witch = MafiaGlyph([
    'M9 7a5 5 0 1 0 0 10 5 5 0 0 0 0-10z',
    'M15 7a5 5 0 1 0 0 10 5 5 0 0 0 0-10z',
  ]);

  /// A track switching: the Switchman sends the bullet on.
  static const switchman = MafiaGlyph([
    'M4 20 12 12V4',
    'm8 8 4-4 4 4',
    'M12 12l8 8',
    'M16 20h4v-4',
  ]);

  /// A crossed-out speech bubble: the Silencer.
  static const silencer = MafiaGlyph([
    'M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z',
    'M4 4l16 16',
  ]);

  /// Turning arrows: the Shapeshifter's rotating role.
  static const shapeshifter = MafiaGlyph([
    'M20 11a8 8 0 0 0-14.3-4.9L4 8',
    'M4 4v4h4',
    'M4 13a8 8 0 0 0 14.3 4.9L20 16',
    'M20 20v-4h-4',
  ]);

  /// Two sticks and a fuse: TNT.
  static const tnt = MafiaGlyph([
    'M5 10h5v10H5zM14 10h5v10h-5z',
    'M7.5 10V7c0-2 2-3 4-3',
    'M14 3l1 1M17 3v1',
  ]);

  static const civilian = MafiaGlyph(['M12 4a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM4 21a8 8 0 0 1 16 0']);
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.strokeWidth);

  final MafiaGlyph glyph;
  final Color color;
  final double strokeWidth;

  static final Map<String, Path> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = glyph.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final d in glyph.paths) {
      canvas.drawPath(_cache.putIfAbsent(d, () => parseSvgPath(d)), paint);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.strokeWidth != strokeWidth;
}

/// Parses SVG path data (M L H V C S Q A Z, absolute and relative).
Path parseSvgPath(String d) {
  final tokens = RegExp(
    r'[MmLlHhVvCcSsQqAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?',
  ).allMatches(d).map((m) => m[0]!).toList();
  final path = Path();
  var i = 0;
  var cmd = 'M';
  var cur = Offset.zero, start = Offset.zero, lastCtrl = Offset.zero;
  var lastCmd = '';
  bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  double n() => double.parse(tokens[i++]);
  bool flag() => n() != 0;

  while (i < tokens.length) {
    if (isCmd(tokens[i])) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    Offset pt(double x, double y) => rel ? cur + Offset(x, y) : Offset(x, y);
    switch (cmd.toUpperCase()) {
      case 'M':
        cur = start = pt(n(), n());
        path.moveTo(cur.dx, cur.dy);
        cmd = rel ? 'l' : 'L'; // subsequent pairs are line-tos
      case 'L':
        cur = pt(n(), n());
        path.lineTo(cur.dx, cur.dy);
      case 'H':
        final x = n();
        cur = Offset(rel ? cur.dx + x : x, cur.dy);
        path.lineTo(cur.dx, cur.dy);
      case 'V':
        final y = n();
        cur = Offset(cur.dx, rel ? cur.dy + y : y);
        path.lineTo(cur.dx, cur.dy);
      case 'C':
        final c1 = pt(n(), n()), c2 = pt(n(), n()), end = pt(n(), n());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCtrl = c2;
        cur = end;
      case 'S':
        final c1 = 'CS'.contains(lastCmd.toUpperCase()) ? cur * 2 - lastCtrl : cur;
        final c2 = pt(n(), n()), end = pt(n(), n());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCtrl = c2;
        cur = end;
      case 'Q':
        final c = pt(n(), n()), end = pt(n(), n());
        path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
        lastCtrl = c;
        cur = end;
      case 'A':
        final rx = n(), ry = n(), rot = n();
        final large = flag(), sweep = flag();
        final end = pt(n(), n());
        path.arcToPoint(
          end,
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: large,
          clockwise: sweep,
        );
        cur = end;
      case 'Z':
        path.close();
        cur = start;
    }
    lastCmd = cmd;
  }
  return path;
}
