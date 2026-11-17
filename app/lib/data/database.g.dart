// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta('settingsJson');
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GameStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<GameStatus>($GamesTable.$converterstatus);
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
    'winner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, settingsJson, status, winner];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(Insertable<Game> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(data['settings_json']!, _settingsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    if (data.containsKey('winner')) {
      context.handle(_winnerMeta, winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      status: $GamesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      winner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GameStatus, String, String> $converterstatus =
      const EnumNameConverter<GameStatus>(GameStatus.values);
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final DateTime createdAt;
  final String settingsJson;
  final GameStatus status;
  final String? winner;
  const Game({
    required this.id,
    required this.createdAt,
    required this.settingsJson,
    required this.status,
    this.winner,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['settings_json'] = Variable<String>(settingsJson);
    {
      map['status'] = Variable<String>($GamesTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || winner != null) {
      map['winner'] = Variable<String>(winner);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      settingsJson: Value(settingsJson),
      status: Value(status),
      winner: winner == null && nullToAbsent ? const Value.absent() : Value(winner),
    );
  }

  factory Game.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      status: $GamesTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      winner: serializer.fromJson<String?>(json['winner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'status': serializer.toJson<String>($GamesTable.$converterstatus.toJson(status)),
      'winner': serializer.toJson<String?>(winner),
    };
  }

  Game copyWith({
    int? id,
    DateTime? createdAt,
    String? settingsJson,
    GameStatus? status,
    Value<String?> winner = const Value.absent(),
  }) => Game(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    settingsJson: settingsJson ?? this.settingsJson,
    status: status ?? this.status,
    winner: winner.present ? winner.value : this.winner,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      settingsJson: data.settingsJson.present ? data.settingsJson.value : this.settingsJson,
      status: data.status.present ? data.status.value : this.status,
      winner: data.winner.present ? data.winner.value : this.winner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('status: $status, ')
          ..write('winner: $winner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, settingsJson, status, winner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.settingsJson == this.settingsJson &&
          other.status == this.status &&
          other.winner == this.winner);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> settingsJson;
  final Value<GameStatus> status;
  final Value<String?> winner;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.winner = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required String settingsJson,
    required GameStatus status,
    this.winner = const Value.absent(),
  }) : createdAt = Value(createdAt),
       settingsJson = Value(settingsJson),
       status = Value(status);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? settingsJson,
    Expression<String>? status,
    Expression<String>? winner,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (status != null) 'status': status,
      if (winner != null) 'winner': winner,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? settingsJson,
    Value<GameStatus>? status,
    Value<String?>? winner,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      settingsJson: settingsJson ?? this.settingsJson,
      status: status ?? this.status,
      winner: winner ?? this.winner,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($GamesTable.$converterstatus.toSql(status.value));
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('status: $status, ')
          ..write('winner: $winner')
          ..write(')'))
        .toString();
  }
}

class $GamePlayersTable extends GamePlayers with TableInfo<$GamePlayersTable, GamePlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamePlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<int> seat = GeneratedColumn<int>(
    'seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chameleonRoleMeta = const VerificationMeta('chameleonRole');
  @override
  late final GeneratedColumn<String> chameleonRole = GeneratedColumn<String>(
    'chameleon_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, seat, playerId, name, role, chameleonRole];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<GamePlayer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta, gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('seat')) {
      context.handle(_seatMeta, seat.isAcceptableOrUnknown(data['seat']!, _seatMeta));
    } else if (isInserting) {
      context.missing(_seatMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('chameleon_role')) {
      context.handle(
        _chameleonRoleMeta,
        chameleonRole.isAcceptableOrUnknown(data['chameleon_role']!, _chameleonRoleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, seat};
  @override
  GamePlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GamePlayer(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      seat: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seat'])!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      chameleonRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chameleon_role'],
      ),
    );
  }

  @override
  $GamePlayersTable createAlias(String alias) {
    return $GamePlayersTable(attachedDatabase, alias);
  }
}

class GamePlayer extends DataClass implements Insertable<GamePlayer> {
  final int gameId;
  final int seat;
  final String playerId;
  final String name;
  final String role;
  final String? chameleonRole;
  const GamePlayer({
    required this.gameId,
    required this.seat,
    required this.playerId,
    required this.name,
    required this.role,
    this.chameleonRole,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['seat'] = Variable<int>(seat);
    map['player_id'] = Variable<String>(playerId);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || chameleonRole != null) {
      map['chameleon_role'] = Variable<String>(chameleonRole);
    }
    return map;
  }

  GamePlayersCompanion toCompanion(bool nullToAbsent) {
    return GamePlayersCompanion(
      gameId: Value(gameId),
      seat: Value(seat),
      playerId: Value(playerId),
      name: Value(name),
      role: Value(role),
      chameleonRole: chameleonRole == null && nullToAbsent
          ? const Value.absent()
          : Value(chameleonRole),
    );
  }

  factory GamePlayer.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GamePlayer(
      gameId: serializer.fromJson<int>(json['gameId']),
      seat: serializer.fromJson<int>(json['seat']),
      playerId: serializer.fromJson<String>(json['playerId']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      chameleonRole: serializer.fromJson<String?>(json['chameleonRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'seat': serializer.toJson<int>(seat),
      'playerId': serializer.toJson<String>(playerId),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'chameleonRole': serializer.toJson<String?>(chameleonRole),
    };
  }

  GamePlayer copyWith({
    int? gameId,
    int? seat,
    String? playerId,
    String? name,
    String? role,
    Value<String?> chameleonRole = const Value.absent(),
  }) => GamePlayer(
    gameId: gameId ?? this.gameId,
    seat: seat ?? this.seat,
    playerId: playerId ?? this.playerId,
    name: name ?? this.name,
    role: role ?? this.role,
    chameleonRole: chameleonRole.present ? chameleonRole.value : this.chameleonRole,
  );
  GamePlayer copyWithCompanion(GamePlayersCompanion data) {
    return GamePlayer(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      seat: data.seat.present ? data.seat.value : this.seat,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      chameleonRole: data.chameleonRole.present ? data.chameleonRole.value : this.chameleonRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GamePlayer(')
          ..write('gameId: $gameId, ')
          ..write('seat: $seat, ')
          ..write('playerId: $playerId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('chameleonRole: $chameleonRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, seat, playerId, name, role, chameleonRole);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GamePlayer &&
          other.gameId == this.gameId &&
          other.seat == this.seat &&
          other.playerId == this.playerId &&
          other.name == this.name &&
          other.role == this.role &&
          other.chameleonRole == this.chameleonRole);
}

class GamePlayersCompanion extends UpdateCompanion<GamePlayer> {
  final Value<int> gameId;
  final Value<int> seat;
  final Value<String> playerId;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> chameleonRole;
  final Value<int> rowid;
  const GamePlayersCompanion({
    this.gameId = const Value.absent(),
    this.seat = const Value.absent(),
    this.playerId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.chameleonRole = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamePlayersCompanion.insert({
    required int gameId,
    required int seat,
    required String playerId,
    required String name,
    required String role,
    this.chameleonRole = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       seat = Value(seat),
       playerId = Value(playerId),
       name = Value(name),
       role = Value(role);
  static Insertable<GamePlayer> custom({
    Expression<int>? gameId,
    Expression<int>? seat,
    Expression<String>? playerId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? chameleonRole,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (seat != null) 'seat': seat,
      if (playerId != null) 'player_id': playerId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (chameleonRole != null) 'chameleon_role': chameleonRole,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamePlayersCompanion copyWith({
    Value<int>? gameId,
    Value<int>? seat,
    Value<String>? playerId,
    Value<String>? name,
    Value<String>? role,
    Value<String?>? chameleonRole,
    Value<int>? rowid,
  }) {
    return GamePlayersCompanion(
      gameId: gameId ?? this.gameId,
      seat: seat ?? this.seat,
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      role: role ?? this.role,
      chameleonRole: chameleonRole ?? this.chameleonRole,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (seat.present) {
      map['seat'] = Variable<int>(seat.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (chameleonRole.present) {
      map['chameleon_role'] = Variable<String>(chameleonRole.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamePlayersCompanion(')
          ..write('gameId: $gameId, ')
          ..write('seat: $seat, ')
          ..write('playerId: $playerId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('chameleonRole: $chameleonRole, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameInputsTable extends GameInputs with TableInfo<$GameInputsTable, GameInputRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameInputsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, seq, payloadJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_inputs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameInputRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta, gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(data['payload_json']!, _payloadJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, seq};
  @override
  GameInputRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameInputRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $GameInputsTable createAlias(String alias) {
    return $GameInputsTable(attachedDatabase, alias);
  }
}

class GameInputRow extends DataClass implements Insertable<GameInputRow> {
  final int gameId;
  final int seq;
  final String payloadJson;
  const GameInputRow({required this.gameId, required this.seq, required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['seq'] = Variable<int>(seq);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  GameInputsCompanion toCompanion(bool nullToAbsent) {
    return GameInputsCompanion(
      gameId: Value(gameId),
      seq: Value(seq),
      payloadJson: Value(payloadJson),
    );
  }

  factory GameInputRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameInputRow(
      gameId: serializer.fromJson<int>(json['gameId']),
      seq: serializer.fromJson<int>(json['seq']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'seq': serializer.toJson<int>(seq),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  GameInputRow copyWith({int? gameId, int? seq, String? payloadJson}) => GameInputRow(
    gameId: gameId ?? this.gameId,
    seq: seq ?? this.seq,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  GameInputRow copyWithCompanion(GameInputsCompanion data) {
    return GameInputRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      seq: data.seq.present ? data.seq.value : this.seq,
      payloadJson: data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameInputRow(')
          ..write('gameId: $gameId, ')
          ..write('seq: $seq, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, seq, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameInputRow &&
          other.gameId == this.gameId &&
          other.seq == this.seq &&
          other.payloadJson == this.payloadJson);
}

class GameInputsCompanion extends UpdateCompanion<GameInputRow> {
  final Value<int> gameId;
  final Value<int> seq;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const GameInputsCompanion({
    this.gameId = const Value.absent(),
    this.seq = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameInputsCompanion.insert({
    required int gameId,
    required int seq,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       seq = Value(seq),
       payloadJson = Value(payloadJson);
  static Insertable<GameInputRow> custom({
    Expression<int>? gameId,
    Expression<int>? seq,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (seq != null) 'seq': seq,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameInputsCompanion copyWith({
    Value<int>? gameId,
    Value<int>? seq,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return GameInputsCompanion(
      gameId: gameId ?? this.gameId,
      seq: seq ?? this.seq,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameInputsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('seq: $seq, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String key;
  final String value;
  const Preference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory Preference.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Preference copyWith({String? key, String? value}) =>
      Preference(key: key ?? this.key, value: value ?? this.value);
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference && other.key == this.key && other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Preference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $GamePlayersTable gamePlayers = $GamePlayersTable(this);
  late final $GameInputsTable gameInputs = $GameInputsTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [games, gamePlayers, gameInputs, preferences];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('games', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('game_players', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('games', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('game_inputs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required String settingsJson,
      required GameStatus status,
      Value<String?> winner,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> settingsJson,
      Value<GameStatus> status,
      Value<String?> winner,
    });

final class $$GamesTableReferences extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GamePlayersTable, List<GamePlayer>> _gamePlayersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.gamePlayers, aliasName: 'games__id__game_players__game_id');

  $$GamePlayersTableProcessedTableManager get gamePlayersRefs {
    final manager = $$GamePlayersTableTableManager(
      $_db,
      $_db.gamePlayers,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlayersRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GameInputsTable, List<GameInputRow>> _gameInputsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.gameInputs, aliasName: 'games__id__game_inputs__game_id');

  $$GameInputsTableProcessedTableManager get gameInputsRefs {
    final manager = $$GameInputsTableTableManager(
      $_db,
      $_db.gameInputs,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameInputsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingsJson =>
      $composableBuilder(column: $table.settingsJson, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<GameStatus, GameStatus, String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => ColumnFilters(column));

  Expression<bool> gamePlayersRefs(
    Expression<bool> Function($$GamePlayersTableFilterComposer f) f,
  ) {
    final $$GamePlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.gameId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamePlayersTableFilterComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameInputsRefs(Expression<bool> Function($$GameInputsTableFilterComposer f) f) {
    final $$GameInputsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameInputs,
      getReferencedColumn: (t) => t.gameId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GameInputsTableFilterComposer(
            $db: $db,
            $table: $db.gameInputs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingsJson =>
      $composableBuilder(column: $table.settingsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => ColumnOrderings(column));
}

class $$GamesTableAnnotationComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get settingsJson =>
      $composableBuilder(column: $table.settingsJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GameStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  Expression<T> gamePlayersRefs<T extends Object>(
    Expression<T> Function($$GamePlayersTableAnnotationComposer a) f,
  ) {
    final $$GamePlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.gameId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamePlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameInputsRefs<T extends Object>(
    Expression<T> Function($$GameInputsTableAnnotationComposer a) f,
  ) {
    final $$GameInputsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameInputs,
      getReferencedColumn: (t) => t.gameId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GameInputsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameInputs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool gamePlayersRefs, bool gameInputsRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<GameStatus> status = const Value.absent(),
                Value<String?> winner = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                createdAt: createdAt,
                settingsJson: settingsJson,
                status: status,
                winner: winner,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required String settingsJson,
                required GameStatus status,
                Value<String?> winner = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                createdAt: createdAt,
                settingsJson: settingsJson,
                status: status,
                winner: winner,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable<$GamesTable, Game>(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({gamePlayersRefs = false, gameInputsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gamePlayersRefs) db.gamePlayers,
                if (gameInputsRefs) db.gameInputs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gamePlayersRefs)
                    await $_getPrefetchedDataByColumns<
                      Game,
                      $GamesTable,
                      GamePlayer,
                      $GamePlayersTable
                    >(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences._gamePlayersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GamesTableReferences(db, table, p0).gamePlayersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'game_id',
                      typedResults: items,
                    ),
                  if (gameInputsRefs)
                    await $_getPrefetchedDataByColumns<
                      Game,
                      $GamesTable,
                      GameInputRow,
                      $GameInputsTable
                    >(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences._gameInputsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GamesTableReferences(db, table, p0).gameInputsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'game_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool gamePlayersRefs, bool gameInputsRefs})
    >;
typedef $$GamePlayersTableCreateCompanionBuilder =
    GamePlayersCompanion Function({
      required int gameId,
      required int seat,
      required String playerId,
      required String name,
      required String role,
      Value<String?> chameleonRole,
      Value<int> rowid,
    });
typedef $$GamePlayersTableUpdateCompanionBuilder =
    GamePlayersCompanion Function({
      Value<int> gameId,
      Value<int> seat,
      Value<String> playerId,
      Value<String> name,
      Value<String> role,
      Value<String?> chameleonRole,
      Value<int> rowid,
    });

final class $$GamePlayersTableReferences
    extends BaseReferences<_$AppDatabase, $GamePlayersTable, GamePlayer> {
  $$GamePlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_players__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GamePlayersTableFilterComposer extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chameleonRole =>
      $composableBuilder(column: $table.chameleonRole, builder: (column) => ColumnFilters(column));

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamePlayersTableOrderingComposer extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chameleonRole => $composableBuilder(
    column: $table.chameleonRole,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamePlayersTableAnnotationComposer extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get chameleonRole =>
      $composableBuilder(column: $table.chameleonRole, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamePlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamePlayersTable,
          GamePlayer,
          $$GamePlayersTableFilterComposer,
          $$GamePlayersTableOrderingComposer,
          $$GamePlayersTableAnnotationComposer,
          $$GamePlayersTableCreateCompanionBuilder,
          $$GamePlayersTableUpdateCompanionBuilder,
          (GamePlayer, $$GamePlayersTableReferences),
          GamePlayer,
          PrefetchHooks Function({bool gameId})
        > {
  $$GamePlayersTableTableManager(_$AppDatabase db, $GamePlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GamePlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GamePlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamePlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<int> seat = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> chameleonRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamePlayersCompanion(
                gameId: gameId,
                seat: seat,
                playerId: playerId,
                name: name,
                role: role,
                chameleonRole: chameleonRole,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int gameId,
                required int seat,
                required String playerId,
                required String name,
                required String role,
                Value<String?> chameleonRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamePlayersCompanion.insert(
                gameId: gameId,
                seat: seat,
                playerId: playerId,
                name: name,
                role: role,
                chameleonRole: chameleonRole,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GamePlayersTable, GamePlayer>(table),
                  $$GamePlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$GamePlayersTableReferences._gameIdTable(db),
                                referencedColumn: $$GamePlayersTableReferences._gameIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GamePlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamePlayersTable,
      GamePlayer,
      $$GamePlayersTableFilterComposer,
      $$GamePlayersTableOrderingComposer,
      $$GamePlayersTableAnnotationComposer,
      $$GamePlayersTableCreateCompanionBuilder,
      $$GamePlayersTableUpdateCompanionBuilder,
      (GamePlayer, $$GamePlayersTableReferences),
      GamePlayer,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$GameInputsTableCreateCompanionBuilder =
    GameInputsCompanion Function({
      required int gameId,
      required int seq,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$GameInputsTableUpdateCompanionBuilder =
    GameInputsCompanion Function({
      Value<int> gameId,
      Value<int> seq,
      Value<String> payloadJson,
      Value<int> rowid,
    });

final class $$GameInputsTableReferences
    extends BaseReferences<_$AppDatabase, $GameInputsTable, GameInputRow> {
  $$GameInputsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_inputs__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GameInputsTableFilterComposer extends Composer<_$AppDatabase, $GameInputsTable> {
  $$GameInputsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameInputsTableOrderingComposer extends Composer<_$AppDatabase, $GameInputsTable> {
  $$GameInputsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameInputsTableAnnotationComposer extends Composer<_$AppDatabase, $GameInputsTable> {
  $$GameInputsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameInputsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameInputsTable,
          GameInputRow,
          $$GameInputsTableFilterComposer,
          $$GameInputsTableOrderingComposer,
          $$GameInputsTableAnnotationComposer,
          $$GameInputsTableCreateCompanionBuilder,
          $$GameInputsTableUpdateCompanionBuilder,
          (GameInputRow, $$GameInputsTableReferences),
          GameInputRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$GameInputsTableTableManager(_$AppDatabase db, $GameInputsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GameInputsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GameInputsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameInputsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameInputsCompanion(
                gameId: gameId,
                seq: seq,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int gameId,
                required int seq,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => GameInputsCompanion.insert(
                gameId: gameId,
                seq: seq,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameInputsTable, GameInputRow>(table),
                  $$GameInputsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$GameInputsTableReferences._gameIdTable(db),
                                referencedColumn: $$GameInputsTableReferences._gameIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameInputsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameInputsTable,
      GameInputRow,
      $$GameInputsTableFilterComposer,
      $$GameInputsTableOrderingComposer,
      $$GameInputsTableAnnotationComposer,
      $$GameInputsTableCreateCompanionBuilder,
      $$GameInputsTableUpdateCompanionBuilder,
      (GameInputRow, $$GameInputsTableReferences),
      GameInputRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$PreferencesTableFilterComposer extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$PreferencesTableOrderingComposer extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$PreferencesTableAnnotationComposer extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (Preference, BaseReferences<_$AppDatabase, $PreferencesTable, Preference>),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferencesTable, Preference>(table),
                  BaseReferences<_$AppDatabase, $PreferencesTable, Preference>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (Preference, BaseReferences<_$AppDatabase, $PreferencesTable, Preference>),
      Preference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games => $$GamesTableTableManager(_db, _db.games);
  $$GamePlayersTableTableManager get gamePlayers =>
      $$GamePlayersTableTableManager(_db, _db.gamePlayers);
  $$GameInputsTableTableManager get gameInputs =>
      $$GameInputsTableTableManager(_db, _db.gameInputs);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
