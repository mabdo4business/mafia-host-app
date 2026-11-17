import 'dart:math' as math;

import 'exceptions.dart';
import 'game_settings.dart';
import 'player.dart';
import 'roles.dart';

enum GamePhase { night, day, gameOver }

/// What happened last night that still matters during the following day
/// (Bomb explosions before the vote). Cleared when the day vote resolves.
final class NightRecord {
  NightRecord({
    required Set<String> blockedPlayerIds,
    required Set<String> savedPlayerIds,
  })  : blockedPlayerIds = Set.unmodifiable(blockedPlayerIds),
        savedPlayerIds = Set.unmodifiable(savedPlayerIds);

  /// Players the Potana blocked.
  final Set<String> blockedPlayerIds;

  /// Targets of unblocked Doctor saves.
  final Set<String> savedPlayerIds;
}

/// Immutable snapshot of a game. Every resolver returns a new instance.
final class GameState {
  GameState._({
    required List<Player> players,
    required this.settings,
    required this.phase,
    required this.nightNumber,
    required Map<String, String> doctorLastTargets,
    required List<String> pendingBombs,
    required this.lastNight,
    required this.winner,
  })  : players = List.unmodifiable(players),
        doctorLastTargets = Map.unmodifiable(doctorLastTargets),
        pendingBombs = List.unmodifiable(pendingBombs);

  /// Validates the table and starts the game at night 1.
  factory GameState.initial({
    required List<Player> players,
    GameSettings settings = const GameSettings(),
  }) {
    if (settings.bombVictimCount != 2 && settings.bombVictimCount != 3) {
      throw const InvalidSetupException(InvalidSetupReason.invalidBombVictimCount);
    }
    final ids = <String>{};
    for (final p in players) {
      if (!ids.add(p.id)) {
        throw InvalidSetupException(InvalidSetupReason.duplicatePlayerId, playerId: p.id);
      }
      final picked = p.chameleonRole;
      if (p.role != Role.chameleon) {
        if (picked != null) {
          throw InvalidSetupException(
            InvalidSetupReason.chameleonRoleOnNonChameleon,
            playerId: p.id,
          );
        }
        continue;
      }
      if (picked == null) {
        throw InvalidSetupException(InvalidSetupReason.chameleonRoleMissing, playerId: p.id);
      }
      if (picked == Role.chameleon ||
          (picked.team == Team.mafia && !settings.chameleonCanPickMafiaRoles)) {
        throw InvalidSetupException(InvalidSetupReason.chameleonRoleNotAllowed, playerId: p.id);
      }
    }
    return GameState._(
      players: players,
      settings: settings,
      phase: GamePhase.night,
      nightNumber: 1,
      doctorLastTargets: const {},
      pendingBombs: const [],
      lastNight: null,
      winner: null,
    );
  }

  /// Players in seating order.
  final List<Player> players;
  final GameSettings settings;
  final GamePhase phase;
  final int nightNumber;

  /// Doctor id → the player they picked on the previous night. Used for the
  /// "not the same player two nights in a row" rule.
  final Map<String, String> doctorLastTargets;

  /// Bombs that died and still have to pick victims, in trigger order.
  final List<String> pendingBombs;

  final NightRecord? lastNight;
  final Team? winner;

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();

  /// How many victims the next Bomb detonation must name.
  int get bombVictimsRequired => math.min(settings.bombVictimCount, alivePlayers.length);

  Player player(String id) {
    for (final p in players) {
      if (p.id == id) return p;
    }
    throw InvalidActionException(InvalidActionReason.unknownPlayer, playerId: id);
  }

  static const Object _unset = Object();

  /// [lastNight] and [winner] accept an explicit `null` to clear them.
  GameState copyWith({
    List<Player>? players,
    GamePhase? phase,
    int? nightNumber,
    Map<String, String>? doctorLastTargets,
    List<String>? pendingBombs,
    Object? lastNight = _unset,
    Object? winner = _unset,
  }) =>
      GameState._(
        players: players ?? this.players,
        settings: settings,
        phase: phase ?? this.phase,
        nightNumber: nightNumber ?? this.nightNumber,
        doctorLastTargets: doctorLastTargets ?? this.doctorLastTargets,
        pendingBombs: pendingBombs ?? this.pendingBombs,
        lastNight: identical(lastNight, _unset) ? this.lastNight : lastNight as NightRecord?,
        winner: identical(winner, _unset) ? this.winner : winner as Team?,
      );
}
