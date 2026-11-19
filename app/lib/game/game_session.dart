import 'package:mafia_engine/mafia_engine.dart';

import 'game_input.dart';

/// Where the host is in the game's flow. Finer-grained than [GamePhase]:
/// the morning announcement and the vote result are their own screens.
enum GameStage { night, morning, day, dayResult, gameOver }

/// Everything fixed at setup.
final class GameSetup {
  const GameSetup({required this.players, required this.settings, this.discussionSeconds = 0});

  final List<Player> players;
  final GameSettings settings;

  /// Day discussion timer; 0 = no timer.
  final int discussionSeconds;
}

/// One host input and what the engine made of it.
final class LogEntry {
  const LogEntry({
    required this.round,
    required this.stage,
    required this.input,
    required this.events,
  });

  /// Night/day number the input belongs to.
  final int round;

  /// The stage the game was in when the input was made.
  final GameStage stage;
  final GameInput input;
  final List<GameEvent> events;
}

/// A running game: its setup, current engine state, flow stage and full log.
/// Immutable; [apply] and [undo] return new sessions.
final class GameSession {
  GameSession._(this.gameId, this.setup, this.state, this.stage, List<LogEntry> log)
    : log = List.unmodifiable(log);

  factory GameSession.start(int gameId, GameSetup setup) => GameSession._(
    gameId,
    setup,
    GameState.initial(players: setup.players, settings: setup.settings),
    GameStage.night,
    const [],
  );

  factory GameSession.replay(int gameId, GameSetup setup, List<GameInput> inputs) =>
      inputs.fold(GameSession.start(gameId, setup), (s, input) => s.apply(input));

  final int gameId;
  final GameSetup setup;
  final GameState state;
  final GameStage stage;
  final List<LogEntry> log;

  List<GameInput> get inputs => [for (final e in log) e.input];

  /// The night/day number shown to the host. A resolved vote has already
  /// moved the engine to the next night, so the result screen looks back one.
  int get round => stage == GameStage.dayResult ? state.nightNumber - 1 : state.nightNumber;

  String nameOf(String playerId) => state.player(playerId).name;

  /// Applies one input. Engine validation errors propagate as
  /// [InvalidActionException]; inputs that don't fit the stage are
  /// programming errors ([StateError]).
  GameSession apply(GameInput input) {
    final Resolution r;
    GameStage next;
    switch (input) {
      case NightInput(:final actions):
        _expectStage({GameStage.night}, input);
        r = resolveNight(state, actions);
        next = GameStage.morning;
      case BombInput(:final bombId, :final victimIds):
        _expectStage({GameStage.morning, GameStage.dayResult}, input);
        r = detonateBomb(state, bombId, victimIds);
        next = stage;
      case DayVoteInput(:final tieBreakerId):
        _expectStage({GameStage.day}, input);
        r = switch (input) {
          VoteInput(:final votes) => resolveDayVote(state, votes, tieBreakerId: tieBreakerId),
          TallyVoteInput(:final tally) => resolveDayVoteTally(
            state,
            tally,
            tieBreakerId: tieBreakerId,
          ),
        };
        final undecided = r.events.any((e) => e is RevoteRequired || e is HostDecisionRequired);
        next = undecided ? GameStage.day : GameStage.dayResult;
      case AdvanceInput():
        _expectStage({GameStage.morning, GameStage.dayResult}, input);
        if (state.pendingBombs.isNotEmpty) {
          throw StateError('Cannot advance while a Bomb is pending');
        }
        r = Resolution(state, const []);
        next = stage == GameStage.morning ? GameStage.day : GameStage.night;
    }
    if (r.state.phase == GamePhase.gameOver) next = GameStage.gameOver;
    return GameSession._(gameId, setup, r.state, next, [
      ...log,
      LogEntry(round: round, stage: stage, input: input, events: r.events),
    ]);
  }

  bool get canUndo => log.isNotEmpty;

  GameSession undo() {
    if (!canUndo) throw StateError('Nothing to undo');
    return GameSession.replay(gameId, setup, inputs..removeLast());
  }

  /// The entries the current announcement is built from: the last night (or
  /// the last decided vote) plus any Bomb detonations after it.
  List<LogEntry> get latestRound {
    for (var i = log.length - 1; i >= 0; i--) {
      final input = log[i].input;
      final decidedVote =
          input is DayVoteInput &&
          !log[i].events.any((e) => e is RevoteRequired || e is HostDecisionRequired);
      if (input is NightInput || decidedVote) {
        return [
          for (final e in log.skip(i))
            if (e.input is! AdvanceInput) e,
        ];
      }
    }
    return const [];
  }

  /// The last vote input, if the day is waiting on a tie decision or revote.
  LogEntry? get pendingTie {
    if (stage != GameStage.day || log.isEmpty) return null;
    final last = log.last;
    return last.input is DayVoteInput ? last : null;
  }

  void _expectStage(Set<GameStage> allowed, GameInput input) {
    if (!allowed.contains(stage)) {
      throw StateError('${input.runtimeType} not allowed during $stage');
    }
  }
}
