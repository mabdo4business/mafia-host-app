import 'package:material_ui/material_ui.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../common/l10n.dart';
import '../theme/app_theme.dart';
import 'haptics.dart';
import 'mafia_icon.dart';

/// A role in the setup grid: 64 h tile with a tinted icon box, the role name
/// and a count badge. Mafia badge is solid red, Civilian badge gold tint, and
/// a role with count 0 is dimmed.
///
/// Tap adds one, long-press removes one (also exposed as semantic
/// increase/decrease actions).
class RoleChip extends StatelessWidget {
  const RoleChip({
    super.key,
    required this.glyph,
    required this.name,
    required this.team,
    required this.count,
    this.selected = false,
    this.showCount = true,
    this.onTap,
    this.onLongPress,
  });

  /// False for pickers (Chameleon choice): no badge, never dimmed.
  final bool showCount;

  final MafiaGlyph glyph;
  final String name;
  final Team team;
  final int count;

  /// Picked state (Chameleon choice): a 2 px team border.
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final mafia = team == Team.mafia;
    final off = showCount && count == 0 && !selected;
    final accent = mafia ? c.mafia : c.civilian;
    final soft = mafia ? c.mafiaSoft : c.civilianSoft;
    final dim = c.textMuted.withValues(alpha: 0.65);

    final bg = off ? c.veil(0.02) : (mafia ? c.tint(c.mafia, 0.07) : c.surface);
    final border = selected
        ? accent
        : off
        ? c.veil(0.05)
        : (mafia ? c.tint(c.mafia, 0.22) : c.surfaceBorder);
    final iconBg = off ? c.veil(0.05) : c.tint(accent, mafia ? 0.18 : 0.16);
    final (badgeBg, badgeFg) = off
        ? (c.veil(0.06), c.textMuted.withValues(alpha: 0.85))
        : mafia
        ? (c.mafia, c.onAccent(c.mafia))
        : (c.tint(c.civilian, 0.18), c.civilianSoft);
    final radius = BorderRadius.circular(Radii.tile);

    return Semantics(
      button: true,
      selected: selected,
      label: showCount ? '$name, ${context.number(count)}' : name,
      excludeSemantics: true,
      onIncrease: onTap,
      onDecrease: onLongPress,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.ease,
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap == null
                ? null
                : () {
                    Haptics.selection();
                    onTap!();
                  },
            onLongPress: onLongPress == null
                ? null
                : () {
                    Haptics.selection();
                    onLongPress!();
                  },
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(Radii.iconBox),
                    ),
                    child: MafiaIcon(glyph, size: 18, color: off ? dim : soft),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        name,
                        maxLines: 1,
                        style: context.type.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: off ? c.textMuted : c.text,
                        ),
                      ),
                    ),
                  ),
                  if (showCount) const SizedBox(width: Space.sm),
                  if (showCount)
                    AnimatedContainer(
                      duration: Motion.fast,
                      constraints: const BoxConstraints(minWidth: 28),
                      height: 28,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(Radii.chip),
                      ),
                      child: Text(
                        context.number(count),
                        style: context.type.labelMedium!.copyWith(
                          color: badgeFg,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
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

/// Mafia vs Civilians split: a 10 px bar (red | gold, 3 px gap) with the
/// team counts under it and a note in the middle.
class TeamBalanceBar extends StatelessWidget {
  const TeamBalanceBar({
    super.key,
    required this.mafia,
    required this.civilians,
    this.note,
    this.warning = false,
  });

  final int mafia;
  final int civilians;

  /// Middle label ("Balanced for 11").
  final String? note;

  /// Shows the note in red (unbalanced).
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final l = context.l10n;
    final label = context.type.labelMedium!;
    Widget seg(int flex, Color color) => Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 10,
          child: mafia + civilians == 0
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.veil(0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              : Row(
                  children: [
                    if (mafia > 0) seg(mafia, c.mafia),
                    if (mafia > 0 && civilians > 0) const SizedBox(width: 3),
                    if (civilians > 0) seg(civilians, c.civilian),
                  ],
                ),
        ),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            Text(
              l.teamCount(l.teamMafia, context.number(mafia)),
              style: label.copyWith(color: c.mafiaSoft),
            ),
            Expanded(
              child: Text(
                note ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: label.copyWith(
                  fontWeight: FontWeight.w400,
                  color: warning ? c.mafiaSoft : c.textMuted,
                ),
              ),
            ),
            Text(
              l.teamCount(l.teamCivilians, context.number(civilians)),
              style: label.copyWith(color: c.civilianSoft),
            ),
          ],
        ),
      ],
    );
  }
}

/// Segmented control on a faint track; the selected segment is a solid
/// light fill with a dark label.
///
/// [dense] is the compact inline form (Bomb 2 / 3): 44×36 segments.
class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.dense = false,
  });

  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T>? onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final segRadius = BorderRadius.circular(dense ? Radii.chip : Radii.iconBox);
    Widget seg(T value, String label) {
      final on = value == selected;
      return Semantics(
        button: true,
        selected: on,
        inMutuallyExclusiveGroup: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: segRadius,
            onTap: onChanged == null || on
                ? null
                : () {
                    Haptics.selection();
                    onChanged!(value);
                  },
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.ease,
              height: dense ? 36 : Sizes.iconButton,
              width: dense ? Sizes.iconButton : null,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? c.text : c.text.withValues(alpha: 0),
                borderRadius: segRadius,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.bodyMedium!.copyWith(
                  height: 1.2,
                  color: on ? c.onText : Color.lerp(c.textMuted, c.text, 0.2),
                  fontWeight: on ? (dense ? FontWeight.w700 : FontWeight.w600) : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsetsDirectional.all(Space.xs),
      decoration: BoxDecoration(
        color: c.veil(dense ? 0.06 : 0.05),
        borderRadius: BorderRadius.circular(dense ? 14 : Radii.iconBoxLg),
      ),
      child: Row(
        mainAxisSize: dense ? MainAxisSize.min : MainAxisSize.max,
        children: [
          for (final (i, (value, label)) in segments.indexed) ...[
            if (i > 0) const SizedBox(width: Space.xs),
            if (dense) seg(value, label) else Expanded(child: seg(value, label)),
          ],
        ],
      ),
    );
  }
}

/// A number with a label under it; optional team/event tint.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label, this.tint});

  final String value;
  final String label;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final t = tint;
    final soft = t == null
        ? c.text
        : t == c.mafia
        ? c.mafiaSoft
        : t == c.civilian
        ? c.civilianSoft
        : t;
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(
          color: t == null ? c.surface : c.tint(t, 0.08),
          borderRadius: BorderRadius.circular(Radii.tile),
          border: Border.all(color: t == null ? c.veil(0.07) : c.tint(t, 0.21)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, style: context.type.headlineMedium!.copyWith(color: soft)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.bodySmall!.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
