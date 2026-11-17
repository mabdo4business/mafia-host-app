import 'dart:math';

import 'package:mafia_engine/mafia_engine.dart';

const minPlayers = 4;

/// Roles the host picks counts for. Civilians fill the remaining seats.
const configurableRoles = [
  Role.godfather,
  Role.mafia,
  Role.potana,
  Role.lawyer,
  Role.doctor,
  Role.detective,
  Role.bomb,
  Role.joker,
  Role.chameleon,
];

/// A starting point for the role mix. The spec leaves the recommended mix as
/// an open question, so this is only a suggestion the host can change:
/// about one Mafia-team role per four players, then the key civilian roles.
Map<Role, int> suggestedRoleMix(int playerCount) {
  final mix = {for (final r in configurableRoles) r: 0};
  if (playerCount < minPlayers) return mix;
  final mafiaTeam = max(1, playerCount ~/ 4);
  const mafiaOrder = [Role.godfather, Role.potana, Role.lawyer];
  for (var i = 0; i < mafiaTeam; i++) {
    final role = i < mafiaOrder.length ? mafiaOrder[i] : Role.mafia;
    mix[role] = mix[role]! + 1;
  }
  mix[Role.doctor] = 1;
  if (playerCount >= 5) mix[Role.detective] = 1;
  if (playerCount >= 8) mix[Role.bomb] = 1;
  if (playerCount >= 10) mix[Role.joker] = 1;
  return mix;
}

enum SetupProblem { tooFewPlayers, duplicateName, tooManyRoles, noMafia, mafiaTooStrong }

/// The first problem that stops the game from starting, or null.
SetupProblem? validateSetup(List<String> names, Map<Role, int> mix) {
  if (names.length < minPlayers) return SetupProblem.tooFewPlayers;
  final normalized = names.map((n) => n.trim().toLowerCase()).toSet();
  if (normalized.length != names.length) return SetupProblem.duplicateName;
  final special = mix.values.fold(0, (a, b) => a + b);
  if (special > names.length) return SetupProblem.tooManyRoles;
  // A Chameleon may later pick a Mafia role (if allowed), but counts as
  // civilian for this up-front check.
  final mafia = mix.entries.where((e) => e.key.team == Team.mafia).fold(0, (a, e) => a + e.value);
  if (mafia == 0) return SetupProblem.noMafia;
  if (mafia >= names.length - mafia) return SetupProblem.mafiaTooStrong;
  return null;
}

/// Shuffles the deck (chosen roles + Civilians) and deals one card per seat.
/// Player ids are stable per seat: `p0`, `p1`, …
List<Player> dealRoles(List<String> names, Map<Role, int> mix, Random random) {
  final deck = [
    for (final MapEntry(key: role, value: count) in mix.entries)
      for (var i = 0; i < count; i++) role,
  ];
  while (deck.length < names.length) {
    deck.add(Role.civilian);
  }
  deck.shuffle(random);
  return [
    for (var i = 0; i < names.length; i++) Player(id: 'p$i', name: names[i].trim(), role: deck[i]),
  ];
}

/// Roles a Chameleon may pick under [settings].
List<Role> chameleonChoices(GameSettings settings) => [
  for (final r in Role.values)
    if (r != Role.chameleon && (r.team == Team.civilians || settings.chameleonCanPickMafiaRoles)) r,
];
