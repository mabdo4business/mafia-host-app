import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_session.dart';
import '../../ui/ui.dart';
import '../morning/announcement_view.dart';

/// The vote result (and a Bomb explosion if the Bomb was voted out), then
/// on to the next night.
class DayResultView extends StatelessWidget {
  const DayResultView({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnnouncementView(
      session: session,
      overline: l.stageDay(session.round),
      title: l.dayResultTitle,
      subtitle: l.morningReadInOrder,
      ctaKey: const Key('startNight'),
      ctaLabel: l.dayStartNight(session.state.nightNumber),
      ctaGlyph: MafiaGlyphs.moon,
      topSpace: Space.xxxl,
    );
  }
}
