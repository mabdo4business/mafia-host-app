import 'roles.dart';
import 'value_equality.dart';

/// A seat at the table. A game's players are listed in seat order.
final class Player extends ValueEquality {
  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.chameleonRole,
    this.joinedMafia = false,
    this.isAlive = true,
  });

  final String id;
  final String name;

  /// The physical card the player holds.
  final Role role;

  /// The role a Chameleon chose on night 3. Null for everyone else, and for
  /// a Chameleon before night 3.
  final Role? chameleonRole;

  /// A Chameleon who chose Mafia and so plays for the Mafia Team
  /// (`chameleonMafiaJoinsMafiaTeam`).
  final bool joinedMafia;

  final bool isAlive;

  /// The role whose ability this player has: a Chameleon plays its chosen
  /// role for the rest of the game.
  Role get effectiveRole => role == Role.chameleon ? (chameleonRole ?? Role.chameleon) : role;

  Team get team => joinedMafia ? Team.mafia : role.team;

  Player copyWith({bool? isAlive, Role? chameleonRole, bool? joinedMafia}) => Player(
        id: id,
        name: name,
        role: role,
        chameleonRole: chameleonRole ?? this.chameleonRole,
        joinedMafia: joinedMafia ?? this.joinedMafia,
        isAlive: isAlive ?? this.isAlive,
      );

  @override
  List<Object?> get props => [id, name, role, chameleonRole, joinedMafia, isAlive];
}
