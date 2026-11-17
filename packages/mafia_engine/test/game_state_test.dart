import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Role teams', () {
    test('civilian-team roles', () {
      for (final r in [
        Role.civilian,
        Role.doctor,
        Role.detective,
        Role.bomb,
        Role.joker,
        Role.chameleon,
      ]) {
        expect(r.team, Team.civilians, reason: r.name);
      }
    });

    test('mafia-team roles', () {
      for (final r in [Role.mafia, Role.godfather, Role.potana, Role.lawyer]) {
        expect(r.team, Team.mafia, reason: r.name);
      }
    });
  });

  group('GameSettings defaults', () {
    test('match the documented defaults', () {
      const s = GameSettings();
      expect(s.bombVictimCount, 2);
      expect(s.doctorSaveBlocksJokerKill, isTrue);
      expect(s.doctorCanSaveBombVictims, isFalse);
      expect(s.blockedBombStillExplodes, isTrue);
      expect(s.chameleonCanPickMafiaRoles, isFalse);
      expect(s.revealRoleOnDeath, isFalse);
      expect(s.tieVoteRule, TieVoteRule.hostDecides);
    });
  });

  group('GameSettings.copyWith', () {
    test('changes only the given fields', () {
      final s = const GameSettings().copyWith(bombVictimCount: 3, tieVoteRule: TieVoteRule.revote);
      expect(s.bombVictimCount, 3);
      expect(s.tieVoteRule, TieVoteRule.revote);
      expect(s.doctorSaveBlocksJokerKill, isTrue);
      expect(s.revealRoleOnDeath, isFalse);
    });
  });

  group('GameState.initial', () {
    test('starts at night 1 with everyone alive and no winner', () {
      final s = newGame();
      expect(s.phase, GamePhase.night);
      expect(s.nightNumber, 1);
      expect(s.winner, isNull);
      expect(s.pendingBombs, isEmpty);
      expect(s.players.every((p) => p.isAlive), isTrue);
    });

    test('players list is unmodifiable', () {
      final s = newGame();
      expect(() => s.players.add(p('x', Role.civilian)), throwsUnsupportedError);
    });

    test('rejects duplicate player ids', () {
      expect(
        () => newGame(players: [p('a', Role.civilian), p('a', Role.mafia)]),
        throwsSetup(InvalidSetupReason.duplicatePlayerId),
      );
    });

    test('bombVictimCount must be 2 or 3', () {
      for (final n in [1, 4]) {
        expect(
          () => newGame(settings: GameSettings(bombVictimCount: n)),
          throwsSetup(InvalidSetupReason.invalidBombVictimCount),
        );
      }
      expect(newGame(settings: const GameSettings(bombVictimCount: 3)).settings.bombVictimCount, 3);
    });

    test('a Chameleon must pick a role', () {
      expect(
        () => newGame(players: [p('ch', Role.chameleon), p('gf', Role.godfather)]),
        throwsSetup(InvalidSetupReason.chameleonRoleMissing),
      );
    });

    test('a Chameleon cannot pick Chameleon', () {
      expect(
        () => newGame(players: [p('ch', Role.chameleon, as: Role.chameleon)]),
        throwsSetup(InvalidSetupReason.chameleonRoleNotAllowed),
      );
    });

    test('a Chameleon cannot pick a Mafia role by default', () {
      expect(
        () => newGame(players: [p('ch', Role.chameleon, as: Role.potana)]),
        throwsSetup(InvalidSetupReason.chameleonRoleNotAllowed),
      );
    });

    test('a Chameleon may pick a Mafia role when allowed, and joins that team', () {
      final s = newGame(
        players: [p('ch', Role.chameleon, as: Role.potana)],
        settings: const GameSettings(chameleonCanPickMafiaRoles: true),
      );
      expect(s.player('ch').effectiveRole, Role.potana);
      expect(s.player('ch').team, Team.mafia);
    });

    test('a Chameleon plays its picked role on the civilian team', () {
      final s = newGame(players: [p('ch', Role.chameleon, as: Role.doctor)]);
      expect(s.player('ch').role, Role.chameleon);
      expect(s.player('ch').effectiveRole, Role.doctor);
      expect(s.player('ch').team, Team.civilians);
    });

    test('only a Chameleon may have a chameleonRole', () {
      expect(
        () => newGame(players: [p('d', Role.doctor, as: Role.detective)]),
        throwsSetup(InvalidSetupReason.chameleonRoleOnNonChameleon),
      );
    });

    test('player() with an unknown id throws', () {
      expect(() => newGame().player('nobody'), throwsInvalid(InvalidActionReason.unknownPlayer));
    });
  });
}
