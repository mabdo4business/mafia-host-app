// Internal: the shots fired at night. Not exported.

import 'game_event.dart';
import 'game_state.dart';
import 'night_action.dart';
import 'roles.dart';

/// One shot fired tonight.
final class Bullet {
  const Bullet(this.targetId, this.cause, {this.redirected = false});
  final String targetId;
  final DeathCause cause;

  /// Sent on by a Switchman.
  final bool redirected;
}

/// The bullets [active] (unblocked) actions fire, in resolution order, and
/// whether the Mafia's kill was cancelled by mismatched numbers.
({List<Bullet> bullets, bool mafiaCancelled}) firedBullets(
  GameState state,
  List<NightAction> active,
) {
  final kills = active.whereType<MafiaKill>().toList();
  final byGodfather = [
    for (final k in kills)
      if (state.abilityOf(k.actorId) == Role.godfather) k.targetId
  ];
  final targets = byGodfather.isNotEmpty ? byGodfather.toSet() : {for (final k in kills) k.targetId};
  final jokers = active.whereType<JokerKill>().toList()
    ..sort((a, b) => state.seatOf(a.actorId).compareTo(state.seatOf(b.actorId)));
  return (
    bullets: [
      if (targets.length == 1) Bullet(targets.single, DeathCause.mafia),
      for (final j in jokers) Bullet(j.targetId, DeathCause.joker),
    ],
    mafiaCancelled: targets.length > 1,
  );
}
