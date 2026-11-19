import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';

/// The table's players in seating order: add, remove, drag to reorder.
Future<void> showPlayersSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Color.alphaBlend(context.mafia.veil(0.05), context.mafia.bg),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.button)),
  ),
  builder: (_) => const PlayersSheet(),
);

class PlayersSheet extends ConsumerStatefulWidget {
  const PlayersSheet({super.key});

  @override
  ConsumerState<PlayersSheet> createState() => _PlayersSheetState();
}

class _PlayersSheetState extends ConsumerState<PlayersSheet> {
  final _name = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    if (ref.read(setupDraftProvider.notifier).addPlayer(_name.text)) _name.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final names = ref.watch(setupDraftProvider).names;
    final controller = ref.read(setupDraftProvider.notifier);
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.xl, Space.page, 0),
              child: Row(
                children: [
                  Expanded(child: Text(l.setupPlayersSection, style: context.type.headlineSmall)),
                  Text(l.playerCount(names.length), style: context.type.bodySmall),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.lg, Space.page, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('playerNameField'),
                      controller: _name,
                      focusNode: _focus,
                      autofocus: names.isEmpty,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      style: context.type.bodyLarge,
                      decoration: InputDecoration(
                        hintText: l.setupPlayerNameHint,
                        hintStyle: context.type.bodyLarge!.copyWith(color: c.textMuted),
                        filled: true,
                        fillColor: c.surface,
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          horizontal: Space.lg,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                          borderSide: BorderSide(color: c.surfaceBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                          borderSide: BorderSide(color: c.civilian, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  IconCircleButton.large(
                    glyph: MafiaGlyphs.plus,
                    semanticLabel: l.setupAddPlayer,
                    filled: true,
                    onPressed: _add,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                // Symmetric, so LTR insets are direction-safe here.
                padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.xl),
                buildDefaultDragHandles: false,
                itemCount: names.length,
                onReorderItem: controller.reorder,
                proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
                itemBuilder: (context, i) => Padding(
                  key: ValueKey(names[i]),
                  padding: const EdgeInsetsDirectional.only(bottom: Space.sm),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsetsDirectional.only(start: Space.md),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(c.surface, c.bg),
                      borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                      border: Border.all(color: c.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            context.number(i + 1),
                            style: context.type.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: Space.sm),
                        Avatar(names[i]),
                        const SizedBox(width: Space.md),
                        Expanded(
                          child: Text(
                            names[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.bodyLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: l.setupRemovePlayer,
                          onPressed: () => controller.removePlayer(i),
                          icon: MafiaIcon(MafiaGlyphs.close, size: 18, color: c.textMuted),
                        ),
                        ReorderableDragStartListener(
                          index: i,
                          child: SizedBox.square(
                            dimension: 48,
                            child: Center(
                              child: MafiaIcon(MafiaGlyphs.grip, size: 18, color: c.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
