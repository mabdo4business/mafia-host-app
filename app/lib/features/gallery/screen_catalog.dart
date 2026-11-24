// Debug-only: the main screens in seeded states matching the mockups in
// docs/design/mockups, for the /gallery route, the simulator comparison
// (`flutter run --route /gallery/screen/<id>`) and the screen goldens.

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/speech.dart';
import '../../data/database.dart';
import '../../data/game_repository.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../day/day_view.dart';
import '../events/event_detail_screen.dart';
import '../events/events_screen.dart';
import '../game_log/game_log_screen.dart';
import '../game_over/game_over_view.dart';
import '../home/join_room_screen.dart';
import '../day/day_result_view.dart';
import '../night/detective_result_screen.dart';
import '../players/leaderboard_screen.dart';
import '../players/player_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../shell/main_shell.dart';
import '../morning/morning_view.dart';
import '../night/night_steps.dart';
import '../night/night_wizard.dart';
import '../setup/assign_cards_screen.dart';
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
    Role.putana, // Omar
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
/// Noor from the Mafia; the Bomb plants on Huda and Ali. Now night 3.
GameSession _night3(BuildContext context) => GameSession.replay(
  1,
  GameSetup(players: _table(context), settings: const GameSettings()),
  const [
    NightInput([JokerKill('p8', 'p3'), DoctorSave('p9', 'p0')]),
    AdvanceInput(),
    TallyVoteInput({}),
    AdvanceInput(),
    NightInput([MafiaKill('p10', 'p5'), DoctorSave('p9', 'p5'), BombPlant('p6', 'p7', 'p8')]),
    AdvanceInput(),
    TallyVoteInput({}),
    AdvanceInput(),
  ],
);

/// Night 3: the Mafia kills Yousef, the Joker kills Faisal (the Bomb, whose
/// charges take Huda and Ali), the Detective checks Sara.
GameSession _morning3(BuildContext context) => _night3(context).apply(
  const NightInput([
    MafiaKill('p10', 'p4'),
    JokerKill('p8', 'p6'),
    DoctorSave('p9', 'p0'),
    DetectiveCheck('p7', 'p2'),
  ]),
);

GameSession _day3(BuildContext context) => _morning3(context).apply(const AdvanceInput());

/// The guide's newer roles at one table: Mafia Team Omar (Witch), Khalid
/// (Mafia), Hamad (Godfather).
List<Player> _guideTable(BuildContext context) {
  final n = sampleNames(context);
  const roles = [
    Role.civilian, // Layla
    Role.witch, // Omar
    Role.silencer, // Sara
    Role.mafia, // Khalid
    Role.tnt, // Yousef
    Role.shapeshifter, // Noor
    Role.switchman, // Faisal
    Role.detective, // Huda
    Role.chameleon, // Ali
    Role.doctor, // Mariam
    Role.godfather, // Hamad
  ];
  return [
    for (var i = 0; i < roles.length; i++)
      Player(id: 'p$i', name: i == 10 ? (_isAr(context) ? 'حمد' : 'Hamad') : n[i], role: roles[i]),
  ];
}

GameSession _guide(BuildContext context, [List<GameInput> inputs = const []]) => GameSession.replay(
  2,
  GameSetup(players: _guideTable(context), settings: const GameSettings()),
  inputs,
);

/// Day 1 after the Silencer silenced Layla.
GameSession _guideDay1(BuildContext context) => _guide(context, const [
  NightInput([SilencerSilence('p2', 'p0')]),
  AdvanceInput(),
]);

GameSession _guideNight(BuildContext context, int night) => _guide(context, [
  for (var i = 1; i < night; i++) ...const [
    NightInput([]),
    AdvanceInput(),
    TallyVoteInput({}),
    AdvanceInput(),
  ],
]);

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
        speakerProvider.overrideWithValue(RecordingSpeaker()),
        // Evening, as in the mockups ("Good evening, Host").
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 14, 21)),
        ...more,
      ],
      child: child,
    );

Widget _stage(GameSession s, Widget view) => _scope(s, GameStageFrame(session: s, child: view));

/// Day 3: the town votes out Omar; the Godfather then takes out two more.
GameSession _mafiaWins(BuildContext context) => _day3(context)
    .apply(const TallyVoteInput({'p0': 4}))
    .apply(const AdvanceInput())
    .apply(const NightInput([MafiaKill('p10', 'p5')]));

GameSession _civiliansWin(BuildContext context) => _day3(context)
    .apply(const TallyVoteInput({'p1': 4}))
    .apply(const AdvanceInput())
    .apply(const NightInput([MafiaKill('p10', 'p0')]))
    .apply(const AdvanceInput())
    .apply(const TallyVoteInput({'p10': 3}))
    .apply(const ChoiceInput('p10', []));

/// History for the Events, Leaderboard and Profile screens.
List<PlayerRecord> _records(BuildContext context) {
  final names = sampleNames(context);
  const stats = [(9, 7), (8, 5), (7, 4), (9, 4), (6, 3), (5, 2), (4, 1)];
  return [
    for (final (i, (games, wins)) in stats.indexed)
      PlayerRecord(name: names[i], lastPlayed: DateTime(2026, 11, 14))
        ..games = games
        ..wins = wins
        ..roles.addAll({
          Role.civilian: games - 3,
          if (i.isEven) Role.godfather: 2 else Role.detective: 2,
          Role.doctor: 1,
        }),
  ];
}

List<GameNight> _nights(BuildContext context) {
  final names = sampleNames(context).take(10).toList();
  GameNight night(DateTime d, List<Team> winners) => GameNight(date: d)
    ..players.addAll(names)
    ..games.addAll([
      for (final (i, w) in winners.indexed)
        GameSummary(
          id: i,
          playedAt: d.add(Duration(hours: 21, minutes: 40 * i)),
          winner: w,
          nights: 3 + i,
          players: names.length,
        ),
    ]);
  return [
    night(DateTime(2026, 11, 14), [Team.mafia, Team.civilians, Team.civilians]),
    night(DateTime(2026, 11, 7), [Team.civilians, Team.mafia]),
    night(DateTime(2026, 10, 31), [Team.mafia]),
  ];
}

Widget _history(BuildContext context, Widget child) => _scope(
  null,
  child,
  more: [
    playerRecordsProvider.overrideWith((ref) async => _records(context)),
    gameNightsProvider.overrideWith((ref) async => _nights(context)),
    lastPlayerNamesProvider.overrideWith((ref) async => sampleNames(context).take(11).toList()),
  ],
);

final List<ScreenScenario> screenCatalog = [
  ScreenScenario('home', (context) {
    final names = sampleNames(context).take(11).toList();
    return _scope(
      null,
      const MainShell(),
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
        playerRecordsProvider.overrideWith((ref) async => _records(context)),
        gameNightsProvider.overrideWith((ref) async => _nights(context)),
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
                Role.putana: 1,
                Role.lawyer: 1,
                Role.bomb: 1,
                Role.joker: 1,
                Role.chameleon: 1,
              },
              customMix: true,
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
        dealt: table,
        initialIndex: 3,
      ),
    );
  }),
  // Cards mode: the Mafia team is recorded; the Doctor is waking.
  ScreenScenario('cards', (context) => _cards(context, mafiaOnly: true)),
  ScreenScenario('cards_check', (context) => _cards(context, mafiaOnly: false)),
  ScreenScenario('night', (context) {
    final s = _night3(context);
    // Steps: Putana, Mafia, Joker, Doctor (3), Detective.
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
  ScreenScenario('night_mafia', (context) {
    final s = _night3(context);
    return _stage(s, NightWizard(session: s, initialIndex: 1));
  }),
  ScreenScenario('night_recognition', (context) {
    final s = _guide(context);
    return _stage(s, NightWizard(session: s, initialIndex: 0));
  }),
  ScreenScenario('night_witch', (context) {
    final s = _guideNight(context, 2);
    // Steps: Mafia, Witch (1), Silencer, Doctor, Shapeshifter, Detective.
    return _stage(
      s,
      NightWizard(
        session: s,
        initialIndex: 1,
        initialPartial: const {
          'witch:p1': ['p4'],
        },
      ),
    );
  }),
  ScreenScenario('night_chameleon', (context) {
    final s = _guideNight(context, 3);
    // Steps: Mafia, Silencer, Doctor, Shapeshifter, Detective, Chameleon (5).
    return _stage(
      s,
      NightWizard(
        session: s,
        initialIndex: 5,
        initialChoices: const {'chameleon:p8': NightPick.role(Role.switchman)},
      ),
    );
  }),
  ScreenScenario('night_switchman', (context) {
    final s = _guide(context);
    // The Mafia shot Faisal (the Switchman), who is woken last (6).
    return _stage(
      s,
      NightWizard(
        session: s,
        initialIndex: 6,
        initialChoices: const {
          'mafia': NightPick.players(['p6']),
        },
      ),
    );
  }),
  ScreenScenario('day_free_chat', (context) {
    final s = _guideDay1(context);
    return _stage(s, DayView(session: s));
  }),
  ScreenScenario('day_speech', (context) {
    final s = _guideDay1(context).apply(const FoulInput('p3'));
    // Layla is silenced, so Khalid speaks third.
    return _stage(s, DayView(session: s, initialPart: DayPart.speeches, initialSpeaker: 2));
  }),
  ScreenScenario('day_revote', (context) {
    final s = _guideDay1(context).apply(const TallyVoteInput({'p1': 3, 'p3': 3}));
    return _stage(s, DayView(session: s));
  }),
  ScreenScenario('choice_godfather', (context) {
    final s = _guideDay1(context).apply(const TallyVoteInput({'p10': 5}));
    return _stage(s, DayResultView(session: s));
  }),
  ScreenScenario('choice_bomb', (context) {
    final s = GameSession.replay(
      1,
      GameSetup(players: _table(context), settings: const GameSettings()),
      const [
        NightInput([]),
        AdvanceInput(),
        TallyVoteInput({'p6': 5}),
      ],
    );
    return _stage(s, DayResultView(session: s));
  }),
  ScreenScenario('detective', (context) {
    return _scope(
      null,
      DetectiveResultScreen(targetName: sampleNames(context)[1], result: DetectiveResult.mafia),
    );
  }),
  ScreenScenario('detective_blocked', (context) {
    return _scope(null, DetectiveResultScreen(targetName: sampleNames(context)[1], result: null));
  }),
  ScreenScenario('game_over_mafia', (context) {
    final s = _mafiaWins(context);
    return _stage(s, GameOverView(session: s));
  }),
  ScreenScenario('game_over_civilians', (context) {
    final s = _civiliansWin(context);
    return _stage(s, GameOverView(session: s));
  }),
  ScreenScenario('game_log', (context) {
    final s = _day3(context);
    return _scope(s, const GameLogScreen());
  }),
  ScreenScenario('events', (context) => _history(context, const EventsScreen())),
  ScreenScenario(
    'event_detail',
    (context) => _history(context, EventDetailScreen(night: _nights(context).first)),
  ),
  ScreenScenario('leaderboard', (context) => _history(context, const LeaderboardScreen())),
  ScreenScenario(
    'profile',
    (context) => _history(context, PlayerProfileScreen(name: sampleNames(context).first)),
  ),
  ScreenScenario('settings', (context) => _scope(null, const SettingsScreen())),
  ScreenScenario('join_room', (context) => _scope(null, const JoinRoomScreen())),
];

Widget _cards(BuildContext context, {required bool mafiaOnly}) {
  final table = _table(context);
  final mix = <Role, int>{};
  for (final p in table) {
    if (p.role != Role.civilian) mix[p.role] = (mix[p.role] ?? 0) + 1;
  }
  final cards = {
    for (final (i, p) in table.indexed)
      if (p.role != Role.civilian && (!mafiaOnly || p.role.team == Team.mafia)) i: p.role,
  };
  final order = cardWakeOrder(mix);
  return _scope(
    null,
    AssignCardsScreen(
      names: [for (final p in table) p.name],
      mix: mix,
      settings: const GameSettings(),
      initialCards: cards,
      initialStep: mafiaOnly ? order.indexOf(Role.doctor) : order.length,
    ),
  );
}
