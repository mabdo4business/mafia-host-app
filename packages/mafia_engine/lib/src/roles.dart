/// The two sides of the game.
enum Team { civilians, mafia }

/// Every role card in the game, with the team it belongs to.
enum Role {
  civilian(Team.civilians),
  doctor(Team.civilians),
  detective(Team.civilians),
  bomb(Team.civilians),
  joker(Team.civilians),
  chameleon(Team.civilians),
  mafia(Team.mafia),
  godfather(Team.mafia),
  potana(Team.mafia),
  lawyer(Team.mafia);

  const Role(this.team);

  final Team team;
}
