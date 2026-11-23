import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'mafia_icon.dart';

/// One tab in [FloatingNavBar].
class NavItem {
  const NavItem(this.glyph, this.label);

  final MafiaGlyph glyph;
  final String label;
}

/// Floating bottom navigation: 64 h, radius 22, over a fade to the page
/// background.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.current,
    required this.onSelect,
  });

  final List<NavItem> items;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.bg.withValues(alpha: 0), c.bg],
          stops: const [0, 0.4],
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          Space.page,
          Space.md,
          Space.page,
          safeBottom > 0 ? 30 : Space.lg,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Color.alphaBlend(c.veil(0.06), c.bg).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.surfaceBorder),
          ),
          child: Row(
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == current,
                    label: item.label,
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => onSelect(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MafiaIcon(
                            item.glyph,
                            size: 22,
                            color: i == current ? c.text : c.textMuted.withValues(alpha: 0.85),
                          ),
                          const SizedBox(height: Space.xs),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.labelSmall!.copyWith(
                              fontSize: TextSizes.caption,
                              letterSpacing: 0,
                              height: 1.2,
                              color: i == current ? c.text : c.textMuted.withValues(alpha: 0.85),
                              fontWeight: i == current ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
