import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Mafia kill', () {
    test("the Godfather's target dies", () {
      final r = resolveNight(newGame(), [const MafiaKill('gf', 'c1')]);
      expect(isAlive(r.state, 'c1'), isFalse);
      expect(r.events, contains(const PlayerDied('c1', {DeathCause.mafia})));
    });

    test('the Godfather has the final say over Mafia proposals', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('maf', 'c1'),
        const MafiaKill('gf', 'c2'),
        const MafiaKill('pot', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
      expect(isAlive(r.state, 'c2'), isFalse);
    });

    test('an agreed Mafia proposal is used when the Godfather does not act', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('maf', 'c1'),
        const MafiaKill('law', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isFalse);
    });

    test('conflicting proposals without a Godfather decision are rejected', () {
      expect(
        () => resolveNight(newGame(), [
          const MafiaKill('maf', 'c1'),
          const MafiaKill('law', 'c2'),
        ]),
        throwsInvalid(InvalidActionReason.conflictingMafiaKill),
      );
    });

    test('when the Godfather is dead, the remaining Mafia decide', () {
      final s = nightThenSkipDay(newGame(), [const JokerKill('joker', 'gf')]);
      expect(isAlive(s, 'gf'), isFalse);

      final r = resolveNight(s, [const MafiaKill('maf', 'c1')]);
      expect(isAlive(r.state, 'c1'), isFalse);

      expect(
        () => resolveNight(s, [const MafiaKill('gf', 'c2')]),
        throwsInvalid(InvalidActionReason.actorDead),
      );
    });

    test('only Mafia-team players can order the kill', () {
      expect(
        () => resolveNight(newGame(), [const MafiaKill('c1', 'c2')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
    });

    test('a night with no actions kills nobody', () {
      final r = resolveNight(newGame(), const []);
      expect(r.state.players.every((p) => p.isAlive), isTrue);
      expect(r.events, isEmpty);
    });
  });

  group('Joker', () {
    test('kills every night with no penalty for killing civilians', () {
      var r = resolveNight(newGame(), [const JokerKill('joker', 'c1')]);
      expect(isAlive(r.state, 'c1'), isFalse);
      expect(isAlive(r.state, 'joker'), isTrue);
      expect(r.events, contains(const PlayerDied('c1', {DeathCause.joker})));

      r = resolveNight(skipDay(r.state), [const JokerKill('joker', 'c2')]);
      expect(isAlive(r.state, 'c2'), isFalse);
      expect(isAlive(r.state, 'joker'), isTrue);
    });

    test('can kill a Mafia member', () {
      final r = resolveNight(newGame(), [const JokerKill('joker', 'maf')]);
      expect(isAlive(r.state, 'maf'), isFalse);
    });

    test('cannot target himself', () {
      expect(
        () => resolveNight(newGame(), [const JokerKill('joker', 'joker')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('a blocked Joker kills nobody', () {
      final r = resolveNight(newGame(), [
        const PotanaBlock('pot', 'joker'),
        const JokerKill('joker', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
      expect(r.events, contains(const PlayerBlocked('joker')));
    });

    test('Joker and Mafia on the same target: one death with both causes', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const JokerKill('joker', 'c1'),
      ]);
      expect(
        r.events.whereType<PlayerDied>(),
        [
          const PlayerDied('c1', {DeathCause.mafia, DeathCause.joker})
        ],
      );
    });

    test('Joker and Mafia on different targets: both die', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const JokerKill('joker', 'c2'),
      ]);
      expect(isAlive(r.state, 'c1'), isFalse);
      expect(isAlive(r.state, 'c2'), isFalse);
    });
  });

  group('Doctor', () {
    test('saves the Mafia target', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
      expect(r.events, [
        const PlayerSaved('c1', {DeathCause.mafia})
      ]);
    });

    test('may save himself', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'doc'),
        const DoctorSave('doc', 'doc'),
      ]);
      expect(isAlive(r.state, 'doc'), isTrue);
    });

    test('saving a player nobody attacked produces no event', () {
      final r = resolveNight(newGame(), [const DoctorSave('doc', 'c1')]);
      expect(r.events, isEmpty);
    });

    test('cannot save the same player two nights in a row', () {
      final s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      expect(
        () => resolveNight(s, [const DoctorSave('doc', 'c1')]),
        throwsInvalid(InvalidActionReason.doctorRepeatTarget),
      );
    });

    test('the two-nights rule also applies to self-saves', () {
      final s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'doc')]);
      expect(
        () => resolveNight(s, [const DoctorSave('doc', 'doc')]),
        throwsInvalid(InvalidActionReason.doctorRepeatTarget),
      );
    });

    test('may save a different player on consecutive nights', () {
      final s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      final r = resolveNight(s, [
        const MafiaKill('gf', 'c2'),
        const DoctorSave('doc', 'c2'),
      ]);
      expect(isAlive(r.state, 'c2'), isTrue);
    });

    test('may save the same player again after a different save in between', () {
      var s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      s = nightThenSkipDay(s, [const DoctorSave('doc', 'c2')]);
      final r = resolveNight(s, [
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
    });

    test('may save the same player again after skipping a night', () {
      var s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      s = nightThenSkipDay(s, const []);
      expect(() => resolveNight(s, [const DoctorSave('doc', 'c1')]), returnsNormally);
    });

    test("a blocked save still counts as that night's pick for the two-nights rule", () {
      final s = nightThenSkipDay(newGame(), [
        const PotanaBlock('pot', 'doc'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(
        () => resolveNight(s, [const DoctorSave('doc', 'c1')]),
        throwsInvalid(InvalidActionReason.doctorRepeatTarget),
      );
    });

    test('a blocked Doctor saves nobody', () {
      final r = resolveNight(newGame(), [
        const PotanaBlock('pot', 'doc'),
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isFalse);
      expect(r.events.whereType<PlayerSaved>(), isEmpty);
      expect(r.events, contains(const PlayerBlocked('doc')));
    });

    test('doctorSaveBlocksJokerKill = true: the save stops a Joker kill', () {
      final r = resolveNight(newGame(), [
        const JokerKill('joker', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
      expect(r.events, [
        const PlayerSaved('c1', {DeathCause.joker})
      ]);
    });

    test('doctorSaveBlocksJokerKill = false: the Joker kill goes through', () {
      final r = resolveNight(
        newGame(settings: const GameSettings(doctorSaveBlocksJokerKill: false)),
        [const JokerKill('joker', 'c1'), const DoctorSave('doc', 'c1')],
      );
      expect(isAlive(r.state, 'c1'), isFalse);
      expect(r.events.whereType<PlayerSaved>(), isEmpty);
    });

    test('flag on: Mafia + Joker on the saved player → survives both', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const JokerKill('joker', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
      expect(r.events, [
        const PlayerSaved('c1', {DeathCause.mafia, DeathCause.joker})
      ]);
    });

    test('flag off: Mafia + Joker on the saved player → dies to the Joker only', () {
      final r = resolveNight(
        newGame(settings: const GameSettings(doctorSaveBlocksJokerKill: false)),
        [
          const MafiaKill('gf', 'c1'),
          const JokerKill('joker', 'c1'),
          const DoctorSave('doc', 'c1'),
        ],
      );
      expect(r.events, [
        const PlayerDied('c1', {DeathCause.joker})
      ]);
    });
  });

  group('Detective', () {
    DetectiveResult check(String target, {List<NightAction> extra = const []}) {
      final r = resolveNight(newGame(), [...extra, DetectiveCheck('det', target)]);
      return r.events.whereType<DetectiveResultRevealed>().single.result;
    }

    test('Mafia, Potana and Lawyer read as Mafia', () {
      expect(check('maf'), DetectiveResult.mafia);
      expect(check('pot'), DetectiveResult.mafia);
      expect(check('law'), DetectiveResult.mafia);
    });

    test('civilian-team players read as Civilian', () {
      for (final id in ['c1', 'doc', 'joker', 'bomb']) {
        expect(check(id), DetectiveResult.civilian, reason: id);
      }
    });

    test('the Godfather reads as Civilian', () {
      expect(check('gf'), DetectiveResult.civilian);
    });

    test('a Lawyer-protected Mafia member reads as Civilian', () {
      final r = resolveNight(newGame(), [
        const LawyerProtect('law', 'maf'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(r.events, [
        const LawyerProtected('maf'),
        const DetectiveResultRevealed('det', 'maf', DetectiveResult.civilian),
      ]);
    });

    test('the Lawyer may protect himself', () {
      expect(
        check('law', extra: [const LawyerProtect('law', 'law')]),
        DetectiveResult.civilian,
      );
    });

    test('Lawyer protection only lasts one night', () {
      final s = nightThenSkipDay(newGame(), [const LawyerProtect('law', 'maf')]);
      final r = resolveNight(s, [const DetectiveCheck('det', 'maf')]);
      expect(
        r.events.whereType<DetectiveResultRevealed>().single.result,
        DetectiveResult.mafia,
      );
    });

    test('Lawyer protection does not stop kills', () {
      final r = resolveNight(newGame(), [
        const LawyerProtect('law', 'maf'),
        const JokerKill('joker', 'maf'),
      ]);
      expect(isAlive(r.state, 'maf'), isFalse);
    });

    test('the Lawyer can only protect Mafia-team players', () {
      expect(
        () => resolveNight(newGame(), [const LawyerProtect('law', 'c1')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('a blocked Detective learns nothing', () {
      final r = resolveNight(newGame(), [
        const PotanaBlock('pot', 'det'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(r.events, [const PlayerBlocked('det')]);
    });

    test('a Detective killed the same night still gets the result', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'det'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(isAlive(r.state, 'det'), isFalse);
      expect(
        r.events,
        contains(const DetectiveResultRevealed('det', 'maf', DetectiveResult.mafia)),
      );
    });

    test('cannot check himself', () {
      expect(
        () => resolveNight(newGame(), [const DetectiveCheck('det', 'det')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });
  });

  group('Potana', () {
    test('can only block civilian-team players', () {
      expect(
        () => resolveNight(newGame(), [const PotanaBlock('pot', 'maf')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('blocking a plain Civilian changes nothing else', () {
      final r = resolveNight(newGame(), [
        const PotanaBlock('pot', 'c1'),
        const MafiaKill('gf', 'c2'),
      ]);
      expect(r.events, [
        const PlayerBlocked('c1'),
        const PlayerDied('c2', {DeathCause.mafia}),
      ]);
    });

    test('the block only lasts one night', () {
      final s = nightThenSkipDay(newGame(), [const PotanaBlock('pot', 'doc')]);
      final r = resolveNight(s, [
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
    });
  });

  group('Chameleon', () {
    List<Player> withChameleon(Role as) => [
          ...standardPlayers().where((p) => p.id != 'doc' && p.id != 'joker'),
          p('ch', Role.chameleon, as: as),
        ];

    test('playing Doctor can save', () {
      final r = resolveNight(newGame(players: withChameleon(Role.doctor)), [
        const MafiaKill('gf', 'c1'),
        const DoctorSave('ch', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isTrue);
    });

    test('playing Joker can kill', () {
      final r = resolveNight(newGame(players: withChameleon(Role.joker)), [
        const JokerKill('ch', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isFalse);
    });

    test('can be blocked by the Potana', () {
      final r = resolveNight(newGame(players: withChameleon(Role.doctor)), [
        const PotanaBlock('pot', 'ch'),
        const MafiaKill('gf', 'c1'),
        const DoctorSave('ch', 'c1'),
      ]);
      expect(isAlive(r.state, 'c1'), isFalse);
    });

    test('two Detectives (one a Chameleon) each get a result, in seating order', () {
      final r = resolveNight(newGame(players: withChameleon(Role.detective)), [
        const DetectiveCheck('ch', 'gf'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(r.events, [
        const DetectiveResultRevealed('det', 'maf', DetectiveResult.mafia),
        const DetectiveResultRevealed('ch', 'gf', DetectiveResult.civilian),
      ]);
    });

    test('cannot use abilities of roles it did not pick', () {
      expect(
        () => resolveNight(newGame(players: withChameleon(Role.doctor)), [
          const DetectiveCheck('ch', 'maf'),
        ]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
    });

    test('playing a Mafia role (when allowed) reads as Mafia', () {
      final r = resolveNight(
        newGame(
          players: withChameleon(Role.mafia),
          settings: const GameSettings(chameleonCanPickMafiaRoles: true),
        ),
        [const DetectiveCheck('det', 'ch')],
      );
      expect(
        r.events.whereType<DetectiveResultRevealed>().single.result,
        DetectiveResult.mafia,
      );
    });
  });

  group('Validation', () {
    test('unknown actor or target', () {
      expect(
        () => resolveNight(newGame(), [const MafiaKill('ghost', 'c1')]),
        throwsInvalid(InvalidActionReason.unknownPlayer),
      );
      expect(
        () => resolveNight(newGame(), [const MafiaKill('gf', 'ghost')]),
        throwsInvalid(InvalidActionReason.unknownPlayer),
      );
    });

    test('dead target', () {
      final s = nightThenSkipDay(newGame(), [const MafiaKill('gf', 'c1')]);
      expect(
        () => resolveNight(s, [const MafiaKill('gf', 'c1')]),
        throwsInvalid(InvalidActionReason.targetDead),
      );
    });

    test('dead actor', () {
      final s = nightThenSkipDay(newGame(), [const MafiaKill('gf', 'doc')]);
      expect(
        () => resolveNight(s, [const DoctorSave('doc', 'c1')]),
        throwsInvalid(InvalidActionReason.actorDead),
      );
    });

    test('actor without the role', () {
      expect(
        () => resolveNight(newGame(), [const DoctorSave('c1', 'c2')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
      expect(
        () => resolveNight(newGame(), [const PotanaBlock('law', 'c2')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
    });

    test('two actions of the same kind from one actor', () {
      expect(
        () => resolveNight(newGame(), [
          const DoctorSave('doc', 'c1'),
          const DoctorSave('doc', 'c2'),
        ]),
        throwsInvalid(InvalidActionReason.duplicateAction),
      );
    });

    test('resolving a night during the day', () {
      final day = resolveNight(newGame(), const []).state;
      expect(() => resolveNight(day, const []), throwsInvalid(InvalidActionReason.wrongPhase));
    });
  });

  group('Resolution order', () {
    test('block → lawyer → kills → save → detective, blocked Detective', () {
      final r = resolveNight(newGame(), [
        const DetectiveCheck('det', 'maf'),
        const DoctorSave('doc', 'c1'),
        const JokerKill('joker', 'c2'),
        const MafiaKill('gf', 'c1'),
        const LawyerProtect('law', 'maf'),
        const PotanaBlock('pot', 'det'),
      ]);
      expect(r.events, [
        const PlayerBlocked('det'),
        const LawyerProtected('maf'),
        const PlayerSaved('c1', {DeathCause.mafia}),
        const PlayerDied('c2', {DeathCause.joker}),
      ]);
    });

    test('block → lawyer → kills → save → detective, blocked Joker', () {
      final r = resolveNight(newGame(), [
        const DetectiveCheck('det', 'maf'),
        const DoctorSave('doc', 'c1'),
        const JokerKill('joker', 'c2'),
        const MafiaKill('gf', 'c1'),
        const LawyerProtect('law', 'maf'),
        const PotanaBlock('pot', 'joker'),
      ]);
      expect(r.events, [
        const PlayerBlocked('joker'),
        const LawyerProtected('maf'),
        const PlayerSaved('c1', {DeathCause.mafia}),
        const DetectiveResultRevealed('det', 'maf', DetectiveResult.civilian),
      ]);
      expect(r.state.alivePlayers, hasLength(12));
    });

    test('submission order does not matter', () {
      final actions = <NightAction>[
        const PotanaBlock('pot', 'doc'),
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c1'),
        const JokerKill('joker', 'c3'),
        const DetectiveCheck('det', 'law'),
      ];
      final a = resolveNight(newGame(), actions);
      final b = resolveNight(newGame(), actions.reversed.toList());
      expect(b.events, a.events);
      expect(b.state.players, a.state.players);
    });

    test('deaths are announced in seating order, then Bomb triggers', () {
      final r = resolveNight(newGame(), [
        const JokerKill('joker', 'c1'),
        const MafiaKill('gf', 'bomb'),
      ]);
      expect(r.events, [
        const PlayerDied('bomb', {DeathCause.mafia}),
        const PlayerDied('c1', {DeathCause.joker}),
        const BombTriggered('bomb'),
      ]);
    });

    test('moves to day, keeps the night number, and leaves input untouched', () {
      final s = newGame();
      final r = resolveNight(s, [const MafiaKill('gf', 'c1')]);
      expect(r.state.phase, GamePhase.day);
      expect(r.state.nightNumber, 1);
      expect(s.phase, GamePhase.night);
      expect(isAlive(s, 'c1'), isTrue);
    });

    test('win check runs last and ends the game', () {
      final r = resolveNight(
        newGame(players: [p('gf', Role.godfather), p('c1', Role.civilian), p('c2', Role.civilian)]),
        [const MafiaKill('gf', 'c1')],
      );
      expect(r.events, [
        const PlayerDied('c1', {DeathCause.mafia}),
        const GameOver(Team.mafia),
      ]);
      expect(r.state.phase, GamePhase.gameOver);
      expect(r.state.winner, Team.mafia);
    });

    test('revealRoleOnDeath includes the role in the death event', () {
      final r = resolveNight(
        newGame(settings: const GameSettings(revealRoleOnDeath: true)),
        [const MafiaKill('gf', 'doc')],
      );
      expect(r.events, [
        const PlayerDied('doc', {DeathCause.mafia}, revealedRole: Role.doctor)
      ]);
    });
  });
}
