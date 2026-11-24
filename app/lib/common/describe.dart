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

  /// Names shown as chips: the players a death took with it.
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
    return switch (a) {
      PutanaBlock(:final targetId) => l.actionPutanaBlock(who, name(targetId)),
      LawyerProtect(:final targetId) => l.actionLawyerProtect(who, name(targetId)),
      MafiaKill(:final targetId) => l.actionMafiaKill(who, name(targetId)),
      JokerKill(:final targetId) => l.actionJokerKill(who, name(targetId)),
      DoctorSave(:final targetId) => l.actionDoctorSave(who, name(targetId)),
      DetectiveCheck(:final targetId) => l.actionDetectiveCheck(who, name(targetId)),
      SilencerSilence(:final targetId) => l.actionSilence(who, name(targetId)),
      SwitchmanRedirect(:final targetId) => l.actionRedirect(who, name(targetId)),
      WitchLink(:final firstId, :final secondId) => l.actionWitchLink(
        who,
        name(firstId),
        name(secondId),
      ),
      BombPlant(:final firstId, :final secondId) => l.actionBombPlant(
        who,
        name(firstId),
        name(secondId),
      ),
      ChameleonChoose(:final role) => l.actionChameleonChoose(who, l.role(role)),
    };
  }

  String detectiveResult(DetectiveResult r) => switch (r) {
    DetectiveResult.mafia => l.resultMafia,
    DetectiveResult.civilian => l.resultCivilian,
  };

  /// Events everyone hears.
  static bool isPublic(GameEvent e) =>
      e is PlayerDied ||
      e is BombExploded ||
      e is PlayerSilenced ||
      e is NoElimination ||
      e is VoteTied ||
      e is GameOver;

  /// What the table hears about a death. Night kills stay vague (who did
  /// it is secret); the chains everyone sees happen are named.
  String deathHeadline(PlayerDied d) {
    final who = name(d.playerId);
    final c = d.causes;
    if (c.contains(DeathCause.vote)) return l.announceVotedOut(who);
    if (c.contains(DeathCause.removed)) return l.announceRemoved(who);
    if (c.contains(DeathCause.bomb)) return l.announceBombVictim(who);
    if (c.contains(DeathCause.tnt)) return l.announceTntVictim(who);
    if (c.contains(DeathCause.godfather)) return l.announceGodfatherVictim(who);
    return l.announceKilled(who);
  }

  String? event(GameEvent e) => switch (e) {
    PlayerDied(:final playerId, :final revealedRole) => [
      deathHeadline(e),
      if (revealedRole != null) l.announceCard(l.playerRole(state.player(playerId))),
    ].join(' '),
    BombExploded(:final playerId) => l.announceBomb(name(playerId)),
    PlayerSilenced(:final playerId) => l.announceSilenced(name(playerId)),
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
    SoulsLinked(:final firstId, :final secondId) => l.hostLinked(name(firstId), name(secondId)),
    BombPlanted(:final bombId, :final firstId, :final secondId) => l.hostBombPlanted(
      name(bombId),
      name(firstId),
      name(secondId),
    ),
    ChameleonChose(:final playerId, :final role) => l.hostChameleonChose(
      name(playerId),
      l.role(role),
    ),
    MafiaKillCancelled() => l.hostMafiaCancelled,
    BulletRedirected(:final switchmanId, :final targetId) => l.hostRedirected(
      name(switchmanId),
      name(targetId),
    ),
    BulletDodged(:final playerId) => l.hostDodged(name(playerId)),
    DetectiveChainArmed(:final detectiveId, :final mafiaIds) => l.hostChainArmed(
      name(detectiveId),
      l.names(mafiaIds.map(name)),
    ),
    PutanaPromoted(:final playerId) => l.hostPutanaPromoted(name(playerId)),
    ChoiceRequired(:final choice) => choiceNote(choice),
    RevoteRequired() || HostDecisionRequired() || DrawLotsRequired() => null,
  };

  /// "Choose now" for a death waiting on the host.
  String choiceNote(PendingChoice c) => switch (c.kind) {
    ChoiceKind.godfatherTakesOne => l.announceGodfatherChoosing,
    ChoiceKind.bombTakesNeighbors => l.announceBombNeighborsChoosing,
  };

  /// The announcement as numbered items: each death (one that took others
  /// carries them as chips), a Doctor save (without saying who), silences,
  /// tie and vote notes, or that nobody died.
  List<Announcement> announcementItems(List<LogEntry> entries) {
    final events = [for (final e in entries) ...e.events];
    final died = {
      for (final e in events)
        if (e is PlayerDied) e.playerId: e,
    };
    // A chain victim is listed under the first death of its chain.
    String root(String id) {
      var at = id;
      while (true) {
        final by = died[at]?.causedBy;
        if (by == null || !died.containsKey(by)) return at;
        at = by;
      }
    }

    final items = <Announcement>[];
    final night = entries.isNotEmpty && entries.first.input is NightInput;
    for (final e in events) {
      switch (e) {
        case PlayerDied(:final playerId, :final revealedRole):
          if (root(playerId) != playerId) continue;
          final taken = [
            for (final d in died.values)
              if (d.playerId != playerId && root(d.playerId) == playerId) name(d.playerId),
          ];
          final pending = state.pendingChoices.where((c) => c.playerId == playerId).firstOrNull;
          final headline = switch (state.player(playerId).effectiveRole) {
            Role.bomb when taken.isNotEmpty || pending != null => l.announceWasBomb(
              deathHeadline(e),
            ),
            Role.tnt when taken.isNotEmpty => l.announceWasTnt(deathHeadline(e)),
            _ => deathHeadline(e),
          };
          final card = revealedRole == null
              ? l.announceRoleSecret
              : l.announceCard(l.playerRole(state.player(playerId)));
          if (taken.isEmpty && pending == null) {
            items.add(Announcement(AnnouncementType.death, headline, detail: card));
          } else {
            items.add(
              Announcement(
                AnnouncementType.bomb,
                headline,
                detail: pending != null ? choiceNote(pending) : l.announceBombTakes(taken.length),
                chips: taken,
              ),
            );
          }
        case PlayerSaved():
          items.add(
            Announcement(
              AnnouncementType.save,
              l.announceSomeoneSaved,
              detail: l.announceDontSayWho,
            ),
          );
        case PlayerSilenced(:final playerId):
          items.add(
            Announcement(
              AnnouncementType.info,
              l.announceSilenced(name(playerId)),
              detail: l.announceSilencedRule,
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
    if (night && died.isEmpty) {
      items.insert(0, Announcement(AnnouncementType.info, l.announceNobodyDied));
    }
    return items;
  }

  /// What "Read aloud" speaks for [items]: each headline in order. Host
  /// notes stay silent, except the "takes N with them:" line when the
  /// victims are known, which is public and reads into their names.
  String spokenText(List<Announcement> items) => [
    for (final item in items)
      item.chips.isEmpty
          ? item.headline
          : [item.headline, ?item.detail, '${l.names(item.chips)}.'].join(' '),
  ].join('\n');

  /// Host-only notes worth flagging after a night.
  List<String> secretNotes(List<LogEntry> entries) => [
    for (final entry in entries)
      for (final e in entry.events)
        if (e is DetectiveResultRevealed)
          l.hostOnlyDetective(name(e.targetId), detectiveResult(e.result))
        else if (e is PlayerBlocked ||
            e is SoulsLinked ||
            e is BombPlanted ||
            e is ChameleonChose ||
            e is MafiaKillCancelled ||
            e is BulletRedirected ||
            e is BulletDodged ||
            e is DetectiveChainArmed ||
            e is PutanaPromoted)
          ?event(e),
  ];

  /// What only the host should see: who did what, and the secret events.
  List<String> hostNotes(List<LogEntry> entries) => [
    for (final entry in entries) ...[
      if (entry.input case NightInput(:final actions)) ...actions.map(action),
      for (final e in entry.events)
        if (!isPublic(e) && e is! ChoiceRequired) ?event(e),
    ],
  ];

  /// The game log lines for [entry], with each line's filter group.
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
      _ => [
        for (final line in _inputLines(entry))
          (kind: entry.input is ChoiceInput ? LogKind.kill : LogKind.vote, text: line),
      ],
    },
    for (final e in entry.events)
      if (event(e) case final text?)
        (
          kind: switch (e) {
            PlayerDied(:final causes) when causes.contains(DeathCause.vote) => LogKind.vote,
            PlayerDied() || BombExploded() => LogKind.kill,
            PlayerSaved() => LogKind.save,
            VoteTied() || NoElimination() => LogKind.vote,
            _ => LogKind.other,
          },
          text: text,
        ),
  ];

  List<String> _inputLines(LogEntry entry) => switch (entry.input) {
    ChoiceInput(:final playerId, :final victimIds) => [
      victimIds.isEmpty
          ? l.logChoiceNone(name(playerId))
          : l.logChoice(name(playerId), l.names(victimIds.map(name))),
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
    FoulInput(:final playerId) => [l.logFoul(name(playerId))],
    _ => const <String>[],
  };

  /// Every line the game log shows for [entry].
  List<String> logLines(LogEntry entry) => [for (final i in logItems(entry)) i.text];
}
