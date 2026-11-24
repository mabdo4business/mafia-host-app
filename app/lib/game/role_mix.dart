import 'dart:math';

import 'package:mafia_engine/mafia_engine.dart';

const minPlayers = 4;

/// Roles the host picks counts for, Mafia Team first (GAME_RULES §1).
/// Civilians fill the remaining seats.
const configurableRoles = [
  Role.godfather,
  Role.mafia,
  Role.putana,
  Role.lawyer,
  Role.witch,
  Role.detective,
  Role.doctor,
  Role.joker,
  Role.switchman,
  Role.silencer,
  Role.bomb,
  Role.shapeshifter,
  Role.chameleon,
  Role.tnt,
];

/// Roles that only one player may hold.
const _unique = {Role.godfather};

int maxRoleCount(Role role, int players) => _unique.contains(role) ? 1 : players;

/// A starting point for the role mix; the guide gives none, so this is only
/// a suggestion the host can change: about one Mafia Team role per four
/// players, then the key Civilian roles as the table grows.
Map<Role, int> suggestedRoleMix(int playerCount) {
  final mix = {for (final r in configurableRoles) r: 0};
  if (playerCount < minPlayers) return mix;
  final mafiaTeam = max(1, playerCount ~/ 4);
  const mafiaOrder = [Role.godfather, Role.putana, Role.lawyer, Role.witch];
  for (var i = 0; i < mafiaTeam; i++) {
    final role = i < mafiaOrder.length ? mafiaOrder[i] : Role.mafia;
    mix[role] = mix[role]! + 1;
  }
  mix[Role.doctor] = 1;
  if (playerCount >= 5) mix[Role.detective] = 1;
  if (playerCount >= 8) mix[Role.bomb] = 1;
  if (playerCount >= 9) mix[Role.silencer] = 1;
  if (playerCount >= 10) mix[Role.joker] = 1;
  if (playerCount >= 12) mix[Role.switchman] = 1;
  if (playerCount >= 14) mix[Role.tnt] = 1;
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
  // A Chameleon may later choose Mafia, but counts as Civilian up front.
  final mafia = mix.entries.where((e) => e.key.team == Team.mafia).fold(0, (a, e) => a + e.value);
  if (mafia == 0) return SetupProblem.noMafia;
  if (mafia >= names.length - mafia) return SetupProblem.mafiaTooStrong;
  return null;
}

/// Shuffles the deck (chosen roles + Civilians) and deals one card per
/// seat. Player ids are stable per seat: `p0`, `p1`, … in seat order.
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

/// Cards mode: the order the host wakes each card holder on night 1 to see
/// who has it — the Mafia Team first, then the Civilian roles. Civilians
/// never wake; they are whoever is left.
List<Role> cardWakeOrder(Map<Role, int> mix) => [
  for (final r in configurableRoles)
    if ((mix[r] ?? 0) > 0) r,
];

/// Cards mode: builds the players from the host's record of who holds which
/// card ([cards]: seat index → role). Unrecorded seats hold Civilian cards.
/// Player ids match [dealRoles]: `p0`, `p1`, … in seat order.
List<Player> playersFromCards(List<String> names, Map<int, Role> cards) => [
  for (var i = 0; i < names.length; i++)
    Player(id: 'p$i', name: names[i].trim(), role: cards[i] ?? Role.civilian),
];
