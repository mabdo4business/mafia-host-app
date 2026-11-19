import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_session.dart';
import '../../ui/ui.dart';
import 'announcement_view.dart';

/// The morning after a night, under the rising sun.
class MorningView extends StatelessWidget {
  const MorningView({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnnouncementView(
      session: session,
      overline: l.stageMorning(session.round),
      title: l.morningTitle,
      subtitle: l.morningReadInOrder,
      ctaKey: const Key('startDay'),
      ctaLabel: l.morningStartDay,
      ctaGlyph: MafiaGlyphs.arrow,
      // The sky draws the sun rising over a horizon 220 px down; the text
      // starts just under it so nothing is read off the bright disc.
      topSpace: 228 - MediaQuery.viewPaddingOf(context).top,
    );
  }
}
