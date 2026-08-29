// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MuscleGroupsTable extends MuscleGroups
    with TableInfo<$MuscleGroupsTable, MuscleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, origin, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscle_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MuscleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuscleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $MuscleGroupsTable createAlias(String alias) {
    return $MuscleGroupsTable(attachedDatabase, alias);
  }
}

class MuscleGroup extends DataClass implements Insertable<MuscleGroup> {
  final String id;
  final String name;
  final String origin;
  final bool archived;
  const MuscleGroup({
    required this.id,
    required this.name,
    required this.origin,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['origin'] = Variable<String>(origin);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  MuscleGroupsCompanion toCompanion(bool nullToAbsent) {
    return MuscleGroupsCompanion(
      id: Value(id),
      name: Value(name),
      origin: Value(origin),
      archived: Value(archived),
    );
  }

  factory MuscleGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      origin: serializer.fromJson<String>(json['origin']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'origin': serializer.toJson<String>(origin),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  MuscleGroup copyWith({
    String? id,
    String? name,
    String? origin,
    bool? archived,
  }) => MuscleGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    origin: origin ?? this.origin,
    archived: archived ?? this.archived,
  );
  MuscleGroup copyWithCompanion(MuscleGroupsCompanion data) {
    return MuscleGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      origin: data.origin.present ? data.origin.value : this.origin,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, origin, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.origin == this.origin &&
          other.archived == this.archived);
}

class MuscleGroupsCompanion extends UpdateCompanion<MuscleGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> origin;
  final Value<bool> archived;
  final Value<int> rowid;
  const MuscleGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.origin = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MuscleGroupsCompanion.insert({
    required String id,
    required String name,
    required String origin,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       origin = Value(origin);
  static Insertable<MuscleGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? origin,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (origin != null) 'origin': origin,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MuscleGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? origin,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return MuscleGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementPatternsTable extends MovementPatterns
    with TableInfo<$MovementPatternsTable, MovementPattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupIdMeta = const VerificationMeta(
    'muscleGroupId',
  );
  @override
  late final GeneratedColumn<String> muscleGroupId = GeneratedColumn<String>(
    'muscle_group_id',
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
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    muscleGroupId,
    name,
    origin,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementPattern> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('muscle_group_id')) {
      context.handle(
        _muscleGroupIdMeta,
        muscleGroupId.isAcceptableOrUnknown(
          data['muscle_group_id']!,
          _muscleGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementPattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementPattern(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      muscleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $MovementPatternsTable createAlias(String alias) {
    return $MovementPatternsTable(attachedDatabase, alias);
  }
}

class MovementPattern extends DataClass implements Insertable<MovementPattern> {
  final String id;
  final String muscleGroupId;
  final String name;
  final String origin;
  final bool archived;
  const MovementPattern({
    required this.id,
    required this.muscleGroupId,
    required this.name,
    required this.origin,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['muscle_group_id'] = Variable<String>(muscleGroupId);
    map['name'] = Variable<String>(name);
    map['origin'] = Variable<String>(origin);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  MovementPatternsCompanion toCompanion(bool nullToAbsent) {
    return MovementPatternsCompanion(
      id: Value(id),
      muscleGroupId: Value(muscleGroupId),
      name: Value(name),
      origin: Value(origin),
      archived: Value(archived),
    );
  }

  factory MovementPattern.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementPattern(
      id: serializer.fromJson<String>(json['id']),
      muscleGroupId: serializer.fromJson<String>(json['muscleGroupId']),
      name: serializer.fromJson<String>(json['name']),
      origin: serializer.fromJson<String>(json['origin']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'muscleGroupId': serializer.toJson<String>(muscleGroupId),
      'name': serializer.toJson<String>(name),
      'origin': serializer.toJson<String>(origin),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  MovementPattern copyWith({
    String? id,
    String? muscleGroupId,
    String? name,
    String? origin,
    bool? archived,
  }) => MovementPattern(
    id: id ?? this.id,
    muscleGroupId: muscleGroupId ?? this.muscleGroupId,
    name: name ?? this.name,
    origin: origin ?? this.origin,
    archived: archived ?? this.archived,
  );
  MovementPattern copyWithCompanion(MovementPatternsCompanion data) {
    return MovementPattern(
      id: data.id.present ? data.id.value : this.id,
      muscleGroupId: data.muscleGroupId.present
          ? data.muscleGroupId.value
          : this.muscleGroupId,
      name: data.name.present ? data.name.value : this.name,
      origin: data.origin.present ? data.origin.value : this.origin,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementPattern(')
          ..write('id: $id, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, muscleGroupId, name, origin, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementPattern &&
          other.id == this.id &&
          other.muscleGroupId == this.muscleGroupId &&
          other.name == this.name &&
          other.origin == this.origin &&
          other.archived == this.archived);
}

class MovementPatternsCompanion extends UpdateCompanion<MovementPattern> {
  final Value<String> id;
  final Value<String> muscleGroupId;
  final Value<String> name;
  final Value<String> origin;
  final Value<bool> archived;
  final Value<int> rowid;
  const MovementPatternsCompanion({
    this.id = const Value.absent(),
    this.muscleGroupId = const Value.absent(),
    this.name = const Value.absent(),
    this.origin = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementPatternsCompanion.insert({
    required String id,
    required String muscleGroupId,
    required String name,
    required String origin,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       muscleGroupId = Value(muscleGroupId),
       name = Value(name),
       origin = Value(origin);
  static Insertable<MovementPattern> custom({
    Expression<String>? id,
    Expression<String>? muscleGroupId,
    Expression<String>? name,
    Expression<String>? origin,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (muscleGroupId != null) 'muscle_group_id': muscleGroupId,
      if (name != null) 'name': name,
      if (origin != null) 'origin': origin,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementPatternsCompanion copyWith({
    Value<String>? id,
    Value<String>? muscleGroupId,
    Value<String>? name,
    Value<String>? origin,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return MovementPatternsCompanion(
      id: id ?? this.id,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (muscleGroupId.present) {
      map['muscle_group_id'] = Variable<String>(muscleGroupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementPatternsCompanion(')
          ..write('id: $id, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseVariationsTable extends ExerciseVariations
    with TableInfo<$ExerciseVariationsTable, ExerciseVariation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseVariationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementPatternIdMeta = const VerificationMeta(
    'movementPatternId',
  );
  @override
  late final GeneratedColumn<String> movementPatternId =
      GeneratedColumn<String>(
        'movement_pattern_id',
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
  static const VerificationMeta _equipmentTypeMeta = const VerificationMeta(
    'equipmentType',
  );
  @override
  late final GeneratedColumn<String> equipmentType = GeneratedColumn<String>(
    'equipment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movementPatternId,
    name,
    equipmentType,
    origin,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_variations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseVariation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('movement_pattern_id')) {
      context.handle(
        _movementPatternIdMeta,
        movementPatternId.isAcceptableOrUnknown(
          data['movement_pattern_id']!,
          _movementPatternIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementPatternIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment_type')) {
      context.handle(
        _equipmentTypeMeta,
        equipmentType.isAcceptableOrUnknown(
          data['equipment_type']!,
          _equipmentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentTypeMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseVariation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseVariation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      movementPatternId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_pattern_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_type'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ExerciseVariationsTable createAlias(String alias) {
    return $ExerciseVariationsTable(attachedDatabase, alias);
  }
}

class ExerciseVariation extends DataClass
    implements Insertable<ExerciseVariation> {
  final String id;
  final String movementPatternId;
  final String name;
  final String equipmentType;
  final String origin;
  final bool archived;
  const ExerciseVariation({
    required this.id,
    required this.movementPatternId,
    required this.name,
    required this.equipmentType,
    required this.origin,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['movement_pattern_id'] = Variable<String>(movementPatternId);
    map['name'] = Variable<String>(name);
    map['equipment_type'] = Variable<String>(equipmentType);
    map['origin'] = Variable<String>(origin);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ExerciseVariationsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseVariationsCompanion(
      id: Value(id),
      movementPatternId: Value(movementPatternId),
      name: Value(name),
      equipmentType: Value(equipmentType),
      origin: Value(origin),
      archived: Value(archived),
    );
  }

  factory ExerciseVariation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseVariation(
      id: serializer.fromJson<String>(json['id']),
      movementPatternId: serializer.fromJson<String>(json['movementPatternId']),
      name: serializer.fromJson<String>(json['name']),
      equipmentType: serializer.fromJson<String>(json['equipmentType']),
      origin: serializer.fromJson<String>(json['origin']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'movementPatternId': serializer.toJson<String>(movementPatternId),
      'name': serializer.toJson<String>(name),
      'equipmentType': serializer.toJson<String>(equipmentType),
      'origin': serializer.toJson<String>(origin),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  ExerciseVariation copyWith({
    String? id,
    String? movementPatternId,
    String? name,
    String? equipmentType,
    String? origin,
    bool? archived,
  }) => ExerciseVariation(
    id: id ?? this.id,
    movementPatternId: movementPatternId ?? this.movementPatternId,
    name: name ?? this.name,
    equipmentType: equipmentType ?? this.equipmentType,
    origin: origin ?? this.origin,
    archived: archived ?? this.archived,
  );
  ExerciseVariation copyWithCompanion(ExerciseVariationsCompanion data) {
    return ExerciseVariation(
      id: data.id.present ? data.id.value : this.id,
      movementPatternId: data.movementPatternId.present
          ? data.movementPatternId.value
          : this.movementPatternId,
      name: data.name.present ? data.name.value : this.name,
      equipmentType: data.equipmentType.present
          ? data.equipmentType.value
          : this.equipmentType,
      origin: data.origin.present ? data.origin.value : this.origin,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseVariation(')
          ..write('id: $id, ')
          ..write('movementPatternId: $movementPatternId, ')
          ..write('name: $name, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, movementPatternId, name, equipmentType, origin, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseVariation &&
          other.id == this.id &&
          other.movementPatternId == this.movementPatternId &&
          other.name == this.name &&
          other.equipmentType == this.equipmentType &&
          other.origin == this.origin &&
          other.archived == this.archived);
}

class ExerciseVariationsCompanion extends UpdateCompanion<ExerciseVariation> {
  final Value<String> id;
  final Value<String> movementPatternId;
  final Value<String> name;
  final Value<String> equipmentType;
  final Value<String> origin;
  final Value<bool> archived;
  final Value<int> rowid;
  const ExerciseVariationsCompanion({
    this.id = const Value.absent(),
    this.movementPatternId = const Value.absent(),
    this.name = const Value.absent(),
    this.equipmentType = const Value.absent(),
    this.origin = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseVariationsCompanion.insert({
    required String id,
    required String movementPatternId,
    required String name,
    required String equipmentType,
    required String origin,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       movementPatternId = Value(movementPatternId),
       name = Value(name),
       equipmentType = Value(equipmentType),
       origin = Value(origin);
  static Insertable<ExerciseVariation> custom({
    Expression<String>? id,
    Expression<String>? movementPatternId,
    Expression<String>? name,
    Expression<String>? equipmentType,
    Expression<String>? origin,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movementPatternId != null) 'movement_pattern_id': movementPatternId,
      if (name != null) 'name': name,
      if (equipmentType != null) 'equipment_type': equipmentType,
      if (origin != null) 'origin': origin,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseVariationsCompanion copyWith({
    Value<String>? id,
    Value<String>? movementPatternId,
    Value<String>? name,
    Value<String>? equipmentType,
    Value<String>? origin,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return ExerciseVariationsCompanion(
      id: id ?? this.id,
      movementPatternId: movementPatternId ?? this.movementPatternId,
      name: name ?? this.name,
      equipmentType: equipmentType ?? this.equipmentType,
      origin: origin ?? this.origin,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (movementPatternId.present) {
      map['movement_pattern_id'] = Variable<String>(movementPatternId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipmentType.present) {
      map['equipment_type'] = Variable<String>(equipmentType.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseVariationsCompanion(')
          ..write('id: $id, ')
          ..write('movementPatternId: $movementPatternId, ')
          ..write('name: $name, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManufacturersTable extends Manufacturers
    with TableInfo<$ManufacturersTable, Manufacturer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManufacturersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, origin, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manufacturers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Manufacturer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Manufacturer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Manufacturer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ManufacturersTable createAlias(String alias) {
    return $ManufacturersTable(attachedDatabase, alias);
  }
}

class Manufacturer extends DataClass implements Insertable<Manufacturer> {
  final String id;
  final String name;
  final String origin;
  final bool archived;
  const Manufacturer({
    required this.id,
    required this.name,
    required this.origin,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['origin'] = Variable<String>(origin);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ManufacturersCompanion toCompanion(bool nullToAbsent) {
    return ManufacturersCompanion(
      id: Value(id),
      name: Value(name),
      origin: Value(origin),
      archived: Value(archived),
    );
  }

  factory Manufacturer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Manufacturer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      origin: serializer.fromJson<String>(json['origin']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'origin': serializer.toJson<String>(origin),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Manufacturer copyWith({
    String? id,
    String? name,
    String? origin,
    bool? archived,
  }) => Manufacturer(
    id: id ?? this.id,
    name: name ?? this.name,
    origin: origin ?? this.origin,
    archived: archived ?? this.archived,
  );
  Manufacturer copyWithCompanion(ManufacturersCompanion data) {
    return Manufacturer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      origin: data.origin.present ? data.origin.value : this.origin,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Manufacturer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, origin, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manufacturer &&
          other.id == this.id &&
          other.name == this.name &&
          other.origin == this.origin &&
          other.archived == this.archived);
}

class ManufacturersCompanion extends UpdateCompanion<Manufacturer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> origin;
  final Value<bool> archived;
  final Value<int> rowid;
  const ManufacturersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.origin = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManufacturersCompanion.insert({
    required String id,
    required String name,
    required String origin,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       origin = Value(origin);
  static Insertable<Manufacturer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? origin,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (origin != null) 'origin': origin,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManufacturersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? origin,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return ManufacturersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManufacturersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MachineModelsTable extends MachineModels
    with TableInfo<$MachineModelsTable, MachineModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MachineModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerIdMeta = const VerificationMeta(
    'manufacturerId',
  );
  @override
  late final GeneratedColumn<String> manufacturerId = GeneratedColumn<String>(
    'manufacturer_id',
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
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    manufacturerId,
    name,
    origin,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'machine_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<MachineModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('manufacturer_id')) {
      context.handle(
        _manufacturerIdMeta,
        manufacturerId.isAcceptableOrUnknown(
          data['manufacturer_id']!,
          _manufacturerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MachineModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MachineModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      manufacturerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $MachineModelsTable createAlias(String alias) {
    return $MachineModelsTable(attachedDatabase, alias);
  }
}

class MachineModel extends DataClass implements Insertable<MachineModel> {
  final String id;
  final String manufacturerId;
  final String name;
  final String origin;
  final bool archived;
  const MachineModel({
    required this.id,
    required this.manufacturerId,
    required this.name,
    required this.origin,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['manufacturer_id'] = Variable<String>(manufacturerId);
    map['name'] = Variable<String>(name);
    map['origin'] = Variable<String>(origin);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  MachineModelsCompanion toCompanion(bool nullToAbsent) {
    return MachineModelsCompanion(
      id: Value(id),
      manufacturerId: Value(manufacturerId),
      name: Value(name),
      origin: Value(origin),
      archived: Value(archived),
    );
  }

  factory MachineModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MachineModel(
      id: serializer.fromJson<String>(json['id']),
      manufacturerId: serializer.fromJson<String>(json['manufacturerId']),
      name: serializer.fromJson<String>(json['name']),
      origin: serializer.fromJson<String>(json['origin']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'manufacturerId': serializer.toJson<String>(manufacturerId),
      'name': serializer.toJson<String>(name),
      'origin': serializer.toJson<String>(origin),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  MachineModel copyWith({
    String? id,
    String? manufacturerId,
    String? name,
    String? origin,
    bool? archived,
  }) => MachineModel(
    id: id ?? this.id,
    manufacturerId: manufacturerId ?? this.manufacturerId,
    name: name ?? this.name,
    origin: origin ?? this.origin,
    archived: archived ?? this.archived,
  );
  MachineModel copyWithCompanion(MachineModelsCompanion data) {
    return MachineModel(
      id: data.id.present ? data.id.value : this.id,
      manufacturerId: data.manufacturerId.present
          ? data.manufacturerId.value
          : this.manufacturerId,
      name: data.name.present ? data.name.value : this.name,
      origin: data.origin.present ? data.origin.value : this.origin,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MachineModel(')
          ..write('id: $id, ')
          ..write('manufacturerId: $manufacturerId, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, manufacturerId, name, origin, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MachineModel &&
          other.id == this.id &&
          other.manufacturerId == this.manufacturerId &&
          other.name == this.name &&
          other.origin == this.origin &&
          other.archived == this.archived);
}

class MachineModelsCompanion extends UpdateCompanion<MachineModel> {
  final Value<String> id;
  final Value<String> manufacturerId;
  final Value<String> name;
  final Value<String> origin;
  final Value<bool> archived;
  final Value<int> rowid;
  const MachineModelsCompanion({
    this.id = const Value.absent(),
    this.manufacturerId = const Value.absent(),
    this.name = const Value.absent(),
    this.origin = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MachineModelsCompanion.insert({
    required String id,
    required String manufacturerId,
    required String name,
    required String origin,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       manufacturerId = Value(manufacturerId),
       name = Value(name),
       origin = Value(origin);
  static Insertable<MachineModel> custom({
    Expression<String>? id,
    Expression<String>? manufacturerId,
    Expression<String>? name,
    Expression<String>? origin,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (manufacturerId != null) 'manufacturer_id': manufacturerId,
      if (name != null) 'name': name,
      if (origin != null) 'origin': origin,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MachineModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? manufacturerId,
    Value<String>? name,
    Value<String>? origin,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return MachineModelsCompanion(
      id: id ?? this.id,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (manufacturerId.present) {
      map['manufacturer_id'] = Variable<String>(manufacturerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MachineModelsCompanion(')
          ..write('id: $id, ')
          ..write('manufacturerId: $manufacturerId, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymLocationsTable extends GymLocations
    with TableInfo<$GymLocationsTable, GymLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isDefault, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<GymLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymLocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $GymLocationsTable createAlias(String alias) {
    return $GymLocationsTable(attachedDatabase, alias);
  }
}

class GymLocation extends DataClass implements Insertable<GymLocation> {
  final String id;
  final String name;
  final bool isDefault;
  final bool archived;
  const GymLocation({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  GymLocationsCompanion toCompanion(bool nullToAbsent) {
    return GymLocationsCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
      archived: Value(archived),
    );
  }

  factory GymLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymLocation(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  GymLocation copyWith({
    String? id,
    String? name,
    bool? isDefault,
    bool? archived,
  }) => GymLocation(
    id: id ?? this.id,
    name: name ?? this.name,
    isDefault: isDefault ?? this.isDefault,
    archived: archived ?? this.archived,
  );
  GymLocation copyWithCompanion(GymLocationsCompanion data) {
    return GymLocation(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymLocation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymLocation &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.archived == this.archived);
}

class GymLocationsCompanion extends UpdateCompanion<GymLocation> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<bool> archived;
  final Value<int> rowid;
  const GymLocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymLocationsCompanion.insert({
    required String id,
    required String name,
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<GymLocation> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymLocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return GymLocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymLocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gymLocationIdMeta = const VerificationMeta(
    'gymLocationId',
  );
  @override
  late final GeneratedColumn<String> gymLocationId = GeneratedColumn<String>(
    'gym_location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gymLocationId,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gym_location_id')) {
      context.handle(
        _gymLocationIdMeta,
        gymLocationId.isAcceptableOrUnknown(
          data['gym_location_id']!,
          _gymLocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gymLocationIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gymLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gym_location_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String id;
  final String gymLocationId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  const WorkoutSession({
    required this.id,
    required this.gymLocationId,
    required this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['gym_location_id'] = Variable<String>(gymLocationId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      gymLocationId: Value(gymLocationId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<String>(json['id']),
      gymLocationId: serializer.fromJson<String>(json['gymLocationId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gymLocationId': serializer.toJson<String>(gymLocationId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  WorkoutSession copyWith({
    String? id,
    String? gymLocationId,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => WorkoutSession(
    id: id ?? this.id,
    gymLocationId: gymLocationId ?? this.gymLocationId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      gymLocationId: data.gymLocationId.present
          ? data.gymLocationId.value
          : this.gymLocationId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('gymLocationId: $gymLocationId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gymLocationId, startedAt, finishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.gymLocationId == this.gymLocationId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<String> gymLocationId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.gymLocationId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required String gymLocationId,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gymLocationId = Value(gymLocationId),
       startedAt = Value(startedAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<String>? gymLocationId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gymLocationId != null) 'gym_location_id': gymLocationId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? gymLocationId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      gymLocationId: gymLocationId ?? this.gymLocationId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gymLocationId.present) {
      map['gym_location_id'] = Variable<String>(gymLocationId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('gymLocationId: $gymLocationId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutEntriesTable extends WorkoutEntries
    with TableInfo<$WorkoutEntriesTable, WorkoutEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseVariationIdMeta =
      const VerificationMeta('exerciseVariationId');
  @override
  late final GeneratedColumn<String> exerciseVariationId =
      GeneratedColumn<String>(
        'exercise_variation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _machineModelIdMeta = const VerificationMeta(
    'machineModelId',
  );
  @override
  late final GeneratedColumn<String> machineModelId = GeneratedColumn<String>(
    'machine_model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseVariationId,
    machineModelId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_variation_id')) {
      context.handle(
        _exerciseVariationIdMeta,
        exerciseVariationId.isAcceptableOrUnknown(
          data['exercise_variation_id']!,
          _exerciseVariationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseVariationIdMeta);
    }
    if (data.containsKey('machine_model_id')) {
      context.handle(
        _machineModelIdMeta,
        machineModelId.isAcceptableOrUnknown(
          data['machine_model_id']!,
          _machineModelIdMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseVariationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_variation_id'],
      )!,
      machineModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}machine_model_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $WorkoutEntriesTable createAlias(String alias) {
    return $WorkoutEntriesTable(attachedDatabase, alias);
  }
}

class WorkoutEntry extends DataClass implements Insertable<WorkoutEntry> {
  final String id;
  final String sessionId;
  final String exerciseVariationId;
  final String? machineModelId;
  final int position;
  const WorkoutEntry({
    required this.id,
    required this.sessionId,
    required this.exerciseVariationId,
    this.machineModelId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_variation_id'] = Variable<String>(exerciseVariationId);
    if (!nullToAbsent || machineModelId != null) {
      map['machine_model_id'] = Variable<String>(machineModelId);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  WorkoutEntriesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseVariationId: Value(exerciseVariationId),
      machineModelId: machineModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(machineModelId),
      position: Value(position),
    );
  }

  factory WorkoutEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutEntry(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseVariationId: serializer.fromJson<String>(
        json['exerciseVariationId'],
      ),
      machineModelId: serializer.fromJson<String?>(json['machineModelId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseVariationId': serializer.toJson<String>(exerciseVariationId),
      'machineModelId': serializer.toJson<String?>(machineModelId),
      'position': serializer.toJson<int>(position),
    };
  }

  WorkoutEntry copyWith({
    String? id,
    String? sessionId,
    String? exerciseVariationId,
    Value<String?> machineModelId = const Value.absent(),
    int? position,
  }) => WorkoutEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseVariationId: exerciseVariationId ?? this.exerciseVariationId,
    machineModelId: machineModelId.present
        ? machineModelId.value
        : this.machineModelId,
    position: position ?? this.position,
  );
  WorkoutEntry copyWithCompanion(WorkoutEntriesCompanion data) {
    return WorkoutEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseVariationId: data.exerciseVariationId.present
          ? data.exerciseVariationId.value
          : this.exerciseVariationId,
      machineModelId: data.machineModelId.present
          ? data.machineModelId.value
          : this.machineModelId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseVariationId: $exerciseVariationId, ')
          ..write('machineModelId: $machineModelId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, exerciseVariationId, machineModelId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseVariationId == this.exerciseVariationId &&
          other.machineModelId == this.machineModelId &&
          other.position == this.position);
}

class WorkoutEntriesCompanion extends UpdateCompanion<WorkoutEntry> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseVariationId;
  final Value<String?> machineModelId;
  final Value<int> position;
  final Value<int> rowid;
  const WorkoutEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseVariationId = const Value.absent(),
    this.machineModelId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutEntriesCompanion.insert({
    required String id,
    required String sessionId,
    required String exerciseVariationId,
    this.machineModelId = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseVariationId = Value(exerciseVariationId),
       position = Value(position);
  static Insertable<WorkoutEntry> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseVariationId,
    Expression<String>? machineModelId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseVariationId != null)
        'exercise_variation_id': exerciseVariationId,
      if (machineModelId != null) 'machine_model_id': machineModelId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseVariationId,
    Value<String?>? machineModelId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return WorkoutEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseVariationId: exerciseVariationId ?? this.exerciseVariationId,
      machineModelId: machineModelId ?? this.machineModelId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseVariationId.present) {
      map['exercise_variation_id'] = Variable<String>(
        exerciseVariationId.value,
      );
    }
    if (machineModelId.present) {
      map['machine_model_id'] = Variable<String>(machineModelId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseVariationId: $exerciseVariationId, ')
          ..write('machineModelId: $machineModelId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoggedSetsTable extends LoggedSets
    with TableInfo<$LoggedSetsTable, LoggedSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoggedSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutEntryIdMeta = const VerificationMeta(
    'workoutEntryId',
  );
  @override
  late final GeneratedColumn<String> workoutEntryId = GeneratedColumn<String>(
    'workout_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loadKgMeta = const VerificationMeta('loadKg');
  @override
  late final GeneratedColumn<double> loadKg = GeneratedColumn<double>(
    'load_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyweightAdjustmentKgMeta =
      const VerificationMeta('bodyweightAdjustmentKg');
  @override
  late final GeneratedColumn<double> bodyweightAdjustmentKg =
      GeneratedColumn<double>(
        'bodyweight_adjustment_kg',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _adjustmentMeta = const VerificationMeta(
    'adjustment',
  );
  @override
  late final GeneratedColumn<String> adjustment = GeneratedColumn<String>(
    'adjustment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutEntryId,
    position,
    reps,
    loadKg,
    bodyweightAdjustmentKg,
    adjustment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logged_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoggedSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_entry_id')) {
      context.handle(
        _workoutEntryIdMeta,
        workoutEntryId.isAcceptableOrUnknown(
          data['workout_entry_id']!,
          _workoutEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutEntryIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('load_kg')) {
      context.handle(
        _loadKgMeta,
        loadKg.isAcceptableOrUnknown(data['load_kg']!, _loadKgMeta),
      );
    }
    if (data.containsKey('bodyweight_adjustment_kg')) {
      context.handle(
        _bodyweightAdjustmentKgMeta,
        bodyweightAdjustmentKg.isAcceptableOrUnknown(
          data['bodyweight_adjustment_kg']!,
          _bodyweightAdjustmentKgMeta,
        ),
      );
    }
    if (data.containsKey('adjustment')) {
      context.handle(
        _adjustmentMeta,
        adjustment.isAcceptableOrUnknown(data['adjustment']!, _adjustmentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoggedSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoggedSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_entry_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      loadKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}load_kg'],
      ),
      bodyweightAdjustmentKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bodyweight_adjustment_kg'],
      ),
      adjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment'],
      )!,
    );
  }

  @override
  $LoggedSetsTable createAlias(String alias) {
    return $LoggedSetsTable(attachedDatabase, alias);
  }
}

class LoggedSet extends DataClass implements Insertable<LoggedSet> {
  final String id;
  final String workoutEntryId;
  final int position;
  final int reps;
  final double? loadKg;
  final double? bodyweightAdjustmentKg;
  final String adjustment;
  const LoggedSet({
    required this.id,
    required this.workoutEntryId,
    required this.position,
    required this.reps,
    this.loadKg,
    this.bodyweightAdjustmentKg,
    required this.adjustment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_entry_id'] = Variable<String>(workoutEntryId);
    map['position'] = Variable<int>(position);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || loadKg != null) {
      map['load_kg'] = Variable<double>(loadKg);
    }
    if (!nullToAbsent || bodyweightAdjustmentKg != null) {
      map['bodyweight_adjustment_kg'] = Variable<double>(
        bodyweightAdjustmentKg,
      );
    }
    map['adjustment'] = Variable<String>(adjustment);
    return map;
  }

  LoggedSetsCompanion toCompanion(bool nullToAbsent) {
    return LoggedSetsCompanion(
      id: Value(id),
      workoutEntryId: Value(workoutEntryId),
      position: Value(position),
      reps: Value(reps),
      loadKg: loadKg == null && nullToAbsent
          ? const Value.absent()
          : Value(loadKg),
      bodyweightAdjustmentKg: bodyweightAdjustmentKg == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyweightAdjustmentKg),
      adjustment: Value(adjustment),
    );
  }

  factory LoggedSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoggedSet(
      id: serializer.fromJson<String>(json['id']),
      workoutEntryId: serializer.fromJson<String>(json['workoutEntryId']),
      position: serializer.fromJson<int>(json['position']),
      reps: serializer.fromJson<int>(json['reps']),
      loadKg: serializer.fromJson<double?>(json['loadKg']),
      bodyweightAdjustmentKg: serializer.fromJson<double?>(
        json['bodyweightAdjustmentKg'],
      ),
      adjustment: serializer.fromJson<String>(json['adjustment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutEntryId': serializer.toJson<String>(workoutEntryId),
      'position': serializer.toJson<int>(position),
      'reps': serializer.toJson<int>(reps),
      'loadKg': serializer.toJson<double?>(loadKg),
      'bodyweightAdjustmentKg': serializer.toJson<double?>(
        bodyweightAdjustmentKg,
      ),
      'adjustment': serializer.toJson<String>(adjustment),
    };
  }

  LoggedSet copyWith({
    String? id,
    String? workoutEntryId,
    int? position,
    int? reps,
    Value<double?> loadKg = const Value.absent(),
    Value<double?> bodyweightAdjustmentKg = const Value.absent(),
    String? adjustment,
  }) => LoggedSet(
    id: id ?? this.id,
    workoutEntryId: workoutEntryId ?? this.workoutEntryId,
    position: position ?? this.position,
    reps: reps ?? this.reps,
    loadKg: loadKg.present ? loadKg.value : this.loadKg,
    bodyweightAdjustmentKg: bodyweightAdjustmentKg.present
        ? bodyweightAdjustmentKg.value
        : this.bodyweightAdjustmentKg,
    adjustment: adjustment ?? this.adjustment,
  );
  LoggedSet copyWithCompanion(LoggedSetsCompanion data) {
    return LoggedSet(
      id: data.id.present ? data.id.value : this.id,
      workoutEntryId: data.workoutEntryId.present
          ? data.workoutEntryId.value
          : this.workoutEntryId,
      position: data.position.present ? data.position.value : this.position,
      reps: data.reps.present ? data.reps.value : this.reps,
      loadKg: data.loadKg.present ? data.loadKg.value : this.loadKg,
      bodyweightAdjustmentKg: data.bodyweightAdjustmentKg.present
          ? data.bodyweightAdjustmentKg.value
          : this.bodyweightAdjustmentKg,
      adjustment: data.adjustment.present
          ? data.adjustment.value
          : this.adjustment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoggedSet(')
          ..write('id: $id, ')
          ..write('workoutEntryId: $workoutEntryId, ')
          ..write('position: $position, ')
          ..write('reps: $reps, ')
          ..write('loadKg: $loadKg, ')
          ..write('bodyweightAdjustmentKg: $bodyweightAdjustmentKg, ')
          ..write('adjustment: $adjustment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutEntryId,
    position,
    reps,
    loadKg,
    bodyweightAdjustmentKg,
    adjustment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoggedSet &&
          other.id == this.id &&
          other.workoutEntryId == this.workoutEntryId &&
          other.position == this.position &&
          other.reps == this.reps &&
          other.loadKg == this.loadKg &&
          other.bodyweightAdjustmentKg == this.bodyweightAdjustmentKg &&
          other.adjustment == this.adjustment);
}

class LoggedSetsCompanion extends UpdateCompanion<LoggedSet> {
  final Value<String> id;
  final Value<String> workoutEntryId;
  final Value<int> position;
  final Value<int> reps;
  final Value<double?> loadKg;
  final Value<double?> bodyweightAdjustmentKg;
  final Value<String> adjustment;
  final Value<int> rowid;
  const LoggedSetsCompanion({
    this.id = const Value.absent(),
    this.workoutEntryId = const Value.absent(),
    this.position = const Value.absent(),
    this.reps = const Value.absent(),
    this.loadKg = const Value.absent(),
    this.bodyweightAdjustmentKg = const Value.absent(),
    this.adjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoggedSetsCompanion.insert({
    required String id,
    required String workoutEntryId,
    required int position,
    this.reps = const Value.absent(),
    this.loadKg = const Value.absent(),
    this.bodyweightAdjustmentKg = const Value.absent(),
    this.adjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutEntryId = Value(workoutEntryId),
       position = Value(position);
  static Insertable<LoggedSet> custom({
    Expression<String>? id,
    Expression<String>? workoutEntryId,
    Expression<int>? position,
    Expression<int>? reps,
    Expression<double>? loadKg,
    Expression<double>? bodyweightAdjustmentKg,
    Expression<String>? adjustment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutEntryId != null) 'workout_entry_id': workoutEntryId,
      if (position != null) 'position': position,
      if (reps != null) 'reps': reps,
      if (loadKg != null) 'load_kg': loadKg,
      if (bodyweightAdjustmentKg != null)
        'bodyweight_adjustment_kg': bodyweightAdjustmentKg,
      if (adjustment != null) 'adjustment': adjustment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoggedSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutEntryId,
    Value<int>? position,
    Value<int>? reps,
    Value<double?>? loadKg,
    Value<double?>? bodyweightAdjustmentKg,
    Value<String>? adjustment,
    Value<int>? rowid,
  }) {
    return LoggedSetsCompanion(
      id: id ?? this.id,
      workoutEntryId: workoutEntryId ?? this.workoutEntryId,
      position: position ?? this.position,
      reps: reps ?? this.reps,
      loadKg: loadKg ?? this.loadKg,
      bodyweightAdjustmentKg:
          bodyweightAdjustmentKg ?? this.bodyweightAdjustmentKg,
      adjustment: adjustment ?? this.adjustment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutEntryId.present) {
      map['workout_entry_id'] = Variable<String>(workoutEntryId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (loadKg.present) {
      map['load_kg'] = Variable<double>(loadKg.value);
    }
    if (bodyweightAdjustmentKg.present) {
      map['bodyweight_adjustment_kg'] = Variable<double>(
        bodyweightAdjustmentKg.value,
      );
    }
    if (adjustment.present) {
      map['adjustment'] = Variable<String>(adjustment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoggedSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutEntryId: $workoutEntryId, ')
          ..write('position: $position, ')
          ..write('reps: $reps, ')
          ..write('loadKg: $loadKg, ')
          ..write('bodyweightAdjustmentKg: $bodyweightAdjustmentKg, ')
          ..write('adjustment: $adjustment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
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
  late final $MuscleGroupsTable muscleGroups = $MuscleGroupsTable(this);
  late final $MovementPatternsTable movementPatterns = $MovementPatternsTable(
    this,
  );
  late final $ExerciseVariationsTable exerciseVariations =
      $ExerciseVariationsTable(this);
  late final $ManufacturersTable manufacturers = $ManufacturersTable(this);
  late final $MachineModelsTable machineModels = $MachineModelsTable(this);
  late final $GymLocationsTable gymLocations = $GymLocationsTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $WorkoutEntriesTable workoutEntries = $WorkoutEntriesTable(this);
  late final $LoggedSetsTable loggedSets = $LoggedSetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    muscleGroups,
    movementPatterns,
    exerciseVariations,
    manufacturers,
    machineModels,
    gymLocations,
    workoutSessions,
    workoutEntries,
    loggedSets,
    appSettings,
  ];
}

typedef $$MuscleGroupsTableCreateCompanionBuilder =
    MuscleGroupsCompanion Function({
      required String id,
      required String name,
      required String origin,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$MuscleGroupsTableUpdateCompanionBuilder =
    MuscleGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> origin,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$MuscleGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MuscleGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuscleGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$MuscleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MuscleGroupsTable,
          MuscleGroup,
          $$MuscleGroupsTableFilterComposer,
          $$MuscleGroupsTableOrderingComposer,
          $$MuscleGroupsTableAnnotationComposer,
          $$MuscleGroupsTableCreateCompanionBuilder,
          $$MuscleGroupsTableUpdateCompanionBuilder,
          (
            MuscleGroup,
            BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup>,
          ),
          MuscleGroup,
          PrefetchHooks Function()
        > {
  $$MuscleGroupsTableTableManager(_$AppDatabase db, $MuscleGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MuscleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MuscleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuscleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion(
                id: id,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String origin,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion.insert(
                id: id,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MuscleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MuscleGroupsTable,
      MuscleGroup,
      $$MuscleGroupsTableFilterComposer,
      $$MuscleGroupsTableOrderingComposer,
      $$MuscleGroupsTableAnnotationComposer,
      $$MuscleGroupsTableCreateCompanionBuilder,
      $$MuscleGroupsTableUpdateCompanionBuilder,
      (
        MuscleGroup,
        BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup>,
      ),
      MuscleGroup,
      PrefetchHooks Function()
    >;
typedef $$MovementPatternsTableCreateCompanionBuilder =
    MovementPatternsCompanion Function({
      required String id,
      required String muscleGroupId,
      required String name,
      required String origin,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$MovementPatternsTableUpdateCompanionBuilder =
    MovementPatternsCompanion Function({
      Value<String> id,
      Value<String> muscleGroupId,
      Value<String> name,
      Value<String> origin,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$MovementPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $MovementPatternsTable> {
  $$MovementPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroupId => $composableBuilder(
    column: $table.muscleGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovementPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $MovementPatternsTable> {
  $$MovementPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroupId => $composableBuilder(
    column: $table.muscleGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovementPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovementPatternsTable> {
  $$MovementPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get muscleGroupId => $composableBuilder(
    column: $table.muscleGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$MovementPatternsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovementPatternsTable,
          MovementPattern,
          $$MovementPatternsTableFilterComposer,
          $$MovementPatternsTableOrderingComposer,
          $$MovementPatternsTableAnnotationComposer,
          $$MovementPatternsTableCreateCompanionBuilder,
          $$MovementPatternsTableUpdateCompanionBuilder,
          (
            MovementPattern,
            BaseReferences<
              _$AppDatabase,
              $MovementPatternsTable,
              MovementPattern
            >,
          ),
          MovementPattern,
          PrefetchHooks Function()
        > {
  $$MovementPatternsTableTableManager(
    _$AppDatabase db,
    $MovementPatternsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementPatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> muscleGroupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementPatternsCompanion(
                id: id,
                muscleGroupId: muscleGroupId,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String muscleGroupId,
                required String name,
                required String origin,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementPatternsCompanion.insert(
                id: id,
                muscleGroupId: muscleGroupId,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovementPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovementPatternsTable,
      MovementPattern,
      $$MovementPatternsTableFilterComposer,
      $$MovementPatternsTableOrderingComposer,
      $$MovementPatternsTableAnnotationComposer,
      $$MovementPatternsTableCreateCompanionBuilder,
      $$MovementPatternsTableUpdateCompanionBuilder,
      (
        MovementPattern,
        BaseReferences<_$AppDatabase, $MovementPatternsTable, MovementPattern>,
      ),
      MovementPattern,
      PrefetchHooks Function()
    >;
typedef $$ExerciseVariationsTableCreateCompanionBuilder =
    ExerciseVariationsCompanion Function({
      required String id,
      required String movementPatternId,
      required String name,
      required String equipmentType,
      required String origin,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$ExerciseVariationsTableUpdateCompanionBuilder =
    ExerciseVariationsCompanion Function({
      Value<String> id,
      Value<String> movementPatternId,
      Value<String> name,
      Value<String> equipmentType,
      Value<String> origin,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$ExerciseVariationsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseVariationsTable> {
  $$ExerciseVariationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementPatternId => $composableBuilder(
    column: $table.movementPatternId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseVariationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseVariationsTable> {
  $$ExerciseVariationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementPatternId => $composableBuilder(
    column: $table.movementPatternId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseVariationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseVariationsTable> {
  $$ExerciseVariationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movementPatternId => $composableBuilder(
    column: $table.movementPatternId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$ExerciseVariationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseVariationsTable,
          ExerciseVariation,
          $$ExerciseVariationsTableFilterComposer,
          $$ExerciseVariationsTableOrderingComposer,
          $$ExerciseVariationsTableAnnotationComposer,
          $$ExerciseVariationsTableCreateCompanionBuilder,
          $$ExerciseVariationsTableUpdateCompanionBuilder,
          (
            ExerciseVariation,
            BaseReferences<
              _$AppDatabase,
              $ExerciseVariationsTable,
              ExerciseVariation
            >,
          ),
          ExerciseVariation,
          PrefetchHooks Function()
        > {
  $$ExerciseVariationsTableTableManager(
    _$AppDatabase db,
    $ExerciseVariationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseVariationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseVariationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseVariationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> movementPatternId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> equipmentType = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseVariationsCompanion(
                id: id,
                movementPatternId: movementPatternId,
                name: name,
                equipmentType: equipmentType,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String movementPatternId,
                required String name,
                required String equipmentType,
                required String origin,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseVariationsCompanion.insert(
                id: id,
                movementPatternId: movementPatternId,
                name: name,
                equipmentType: equipmentType,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseVariationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseVariationsTable,
      ExerciseVariation,
      $$ExerciseVariationsTableFilterComposer,
      $$ExerciseVariationsTableOrderingComposer,
      $$ExerciseVariationsTableAnnotationComposer,
      $$ExerciseVariationsTableCreateCompanionBuilder,
      $$ExerciseVariationsTableUpdateCompanionBuilder,
      (
        ExerciseVariation,
        BaseReferences<
          _$AppDatabase,
          $ExerciseVariationsTable,
          ExerciseVariation
        >,
      ),
      ExerciseVariation,
      PrefetchHooks Function()
    >;
typedef $$ManufacturersTableCreateCompanionBuilder =
    ManufacturersCompanion Function({
      required String id,
      required String name,
      required String origin,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$ManufacturersTableUpdateCompanionBuilder =
    ManufacturersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> origin,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$ManufacturersTableFilterComposer
    extends Composer<_$AppDatabase, $ManufacturersTable> {
  $$ManufacturersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ManufacturersTableOrderingComposer
    extends Composer<_$AppDatabase, $ManufacturersTable> {
  $$ManufacturersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManufacturersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManufacturersTable> {
  $$ManufacturersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$ManufacturersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManufacturersTable,
          Manufacturer,
          $$ManufacturersTableFilterComposer,
          $$ManufacturersTableOrderingComposer,
          $$ManufacturersTableAnnotationComposer,
          $$ManufacturersTableCreateCompanionBuilder,
          $$ManufacturersTableUpdateCompanionBuilder,
          (
            Manufacturer,
            BaseReferences<_$AppDatabase, $ManufacturersTable, Manufacturer>,
          ),
          Manufacturer,
          PrefetchHooks Function()
        > {
  $$ManufacturersTableTableManager(_$AppDatabase db, $ManufacturersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManufacturersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManufacturersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManufacturersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManufacturersCompanion(
                id: id,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String origin,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManufacturersCompanion.insert(
                id: id,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManufacturersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManufacturersTable,
      Manufacturer,
      $$ManufacturersTableFilterComposer,
      $$ManufacturersTableOrderingComposer,
      $$ManufacturersTableAnnotationComposer,
      $$ManufacturersTableCreateCompanionBuilder,
      $$ManufacturersTableUpdateCompanionBuilder,
      (
        Manufacturer,
        BaseReferences<_$AppDatabase, $ManufacturersTable, Manufacturer>,
      ),
      Manufacturer,
      PrefetchHooks Function()
    >;
typedef $$MachineModelsTableCreateCompanionBuilder =
    MachineModelsCompanion Function({
      required String id,
      required String manufacturerId,
      required String name,
      required String origin,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$MachineModelsTableUpdateCompanionBuilder =
    MachineModelsCompanion Function({
      Value<String> id,
      Value<String> manufacturerId,
      Value<String> name,
      Value<String> origin,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$MachineModelsTableFilterComposer
    extends Composer<_$AppDatabase, $MachineModelsTable> {
  $$MachineModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturerId => $composableBuilder(
    column: $table.manufacturerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MachineModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $MachineModelsTable> {
  $$MachineModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturerId => $composableBuilder(
    column: $table.manufacturerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MachineModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MachineModelsTable> {
  $$MachineModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get manufacturerId => $composableBuilder(
    column: $table.manufacturerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$MachineModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MachineModelsTable,
          MachineModel,
          $$MachineModelsTableFilterComposer,
          $$MachineModelsTableOrderingComposer,
          $$MachineModelsTableAnnotationComposer,
          $$MachineModelsTableCreateCompanionBuilder,
          $$MachineModelsTableUpdateCompanionBuilder,
          (
            MachineModel,
            BaseReferences<_$AppDatabase, $MachineModelsTable, MachineModel>,
          ),
          MachineModel,
          PrefetchHooks Function()
        > {
  $$MachineModelsTableTableManager(_$AppDatabase db, $MachineModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MachineModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MachineModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MachineModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> manufacturerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MachineModelsCompanion(
                id: id,
                manufacturerId: manufacturerId,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String manufacturerId,
                required String name,
                required String origin,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MachineModelsCompanion.insert(
                id: id,
                manufacturerId: manufacturerId,
                name: name,
                origin: origin,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MachineModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MachineModelsTable,
      MachineModel,
      $$MachineModelsTableFilterComposer,
      $$MachineModelsTableOrderingComposer,
      $$MachineModelsTableAnnotationComposer,
      $$MachineModelsTableCreateCompanionBuilder,
      $$MachineModelsTableUpdateCompanionBuilder,
      (
        MachineModel,
        BaseReferences<_$AppDatabase, $MachineModelsTable, MachineModel>,
      ),
      MachineModel,
      PrefetchHooks Function()
    >;
typedef $$GymLocationsTableCreateCompanionBuilder =
    GymLocationsCompanion Function({
      required String id,
      required String name,
      Value<bool> isDefault,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$GymLocationsTableUpdateCompanionBuilder =
    GymLocationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isDefault,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$GymLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $GymLocationsTable> {
  $$GymLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GymLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $GymLocationsTable> {
  $$GymLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GymLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymLocationsTable> {
  $$GymLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$GymLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GymLocationsTable,
          GymLocation,
          $$GymLocationsTableFilterComposer,
          $$GymLocationsTableOrderingComposer,
          $$GymLocationsTableAnnotationComposer,
          $$GymLocationsTableCreateCompanionBuilder,
          $$GymLocationsTableUpdateCompanionBuilder,
          (
            GymLocation,
            BaseReferences<_$AppDatabase, $GymLocationsTable, GymLocation>,
          ),
          GymLocation,
          PrefetchHooks Function()
        > {
  $$GymLocationsTableTableManager(_$AppDatabase db, $GymLocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GymLocationsCompanion(
                id: id,
                name: name,
                isDefault: isDefault,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GymLocationsCompanion.insert(
                id: id,
                name: name,
                isDefault: isDefault,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GymLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GymLocationsTable,
      GymLocation,
      $$GymLocationsTableFilterComposer,
      $$GymLocationsTableOrderingComposer,
      $$GymLocationsTableAnnotationComposer,
      $$GymLocationsTableCreateCompanionBuilder,
      $$GymLocationsTableUpdateCompanionBuilder,
      (
        GymLocation,
        BaseReferences<_$AppDatabase, $GymLocationsTable, GymLocation>,
      ),
      GymLocation,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      required String gymLocationId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String> gymLocationId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gymLocationId => $composableBuilder(
    column: $table.gymLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gymLocationId => $composableBuilder(
    column: $table.gymLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gymLocationId => $composableBuilder(
    column: $table.gymLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            WorkoutSession,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTable,
              WorkoutSession
            >,
          ),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gymLocationId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                gymLocationId: gymLocationId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gymLocationId,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                gymLocationId: gymLocationId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        WorkoutSession,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>,
      ),
      WorkoutSession,
      PrefetchHooks Function()
    >;
typedef $$WorkoutEntriesTableCreateCompanionBuilder =
    WorkoutEntriesCompanion Function({
      required String id,
      required String sessionId,
      required String exerciseVariationId,
      Value<String?> machineModelId,
      required int position,
      Value<int> rowid,
    });
typedef $$WorkoutEntriesTableUpdateCompanionBuilder =
    WorkoutEntriesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> exerciseVariationId,
      Value<String?> machineModelId,
      Value<int> position,
      Value<int> rowid,
    });

class $$WorkoutEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutEntriesTable> {
  $$WorkoutEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseVariationId => $composableBuilder(
    column: $table.exerciseVariationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get machineModelId => $composableBuilder(
    column: $table.machineModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutEntriesTable> {
  $$WorkoutEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseVariationId => $composableBuilder(
    column: $table.exerciseVariationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get machineModelId => $composableBuilder(
    column: $table.machineModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutEntriesTable> {
  $$WorkoutEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get exerciseVariationId => $composableBuilder(
    column: $table.exerciseVariationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get machineModelId => $composableBuilder(
    column: $table.machineModelId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$WorkoutEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutEntriesTable,
          WorkoutEntry,
          $$WorkoutEntriesTableFilterComposer,
          $$WorkoutEntriesTableOrderingComposer,
          $$WorkoutEntriesTableAnnotationComposer,
          $$WorkoutEntriesTableCreateCompanionBuilder,
          $$WorkoutEntriesTableUpdateCompanionBuilder,
          (
            WorkoutEntry,
            BaseReferences<_$AppDatabase, $WorkoutEntriesTable, WorkoutEntry>,
          ),
          WorkoutEntry,
          PrefetchHooks Function()
        > {
  $$WorkoutEntriesTableTableManager(
    _$AppDatabase db,
    $WorkoutEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseVariationId = const Value.absent(),
                Value<String?> machineModelId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutEntriesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseVariationId: exerciseVariationId,
                machineModelId: machineModelId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String exerciseVariationId,
                Value<String?> machineModelId = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseVariationId: exerciseVariationId,
                machineModelId: machineModelId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutEntriesTable,
      WorkoutEntry,
      $$WorkoutEntriesTableFilterComposer,
      $$WorkoutEntriesTableOrderingComposer,
      $$WorkoutEntriesTableAnnotationComposer,
      $$WorkoutEntriesTableCreateCompanionBuilder,
      $$WorkoutEntriesTableUpdateCompanionBuilder,
      (
        WorkoutEntry,
        BaseReferences<_$AppDatabase, $WorkoutEntriesTable, WorkoutEntry>,
      ),
      WorkoutEntry,
      PrefetchHooks Function()
    >;
typedef $$LoggedSetsTableCreateCompanionBuilder = LoggedSetsCompanion Function({
  required String id,
  required String workoutEntryId,
  required int position,
  Value<int> reps,
  Value<double?> loadKg,
  Value<double?> bodyweightAdjustmentKg,
  Value<String> adjustment,
  Value<int> rowid,
});
typedef $$LoggedSetsTableUpdateCompanionBuilder = LoggedSetsCompanion Function({
  Value<String> id,
  Value<String> workoutEntryId,
  Value<int> position,
  Value<int> reps,
  Value<double?> loadKg,
  Value<double?> bodyweightAdjustmentKg,
  Value<String> adjustment,
  Value<int> rowid,
});

class $$LoggedSetsTableFilterComposer
    extends Composer<_$AppDatabase, $LoggedSetsTable> {
  $$LoggedSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutEntryId => $composableBuilder(
    column: $table.workoutEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loadKg => $composableBuilder(
    column: $table.loadKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyweightAdjustmentKg => $composableBuilder(
    column: $table.bodyweightAdjustmentKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoggedSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoggedSetsTable> {
  $$LoggedSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutEntryId => $composableBuilder(
    column: $table.workoutEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loadKg => $composableBuilder(
    column: $table.loadKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyweightAdjustmentKg => $composableBuilder(
    column: $table.bodyweightAdjustmentKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoggedSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoggedSetsTable> {
  $$LoggedSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workoutEntryId => $composableBuilder(
    column: $table.workoutEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get loadKg =>
      $composableBuilder(column: $table.loadKg, builder: (column) => column);

  GeneratedColumn<double> get bodyweightAdjustmentKg => $composableBuilder(
    column: $table.bodyweightAdjustmentKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => column,
  );
}

class $$LoggedSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoggedSetsTable,
          LoggedSet,
          $$LoggedSetsTableFilterComposer,
          $$LoggedSetsTableOrderingComposer,
          $$LoggedSetsTableAnnotationComposer,
          $$LoggedSetsTableCreateCompanionBuilder,
          $$LoggedSetsTableUpdateCompanionBuilder,
          (
            LoggedSet,
            BaseReferences<_$AppDatabase, $LoggedSetsTable, LoggedSet>,
          ),
          LoggedSet,
          PrefetchHooks Function()
        > {
  $$LoggedSetsTableTableManager(_$AppDatabase db, $LoggedSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoggedSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoggedSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoggedSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutEntryId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double?> loadKg = const Value.absent(),
                Value<double?> bodyweightAdjustmentKg = const Value.absent(),
                Value<String> adjustment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoggedSetsCompanion(
                id: id,
                workoutEntryId: workoutEntryId,
                position: position,
                reps: reps,
                loadKg: loadKg,
                bodyweightAdjustmentKg: bodyweightAdjustmentKg,
                adjustment: adjustment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutEntryId,
                required int position,
                Value<int> reps = const Value.absent(),
                Value<double?> loadKg = const Value.absent(),
                Value<double?> bodyweightAdjustmentKg = const Value.absent(),
                Value<String> adjustment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoggedSetsCompanion.insert(
                id: id,
                workoutEntryId: workoutEntryId,
                position: position,
                reps: reps,
                loadKg: loadKg,
                bodyweightAdjustmentKg: bodyweightAdjustmentKg,
                adjustment: adjustment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoggedSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoggedSetsTable,
      LoggedSet,
      $$LoggedSetsTableFilterComposer,
      $$LoggedSetsTableOrderingComposer,
      $$LoggedSetsTableAnnotationComposer,
      $$LoggedSetsTableCreateCompanionBuilder,
      $$LoggedSetsTableUpdateCompanionBuilder,
      (LoggedSet, BaseReferences<_$AppDatabase, $LoggedSetsTable, LoggedSet>),
      LoggedSet,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MuscleGroupsTableTableManager get muscleGroups =>
      $$MuscleGroupsTableTableManager(_db, _db.muscleGroups);
  $$MovementPatternsTableTableManager get movementPatterns =>
      $$MovementPatternsTableTableManager(_db, _db.movementPatterns);
  $$ExerciseVariationsTableTableManager get exerciseVariations =>
      $$ExerciseVariationsTableTableManager(_db, _db.exerciseVariations);
  $$ManufacturersTableTableManager get manufacturers =>
      $$ManufacturersTableTableManager(_db, _db.manufacturers);
  $$MachineModelsTableTableManager get machineModels =>
      $$MachineModelsTableTableManager(_db, _db.machineModels);
  $$GymLocationsTableTableManager get gymLocations =>
      $$GymLocationsTableTableManager(_db, _db.gymLocations);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutEntriesTableTableManager get workoutEntries =>
      $$WorkoutEntriesTableTableManager(_db, _db.workoutEntries);
  $$LoggedSetsTableTableManager get loggedSets =>
      $$LoggedSetsTableTableManager(_db, _db.loggedSets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
