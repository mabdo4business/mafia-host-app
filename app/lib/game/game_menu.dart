import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../common/l10n.dart';
import '../common/widgets.dart';
import '../features/game_log/game_log_screen.dart';
import 'game_input.dart';
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

/// The "⋯" button on game screens: game log, undo, remove a player, end
/// game, home.
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
                if (_canRemove) item(_MenuAction.remove, MafiaGlyphs.skull, l.menuRemovePlayer),
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
      case _MenuAction.remove:
        final id = await _pickPlayer(context);
        if (id == null || !context.mounted) return;
        final name = session.state.player(id).name;
        if (!await confirm(
          context,
          title: l.removePlayerConfirmTitle(name),
          body: l.removePlayerConfirmBody,
          confirmLabel: l.removePlayerConfirm,
        )) {
          return;
        }
        await controller.apply(RemoveInput(id));
      case _MenuAction.home:
        Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  /// The host may remove a player for repeatedly breaking the table rules
  /// (GAME_RULES §3), by day or while announcing.
  bool get _canRemove =>
      const {GameStage.morning, GameStage.day, GameStage.dayResult}.contains(session.stage) &&
      session.state.pendingChoices.isEmpty;

  Future<String?> _pickPlayer(BuildContext context) {
    final c = context.mafia;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Color.alphaBlend(c.veil(0.05), c.bg),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.button)),
      ),
      builder: (context) {
        final l = context.l10n;
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.xl, Space.page, Space.xl),
          children: [
            Text(l.menuRemovePlayer, style: context.type.headlineSmall),
            const SizedBox(height: Space.sm),
            Text(l.removePlayerHint, style: context.type.bodySmall),
            const SizedBox(height: Space.lg),
            PlayerTargetGrid(
              children: [
                for (final p in session.state.alivePlayers)
                  PlayerTile(
                    key: Key('remove_${p.id}'),
                    name: p.name,
                    accent: c.mafia,
                    onTap: () => Navigator.pop(context, p.id),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

enum _MenuAction { log, undo, remove, end, home }
