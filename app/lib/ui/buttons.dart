import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'mafia_icon.dart';

/// What the bottom action does, which sets its color.
enum ActionTone {
  /// The phase CTA: gold at night, amber by day.
  phase,

  /// Eliminations and Mafia actions: red.
  danger,

  /// Quiet, light fill without a glow ("Hide & pass to next player").
  neutral,

  /// Bomb detonation: orange.
  bomb,
}

/// Full-width, bottom-anchored primary action: 60 h, radius 20, soft colored
/// shadow. Pass `onPressed: null` for the disabled ("Pick a player…") state.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = ActionTone.phase,
    this.trailing,
    this.height = Sizes.primaryButton,
    this.radius = Radii.button,
  });

  final String label;
  final VoidCallback? onPressed;
  final ActionTone tone;
  final MafiaGlyph? trailing;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final enabled = onPressed != null;
    final (Color bg, Color fg) = switch (tone) {
      _ when !enabled => (c.veil(0.06), c.textMuted.withValues(alpha: 0.85)),
      ActionTone.phase => (c.primaryCta, c.onPrimaryCta),
      ActionTone.danger => (c.mafia, c.onAccent(c.mafia)),
      ActionTone.bomb => (c.bomb, c.onAccent(c.bomb)),
      ActionTone.neutral => (c.text, c.onText),
    };
    final glow = enabled && tone != ActionTone.neutral;
    final style = context.type.labelLarge!.copyWith(
      color: fg,
      fontWeight: enabled ? FontWeight.w700 : FontWeight.w600,
      fontSize: enabled ? null : TextSizes.row,
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.ease,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: glow ? bg.withValues(alpha: 0.32) : bg.withValues(alpha: 0),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (trailing != null && enabled) ...[
                    const SizedBox(width: 10),
                    MafiaIcon(trailing!, size: 18, color: fg),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round glass icon button for headers (44×44), or the larger square-ish
/// bottom-bar variant (60×60, radius 20) via [IconCircleButton.large].
/// A [semanticLabel] is required: the icon has no text.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.glyph,
    required this.semanticLabel,
    required this.onPressed,
    this.badge = false,
  }) : size = Sizes.iconButton,
       radius = Sizes.iconButton / 2,
       filled = true;

  const IconCircleButton.large({
    super.key,
    required this.glyph,
    required this.semanticLabel,
    required this.onPressed,
    this.filled = false,
  }) : size = Sizes.primaryButton,
       radius = Radii.button,
       badge = false;

  final MafiaGlyph glyph;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;
  final double radius;
  final bool filled;

  /// A small dot for unread state (notifications).
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: c.veil(filled ? 0.10 : 0.12)),
    );
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: semanticLabel,
        excludeFromSemantics: true,
        child: Opacity(
          opacity: onPressed == null ? 0.4 : 1,
          child: Material(
            shape: shape,
            color: filled ? c.veil(0.04) : Colors.transparent,
            child: InkWell(
              customBorder: shape,
              onTap: onPressed,
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MafiaIcon(glyph, size: size > 50 ? 22 : 20, color: c.text),
                    if (badge)
                      PositionedDirectional(
                        top: 10,
                        end: 11,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: c.mafia, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded pill button with text ("Game log").
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({super.key, required this.label, required this.onPressed, this.glyph});

  final String label;
  final VoidCallback? onPressed;
  final MafiaGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final shape = StadiumBorder(side: BorderSide(color: c.veil(0.10)));
    return Material(
      shape: shape,
      color: c.veil(0.04),
      child: InkWell(
        customBorder: shape,
        onTap: onPressed,
        child: Container(
          height: 40,
          constraints: const BoxConstraints(minWidth: 48),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (glyph != null) ...[
                MafiaIcon(glyph!, size: 16, color: c.textMuted),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: context.type.labelMedium!.copyWith(
                  color: c.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
