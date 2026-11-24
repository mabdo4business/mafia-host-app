import 'bullets.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_settings.dart';
import 'night_action.dart';
import 'player.dart';
import 'roles.dart';
import 'value_equality.dart';

enum GamePhase { night, day, gameOver }

/// A death the host settles before play goes on.
enum ChoiceKind {
  /// The voted-out Godfather takes one player with him, or no one.
  godfatherTakesOne,

  /// A Bomb voted out on day 1 (before planting) takes both neighbors, or
  /// no one.
  bombTakesNeighbors,
}

final class PendingChoice extends ValueEquality {
  const PendingChoice(this.playerId, this.kind, {this.options = const [], this.atNight = false});

  /// The player who died and now chooses.
  final String playerId;
  final ChoiceKind kind;

  /// For [ChoiceKind.bombTakesNeighbors]: the neighbors at the time of death.
  final List<String> options;

  /// The death happened at night, so the victims die at night (Witch link).
  final bool atNight;

  @override
  List<Object?> get props => [playerId, kind, options, atNight];
}

/// A Detective's investigations so far (for the chain rule).
final class DetectiveRecord extends ValueEquality {
  const DetectiveRecord({this.checks = 0, this.mafiaFound = const []});

  final int checks;

  /// Mafia Team players the Detective was shown as Mafia, in order.
  final List<String> mafiaFound;

  /// Three investigations with two Mafia identified.
  bool get armed => checks >= 3 && mafiaFound.length >= 2;

  /// The two who die with the Detective once [armed].
  List<String> get chainVictims => armed ? mafiaFound.take(2).toList() : const [];

  @override
  List<Object?> get props => [checks, mafiaFound];
}

/// The player a Doctor saved on consecutive nights, and for how many.
typedef DoctorStreak = ({String targetId, int nights});

/// Immutable snapshot of a game. Every resolver returns a new instance.
final class GameState {
  GameState._({
    required List<Player> players,
    required this.settings,
    required this.phase,
    required this.nightNumber,
    required Map<String, DoctorStreak> doctorStreaks,
    required Map<String, DetectiveRecord> detectiveRecords,
    required this.witchLink,
    required Map<String, List<String>> bombPlants,
    required Map<String, int> silencedThrough,
    required Set<String> promotedPutanas,
    required Map<String, int> fouls,
    required List<PendingChoice> pendingChoices,
    required List<String>? revoteCandidates,
    required this.winner,
  })  : players = List.unmodifiable(players),
        doctorStreaks = Map.unmodifiable(doctorStreaks),
        detectiveRecords = Map.unmodifiable(detectiveRecords),
        bombPlants = Map.unmodifiable(bombPlants),
        silencedThrough = Map.unmodifiable(silencedThrough),
        promotedPutanas = Set.unmodifiable(promotedPutanas),
        fouls = Map.unmodifiable(fouls),
        pendingChoices = List.unmodifiable(pendingChoices),
        revoteCandidates = revoteCandidates == null ? null : List.unmodifiable(revoteCandidates);

  /// Validates the table and starts the game at night 1. [players] are in
  /// seat order around a circular table.
  factory GameState.initial({
    required List<Player> players,
    GameSettings settings = const GameSettings(),
  }) {
    final ids = <String>{};
    for (final p in players) {
      if (!ids.add(p.id)) {
        throw InvalidSetupException(InvalidSetupReason.duplicatePlayerId, playerId: p.id);
      }
      if (p.chameleonRole != null) {
        throw InvalidSetupException(InvalidSetupReason.chameleonRolePreset, playerId: p.id);
      }
    }
    return GameState._(
      players: players,
      settings: settings,
      phase: GamePhase.night,
      nightNumber: 1,
      doctorStreaks: const {},
      detectiveRecords: const {},
      witchLink: null,
      bombPlants: const {},
      silencedThrough: const {},
      promotedPutanas: const {},
      fouls: const {},
      pendingChoices: const [],
      revoteCandidates: null,
      winner: null,
    );
  }

  /// Players in seat order.
  final List<Player> players;
  final GameSettings settings;
  final GamePhase phase;

  /// The current night, or the day that follows it.
  final int nightNumber;

  /// Doctor (or any saver) id → who they saved on the nights just before.
  final Map<String, DoctorStreak> doctorStreaks;

  /// Detective id → their investigations.
  final Map<String, DetectiveRecord> detectiveRecords;

  /// The two souls the Witch linked. Stays active after the Witch dies.
  final (String, String)? witchLink;

  /// Bomb id → the two players carrying its charges.
  final Map<String, List<String>> bombPlants;

  /// Player id → the last day they are silenced on.
  final Map<String, int> silencedThrough;

  /// Putanas who became the last Mafia Team player and now kill.
  final Set<String> promotedPutanas;

  /// Player id → Fouls taken this game.
  final Map<String, int> fouls;

  /// Deaths waiting for the host's choice, in trigger order.
  final List<PendingChoice> pendingChoices;

  /// During a re-vote: the tied players, the only ones who may be voted.
  final List<String>? revoteCandidates;

  final Team? winner;

  List<Player> get alivePlayers => [
        for (final p in players)
          if (p.isAlive) p
      ];

  Player player(String id) {
    for (final p in players) {
      if (p.id == id) return p;
    }
    throw InvalidActionException(InvalidActionReason.unknownPlayer, playerId: id);
  }

  int seatOf(String id) {
    final i = players.indexWhere((p) => p.id == id);
    if (i < 0) throw InvalidActionException(InvalidActionReason.unknownPlayer, playerId: id);
    return i;
  }

  /// The nearest players to the left (previous seat) and right (next seat)
  /// of [id] around the table, among [seated] (default: the living). Empty
  /// seats are skipped; with one other player, they are both neighbors.
  List<String> neighborsOf(String id, {Set<String>? seated}) {
    final present = seated ?? {for (final p in alivePlayers) p.id};
    final n = players.length;
    final seat = seatOf(id);
    String? walk(int step) {
      for (var i = 1; i < n; i++) {
        final candidate = players[(seat + step * i) % n].id;
        if (present.contains(candidate) && candidate != id) return candidate;
      }
      return null;
    }

    return {?walk(-1), ?walk(1)}.toList();
  }

  /// The ability [id] has tonight: a Chameleon's chosen role, the
  /// Shapeshifter's role for this night, Mafia for a promoted Putana.
  Role abilityOf(String id) {
    if (promotedPutanas.contains(id)) return Role.mafia;
    final role = player(id).effectiveRole;
    return role == Role.shapeshifter ? shapeshifterRoleFor(nightNumber) : role;
  }

  /// Wakes for the Mafia kill: the Mafia Team except an unpromoted Putana,
  /// plus a Chameleon who chose Mafia without joining the team.
  bool joinsMafiaKill(String id) {
    final ability = abilityOf(id);
    if (ability == Role.putana) return false;
    return player(id).team == Team.mafia || ability == Role.mafia;
  }

  /// Living players who wake for the Mafia kill, in seat order.
  List<Player> get mafiaKillers => [
        for (final p in alivePlayers)
          if (joinsMafiaKill(p.id)) p
      ];

  /// Silenced today: no Free Chat, no Speech, no Foul, no vote.
  bool isSilenced(String id) =>
      phase == GamePhase.day && (silencedThrough[id] ?? 0) >= nightNumber;

  /// Living players who may vote today.
  int get voterCount => alivePlayers.where((p) => !isSilenced(p.id)).length;

  int foulsOf(String id) => fouls[id] ?? 0;

  /// The bullets [actions] fire at [id] tonight, before any Switchman
  /// redirect or Doctor save, in resolution order: the Mafia's, then each
  /// Joker kill by seat. A Switchman's redirects are matched to these.
  List<DeathCause> bulletsAt(String id, List<NightAction> actions) {
    final blocked = {for (final a in actions.whereType<PutanaBlock>()) a.targetId};
    final active = [
      for (final a in actions)
        if (!blocked.contains(a.actorId)) a
    ];
    return [
      for (final b in firedBullets(this, active).bullets)
        if (b.targetId == id) b.cause
    ];
  }

  static const Object _unset = Object();

  /// [witchLink], [revoteCandidates] and [winner] accept an explicit `null`.
  GameState copyWith({
    List<Player>? players,
    GamePhase? phase,
    int? nightNumber,
    Map<String, DoctorStreak>? doctorStreaks,
    Map<String, DetectiveRecord>? detectiveRecords,
    Object? witchLink = _unset,
    Map<String, List<String>>? bombPlants,
    Map<String, int>? silencedThrough,
    Set<String>? promotedPutanas,
    Map<String, int>? fouls,
    List<PendingChoice>? pendingChoices,
    Object? revoteCandidates = _unset,
    Object? winner = _unset,
  }) =>
      GameState._(
        players: players ?? this.players,
        settings: settings,
        phase: phase ?? this.phase,
        nightNumber: nightNumber ?? this.nightNumber,
        doctorStreaks: doctorStreaks ?? this.doctorStreaks,
        detectiveRecords: detectiveRecords ?? this.detectiveRecords,
        witchLink: identical(witchLink, _unset) ? this.witchLink : witchLink as (String, String)?,
        bombPlants: bombPlants ?? this.bombPlants,
        silencedThrough: silencedThrough ?? this.silencedThrough,
        promotedPutanas: promotedPutanas ?? this.promotedPutanas,
        fouls: fouls ?? this.fouls,
        pendingChoices: pendingChoices ?? this.pendingChoices,
        revoteCandidates: identical(revoteCandidates, _unset)
            ? this.revoteCandidates
            : revoteCandidates as List<String>?,
        winner: identical(winner, _unset) ? this.winner : winner as Team?,
      );
}
