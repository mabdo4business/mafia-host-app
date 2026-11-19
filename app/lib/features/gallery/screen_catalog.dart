// Debug-only: the main screens in seeded states matching the mockups in
// docs/design/mockups, for the /gallery route, the simulator comparison
// (`flutter run --route /gallery/screen/<id>`) and the screen goldens.

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/database.dart';
import '../../data/game_repository.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../day/day_view.dart';
import '../home/home_screen.dart';
import '../morning/morning_view.dart';
import '../night/night_wizard.dart';
import '../setup/reveal_screen.dart';
import '../setup/setup_screen.dart';
import 'component_catalog.dart';

class ScreenScenario {
  const ScreenScenario(this.id, this.build);

  final String id;

  /// Builds the screen with its own seeded provider scope.
  final Widget Function(BuildContext context) build;
}

/// The mockups' table: 11 players, Mafia 3 (Omar, Khalid, Hamad).
List<Player> _table(BuildContext context) {
  final n = sampleNames(context);
  const roles = [
    Role.civilian, // Layla
    Role.potana, // Omar
    Role.civilian, // Sara
    Role.lawyer, // Khalid
    Role.civilian, // Yousef
    Role.civilian, // Noor
    Role.bomb, // Faisal
    Role.detective, // Huda
    Role.joker, // Ali
    Role.doctor, // Mariam
    Role.godfather, // Hamad
  ];
  return [
    for (var i = 0; i < roles.length; i++)
      Player(id: 'p$i', name: i == 10 ? (_isAr(context) ? 'حمد' : 'Hamad') : n[i], role: roles[i]),
  ];
}

bool _isAr(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';

/// Night 1: the Joker kills Khalid (the Lawyer). Night 2: the Doctor saves
/// Noor from the Mafia.
/// Now night 3 (Khalid out, Noor "saved last night").
GameSession _night3(BuildContext context) => GameSession.replay(
  1,
  GameSetup(
    players: _table(context),
    settings: const GameSettings(bombVictimCount: 2),
    discussionSeconds: 180,
  ),
  const [
    NightInput([JokerKill('p8', 'p3'), DoctorSave('p9', 'p0')]),
    AdvanceInput(),
    TallyVoteInput({}),
    AdvanceInput(),
    NightInput([MafiaKill('p10', 'p5'), DoctorSave('p9', 'p5')]),
    AdvanceInput(),
    TallyVoteInput({}),
    AdvanceInput(),
  ],
);

/// Night 3: the Mafia kills Yousef, the Joker kills Faisal (the Bomb, who
/// takes Ali and Huda), the Detective checks Sara.
GameSession _morning3(BuildContext context) => _night3(context)
    .apply(
      const NightInput([
        MafiaKill('p10', 'p4'),
        JokerKill('p8', 'p6'),
        DoctorSave('p9', 'p0'),
        DetectiveCheck('p7', 'p2'),
      ]),
    )
    .apply(const BombInput('p6', ['p8', 'p7']));

GameSession _day3(BuildContext context) => _morning3(context).apply(const AdvanceInput());

class _FixedGame extends ActiveGameController {
  _FixedGame(this.session);

  final GameSession? session;

  @override
  Future<GameSession?> build() async => session;
}

class _FixedSetup extends SetupController {
  _FixedSetup(this.draft);

  final SetupDraft draft;

  @override
  SetupDraft build() => draft;
}

Widget _scope(GameSession? session, Widget child, {List<Override> more = const []}) =>
    ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
        activeGameProvider.overrideWith(() => _FixedGame(session)),
        ...more,
      ],
      child: child,
    );

Widget _stage(GameSession s, Widget view) => _scope(s, GameStageFrame(session: s, child: view));

final List<ScreenScenario> screenCatalog = [
  ScreenScenario('home', (context) {
    final names = sampleNames(context).take(11).toList();
    return _scope(
      null,
      const HomeScreen(),
      more: [
        tableStatsProvider.overrideWith(
          (ref) async => const TableStats(games: 48, mafiaWins: 22, civilianWins: 26),
        ),
        recentGamesProvider.overrideWith(
          (ref) async => [
            GameSummary(
              id: 2,
              playedAt: DateTime(2026, 11, 14),
              winner: Team.mafia,
              nights: 4,
              players: 11,
            ),
            GameSummary(
              id: 1,
              playedAt: DateTime(2026, 11, 14),
              winner: Team.civilians,
              nights: 6,
              players: 11,
            ),
          ],
        ),
        lastPlayerNamesProvider.overrideWith((ref) async => names),
      ],
    );
  }),
  ScreenScenario('setup', (context) {
    final names = sampleNames(context).take(10).toList()..add(_isAr(context) ? 'حمد' : 'Hamad');
    return _scope(
      null,
      const SetupScreen(),
      more: [
        setupDraftProvider.overrideWith(
          () => _FixedSetup(
            SetupDraft(
              names: names,
              mix: {
                ...suggestedRoleMix(11),
                Role.godfather: 1,
                Role.potana: 1,
                Role.lawyer: 1,
                Role.bomb: 1,
                Role.joker: 1,
                Role.chameleon: 1,
              },
              customMix: true,
              settings: const GameSettings(bombVictimCount: 3),
            ),
          ),
        ),
      ],
    );
  }),
  ScreenScenario('reveal', (context) {
    final table = _table(context);
    // Seat 3 holds the Godfather card in the mockup.
    final dealt = [
      for (final (i, p) in table.indexed)
        Player(
          id: p.id,
          name: i == 3 ? table[0].name : (i == 0 ? table[3].name : p.name),
          role: i == 3 ? Role.godfather : (i == 10 ? Role.civilian : p.role),
        ),
    ];
    return _scope(
      null,
      RevealScreen(
        names: [for (final p in dealt) p.name],
        mix: const {},
        settings: const GameSettings(),
        discussionSeconds: 0,
        dealt: dealt,
        initialIndex: 3,
        initiallyRevealed: true,
      ),
    );
  }),
  ScreenScenario('reveal_back', (context) {
    final table = _table(context);
    return _scope(
      null,
      RevealScreen(
        names: [for (final p in table) p.name],
        mix: const {},
        settings: const GameSettings(),
        discussionSeconds: 0,
        dealt: table,
        initialIndex: 3,
      ),
    );
  }),
  ScreenScenario('night', (context) {
    final s = _night3(context);
    // Steps: Potana, Mafia, Joker, Doctor (3), Detective.
    return _stage(s, NightWizard(session: s, initialIndex: 3));
  }),
  ScreenScenario('morning', (context) {
    final s = _morning3(context);
    return _stage(s, MorningView(session: s));
  }),
  ScreenScenario('day_vote', (context) {
    final s = _day3(context);
    return _stage(s, DayView(session: s, initialTally: const {'p1': 3, 'p2': 2, 'p5': 1}));
  }),
];
