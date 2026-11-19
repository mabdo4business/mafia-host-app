import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../ui/ui.dart';
import '../events/events_screen.dart';
import '../home/home_screen.dart';
import '../players/leaderboard_screen.dart';
import '../settings/settings_screen.dart';

/// The app's tabs (Home, Events, Players, Settings) under the floating nav.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    return Material(
      color: c.bg,
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _tab,
              children: [
                HomeScreen(onSeeStats: () => setState(() => _tab = 2)),
                const EventsScreen(),
                const LeaderboardScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: FloatingNavBar(
              key: const Key('mainNav'),
              current: _tab,
              items: [
                NavItem(MafiaGlyphs.home, l.navHome),
                NavItem(MafiaGlyphs.calendar, l.navEvents),
                NavItem(MafiaGlyphs.players, l.navPlayers),
                NavItem(MafiaGlyphs.settings, l.settingsTitle),
              ],
              onSelect: (i) => setState(() => _tab = i),
            ),
          ),
        ],
      ),
    );
  }
}
