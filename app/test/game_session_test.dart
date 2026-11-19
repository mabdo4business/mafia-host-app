import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/features/night/night_steps.dart';
import 'package:mafia_host/game/codec.dart';
import 'package:mafia_host/game/game_input.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/role_mix.dart';

Player p(String id, Role role, {Role? as}) =>
    Player(id: id, name: id.toUpperCase(), role: role, chameleonRole: as);

GameSetup setup({GameSettings settings = const GameSettings(), List<Player>? players}) => GameSetup(
  settings: settings,
  players:
      players ??
      [
        p('gf', Role.godfather),
        p('pot', Role.potana),
        p('law', Role.lawyer),
        p('doc', Role.doctor),
        p('det', Role.detective),
        p('bomb', Role.bomb),
        p('joker', Role.joker),
        p('c1', Role.civilian),
        p('c2', Role.civilian),
        p('c3', Role.civilian),
      ],
);

void main() {
  group('GameSession stages', () {
    test('night → morning → day → day result → night', () {
      var s = GameSession.start(1, setup());
      expect(s.stage, GameStage.night);
      expect(s.round, 1);

      s = s.apply(const NightInput([MafiaKill('gf', 'c1')]));
      expect(s.stage, GameStage.morning);
      expect(s.round, 1);

      s = s.apply(const AdvanceInput());
      expect(s.stage, GameStage.day);

      s = s.apply(const VoteInput({'c2': 'c3'}));
      expect(s.stage, GameStage.dayResult);
      expect(s.round, 1, reason: 'still showing day 1 result');

      s = s.apply(const AdvanceInput());
      expect(s.stage, GameStage.night);
      expect(s.round, 2);
    });

    test('a tie waiting on the host keeps the day open', () {
      var s = GameSession.start(1, setup()).apply(const NightInput([])).apply(const AdvanceInput());
      s = s.apply(const VoteInput({'c1': 'gf', 'c2': 'c3'}));
      expect(s.stage, GameStage.day);
      expect(s.pendingTie, isNotNull);

      s = s.apply(const VoteInput({'c1': 'gf', 'c2': 'c3'}, tieBreakerId: 'gf'));
      expect(s.stage, GameStage.dayResult);
      expect(s.latestRound.single.events.whereType<PlayerDied>().single.playerId, 'gf');
    });

    test('cannot advance while a Bomb is pending; detonation then unlocks it', () {
      var s = GameSession.start(1, setup()).apply(const NightInput([MafiaKill('gf', 'bomb')]));
      expect(s.state.pendingBombs, ['bomb']);
      expect(() => s.apply(const AdvanceInput()), throwsStateError);

      s = s.apply(const BombInput('bomb', ['c1', 'c2']));
      expect(s.stage, GameStage.morning);
      expect(s.latestRound, hasLength(2));
      s = s.apply(const AdvanceInput());
      expect(s.stage, GameStage.day);
    });

    test('a win moves to game over', () {
      final s = GameSession.start(
        1,
        setup(players: [p('gf', Role.godfather), p('a', Role.civilian), p('b', Role.civilian)]),
      ).apply(const NightInput([MafiaKill('gf', 'a')]));
      expect(s.stage, GameStage.gameOver);
      expect(s.state.winner, Team.mafia);
    });

    test('inputs that do not fit the stage are rejected', () {
      expect(() => GameSession.start(1, setup()).apply(const VoteInput({})), throwsStateError);
    });

    test('undo replays everything but the last input', () {
      final s = GameSession.start(
        1,
        setup(),
      ).apply(const NightInput([MafiaKill('gf', 'c1')])).apply(const AdvanceInput());
      final u = s.undo();
      expect(u.stage, GameStage.morning);
      expect(u.log, hasLength(1));
      expect(u.undo().state.player('c1').isAlive, isTrue);
      expect(GameSession.start(1, setup()).canUndo, isFalse);
    });

    test('replay rebuilds the same session', () {
      final s = GameSession.start(1, setup())
          .apply(const NightInput([MafiaKill('gf', 'c1'), DoctorSave('doc', 'c2')]))
          .apply(const AdvanceInput())
          .apply(const VoteInput({'c2': 'pot', 'c3': 'pot'}));
      final r = GameSession.replay(1, s.setup, s.inputs);
      expect(r.stage, s.stage);
      expect(r.state.players, s.state.players);
      expect(r.log.last.events, s.log.last.events);
    });
  });

  group('tallied vote', () {
    test('eliminates the leader and shows the day result', () {
      var s = GameSession.start(1, setup()).apply(const NightInput([])).apply(const AdvanceInput());
      s = s.apply(const TallyVoteInput({'c3': 2, 'c2': 1}));
      expect(s.stage, GameStage.dayResult);
      expect(s.state.player('c3').isAlive, isFalse);
      expect(s.latestRound.single.input, isA<TallyVoteInput>());
    });

    test('a tie waits for the host, then the tie-breaker decides', () {
      var s = GameSession.start(1, setup()).apply(const NightInput([])).apply(const AdvanceInput());
      s = s.apply(const TallyVoteInput({'c3': 1, 'c2': 1}));
      expect(s.stage, GameStage.day);
      expect(s.pendingTie?.input, isA<TallyVoteInput>());
      s = s.apply(const TallyVoteInput({'c3': 1, 'c2': 1}, tieBreakerId: 'c2'));
      expect(s.stage, GameStage.dayResult);
      expect(s.state.player('c2').isAlive, isFalse);
    });
  });

  group('codec', () {
    test('inputs round-trip through JSON', () {
      const inputs = <GameInput>[
        NightInput([
          PotanaBlock('pot', 'doc'),
          LawyerProtect('law', 'gf'),
          MafiaKill('gf', 'c1'),
          JokerKill('joker', 'c2'),
          DoctorSave('doc', 'c1'),
          DetectiveCheck('det', 'law'),
        ]),
        BombInput('bomb', ['a', 'b']),
        VoteInput({'a': 'b', 'c': null}, tieBreakerId: 'b'),
        TallyVoteInput({'b': 3, 'c': 1}, tieBreakerId: 'b'),
        AdvanceInput(),
      ];
      final decoded = [
        for (final i in inputs)
          inputFromJson(jsonDecode(jsonEncode(inputToJson(i))) as Map<String, Object?>),
      ];
      expect(
        jsonEncode([for (final i in decoded) inputToJson(i)]),
        jsonEncode([for (final i in inputs) inputToJson(i)]),
      );
      expect((decoded.first as NightInput).actions, (inputs.first as NightInput).actions);
    });

    test('settings round-trip through JSON', () {
      const s = GameSettings(
        bombVictimCount: 3,
        doctorSaveBlocksJokerKill: false,
        doctorCanSaveBombVictims: true,
        blockedBombStillExplodes: false,
        chameleonCanPickMafiaRoles: true,
        revealRoleOnDeath: true,
        tieVoteRule: TieVoteRule.revote,
      );
      final j =
          jsonDecode(jsonEncode(settingsToJson(s, discussionSeconds: 120))) as Map<String, Object?>;
      expect(
        settingsToJson(settingsFromJson(j), discussionSeconds: 120),
        settingsToJson(s, discussionSeconds: 120),
      );
      expect(discussionSecondsFromJson(j), 120);
    });
  });

  group('role mix and deal', () {
    test('suggested mix has a Mafia minority and fits the table', () {
      for (var n = minPlayers; n <= 20; n++) {
        final mix = suggestedRoleMix(n);
        expect(validateSetup(List.generate(n, (i) => 'P$i'), mix), isNull, reason: '$n players');
        expect(mix[Role.godfather], 1);
      }
    });

    test('validation catches each problem', () {
      final names = ['A', 'B', 'C', 'D'];
      final mix = suggestedRoleMix(4);
      expect(validateSetup(['A', 'B', 'C'], mix), SetupProblem.tooFewPlayers);
      expect(validateSetup(['A', 'b ', 'B', 'D'], mix), SetupProblem.duplicateName);
      expect(validateSetup(names, {...mix, Role.joker: 4}), SetupProblem.tooManyRoles);
      expect(validateSetup(names, {Role.doctor: 1}), SetupProblem.noMafia);
      expect(validateSetup(names, {Role.godfather: 1, Role.mafia: 1}), SetupProblem.mafiaTooStrong);
      expect(validateSetup(names, mix), isNull);
    });

    test('deal gives every seat one card and fills with Civilians', () {
      final names = List.generate(10, (i) => 'P$i');
      final mix = suggestedRoleMix(10);
      final players = dealRoles(names, mix, Random(1));
      expect(players.map((p) => p.name), names);
      expect(players.map((p) => p.id).toSet(), hasLength(10));
      for (final MapEntry(key: role, value: count) in mix.entries) {
        expect(players.where((p) => p.role == role), hasLength(count), reason: role.name);
      }
      final special = mix.values.fold(0, (a, b) => a + b);
      expect(players.where((p) => p.role == Role.civilian), hasLength(10 - special));
    });

    test('chameleon choices follow the setting', () {
      expect(chameleonChoices(const GameSettings()).any((r) => r.team == Team.mafia), isFalse);
      expect(
        chameleonChoices(const GameSettings(chameleonCanPickMafiaRoles: true)),
        contains(Role.godfather),
      );
      expect(
        chameleonChoices(const GameSettings(chameleonCanPickMafiaRoles: true)),
        isNot(contains(Role.chameleon)),
      );
    });
  });

  group('night steps', () {
    test('follow resolution order and skip missing or dead roles', () {
      final s = GameSession.start(1, setup()).state;
      expect(buildNightSteps(s).map((st) => st.kind), [
        NightStepKind.potana,
        NightStepKind.lawyer,
        NightStepKind.mafia,
        NightStepKind.joker,
        NightStepKind.doctor,
        NightStepKind.detective,
      ]);

      final afterNight = GameSession.start(1, setup())
          .apply(const NightInput([JokerKill('joker', 'pot'), MafiaKill('gf', 'joker')]))
          .apply(const AdvanceInput())
          .apply(const VoteInput({}))
          .apply(const AdvanceInput());
      expect(afterNight.stage, GameStage.night);
      expect(buildNightSteps(afterNight.state).map((st) => st.kind), [
        NightStepKind.lawyer,
        NightStepKind.mafia,
        NightStepKind.doctor,
        NightStepKind.detective,
      ]);
    });

    test('target lists respect each role', () {
      final steps = {
        for (final st in buildNightSteps(GameSession.start(1, setup()).state)) st.kind: st,
      };
      expect(steps[NightStepKind.potana]!.targetIds, isNot(contains('gf')));
      expect(steps[NightStepKind.lawyer]!.targetIds, ['gf', 'pot', 'law']);
      expect(steps[NightStepKind.mafia]!.actorId, 'gf');
      expect(steps[NightStepKind.mafia]!.targetIds, isNot(contains('law')));
      expect(steps[NightStepKind.joker]!.targetIds, isNot(contains('joker')));
      expect(steps[NightStepKind.detective]!.targetIds, isNot(contains('det')));
    });

    test("the Doctor's last pick is disabled the next night", () {
      final s = GameSession.start(1, setup())
          .apply(const NightInput([DoctorSave('doc', 'c2')]))
          .apply(const AdvanceInput())
          .apply(const VoteInput({}))
          .apply(const AdvanceInput());
      final doctor = buildNightSteps(s.state).firstWhere((st) => st.kind == NightStepKind.doctor);
      expect(doctor.disabledTargetIds, {'c2'});
    });

    test('Mafia step falls to the next Mafia member when the Godfather is dead', () {
      final s = GameSession.start(1, setup())
          .apply(const NightInput([JokerKill('joker', 'gf')]))
          .apply(const AdvanceInput())
          .apply(const VoteInput({}))
          .apply(const AdvanceInput());
      expect(
        buildNightSteps(s.state).firstWhere((st) => st.kind == NightStepKind.mafia).actorId,
        'pot',
      );
    });

    test('Detective preview reflects the Lawyer and the Potana', () {
      final state = GameSession.start(1, setup()).state;
      expect(
        previewDetectiveResult(state, const [], const DetectiveCheck('det', 'law')),
        DetectiveResult.mafia,
      );
      expect(
        previewDetectiveResult(state, const [
          LawyerProtect('law', 'law'),
        ], const DetectiveCheck('det', 'law')),
        DetectiveResult.civilian,
      );
      expect(
        previewDetectiveResult(state, const [
          PotanaBlock('pot', 'det'),
        ], const DetectiveCheck('det', 'law')),
        isNull,
      );
    });
  });
}
