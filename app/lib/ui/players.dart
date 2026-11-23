import 'package:material_ui/material_ui.dart';

import '../common/l10n.dart';
import '../theme/app_theme.dart';
import 'haptics.dart';

/// "LA" for Layla, "AS" for Abu Saleh, "ل" for ليلى (Arabic letters join, so
/// one letter reads better than two).
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  final first = words.first.characters;
  if (RegExp(r'[؀-ۿ]').hasMatch(first.first)) return first.first;
  if (words.length > 1) return (first.first + words[1].characters.first).toUpperCase();
  return first.take(2).toString().toUpperCase();
}

/// A round initials avatar.
class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = Sizes.avatar, this.color, this.ring});

  final String name;
  final double size;

  /// Solid fill for highlighted states (selected = gold, leader = red).
  final Color? color;

  /// Border matching the surface behind, for overlapping stacks.
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final initials = initialsOf(name);
    final arabic = !RegExp(r'[A-Za-z]').hasMatch(initials);
    final fill = color ?? c.avatar;
    return AnimatedContainer(
      duration: Motion.fast,
      curve: Motion.ease,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: ring == null ? null : Border.all(color: ring!, width: 2),
      ),
      child: Text(
        initials,
        style: context.type.labelSmall!.copyWith(
          color: color == null ? c.onAvatar : c.onAccent(fill),
          fontSize: (size * (arabic ? 0.42 : 0.36)).roundToDouble(),
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}

/// Overlapping avatars with an optional "+8" bubble.
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.names, this.extra = 0, this.ring});

  final List<String> names;
  final int extra;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    const size = 30.0, overlap = 8.0;
    final ringColor = ring ?? c.bg;
    final count = names.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      height: size,
      width: count == 0 ? 0 : size + (count - 1) * (size - overlap),
      child: Stack(
        children: [
          for (final (i, n) in names.indexed)
            PositionedDirectional(
              start: i * (size - overlap),
              child: Avatar(n, size: size, ring: ringColor),
            ),
          if (extra > 0)
            PositionedDirectional(
              start: names.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.civilian,
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 2),
                ),
                child: Text(
                  '+${context.number(extra)}',
                  style: context.type.labelSmall!.copyWith(
                    color: c.onAccent(c.civilian),
                    fontSize: TextSizes.caption,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A player in a target grid. 80 h, radius 18.
///
/// - selected: 2 px accent border, tinted fill, accent avatar.
/// - disabled: 0.45 opacity with a [note] saying why; [struck] crosses out
///   the name (eliminated players).
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    this.selected = false,
    this.enabled = true,
    this.struck = false,
    this.note,
    this.accent,
    this.dots = 0,
    this.dotColor,
    this.onTap,
    this.onLongPress,
  });

  /// Secondary gesture (marking a Mafia proposal).
  final VoidCallback? onLongPress;

  final String name;
  final bool selected;
  final bool enabled;
  final bool struck;
  final String? note;

  /// Selection color; defaults to `civilian` gold. Mafia steps pass `mafia`,
  /// the Bomb picker `bomb`.
  final Color? accent;

  /// Small vote dots (Mafia proposals) shown at the top end corner.
  final int dots;
  final Color? dotColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final a = accent ?? c.civilian;
    final tappable = enabled && onTap != null;
    final radius = BorderRadius.circular(Radii.tile);
    final noteStyle = context.type.bodySmall!.copyWith(fontSize: TextSizes.note, height: 1.2);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: note == null ? name : '$name, $note',
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: Motion.fast,
        opacity: enabled ? 1 : 0.45,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.ease,
          height: Sizes.playerTile,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: selected ? c.tint(a, 0.14) : c.surface,
            borderRadius: radius,
            border: Border.all(color: selected ? a : c.surfaceBorder, width: selected ? 2 : 1),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: tappable
                  ? () {
                      Haptics.selection();
                      onTap!();
                    }
                  : null,
              onLongPress: enabled && onLongPress != null
                  ? () {
                      Haptics.light();
                      onLongPress!();
                    }
                  : null,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: Space.xs,
                      vertical: Space.xs,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Avatar(name, color: selected ? a : null),
                        SizedBox(height: note == null ? 6 : Space.xs),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.labelMedium!.copyWith(
                            height: 1.2,
                            decoration: struck ? TextDecoration.lineThrough : null,
                            decorationColor: c.text,
                          ),
                        ),
                        if (note != null)
                          Text(
                            note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: noteStyle,
                          ),
                      ],
                    ),
                  ),
                  if (dots > 0)
                    PositionedDirectional(
                      top: Space.sm,
                      end: Space.sm,
                      child: Row(
                        children: [
                          for (var i = 0; i < dots; i++)
                            Container(
                              margin: const EdgeInsetsDirectional.only(start: 3),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: dotColor ?? a,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
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

/// Three-column grid of [PlayerTile]s, gap 8.
class PlayerTargetGrid extends StatelessWidget {
  const PlayerTargetGrid({super.key, required this.children, this.columns = 3});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      const gap = Space.sm;
      final w = (box.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final t in children) SizedBox(width: w.floorToDouble(), child: t)],
      );
    },
  );
}

/// A Day-vote row: 64 h, the vote share fills from the start edge; the
/// leader gets a red border and red avatar.
class VoteRow extends StatelessWidget {
  const VoteRow({
    super.key,
    required this.name,
    required this.votes,
    required this.total,
    this.leader = false,
    this.onTap,
  });

  final String name;
  final int votes;

  /// Number of voters; the fill is `votes / total`.
  final int total;
  final bool leader;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final radius = BorderRadius.circular(Radii.tile);
    final share = total == 0 ? 0.0 : (votes / total).clamp(0.0, 1.0);
    return Semantics(
      button: true,
      label: '$name, ${context.l10n.voteCount(votes)}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: Motion.fast,
        height: 64,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: radius,
          border: Border.all(
            color: leader ? c.tint(c.mafia, 0.6) : c.surfaceBorder,
            width: leader ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      Haptics.light();
                      onTap!();
                    },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: AnimatedFractionallySizedBox(
                      duration: Motion.base,
                      curve: Motion.ease,
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: share,
                      child: ColoredBox(
                        color: leader ? c.tint(c.mafia, 0.22) : c.tint(c.primaryCta, 0.12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Avatar(name, size: Sizes.avatarLg, color: leader ? c.mafia : null),
                        const SizedBox(width: Space.md),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.bodyLarge!.copyWith(fontSize: TextSizes.row),
                          ),
                        ),
                        Text(
                          context.number(votes),
                          style: context.type.titleLarge!.copyWith(
                            fontSize: TextSizes.count,
                            color: leader
                                ? c.mafiaSoft
                                : votes > 0
                                ? c.civilianSoft
                                : c.textMuted.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
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
