import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Mafia kill', () {
    test("the Godfather's target dies", () {
      final r = resolveNight(newGame(), [const MafiaKill('gf', 'c1')]);
      expect(isAlive(r.state, 'c1'), isFalse);
      expect(deathOf(r, 'c1').causes, {DeathCause.mafia});
    });

    test('the final decision belongs to the Godfather', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('maf', 'c1'),
        const MafiaKill('gf', 'c2'),
        const MafiaKill('law', 'c1'),
      ]);
      expect(deaths(r), ['c2']);
    });

    test('without the Godfather, the remaining Mafia must show the same number', () {
      final s = nightThenSkipDay(newGame(), [const JokerKill('joker', 'gf')]);
      final r = resolveNight(s, [
        const MafiaKill('maf', 'c1'),
        const MafiaKill('law', 'c1'),
        const MafiaKill('witch', 'c1'),
      ]);
      expect(deaths(r), ['c1']);
    });

    test('different numbers cancel the murder', () {
      final s = nightThenSkipDay(newGame(), [const JokerKill('joker', 'gf')]);
      final r = resolveNight(s, [const MafiaKill('maf', 'c1'), const MafiaKill('law', 'c2')]);
      expect(deaths(r), isEmpty);
      expect(r.events, contains(const MafiaKillCancelled()));
    });

    test('a dead Godfather cannot act', () {
      final s = nightThenSkipDay(newGame(), [const JokerKill('joker', 'gf')]);
      expect(
        () => resolveNight(s, [const MafiaKill('gf', 'c1')]),
        throwsInvalid(InvalidActionReason.actorDead),
      );
    });

    test('only Mafia Team killers order the kill; Putana wakes separately', () {
      expect(
        () => resolveNight(newGame(), [const MafiaKill('c1', 'c2')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
      expect(
        () => resolveNight(newGame(), [const MafiaKill('put', 'c2')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
    });

    test('nobody targets themselves', () {
      expect(
        () => resolveNight(newGame(), [const MafiaKill('gf', 'gf')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('a night with no actions kills nobody', () {
      final r = resolveNight(newGame(), const []);
      expect(r.events, isEmpty);
      expect(r.state.phase, GamePhase.day);
    });
  });

  group('Putana', () {
    test('night 1 is recognition only: no block', () {
      expect(
        () => resolveNight(newGame(), [const PutanaBlock('put', 'joker')]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
    });

    test("from night 2 her block cancels one player's ability (Q15: the Joker too)", () {
      final s = toNight(newGame(), 2);
      final r = resolveNight(s, [
        const PutanaBlock('put', 'joker'),
        const JokerKill('joker', 'c1'),
      ]);
      expect(deaths(r), isEmpty);
      expect(r.events, contains(const PlayerBlocked('joker')));
    });

    test('a blocked Doctor saves nobody', () {
      final s = toNight(newGame(), 2);
      final r = resolveNight(s, [
        const PutanaBlock('put', 'doc'),
        const DoctorSave('doc', 'c1'),
        const MafiaKill('gf', 'c1'),
      ]);
      expect(deaths(r), ['c1']);
    });

    test('cannot block herself', () {
      expect(
        () => resolveNight(toNight(newGame(), 2), [const PutanaBlock('put', 'put')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('as the last Mafia Team player she becomes a regular Mafia and kills', () {
      final s = GameState.initial(players: table([
        ('gf', Role.godfather),
        ('put', Role.putana),
        ('joker', Role.joker),
        ('c1', Role.civilian),
        ('c2', Role.civilian),
        ('c3', Role.civilian),
        ('c4', Role.civilian),
      ]));
      final r = resolveNight(s, [const JokerKill('joker', 'gf')]);
      expect(r.events, contains(const PutanaPromoted('put')));
      expect(r.state.abilityOf('put'), Role.mafia);

      final next = skipDay(r.state);
      expect(deaths(resolveNight(next, [const MafiaKill('put', 'c1')])), ['c1']);
      expect(
        () => resolveNight(next, [const PutanaBlock('put', 'c1')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
    });
  });

  group('Lawyer', () {
    test('a protected Mafia player reads as Civilian to the Detective', () {
      final r = resolveNight(newGame(), [
        const LawyerProtect('law', 'maf'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(
        r.events,
        contains(const DetectiveResultRevealed('det', 'maf', DetectiveResult.civilian)),
      );
    });

    test('protects Mafia players only', () {
      expect(
        () => resolveNight(newGame(), [const LawyerProtect('law', 'c1')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });
  });

  group('Witch', () {
    test('links two Civilians on night 2 only', () {
      expect(
        () => resolveNight(newGame(), [const WitchLink('witch', 'c1', 'c2')]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
      final r = resolveNight(toNight(newGame(), 2), [const WitchLink('witch', 'c1', 'c2')]);
      expect(r.state.witchLink, ('c1', 'c2'));
      expect(r.events, contains(const SoulsLinked('c1', 'c2')));
      expect(
        () => resolveNight(toNight(newGame(), 3), [const WitchLink('witch', 'c1', 'c2')]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
    });

    test('needs two different players', () {
      expect(
        () => resolveNight(toNight(newGame(), 2), [const WitchLink('witch', 'c1', 'c1')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('a blocked Witch links nobody', () {
      final r = resolveNight(toNight(newGame(), 2), [
        const PutanaBlock('put', 'witch'),
        const WitchLink('witch', 'c1', 'c2'),
      ]);
      expect(r.state.witchLink, isNull);
    });
  });

  group('Joker', () {
    test('kills one player each night, with no penalty', () {
      var r = resolveNight(newGame(), [const JokerKill('joker', 'c1')]);
      expect(deathOf(r, 'c1').causes, {DeathCause.joker});
      r = resolveNight(skipDay(r.state), [const JokerKill('joker', 'c2')]);
      expect(deaths(r), ['c2']);
      expect(isAlive(r.state, 'joker'), isTrue);
    });

    test('a Mafia and a Joker kill on the same night both land', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const JokerKill('joker', 'maf'),
      ]);
      expect(deaths(r), ['maf', 'c1']);
    });

    test('the same victim from both records both causes', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const JokerKill('joker', 'c1'),
      ]);
      expect(deathOf(r, 'c1').causes, {DeathCause.mafia, DeathCause.joker});
    });

    test('cannot target themselves', () {
      expect(
        () => resolveNight(newGame(), [const JokerKill('joker', 'joker')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });
  });

  group('Silencer', () {
    test('the silenced player is silenced for the next day', () {
      final r = resolveNight(newGame(), [const SilencerSilence('sil', 'c1')]);
      expect(r.events, contains(const PlayerSilenced('c1')));
      expect(r.state.isSilenced('c1'), isTrue);
      expect(r.state.isSilenced('c2'), isFalse);
    });

    test('cannot silence themselves', () {
      expect(
        () => resolveNight(newGame(), [const SilencerSilence('sil', 'sil')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('a blocked Silencer silences nobody', () {
      final r = resolveNight(toNight(newGame(), 2), [
        const PutanaBlock('put', 'sil'),
        const SilencerSilence('sil', 'c1'),
      ]);
      expect(r.state.isSilenced('c1'), isFalse);
    });
  });

  group('Doctor', () {
    test('saves from a night kill (Mafia or Joker)', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'c1'),
        const JokerKill('joker', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(deaths(r), isEmpty);
      expect(r.events, contains(const PlayerSaved('c1', {DeathCause.mafia, DeathCause.joker})));
    });

    test('may save themselves', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'doc'),
        const DoctorSave('doc', 'doc'),
      ]);
      expect(deaths(r), isEmpty);
    });

    test('the same player two nights in a row, but not three', () {
      var s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      s = nightThenSkipDay(s, [const DoctorSave('doc', 'c1')]);
      expect(
        () => resolveNight(s, [const DoctorSave('doc', 'c1')]),
        throwsInvalid(InvalidActionReason.doctorRepeatTarget),
      );
      expect(() => resolveNight(s, [const DoctorSave('doc', 'c2')]), returnsNormally);
    });

    test('a different pick or a night off resets the streak', () {
      var s = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      s = nightThenSkipDay(s, [const DoctorSave('doc', 'c2')]);
      s = nightThenSkipDay(s, [const DoctorSave('doc', 'c1')]);
      expect(() => resolveNight(s, [const DoctorSave('doc', 'c1')]), returnsNormally);

      var t = nightThenSkipDay(newGame(), [const DoctorSave('doc', 'c1')]);
      t = nightThenSkipDay(t, [const DoctorSave('doc', 'c1')]);
      t = nightThenSkipDay(t);
      expect(() => resolveNight(t, [const DoctorSave('doc', 'c1')]), returnsNormally);
    });

    test('a blocked pick still counts toward the streak', () {
      var s = toNight(newGame(), 2);
      s = nightThenSkipDay(s, [const DoctorSave('doc', 'c1')]);
      s = nightThenSkipDay(s, [const PutanaBlock('put', 'doc'), const DoctorSave('doc', 'c1')]);
      expect(
        () => resolveNight(s, [const DoctorSave('doc', 'c1')]),
        throwsInvalid(InvalidActionReason.doctorRepeatTarget),
      );
    });
  });

  group('Detective', () {
    test('learns whether the player is Mafia', () {
      final r = resolveNight(newGame(), [const DetectiveCheck('det', 'maf')]);
      expect(r.events, contains(const DetectiveResultRevealed('det', 'maf', DetectiveResult.mafia)));
      final r2 = resolveNight(newGame(), [const DetectiveCheck('det', 'c1')]);
      expect(
        r2.events,
        contains(const DetectiveResultRevealed('det', 'c1', DetectiveResult.civilian)),
      );
    });

    test('Q1 default: the Godfather reads as Mafia', () {
      final r = resolveNight(newGame(), [const DetectiveCheck('det', 'gf')]);
      expect(r.events, contains(const DetectiveResultRevealed('det', 'gf', DetectiveResult.mafia)));
    });

    test('a blocked Detective learns nothing', () {
      final r = resolveNight(toNight(newGame(), 2), [
        const PutanaBlock('put', 'det'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(r.events.whereType<DetectiveResultRevealed>(), isEmpty);
    });

    test('cannot check themselves', () {
      expect(
        () => resolveNight(newGame(), [const DetectiveCheck('det', 'det')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });
  });

  group('Shapeshifter', () {
    test("plays tonight's role: Detective, Doctor, Joker, then repeats", () {
      var s = newGame();
      expect(s.abilityOf('shape'), Role.detective);
      var r = resolveNight(s, [const DetectiveCheck('shape', 'maf')]);
      expect(
        r.events,
        contains(const DetectiveResultRevealed('shape', 'maf', DetectiveResult.mafia)),
      );
      expect(
        () => resolveNight(s, [const DoctorSave('shape', 'c1')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );

      s = skipDay(r.state);
      expect(s.abilityOf('shape'), Role.doctor);
      r = resolveNight(s, [const MafiaKill('gf', 'c1'), const DoctorSave('shape', 'c1')]);
      expect(deaths(r), isEmpty);

      s = skipDay(r.state);
      expect(s.abilityOf('shape'), Role.joker);
      r = resolveNight(s, [const JokerKill('shape', 'maf')]);
      expect(deaths(r), ['maf']);

      expect(skipDay(r.state).abilityOf('shape'), Role.detective);
    });

    test('always stays on the Civilians Team', () {
      final s = toNight(newGame(), 3);
      expect(s.player('shape').team, Team.civilians);
    });
  });

  group('Bomb planting', () {
    test('wakes once, on night 2, and plants on two players', () {
      expect(
        () => resolveNight(newGame(), [const BombPlant('bomb', 'c1', 'c2')]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
      final r = resolveNight(toNight(newGame(), 2), [const BombPlant('bomb', 'c1', 'c2')]);
      expect(r.state.bombPlants, {
        'bomb': ['c1', 'c2'],
      });
      expect(r.events, contains(const BombPlanted('bomb', 'c1', 'c2')));
      expect(
        () => resolveNight(toNight(newGame(), 3), [const BombPlant('bomb', 'c1', 'c2')]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
    });

    test('two different players, not the Bomb', () {
      final s = toNight(newGame(), 2);
      expect(
        () => resolveNight(s, [const BombPlant('bomb', 'c1', 'c1')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
      expect(
        () => resolveNight(s, [const BombPlant('bomb', 'bomb', 'c1')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('a blocked Bomb plants nothing', () {
      final r = resolveNight(toNight(newGame(), 2), [
        const PutanaBlock('put', 'bomb'),
        const BombPlant('bomb', 'c1', 'c2'),
      ]);
      expect(r.state.bombPlants, isEmpty);
    });
  });

  group('Chameleon', () {
    test('chooses on night 3, from the five roles', () {
      expect(
        () => resolveNight(toNight(newGame(), 2), [const ChameleonChoose('cham', Role.doctor)]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
      final s = toNight(newGame(), 3);
      expect(
        () => resolveNight(s, [const ChameleonChoose('cham', Role.civilian)]),
        throwsInvalid(InvalidActionReason.roleNotAllowed),
      );
      final r = resolveNight(s, [const ChameleonChoose('cham', Role.detective)]);
      expect(r.events, contains(const ChameleonChose('cham', Role.detective)));
      expect(r.state.player('cham').chameleonRole, Role.detective);
    });

    test('plays the chosen role from night 4, for the rest of the game', () {
      final s = toNight(newGame(), 3);
      expect(
        () => resolveNight(s, [
          const ChameleonChoose('cham', Role.detective),
          const DetectiveCheck('cham', 'maf'),
        ]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
      var next = nightThenSkipDay(s, [const ChameleonChoose('cham', Role.detective)]);
      expect(next.abilityOf('cham'), Role.detective);
      final r = resolveNight(next, [const DetectiveCheck('cham', 'maf')]);
      expect(r.events, contains(const DetectiveResultRevealed('cham', 'maf', DetectiveResult.mafia)));
      next = toNight(skipDay(r.state), 6);
      expect(next.abilityOf('cham'), Role.detective);
    });

    test('chooses once', () {
      final s = nightThenSkipDay(toNight(newGame(), 3), [
        const ChameleonChoose('cham', Role.doctor),
      ]);
      expect(
        () => resolveNight(s, [const ChameleonChoose('cham', Role.joker)]),
        throwsInvalid(InvalidActionReason.notTonight),
      );
    });

    test('Q4 default: choosing Mafia joins the Mafia Team', () {
      final s = nightThenSkipDay(toNight(newGame(), 3), [const ChameleonChoose('cham', Role.mafia)]);
      expect(s.player('cham').team, Team.mafia);
      final r = resolveNight(s, [
        const MafiaKill('gf', 'c1'),
        const MafiaKill('cham', 'c1'),
        const DetectiveCheck('det', 'cham'),
      ]);
      expect(deaths(r), ['c1']);
      expect(r.events, contains(const DetectiveResultRevealed('det', 'cham', DetectiveResult.mafia)));
    });

    test('a Chameleon-Switchman redirects from night 4', () {
      final s = nightThenSkipDay(toNight(newGame(), 3), [
        const ChameleonChoose('cham', Role.switchman),
      ]);
      final r = resolveNight(s, [
        const MafiaKill('gf', 'cham'),
        const SwitchmanRedirect('cham', 'maf'),
      ]);
      expect(deaths(r), ['maf']);
    });
  });

  group('Switchman', () {
    test('a bullet aimed at the Switchman goes to the player they choose', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'sw'),
        const SwitchmanRedirect('sw', 'maf'),
      ]);
      expect(deaths(r), ['maf']);
      expect(r.events, contains(const BulletRedirected('sw', 'maf')));
    });

    test('immortal at night: no redirect means the bullet hits nobody', () {
      final r = resolveNight(newGame(), [const JokerKill('joker', 'sw')]);
      expect(deaths(r), isEmpty);
      expect(r.events, contains(const BulletDodged('sw')));
    });

    test('dies only if Putana blocks them that night', () {
      final r = resolveNight(toNight(newGame(), 2), [
        const PutanaBlock('put', 'sw'),
        const MafiaKill('gf', 'sw'),
        const SwitchmanRedirect('sw', 'maf'),
      ]);
      expect(deaths(r), ['sw']);
    });

    test('the Doctor saves the redirected target (Q9 default)', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'sw'),
        const SwitchmanRedirect('sw', 'c1'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(deaths(r), isEmpty);
    });

    test('redirects only when targeted, never onto themselves', () {
      expect(
        () => resolveNight(newGame(), [const SwitchmanRedirect('sw', 'c1')]),
        throwsInvalid(InvalidActionReason.notTargeted),
      );
      expect(
        () => resolveNight(newGame(), [
          const MafiaKill('gf', 'sw'),
          const SwitchmanRedirect('sw', 'sw'),
        ]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('bulletsAt lists who is shooting the Switchman tonight, in resolution order', () {
      final s = newGame();
      expect(
        s.bulletsAt('sw', [const JokerKill('joker', 'sw'), const MafiaKill('gf', 'sw')]),
        [DeathCause.mafia, DeathCause.joker],
      );
      expect(s.bulletsAt('sw', [const MafiaKill('gf', 'c1')]), isEmpty);
    });
  });

  group('Resolution', () {
    test('does not depend on the order actions were submitted in', () {
      final actions = <NightAction>[
        const MafiaKill('gf', 'c1'),
        const DoctorSave('doc', 'c1'),
        const JokerKill('joker', 'c2'),
        const DetectiveCheck('det', 'maf'),
        const SilencerSilence('sil', 'c3'),
      ];
      final a = resolveNight(newGame(), actions);
      final b = resolveNight(newGame(), actions.reversed.toList());
      expect(b.events, a.events);
      expect(b.state.players, a.state.players);
    });

    test('rejects a second action of the same kind by the same player', () {
      expect(
        () => resolveNight(newGame(), [
          const JokerKill('joker', 'c1'),
          const JokerKill('joker', 'c2'),
        ]),
        throwsInvalid(InvalidActionReason.duplicateAction),
      );
    });

    test('rejects dead actors and dead targets', () {
      final s = nightThenSkipDay(newGame(), [const MafiaKill('gf', 'c1')]);
      expect(
        () => resolveNight(s, [const JokerKill('joker', 'c1')]),
        throwsInvalid(InvalidActionReason.targetDead),
      );
    });

    test('only at night', () {
      final day = resolveNight(newGame(), const []).state;
      expect(() => resolveNight(day, const []), throwsInvalid(InvalidActionReason.wrongPhase));
    });

    test('roles act only through their own ability', () {
      expect(
        () => resolveNight(newGame(), [const DoctorSave('c1', 'c2')]),
        throwsInvalid(InvalidActionReason.actorLacksRole),
      );
    });

    test('moves to the day with the same number', () {
      final s = resolveNight(newGame(), const []).state;
      expect(s.phase, GamePhase.day);
      expect(s.nightNumber, 1);
    });
  });
}
