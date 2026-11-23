import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

import '../common/l10n.dart';
import '../theme/app_theme.dart';
import 'mafia_icon.dart';
import 'surfaces.dart';

enum AnnouncementKind { death, bomb, save, info }

/// One numbered line of the morning (or day result) announcement, on a card
/// tinted by event type: death = mafia, bomb = bomb, save = saved.
///
/// With [delay] it enters on its own (fade + rise; deaths also scale in from
/// 0.96), so a list can stagger by `Motion.announceStagger`.
class AnnouncementItem extends StatelessWidget {
  const AnnouncementItem({
    super.key,
    required this.index,
    required this.kind,
    required this.headline,
    this.detail,
    this.chips = const [],
    this.delay,
  });

  final int index;
  final AnnouncementKind kind;
  final String headline;
  final String? detail;

  /// Names shown as chips (Bomb victims).
  final List<String> chips;
  final Duration? delay;

  static Color colorOf(MafiaColors c, AnnouncementKind k) => switch (k) {
    AnnouncementKind.death => c.mafia,
    AnnouncementKind.bomb => c.bomb,
    AnnouncementKind.save => c.saved,
    AnnouncementKind.info => c.primaryCta,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final color = colorOf(c, kind);
    final card = Container(
      padding: const EdgeInsetsDirectional.all(Space.lg),
      decoration: BoxDecoration(
        color: kind == AnnouncementKind.info ? c.surface : c.tint(color, 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: kind == AnnouncementKind.info
              ? c.surfaceBorder
              : c.tint(color, kind == AnnouncementKind.bomb ? 0.40 : 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              context.number(index),
              style: context.type.labelMedium!.copyWith(
                color: c.onAccent(color),
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: context.type.bodyLarge),
                if (detail != null) ...[
                  SizedBox(height: chips.isEmpty ? Space.xs : Space.sm),
                  Text(detail!, style: context.type.bodySmall),
                ],
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: [
                      for (final name in chips)
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: Space.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: c.veil(0.08),
                            borderRadius: BorderRadius.circular(Radii.chip),
                          ),
                          child: Text(
                            name,
                            style: context.type.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    final d = delay;
    if (d == null || MediaQuery.disableAnimationsOf(context)) return card;
    var a = card
        .animate(delay: d)
        .fadeIn(duration: Motion.base, curve: Motion.ease)
        .moveY(begin: 12, end: 0, duration: Motion.base, curve: Motion.ease);
    if (kind == AnnouncementKind.death || kind == AnnouncementKind.bomb) {
      a = a.scaleXY(begin: 0.96, end: 1, duration: Motion.base, curve: Motion.ease);
    }
    return a;
  }
}

/// Information only the host may see (the Detective result), in a dashed
/// box with a lock. Never put this on a screen shown to players.
///
/// [highlight] is a substring of [text] drawn bold (the player's name).
class HostOnlyNote extends StatelessWidget {
  const HostOnlyNote({super.key, required this.text, this.highlight});

  final String text;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final style = context.type.bodySmall!;
    final h = highlight;
    final at = h == null || h.isEmpty ? -1 : text.indexOf(h);
    final span = at < 0
        ? TextSpan(text: text)
        : TextSpan(
            children: [
              TextSpan(text: text.substring(0, at)),
              TextSpan(
                text: h,
                style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
              ),
              TextSpan(text: text.substring(at + h!.length)),
            ],
          );
    return CustomPaint(
      painter: DashedBorderPainter(color: c.veil(0.18), radius: Radii.tile),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg, vertical: 14),
        decoration: BoxDecoration(
          color: c.scrim(0x4D / 255), // black 30%
          borderRadius: BorderRadius.circular(Radii.tile),
        ),
        child: Row(
          children: [
            MafiaIcon(MafiaGlyphs.lock, size: 20, color: c.textMuted),
            const SizedBox(width: Space.md),
            Expanded(child: Text.rich(span, style: style)),
          ],
        ),
      ),
    );
  }
}
