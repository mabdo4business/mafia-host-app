/// The two sides of the game.
enum Team { civilians, mafia }

/// Every role card in the game (docs/GAME_RULES.md §1), with its team.
enum Role {
  // Mafia Team.
  godfather(Team.mafia),
  mafia(Team.mafia),
  putana(Team.mafia),
  lawyer(Team.mafia),
  witch(Team.mafia),

  // Civilians Team.
  detective(Team.civilians),
  doctor(Team.civilians),
  joker(Team.civilians),
  switchman(Team.civilians),
  silencer(Team.civilians),
  bomb(Team.civilians),
  shapeshifter(Team.civilians),
  chameleon(Team.civilians),
  tnt(Team.civilians),
  civilian(Team.civilians);

  const Role(this.team);

  final Team team;
}

/// The roles the host offers the Chameleon on night 3, in this order.
const chameleonChoices = [Role.mafia, Role.detective, Role.doctor, Role.joker, Role.switchman];

/// The ability the Shapeshifter plays on night [night]: Detective, Doctor,
/// Joker, then repeats.
Role shapeshifterRoleFor(int night) =>
    const [Role.detective, Role.doctor, Role.joker][(night - 1) % 3];
