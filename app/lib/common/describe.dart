import 'package:mafia_engine/mafia_engine.dart';

import '../game/game_input.dart';
import '../game/game_session.dart';
import '../l10n/app_localizations.dart';
import 'l10n.dart';

/// Turns engine actions and events into localized sentences.
class Describer {
  Describer(this.l, this.state);

  final AppLocalizations l;
  final GameState state;

  String name(String id) => state.player(id).name;

  String actor(String id) => l.actorWithRole(name(id), l.playerRole(state.player(id)));

  String action(NightAction a) {
    final who = actor(a.actorId);
    final target = name(a.targetId);
    return switch (a) {
      PotanaBlock() => l.actionPotanaBlock(who, target),
      LawyerProtect() => l.actionLawyerProtect(who, target),
      MafiaKill() => l.actionMafiaKill(who, target),
      JokerKill() => l.actionJokerKill(who, target),
      DoctorSave() => l.actionDoctorSave(who, target),
      DetectiveCheck() => l.actionDetectiveCheck(who, target),
    };
  }

  String detectiveResult(DetectiveResult r) => switch (r) {
    DetectiveResult.mafia => l.resultMafia,
    DetectiveResult.civilian => l.resultCivilian,
  };

  /// Events everyone hears.
  static bool isPublic(GameEvent e) =>
      e is PlayerDied || e is BombTriggered || e is NoElimination || e is VoteTied || e is GameOver;

  String? event(GameEvent e) => switch (e) {
    PlayerDied(:final playerId, :final causes, :final revealedRole) => [
      if (causes.contains(DeathCause.vote))
        l.announceVotedOut(name(playerId))
      else if (causes.contains(DeathCause.bomb))
        l.announceBombVictim(name(playerId))
      else
        l.announceKilled(name(playerId)),
      if (revealedRole != null) l.announceCard(l.playerRole(state.player(playerId))),
    ].join(' '),
    BombTriggered(:final bombId) => l.announceBomb(name(bombId)),
    NoElimination() => l.announceNoElimination,
    VoteTied(:final candidateIds) => l.announceTie(l.names(candidateIds.map(name))),
    GameOver(:final winner) => winner == Team.mafia ? l.winMafia : l.winCivilians,
    PlayerBlocked(:final playerId) => l.hostBlocked(name(playerId)),
    LawyerProtected(:final playerId) => l.hostProtected(name(playerId)),
    PlayerSaved(:final playerId) => l.hostSaved(name(playerId)),
    DetectiveResultRevealed(:final targetId, :final result) => l.hostDetective(
      name(targetId),
      detectiveResult(result),
    ),
    BombDefused(:final bombId) => l.hostBombDefused(name(bombId)),
    RevoteRequired() || HostDecisionRequired() => null,
  };

  /// The read-aloud announcement for [entries] (one night or one vote, plus
  /// any Bomb explosions after it). Game over is shown separately.
  List<String> announcement(List<LogEntry> entries) {
    final lines = <String>[];
    if (entries.isNotEmpty &&
        entries.first.input is NightInput &&
        !entries.first.events.any((e) => e is PlayerDied)) {
      lines.add(l.announceNobodyDied);
    }
    for (final entry in entries) {
      for (final e in entry.events) {
        if (isPublic(e) && e is! GameOver) lines.add(event(e)!);
      }
    }
    return lines;
  }

  /// What only the host should see: who did what, blocks, saves, the
  /// Detective's result.
  List<String> hostNotes(List<LogEntry> entries) => [
    for (final entry in entries) ...[
      if (entry.input case NightInput(:final actions)) ...actions.map(action),
      for (final e in entry.events)
        if (!isPublic(e)) ?event(e),
    ],
  ];

  /// Every line the game log shows for [entry].
  List<String> logLines(LogEntry entry) => [
    ...switch (entry.input) {
      NightInput(:final actions) when actions.isEmpty => [l.logNoActions],
      NightInput(:final actions) => actions.map(action),
      BombInput(:final bombId, :final victimIds) => [
        l.logBomb(name(bombId), l.names(victimIds.map(name))),
      ],
      VoteInput(:final votes, :final tieBreakerId) => [
        for (final MapEntry(key: voter, value: target) in votes.entries)
          target == null ? l.logAbstain(name(voter)) : l.logVote(name(voter), name(target)),
        if (votes.isEmpty) l.logNoVote,
        if (tieBreakerId != null) l.logTieBreak(name(tieBreakerId)),
      ],
      AdvanceInput() => const <String>[],
    },
    for (final e in entry.events) ?event(e),
  ];
}
