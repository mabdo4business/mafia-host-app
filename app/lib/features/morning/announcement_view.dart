import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_menu.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import 'bomb_picker.dart';

/// The read-aloud screen after a night (Morning) or a vote (Day result):
/// numbered announcement items appearing one by one, host-only notes, the
/// alive / eliminated count, and the CTA to move on. A pending Bomb first
/// takes over with the victims picker.
class AnnouncementView extends ConsumerWidget {
  const AnnouncementView({
    super.key,
    required this.session,
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.ctaKey,
    required this.ctaLabel,
    required this.ctaGlyph,
    this.topSpace = 0,
  });

  final GameSession session;
  final String overline;
  final String title;
  final String subtitle;
  final Key ctaKey;
  final String ctaLabel;
  final MafiaGlyph ctaGlyph;

  /// Room above the title (the rising sun on Morning).
  final double topSpace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = session.state.pendingBombs;
    if (pending.isNotEmpty) {
      return BombPicker(key: ValueKey(pending.first), session: session, bombId: pending.first);
    }
    final l = context.l10n;
    final c = context.mafia;
    final describe = Describer(l, session.state);
    final round = session.latestRound;
    final items = describe.announcementItems(round);
    final notes = describe.secretNotes(round);
    final alive = session.state.alivePlayers.length;
    final dead = session.state.players.length - alive;
    final numberStyle = context.type.bodyLarge!.copyWith(fontSize: TextSizes.row, fontWeight: FontWeight.w700);

    return PhaseScaffold(
      transparent: true,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsetsDirectional.fromSTEB(20, topSpace, 20, Space.lg),
            children: [
              Column(
                children: [
                  Overline(overline, color: c.civilianSoft, wide: true),
                  const SizedBox(height: 6),
                  Text(title, textAlign: TextAlign.center, style: context.type.headlineLarge),
                  const SizedBox(height: 6),
                  Text(subtitle, style: context.type.bodyMedium!.copyWith(color: c.textMuted)),
                ],
              ),
              const SizedBox(height: 26),
              for (final (i, item) in items.indexed) ...[
                AnnouncementItem(
                  index: i + 1,
                  kind: AnnouncementKind.values.byName(item.type.name),
                  headline: item.headline,
                  detail: item.detail,
                  chips: item.chips,
                  delay: Motion.announceStagger * i,
                ),
                const SizedBox(height: 10),
              ],
              for (final note in notes) ...[HostOnlyNote(text: note), const SizedBox(height: 10)],
              const SizedBox(height: Space.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(_count(context, alive, l.countAlive(alive), numberStyle)),
                  const SizedBox(width: 18),
                  Text.rich(_count(context, dead, l.countEliminated(dead), numberStyle)),
                ],
              ),
            ],
          ),
          PositionedDirectional(
            top: Space.sm,
            end: Space.page,
            child: GameMenuButton(session: session),
          ),
        ],
      ),
      bottom: PrimaryActionButton(
        key: ctaKey,
        label: ctaLabel,
        trailing: ctaGlyph,
        onPressed: () => ref.read(activeGameProvider.notifier).apply(const AdvanceInput()),
      ),
    );
  }

  /// "**6** alive": the localized phrase with its number in bold.
  TextSpan _count(BuildContext context, int n, String phrase, TextStyle bold) {
    final digits = context.number(n);
    final at = phrase.indexOf(digits);
    final base = context.type.bodySmall!;
    if (at < 0) return TextSpan(text: phrase, style: base);
    return TextSpan(
      style: base,
      children: [
        TextSpan(text: phrase.substring(0, at)),
        TextSpan(text: digits, style: bold),
        TextSpan(text: phrase.substring(at + digits.length)),
      ],
    );
  }
}
