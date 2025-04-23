// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// ignore_for_file: type=lint
class $SensorTable extends Sensor with TableInfo<$SensorTable, SensorData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
    'ip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerationXMeta = const VerificationMeta(
    'accelerationX',
  );
  @override
  late final GeneratedColumn<double> accelerationX = GeneratedColumn<double>(
    'acceleration_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerationYMeta = const VerificationMeta(
    'accelerationY',
  );
  @override
  late final GeneratedColumn<double> accelerationY = GeneratedColumn<double>(
    'acceleration_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerationZMeta = const VerificationMeta(
    'accelerationZ',
  );
  @override
  late final GeneratedColumn<double> accelerationZ = GeneratedColumn<double>(
    'acceleration_z',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    ip,
    accelerationX,
    accelerationY,
    accelerationZ,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('acceleration_x')) {
      context.handle(
        _accelerationXMeta,
        accelerationX.isAcceptableOrUnknown(
          data['acceleration_x']!,
          _accelerationXMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerationXMeta);
    }
    if (data.containsKey('acceleration_y')) {
      context.handle(
        _accelerationYMeta,
        accelerationY.isAcceptableOrUnknown(
          data['acceleration_y']!,
          _accelerationYMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerationYMeta);
    }
    if (data.containsKey('acceleration_z')) {
      context.handle(
        _accelerationZMeta,
        accelerationZ.isAcceptableOrUnknown(
          data['acceleration_z']!,
          _accelerationZMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerationZMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      ip:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}ip'],
          )!,
      accelerationX:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}acceleration_x'],
          )!,
      accelerationY:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}acceleration_y'],
          )!,
      accelerationZ:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}acceleration_z'],
          )!,
    );
  }

  @override
  $SensorTable createAlias(String alias) {
    return $SensorTable(attachedDatabase, alias);
  }
}

class SensorData extends DataClass implements Insertable<SensorData> {
  final int id;
  final DateTime date;
  final String ip;
  final double accelerationX;
  final double accelerationY;
  final double accelerationZ;
  const SensorData({
    required this.id,
    required this.date,
    required this.ip,
    required this.accelerationX,
    required this.accelerationY,
    required this.accelerationZ,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['ip'] = Variable<String>(ip);
    map['acceleration_x'] = Variable<double>(accelerationX);
    map['acceleration_y'] = Variable<double>(accelerationY);
    map['acceleration_z'] = Variable<double>(accelerationZ);
    return map;
  }

  SensorCompanion toCompanion(bool nullToAbsent) {
    return SensorCompanion(
      id: Value(id),
      date: Value(date),
      ip: Value(ip),
      accelerationX: Value(accelerationX),
      accelerationY: Value(accelerationY),
      accelerationZ: Value(accelerationZ),
    );
  }

  factory SensorData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      ip: serializer.fromJson<String>(json['ip']),
      accelerationX: serializer.fromJson<double>(json['accelerationX']),
      accelerationY: serializer.fromJson<double>(json['accelerationY']),
      accelerationZ: serializer.fromJson<double>(json['accelerationZ']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'ip': serializer.toJson<String>(ip),
      'accelerationX': serializer.toJson<double>(accelerationX),
      'accelerationY': serializer.toJson<double>(accelerationY),
      'accelerationZ': serializer.toJson<double>(accelerationZ),
    };
  }

  SensorData copyWith({
    int? id,
    DateTime? date,
    String? ip,
    double? accelerationX,
    double? accelerationY,
    double? accelerationZ,
  }) => SensorData(
    id: id ?? this.id,
    date: date ?? this.date,
    ip: ip ?? this.ip,
    accelerationX: accelerationX ?? this.accelerationX,
    accelerationY: accelerationY ?? this.accelerationY,
    accelerationZ: accelerationZ ?? this.accelerationZ,
  );
  SensorData copyWithCompanion(SensorCompanion data) {
    return SensorData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      ip: data.ip.present ? data.ip.value : this.ip,
      accelerationX:
          data.accelerationX.present
              ? data.accelerationX.value
              : this.accelerationX,
      accelerationY:
          data.accelerationY.present
              ? data.accelerationY.value
              : this.accelerationY,
      accelerationZ:
          data.accelerationZ.present
              ? data.accelerationZ.value
              : this.accelerationZ,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('ip: $ip, ')
          ..write('accelerationX: $accelerationX, ')
          ..write('accelerationY: $accelerationY, ')
          ..write('accelerationZ: $accelerationZ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, ip, accelerationX, accelerationY, accelerationZ);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorData &&
          other.id == this.id &&
          other.date == this.date &&
          other.ip == this.ip &&
          other.accelerationX == this.accelerationX &&
          other.accelerationY == this.accelerationY &&
          other.accelerationZ == this.accelerationZ);
}

class SensorCompanion extends UpdateCompanion<SensorData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> ip;
  final Value<double> accelerationX;
  final Value<double> accelerationY;
  final Value<double> accelerationZ;
  const SensorCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.ip = const Value.absent(),
    this.accelerationX = const Value.absent(),
    this.accelerationY = const Value.absent(),
    this.accelerationZ = const Value.absent(),
  });
  SensorCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String ip,
    required double accelerationX,
    required double accelerationY,
    required double accelerationZ,
  }) : date = Value(date),
       ip = Value(ip),
       accelerationX = Value(accelerationX),
       accelerationY = Value(accelerationY),
       accelerationZ = Value(accelerationZ);
  static Insertable<SensorData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? ip,
    Expression<double>? accelerationX,
    Expression<double>? accelerationY,
    Expression<double>? accelerationZ,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (ip != null) 'ip': ip,
      if (accelerationX != null) 'acceleration_x': accelerationX,
      if (accelerationY != null) 'acceleration_y': accelerationY,
      if (accelerationZ != null) 'acceleration_z': accelerationZ,
    });
  }

  SensorCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? ip,
    Value<double>? accelerationX,
    Value<double>? accelerationY,
    Value<double>? accelerationZ,
  }) {
    return SensorCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      ip: ip ?? this.ip,
      accelerationX: accelerationX ?? this.accelerationX,
      accelerationY: accelerationY ?? this.accelerationY,
      accelerationZ: accelerationZ ?? this.accelerationZ,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (accelerationX.present) {
      map['acceleration_x'] = Variable<double>(accelerationX.value);
    }
    if (accelerationY.present) {
      map['acceleration_y'] = Variable<double>(accelerationY.value);
    }
    if (accelerationZ.present) {
      map['acceleration_z'] = Variable<double>(accelerationZ.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('ip: $ip, ')
          ..write('accelerationX: $accelerationX, ')
          ..write('accelerationY: $accelerationY, ')
          ..write('accelerationZ: $accelerationZ')
          ..write(')'))
        .toString();
  }
}

class $NoteTable extends Note with TableInfo<$NoteTable, NoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      note:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}note'],
          )!,
    );
  }

  @override
  $NoteTable createAlias(String alias) {
    return $NoteTable(attachedDatabase, alias);
  }
}

class NoteData extends DataClass implements Insertable<NoteData> {
  final int id;
  final DateTime date;
  final String note;
  const NoteData({required this.id, required this.date, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['note'] = Variable<String>(note);
    return map;
  }

  NoteCompanion toCompanion(bool nullToAbsent) {
    return NoteCompanion(id: Value(id), date: Value(date), note: Value(note));
  }

  factory NoteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String>(note),
    };
  }

  NoteData copyWith({int? id, DateTime? date, String? note}) => NoteData(
    id: id ?? this.id,
    date: date ?? this.date,
    note: note ?? this.note,
  );
  NoteData copyWithCompanion(NoteCompanion data) {
    return NoteData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteData &&
          other.id == this.id &&
          other.date == this.date &&
          other.note == this.note);
}

class NoteCompanion extends UpdateCompanion<NoteData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> note;
  const NoteCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
  });
  NoteCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String note,
  }) : date = Value(date),
       note = Value(note);
  static Insertable<NoteData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
    });
  }

  NoteCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? note,
  }) {
    return NoteCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $IdentificationTable extends Identification
    with TableInfo<$IdentificationTable, IdentificationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentificationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
    'ip',
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
  @override
  List<GeneratedColumn> get $columns => [ip, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identification';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentificationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ip};
  @override
  IdentificationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentificationData(
      ip:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}ip'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
    );
  }

  @override
  $IdentificationTable createAlias(String alias) {
    return $IdentificationTable(attachedDatabase, alias);
  }
}

class IdentificationData extends DataClass
    implements Insertable<IdentificationData> {
  final String ip;
  final String name;
  const IdentificationData({required this.ip, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ip'] = Variable<String>(ip);
    map['name'] = Variable<String>(name);
    return map;
  }

  IdentificationCompanion toCompanion(bool nullToAbsent) {
    return IdentificationCompanion(ip: Value(ip), name: Value(name));
  }

  factory IdentificationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentificationData(
      ip: serializer.fromJson<String>(json['ip']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ip': serializer.toJson<String>(ip),
      'name': serializer.toJson<String>(name),
    };
  }

  IdentificationData copyWith({String? ip, String? name}) =>
      IdentificationData(ip: ip ?? this.ip, name: name ?? this.name);
  IdentificationData copyWithCompanion(IdentificationCompanion data) {
    return IdentificationData(
      ip: data.ip.present ? data.ip.value : this.ip,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentificationData(')
          ..write('ip: $ip, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ip, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentificationData &&
          other.ip == this.ip &&
          other.name == this.name);
}

class IdentificationCompanion extends UpdateCompanion<IdentificationData> {
  final Value<String> ip;
  final Value<String> name;
  final Value<int> rowid;
  const IdentificationCompanion({
    this.ip = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentificationCompanion.insert({
    required String ip,
    required String name,
    this.rowid = const Value.absent(),
  }) : ip = Value(ip),
       name = Value(name);
  static Insertable<IdentificationData> custom({
    Expression<String>? ip,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ip != null) 'ip': ip,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentificationCompanion copyWith({
    Value<String>? ip,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return IdentificationCompanion(
      ip: ip ?? this.ip,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentificationCompanion(')
          ..write('ip: $ip, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SensorTable sensor = $SensorTable(this);
  late final $NoteTable note = $NoteTable(this);
  late final $IdentificationTable identification = $IdentificationTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sensor,
    note,
    identification,
  ];
}

typedef $$SensorTableCreateCompanionBuilder =
    SensorCompanion Function({
      Value<int> id,
      required DateTime date,
      required String ip,
      required double accelerationX,
      required double accelerationY,
      required double accelerationZ,
    });
typedef $$SensorTableUpdateCompanionBuilder =
    SensorCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> ip,
      Value<double> accelerationX,
      Value<double> accelerationY,
      Value<double> accelerationZ,
    });

class $$SensorTableFilterComposer
    extends Composer<_$AppDatabase, $SensorTable> {
  $$SensorTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerationX => $composableBuilder(
    column: $table.accelerationX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerationY => $composableBuilder(
    column: $table.accelerationY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerationZ => $composableBuilder(
    column: $table.accelerationZ,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SensorTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorTable> {
  $$SensorTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerationX => $composableBuilder(
    column: $table.accelerationX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerationY => $composableBuilder(
    column: $table.accelerationY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerationZ => $composableBuilder(
    column: $table.accelerationZ,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SensorTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorTable> {
  $$SensorTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get ip =>
      $composableBuilder(column: $table.ip, builder: (column) => column);

  GeneratedColumn<double> get accelerationX => $composableBuilder(
    column: $table.accelerationX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerationY => $composableBuilder(
    column: $table.accelerationY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerationZ => $composableBuilder(
    column: $table.accelerationZ,
    builder: (column) => column,
  );
}

class $$SensorTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorTable,
          SensorData,
          $$SensorTableFilterComposer,
          $$SensorTableOrderingComposer,
          $$SensorTableAnnotationComposer,
          $$SensorTableCreateCompanionBuilder,
          $$SensorTableUpdateCompanionBuilder,
          (SensorData, BaseReferences<_$AppDatabase, $SensorTable, SensorData>),
          SensorData,
          PrefetchHooks Function()
        > {
  $$SensorTableTableManager(_$AppDatabase db, $SensorTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SensorTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SensorTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SensorTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> ip = const Value.absent(),
                Value<double> accelerationX = const Value.absent(),
                Value<double> accelerationY = const Value.absent(),
                Value<double> accelerationZ = const Value.absent(),
              }) => SensorCompanion(
                id: id,
                date: date,
                ip: ip,
                accelerationX: accelerationX,
                accelerationY: accelerationY,
                accelerationZ: accelerationZ,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String ip,
                required double accelerationX,
                required double accelerationY,
                required double accelerationZ,
              }) => SensorCompanion.insert(
                id: id,
                date: date,
                ip: ip,
                accelerationX: accelerationX,
                accelerationY: accelerationY,
                accelerationZ: accelerationZ,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SensorTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorTable,
      SensorData,
      $$SensorTableFilterComposer,
      $$SensorTableOrderingComposer,
      $$SensorTableAnnotationComposer,
      $$SensorTableCreateCompanionBuilder,
      $$SensorTableUpdateCompanionBuilder,
      (SensorData, BaseReferences<_$AppDatabase, $SensorTable, SensorData>),
      SensorData,
      PrefetchHooks Function()
    >;
typedef $$NoteTableCreateCompanionBuilder =
    NoteCompanion Function({
      Value<int> id,
      required DateTime date,
      required String note,
    });
typedef $$NoteTableUpdateCompanionBuilder =
    NoteCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> note,
    });

class $$NoteTableFilterComposer extends Composer<_$AppDatabase, $NoteTable> {
  $$NoteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteTableOrderingComposer extends Composer<_$AppDatabase, $NoteTable> {
  $$NoteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTable> {
  $$NoteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$NoteTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTable,
          NoteData,
          $$NoteTableFilterComposer,
          $$NoteTableOrderingComposer,
          $$NoteTableAnnotationComposer,
          $$NoteTableCreateCompanionBuilder,
          $$NoteTableUpdateCompanionBuilder,
          (NoteData, BaseReferences<_$AppDatabase, $NoteTable, NoteData>),
          NoteData,
          PrefetchHooks Function()
        > {
  $$NoteTableTableManager(_$AppDatabase db, $NoteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NoteTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$NoteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$NoteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => NoteCompanion(id: id, date: date, note: note),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String note,
              }) => NoteCompanion.insert(id: id, date: date, note: note),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTable,
      NoteData,
      $$NoteTableFilterComposer,
      $$NoteTableOrderingComposer,
      $$NoteTableAnnotationComposer,
      $$NoteTableCreateCompanionBuilder,
      $$NoteTableUpdateCompanionBuilder,
      (NoteData, BaseReferences<_$AppDatabase, $NoteTable, NoteData>),
      NoteData,
      PrefetchHooks Function()
    >;
typedef $$IdentificationTableCreateCompanionBuilder =
    IdentificationCompanion Function({
      required String ip,
      required String name,
      Value<int> rowid,
    });
typedef $$IdentificationTableUpdateCompanionBuilder =
    IdentificationCompanion Function({
      Value<String> ip,
      Value<String> name,
      Value<int> rowid,
    });

class $$IdentificationTableFilterComposer
    extends Composer<_$AppDatabase, $IdentificationTable> {
  $$IdentificationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdentificationTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentificationTable> {
  $$IdentificationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdentificationTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentificationTable> {
  $$IdentificationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ip =>
      $composableBuilder(column: $table.ip, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$IdentificationTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdentificationTable,
          IdentificationData,
          $$IdentificationTableFilterComposer,
          $$IdentificationTableOrderingComposer,
          $$IdentificationTableAnnotationComposer,
          $$IdentificationTableCreateCompanionBuilder,
          $$IdentificationTableUpdateCompanionBuilder,
          (
            IdentificationData,
            BaseReferences<
              _$AppDatabase,
              $IdentificationTable,
              IdentificationData
            >,
          ),
          IdentificationData,
          PrefetchHooks Function()
        > {
  $$IdentificationTableTableManager(
    _$AppDatabase db,
    $IdentificationTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$IdentificationTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$IdentificationTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$IdentificationTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ip = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentificationCompanion(ip: ip, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String ip,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => IdentificationCompanion.insert(
                ip: ip,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdentificationTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdentificationTable,
      IdentificationData,
      $$IdentificationTableFilterComposer,
      $$IdentificationTableOrderingComposer,
      $$IdentificationTableAnnotationComposer,
      $$IdentificationTableCreateCompanionBuilder,
      $$IdentificationTableUpdateCompanionBuilder,
      (
        IdentificationData,
        BaseReferences<_$AppDatabase, $IdentificationTable, IdentificationData>,
      ),
      IdentificationData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SensorTableTableManager get sensor =>
      $$SensorTableTableManager(_db, _db.sensor);
  $$NoteTableTableManager get note => $$NoteTableTableManager(_db, _db.note);
  $$IdentificationTableTableManager get identification =>
      $$IdentificationTableTableManager(_db, _db.identification);
}
