import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/features/night/night_steps.dart';
import 'package:mafia_host/game/codec.dart';
import 'package:mafia_host/game/game_input.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/role_mix.dart';

Player p(String id, Role role) => Player(id: id, name: id.toUpperCase(), role: role);

/// Seat order matters: TNT sits between c1 and c2.
GameSetup setup({GameSettings settings = const GameSettings(), List<Player>? players}) => GameSetup(
  settings: settings,
  players:
      players ??
      [
        p('gf', Role.godfather),
        p('put', Role.putana),
        p('law', Role.lawyer),
        p('witch', Role.witch),
        p('doc', Role.doctor),
        p('det', Role.detective),
        p('bomb', Role.bomb),
        p('joker', Role.joker),
        p('sw', Role.switchman),
        p('sil', Role.silencer),
        p('shape', Role.shapeshifter),
        p('cham', Role.chameleon),
        p('c1', Role.civilian),
        p('tnt', Role.tnt),
        p('c2', Role.civilian),
        p('c3', Role.civilian),
      ],
);

GameSession day1([List<NightAction> actions = const []]) =>
    GameSession.start(1, setup()).apply(NightInput(actions)).apply(const AdvanceInput());

/// Plays quiet nights and days until night [n] begins.
GameSession toNight(GameSession s, int n) {
  while (s.state.nightNumber < n) {
    s = s
        .apply(const NightInput([]))
        .apply(const AdvanceInput())
        .apply(const TallyVoteInput({}))
        .apply(const AdvanceInput());
  }
  return s;
}

void main() {
  group('GameSession stages', () {
    test('night → morning → day → day result → night', () {
      var s = GameSession.start(1, setup());
      expect(s.stage, GameStage.night);
      expect(s.round, 1);

      s = s.apply(const NightInput([MafiaKill('gf', 'c1')]));
      expect(s.stage, GameStage.morning);

      s = s.apply(const AdvanceInput());
      expect(s.stage, GameStage.day);

      s = s.apply(const VoteInput({'c2': 'c3'}));
      expect(s.stage, GameStage.dayResult);
      expect(s.round, 1, reason: 'still showing day 1 result');

      s = s.apply(const AdvanceInput());
      expect(s.stage, GameStage.night);
      expect(s.round, 2);
    });

    test('a tie calls a re-vote; a second tie eliminates nobody (default)', () {
      var s = day1().apply(const TallyVoteInput({'c1': 2, 'c2': 2}));
      expect(s.stage, GameStage.day);
      expect(s.pendingTie?.events.last, const RevoteRequired(['c1', 'c2']));
      expect(s.state.revoteCandidates, ['c1', 'c2']);

      s = s.apply(const TallyVoteInput({'c1': 1, 'c2': 1}));
      expect(s.stage, GameStage.dayResult);
      expect(s.latestRound.single.events.last, const NoElimination());
    });

    test('a second tie with hostDecides waits for the pick', () {
      var s = GameSession.start(
        1,
        setup(settings: const GameSettings(secondTieRule: SecondTieRule.hostDecides)),
      ).apply(const NightInput([])).apply(const AdvanceInput());
      s = s.apply(const TallyVoteInput({'c1': 2, 'c2': 2}));
      s = s.apply(const TallyVoteInput({'c1': 1, 'c2': 1}));
      expect(s.stage, GameStage.day);
      expect(s.pendingTie?.events.last, const HostDecisionRequired(['c1', 'c2']));
      s = s.apply((s.pendingTie!.input as DayVoteInput).withTieBreaker('c2'));
      expect(s.stage, GameStage.dayResult);
      expect(s.state.player('c2').isAlive, isFalse);
    });

    test("cannot advance until the voted-out Godfather's choice is made", () {
      var s = day1().apply(const TallyVoteInput({'gf': 5}));
      expect(s.stage, GameStage.dayResult);
      expect(s.state.pendingChoices.single.kind, ChoiceKind.godfatherTakesOne);
      expect(() => s.apply(const AdvanceInput()), throwsStateError);

      s = s.apply(const ChoiceInput('gf', ['c3']));
      expect(s.state.player('c3').isAlive, isFalse);
      expect(s.latestRound, hasLength(2), reason: 'the vote and the choice');
      expect(s.apply(const AdvanceInput()).stage, GameStage.night);
    });

    test('a Foul or a removal keeps the day screen (viewKey)', () {
      var s = day1();
      final key = s.viewKey;
      s = s.apply(const FoulInput('c1'));
      expect(s.state.foulsOf('c1'), 1);
      expect(s.viewKey, key);
      s = s.apply(const RemoveInput('tnt'));
      expect(s.viewKey, key);
      expect(s.stage, GameStage.day);
      expect(
        [
          for (final p in s.state.players)
            if (!p.isAlive) p.id,
        ],
        ['c1', 'tnt', 'c2'],
      );
      expect(s.apply(const TallyVoteInput({})).viewKey, key + 1);
    });

    test('a pending re-vote survives a Foul', () {
      final s = day1().apply(const TallyVoteInput({'c1': 2, 'c2': 2})).apply(const FoulInput('c3'));
      expect(s.pendingTie, isNotNull);
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
      expect(() => GameSession.start(1, setup()).apply(const FoulInput('c1')), throwsStateError);
    });

    test('undo replays everything but the last input', () {
      final s = GameSession.start(
        1,
        setup(),
      ).apply(const NightInput([MafiaKill('gf', 'c1')])).apply(const AdvanceInput());
      final u = s.undo();
      expect(u.stage, GameStage.morning);
      expect(u.undo().state.player('c1').isAlive, isTrue);
      expect(GameSession.start(1, setup()).canUndo, isFalse);
    });

    test('replay rebuilds the same session', () {
      final s = day1([
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c2'),
      ]).apply(const FoulInput('c3')).apply(const VoteInput({'c2': 'put', 'c3': 'put'}));
      final r = GameSession.replay(1, s.setup, s.inputs);
      expect(r.stage, s.stage);
      expect(r.state.players, s.state.players);
      expect(r.state.fouls, s.state.fouls);
      expect(r.log.last.events, s.log.last.events);
    });
  });

  group('codec', () {
    test('inputs round-trip through JSON', () {
      const inputs = <GameInput>[
        NightInput([
          PutanaBlock('put', 'doc'),
          LawyerProtect('law', 'gf'),
          MafiaKill('gf', 'c1'),
          WitchLink('witch', 'c1', 'c2'),
          JokerKill('joker', 'c2'),
          SilencerSilence('sil', 'c3'),
          DoctorSave('doc', 'c1'),
          DetectiveCheck('det', 'law'),
          BombPlant('bomb', 'c1', 'c3'),
          ChameleonChoose('cham', Role.switchman),
          SwitchmanRedirect('sw', 'gf'),
        ]),
        ChoiceInput('gf', ['a']),
        ChoiceInput('bomb', []),
        VoteInput({'a': 'b', 'c': null}, tieBreakerId: 'b'),
        TallyVoteInput({'b': 3, 'c': 1}, tieBreakerId: 'b'),
        FoulInput('a'),
        RemoveInput('b'),
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

    test('settings round-trip through JSON with the rules version', () {
      const s = GameSettings(
        godfatherAppearsCivilian: true,
        putanaCanBlockMafia: false,
        secondTieRule: SecondTieRule.randomAmongTied,
        chameleonMafiaJoinsMafiaTeam: false,
        detectiveChainOnVote: true,
        blockedChecksCount: true,
        doctorBlocksChainDeaths: true,
        switchmanRedirectsEach: false,
        doctorSavesRedirectedBullet: false,
        bombNoEffectBeforePlant: false,
        silenceLastsNextDay: false,
        witchCiviliansOnly: false,
        mafiaWinsAtParity: false,
        revealRoleOnDeath: true,
        mafiaDiscussionSeconds: 30,
        freeChatSeconds: 180,
        speechSeconds: 45,
        foulSeconds: 20,
      );
      final j = jsonDecode(jsonEncode(settingsToJson(s))) as Map<String, Object?>;
      expect(settingsFromJson(j), s);
      expect(isCurrentRules(j), isTrue);
    });

    test('games stored before GAME_RULES.md are recognized as legacy', () {
      expect(isCurrentRules({'bombVictimCount': 2, 'discussionSeconds': 0}), isFalse);
      expect(settingsFromJson({'bombVictimCount': 3}), const GameSettings());
      expect(roleFromName('potana'), Role.putana);
      expect(roleFromName('witch'), Role.witch);
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

    test('every role but Civilian is configurable, Mafia Team first', () {
      expect(configurableRoles.toSet(), Role.values.toSet()..remove(Role.civilian));
      expect(configurableRoles.takeWhile((r) => r.team == Team.mafia), hasLength(5));
    });

    test('validation catches each problem', () {
      final names = ['A', 'B', 'C', 'D'];
      final mix = suggestedRoleMix(4);
      expect(validateSetup(['A', 'B', 'C'], mix), SetupProblem.tooFewPlayers);
      expect(validateSetup(['A', 'b ', 'B', 'D'], mix), SetupProblem.duplicateName);
      expect(validateSetup(names, {...mix, Role.joker: 4}), SetupProblem.tooManyRoles);
      expect(validateSetup(names, {Role.doctor: 1}), SetupProblem.noMafia);
      expect(validateSetup(names, {Role.godfather: 1, Role.witch: 1}), SetupProblem.mafiaTooStrong);
      expect(validateSetup(names, mix), isNull);
    });

    test('deal gives every seat one card, in seat order, and fills with Civilians', () {
      final names = List.generate(10, (i) => 'P$i');
      final mix = suggestedRoleMix(10);
      final players = dealRoles(names, mix, Random(1));
      expect(players.map((p) => p.name), names);
      expect(players.map((p) => p.id), [for (var i = 0; i < 10; i++) 'p$i']);
      for (final MapEntry(key: role, value: count) in mix.entries) {
        expect(players.where((p) => p.role == role), hasLength(count), reason: role.name);
      }
      expect(players.every((p) => p.chameleonRole == null), isTrue);
    });
  });

  group('night steps (wake order, GAME_RULES §5)', () {
    List<NightStepKind> kinds(GameSession s) => [
      for (final st in buildNightSteps(s.state)) st.kind,
    ];

    test('night 1: the Mafia Team recognize each other; Putana does not block yet', () {
      final s = GameSession.start(1, setup());
      expect(kinds(s), [
        NightStepKind.recognition,
        NightStepKind.lawyer,
        NightStepKind.mafia,
        NightStepKind.joker,
        NightStepKind.silencer,
        NightStepKind.doctor,
        NightStepKind.shapeshifter,
        NightStepKind.detective,
      ]);
      final recognition = buildNightSteps(s.state).first;
      expect(recognition.memberIds, ['gf', 'put', 'law', 'witch']);
      expect(recognition.actionsFor(const NightPick.players([])), isEmpty);
    });

    test('night 2: Putana blocks, the Witch links, the Bomb plants', () {
      expect(kinds(toNight(GameSession.start(1, setup()), 2)), [
        NightStepKind.putana,
        NightStepKind.lawyer,
        NightStepKind.mafia,
        NightStepKind.witch,
        NightStepKind.joker,
        NightStepKind.silencer,
        NightStepKind.doctor,
        NightStepKind.shapeshifter,
        NightStepKind.detective,
        NightStepKind.bomb,
      ]);
    });

    test('night 3: the Chameleon chooses; from night 4 wakes as the chosen role', () {
      final n3 = toNight(GameSession.start(1, setup()), 3);
      final cham = buildNightSteps(n3.state).last;
      expect(cham.kind, NightStepKind.chameleon);
      expect(cham.roleChoices, chameleonChoices);
      expect(cham.actionsFor(const NightPick.role(Role.doctor)), [
        const ChameleonChoose('cham', Role.doctor),
      ]);

      final n4 = toNight(
        n3
            .apply(const NightInput([ChameleonChoose('cham', Role.doctor)]))
            .apply(const AdvanceInput())
            .apply(const TallyVoteInput({}))
            .apply(const AdvanceInput()),
        4,
      );
      final as = buildNightSteps(n4.state).last;
      expect((as.kind, as.ability), (NightStepKind.chameleon, Role.doctor));
      expect(as.actionsFor(const NightPick.players(['c1'])), [const DoctorSave('cham', 'c1')]);
    });

    test("the Shapeshifter's step uses tonight's ability", () {
      Role ability(GameSession s) => buildNightSteps(
        s.state,
      ).firstWhere((st) => st.kind == NightStepKind.shapeshifter).ability;
      final s = GameSession.start(1, setup());
      expect(ability(s), Role.detective);
      expect(ability(toNight(s, 2)), Role.doctor);
      expect(ability(toNight(s, 3)), Role.joker);
    });

    test('target lists respect each role', () {
      final s = toNight(GameSession.start(1, setup()), 2);
      final steps = {for (final st in buildNightSteps(s.state)) st.kind: st};
      expect(steps[NightStepKind.putana]!.targetIds, isNot(contains('put')));
      expect(steps[NightStepKind.lawyer]!.targetIds, ['gf', 'put', 'law', 'witch']);
      expect(steps[NightStepKind.mafia]!.actorId, 'gf');
      expect(steps[NightStepKind.mafia]!.memberIds, ['gf', 'law', 'witch']);
      expect(steps[NightStepKind.mafia]!.targetIds, isNot(contains('put')));
      expect(steps[NightStepKind.witch]!.picks, 2);
      expect(steps[NightStepKind.witch]!.targetIds, isNot(contains('gf')), reason: 'Q12');
      expect(steps[NightStepKind.bomb]!.targetIds, isNot(contains('bomb')));
      expect(steps[NightStepKind.detective]!.targetIds, isNot(contains('det')));
    });

    test("the Doctor's third night on the same player is disabled", () {
      var s = GameSession.start(1, setup());
      for (var i = 0; i < 2; i++) {
        s = s
            .apply(const NightInput([DoctorSave('doc', 'c2')]))
            .apply(const AdvanceInput())
            .apply(const TallyVoteInput({}))
            .apply(const AdvanceInput());
      }
      final doctor = buildNightSteps(s.state).firstWhere((st) => st.kind == NightStepKind.doctor);
      expect(doctor.disabledTargetIds, {'c2'});
    });

    test('without the Godfather the next Mafia killer decides', () {
      final s = GameSession.start(1, setup())
          .apply(const NightInput([JokerKill('joker', 'gf')]))
          .apply(const AdvanceInput())
          .apply(const TallyVoteInput({}))
          .apply(const AdvanceInput());
      final mafia = buildNightSteps(s.state).firstWhere((st) => st.kind == NightStepKind.mafia);
      expect(mafia.actorId, 'law');
    });

    test("a blocked decider's kill falls to the others' agreed number", () {
      final s = toNight(GameSession.start(1, setup()), 2);
      final mafia = buildNightSteps(s.state).firstWhere((st) => st.kind == NightStepKind.mafia);
      const pick = NightPick.players(['c1']);
      expect(mafia.actionsFor(pick), [const MafiaKill('gf', 'c1')]);
      expect(mafia.actionsFor(pick, blocked: {'gf'}), [
        const MafiaKill('gf', 'c1'),
        const MafiaKill('law', 'c1'),
        const MafiaKill('witch', 'c1'),
      ]);
      final r = resolveNight(s.state, [
        const PutanaBlock('put', 'gf'),
        ...mafia.actionsFor(pick, blocked: {'gf'}),
      ]);
      expect(r.state.player('c1').isAlive, isFalse);
    });

    test('the Switchman is woken once per bullet, only when shot at', () {
      final state = GameSession.start(1, setup()).state;
      expect(switchmanSteps(state, const [MafiaKill('gf', 'c1')]), isEmpty);
      final steps = switchmanSteps(state, const [MafiaKill('gf', 'sw'), JokerKill('joker', 'sw')]);
      expect([for (final s in steps) s.bullet], [DeathCause.mafia, DeathCause.joker]);
      expect(steps.first.targetIds, isNot(contains('sw')));

      final once = GameState.initial(
        players: setup().players,
        settings: const GameSettings(switchmanRedirectsEach: false),
      );
      expect(
        switchmanSteps(once, const [MafiaKill('gf', 'sw'), JokerKill('joker', 'sw')]),
        hasLength(1),
      );
    });

    test('Detective preview reflects the Lawyer and Putana', () {
      final state = toNight(GameSession.start(1, setup()), 2).state;
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
          PutanaBlock('put', 'det'),
        ], const DetectiveCheck('det', 'law')),
        isNull,
      );
    });
  });
}
