import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../common/l10n.dart';
import '../common/widgets.dart';
import '../features/game_log/game_log_screen.dart';
import '../ui/ui.dart';
import 'game_session.dart';
import 'providers.dart';

/// Opens the game log.
/// The log route keeps the current phase theme (it is pushed above the game
/// flow's AnimatedTheme).
void openGameLog(BuildContext context) {
  final theme = Theme.of(context);
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => Theme(data: theme, child: const GameLogScreen()),
    ),
  );
}

/// The "⋯" button on game screens: game log, undo, end game, home.
class GameMenuButton extends ConsumerWidget {
  const GameMenuButton({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return IconCircleButton(
      key: const Key('gameMenu'),
      glyph: MafiaGlyphs.more,
      semanticLabel: l.menuMore,
      onPressed: () => _open(context, ref),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final c = context.mafia;
    final controller = ref.read(activeGameProvider.notifier);
    final action = await showModalBottomSheet<_MenuAction>(
      context: context,
      backgroundColor: Color.alphaBlend(c.veil(0.05), c.bg),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.button)),
      ),
      builder: (context) {
        Widget item(_MenuAction a, MafiaGlyph glyph, String label, {bool enabled = true}) =>
            ListTile(
              key: Key('menu_${a.name}'),
              enabled: enabled,
              minTileHeight: 56,
              leading: MafiaIcon(glyph, color: enabled ? c.text : c.textMuted),
              title: Text(label, style: context.type.bodyLarge),
              onTap: () => Navigator.pop(context, a),
            );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: Space.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                item(_MenuAction.log, MafiaGlyphs.log, l.logTitle),
                item(_MenuAction.undo, MafiaGlyphs.undo, l.menuUndo, enabled: session.canUndo),
                if (session.stage != GameStage.gameOver)
                  item(_MenuAction.end, MafiaGlyphs.close, l.menuEndGame),
                item(_MenuAction.home, MafiaGlyphs.home, l.menuHome),
              ],
            ),
          ),
        );
      },
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _MenuAction.log:
        openGameLog(context);
      case _MenuAction.undo:
        await controller.undo();
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l.undoDone)));
        }
      case _MenuAction.end:
        if (!await confirm(
          context,
          title: l.endGameConfirmTitle,
          body: l.endGameConfirmBody,
          confirmLabel: l.menuEndGame,
        )) {
          return;
        }
        await controller.abandon();
        if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
      case _MenuAction.home:
        Navigator.popUntil(context, (route) => route.isFirst);
    }
  }
}

enum _MenuAction { log, undo, end, home }
