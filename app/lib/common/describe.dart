import 'package:mafia_engine/mafia_engine.dart';

import '../game/game_input.dart';
import '../game/game_session.dart';
import '../l10n/app_localizations.dart';
import 'l10n.dart';

enum AnnouncementType { death, bomb, save, info }

/// Game log filter groups.
enum LogKind { kill, save, vote, other }

/// One line of the game log and the group it filters under.
typedef LogItem = ({LogKind kind, String text});

/// One numbered item of a morning / vote-result announcement.
final class Announcement {
  const Announcement(this.type, this.headline, {this.detail, this.chips = const []});

  final AnnouncementType type;

  /// What the host reads aloud.
  final String headline;

  /// A note for the host under it (not read aloud).
  final String? detail;

  /// Names shown as chips (the Bomb's victims).
  final List<String> chips;
}

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

  /// The announcement as numbered items: deaths (a dead Bomb carries its
  /// victims), a Doctor save (without saying who), or that nobody died.
  List<Announcement> announcementItems(List<LogEntry> entries) {
    final events = [for (final e in entries) ...e.events];
    final bombs = {
      for (final e in events)
        if (e is BombTriggered) e.bombId,
    };
    final items = <Announcement>[];
    final night = entries.isNotEmpty && entries.first.input is NightInput;
    for (final e in events) {
      switch (e) {
        case PlayerDied(:final causes) when causes.contains(DeathCause.bomb):
          if (bombs.isEmpty) items.add(Announcement(AnnouncementType.death, event(e)!));
        // Listed as chips under the Bomb's own item.
        case PlayerDied(:final playerId, :final causes, :final revealedRole):
          final card = revealedRole == null
              ? l.announceRoleSecret
              : l.announceCard(l.playerRole(state.player(playerId)));
          final headline = causes.contains(DeathCause.vote)
              ? l.announceVotedOut(name(playerId))
              : l.announceKilled(name(playerId));
          if (bombs.contains(playerId)) {
            final victims = [
              for (final v in events)
                if (v is PlayerDied && v.causes.contains(DeathCause.bomb)) name(v.playerId),
            ];
            final pending = state.pendingBombs.contains(playerId);
            items.add(
              Announcement(
                AnnouncementType.bomb,
                l.announceWasBomb(headline),
                detail: pending
                    ? l.announceBombChoosing(state.bombVictimsRequired)
                    : victims.isEmpty
                    ? null
                    : l.announceBombTakes(victims.length),
                chips: victims,
              ),
            );
          } else {
            items.add(Announcement(AnnouncementType.death, headline, detail: card));
          }
        case PlayerSaved():
          items.add(
            Announcement(
              AnnouncementType.save,
              l.announceSomeoneSaved,
              detail: l.announceDontSayWho,
            ),
          );
        case VoteTied(:final candidateIds):
          items.add(
            Announcement(AnnouncementType.info, l.announceTie(l.names(candidateIds.map(name)))),
          );
        case NoElimination():
          items.add(Announcement(AnnouncementType.info, l.announceNoElimination));
        default:
      }
    }
    if (night && !events.any((e) => e is PlayerDied)) {
      items.insert(0, Announcement(AnnouncementType.info, l.announceNobodyDied));
    }
    return items;
  }

  /// Host-only notes worth flagging after a night: the Detective's result,
  /// blocks and a Bomb that did not explode.
  /// What "Read aloud" speaks for [items]: each headline in order. Host
  /// notes stay silent, except a Bomb's "takes N with them:" line when its
  /// victims are known, which is public and reads into their names.
  String spokenText(List<Announcement> items) => [
    for (final item in items)
      item.chips.isEmpty
          ? item.headline
          : [item.headline, ?item.detail, '${l.names(item.chips)}.'].join(' '),
  ].join('\n');

  List<String> secretNotes(List<LogEntry> entries) => [
    for (final entry in entries)
      for (final e in entry.events)
        if (e is DetectiveResultRevealed)
          l.hostOnlyDetective(name(e.targetId), detectiveResult(e.result))
        else if (e is PlayerBlocked || e is BombDefused)
          ?event(e),
  ];

  /// What only the host should see: who did what, blocks, saves, the
  /// Detective's result.
  List<String> hostNotes(List<LogEntry> entries) => [
    for (final entry in entries) ...[
      if (entry.input case NightInput(:final actions)) ...actions.map(action),
      for (final e in entry.events)
        if (!isPublic(e)) ?event(e),
    ],
  ];

  /// [logLines] with each line's group, for the filtered timeline.
  List<LogItem> logItems(LogEntry entry) => [
    ...switch (entry.input) {
      NightInput(:final actions) when actions.isEmpty => [
        (kind: LogKind.other, text: l.logNoActions),
      ],
      NightInput(:final actions) => [
        for (final a in actions)
          (
            kind: switch (a) {
              MafiaKill() || JokerKill() => LogKind.kill,
              DoctorSave() => LogKind.save,
              _ => LogKind.other,
            },
            text: action(a),
          ),
      ],
      BombInput() || DayVoteInput() || AdvanceInput() => [
        for (final line in _inputLines(entry))
          (kind: entry.input is BombInput ? LogKind.kill : LogKind.vote, text: line),
      ],
    },
    for (final e in entry.events)
      if (event(e) case final text?)
        (
          kind: switch (e) {
            PlayerDied(:final causes) when causes.contains(DeathCause.vote) => LogKind.vote,
            PlayerDied() || BombTriggered() => LogKind.kill,
            PlayerSaved() => LogKind.save,
            VoteTied() || NoElimination() => LogKind.vote,
            _ => LogKind.other,
          },
          text: text,
        ),
  ];

  List<String> _inputLines(LogEntry entry) => switch (entry.input) {
    BombInput(:final bombId, :final victimIds) => [
      l.logBomb(name(bombId), l.names(victimIds.map(name))),
    ],
    VoteInput(:final votes, :final tieBreakerId) => [
      for (final MapEntry(key: voter, value: target) in votes.entries)
        target == null ? l.logAbstain(name(voter)) : l.logVote(name(voter), name(target)),
      if (votes.isEmpty) l.logNoVote,
      if (tieBreakerId != null) l.logTieBreak(name(tieBreakerId)),
    ],
    TallyVoteInput(:final tally, :final tieBreakerId) => [
      for (final MapEntry(key: target, value: count) in tally.entries)
        if (count > 0) l.logVotesFor(name(target), count),
      if (!tally.values.any((n) => n > 0)) l.logNoVote,
      if (tieBreakerId != null) l.logTieBreak(name(tieBreakerId)),
    ],
    _ => const <String>[],
  };

  /// Every line the game log shows for [entry].
  List<String> logLines(LogEntry entry) => [for (final i in logItems(entry)) i.text];
}
