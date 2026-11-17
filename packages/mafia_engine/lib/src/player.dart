import 'roles.dart';
import 'value_equality.dart';

/// A seat at the table.
final class Player extends ValueEquality {
  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.chameleonRole,
    this.isAlive = true,
  });

  final String id;
  final String name;

  /// The physical card the player holds.
  final Role role;

  /// The role a Chameleon picked at game start. Null for everyone else.
  final Role? chameleonRole;

  final bool isAlive;

  /// The role whose ability this player uses: a Chameleon plays its picked
  /// role all game.
  Role get effectiveRole => role == Role.chameleon ? (chameleonRole ?? Role.chameleon) : role;

  /// A Chameleon belongs to the team of the role it plays.
  Team get team => effectiveRole.team;

  Player copyWith({bool? isAlive}) => Player(
        id: id,
        name: name,
        role: role,
        chameleonRole: chameleonRole,
        isAlive: isAlive ?? this.isAlive,
      );

  @override
  List<Object?> get props => [id, name, role, chameleonRole, isAlive];
}
