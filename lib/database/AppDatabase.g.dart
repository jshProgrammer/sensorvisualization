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
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelerationYMeta = const VerificationMeta(
    'accelerationY',
  );
  @override
  late final GeneratedColumn<double> accelerationY = GeneratedColumn<double>(
    'acceleration_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelerationZMeta = const VerificationMeta(
    'accelerationZ',
  );
  @override
  late final GeneratedColumn<double> accelerationZ = GeneratedColumn<double>(
    'acceleration_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroskopXMeta = const VerificationMeta(
    'gyroskopX',
  );
  @override
  late final GeneratedColumn<double> gyroskopX = GeneratedColumn<double>(
    'gyroskop_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroskopYMeta = const VerificationMeta(
    'gyroskopY',
  );
  @override
  late final GeneratedColumn<double> gyroskopY = GeneratedColumn<double>(
    'gyroskop_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroskopZMeta = const VerificationMeta(
    'gyroskopZ',
  );
  @override
  late final GeneratedColumn<double> gyroskopZ = GeneratedColumn<double>(
    'gyroskop_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magnetometerXMeta = const VerificationMeta(
    'magnetometerX',
  );
  @override
  late final GeneratedColumn<double> magnetometerX = GeneratedColumn<double>(
    'magnetometer_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magnetometerYMeta = const VerificationMeta(
    'magnetometerY',
  );
  @override
  late final GeneratedColumn<double> magnetometerY = GeneratedColumn<double>(
    'magnetometer_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magnetometerZMeta = const VerificationMeta(
    'magnetometerZ',
  );
  @override
  late final GeneratedColumn<double> magnetometerZ = GeneratedColumn<double>(
    'magnetometer_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barometerMeta = const VerificationMeta(
    'barometer',
  );
  @override
  late final GeneratedColumn<double> barometer = GeneratedColumn<double>(
    'barometer',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    ip,
    accelerationX,
    accelerationY,
    accelerationZ,
    gyroskopX,
    gyroskopY,
    gyroskopZ,
    magnetometerX,
    magnetometerY,
    magnetometerZ,
    barometer,
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
    }
    if (data.containsKey('acceleration_y')) {
      context.handle(
        _accelerationYMeta,
        accelerationY.isAcceptableOrUnknown(
          data['acceleration_y']!,
          _accelerationYMeta,
        ),
      );
    }
    if (data.containsKey('acceleration_z')) {
      context.handle(
        _accelerationZMeta,
        accelerationZ.isAcceptableOrUnknown(
          data['acceleration_z']!,
          _accelerationZMeta,
        ),
      );
    }
    if (data.containsKey('gyroskop_x')) {
      context.handle(
        _gyroskopXMeta,
        gyroskopX.isAcceptableOrUnknown(data['gyroskop_x']!, _gyroskopXMeta),
      );
    }
    if (data.containsKey('gyroskop_y')) {
      context.handle(
        _gyroskopYMeta,
        gyroskopY.isAcceptableOrUnknown(data['gyroskop_y']!, _gyroskopYMeta),
      );
    }
    if (data.containsKey('gyroskop_z')) {
      context.handle(
        _gyroskopZMeta,
        gyroskopZ.isAcceptableOrUnknown(data['gyroskop_z']!, _gyroskopZMeta),
      );
    }
    if (data.containsKey('magnetometer_x')) {
      context.handle(
        _magnetometerXMeta,
        magnetometerX.isAcceptableOrUnknown(
          data['magnetometer_x']!,
          _magnetometerXMeta,
        ),
      );
    }
    if (data.containsKey('magnetometer_y')) {
      context.handle(
        _magnetometerYMeta,
        magnetometerY.isAcceptableOrUnknown(
          data['magnetometer_y']!,
          _magnetometerYMeta,
        ),
      );
    }
    if (data.containsKey('magnetometer_z')) {
      context.handle(
        _magnetometerZMeta,
        magnetometerZ.isAcceptableOrUnknown(
          data['magnetometer_z']!,
          _magnetometerZMeta,
        ),
      );
    }
    if (data.containsKey('barometer')) {
      context.handle(
        _barometerMeta,
        barometer.isAcceptableOrUnknown(data['barometer']!, _barometerMeta),
      );
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
      accelerationX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acceleration_x'],
      ),
      accelerationY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acceleration_y'],
      ),
      accelerationZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acceleration_z'],
      ),
      gyroskopX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroskop_x'],
      ),
      gyroskopY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroskop_y'],
      ),
      gyroskopZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroskop_z'],
      ),
      magnetometerX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnetometer_x'],
      ),
      magnetometerY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnetometer_y'],
      ),
      magnetometerZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnetometer_z'],
      ),
      barometer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}barometer'],
      ),
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
  final double? accelerationX;
  final double? accelerationY;
  final double? accelerationZ;
  final double? gyroskopX;
  final double? gyroskopY;
  final double? gyroskopZ;
  final double? magnetometerX;
  final double? magnetometerY;
  final double? magnetometerZ;
  final double? barometer;
  const SensorData({
    required this.id,
    required this.date,
    required this.ip,
    this.accelerationX,
    this.accelerationY,
    this.accelerationZ,
    this.gyroskopX,
    this.gyroskopY,
    this.gyroskopZ,
    this.magnetometerX,
    this.magnetometerY,
    this.magnetometerZ,
    this.barometer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['ip'] = Variable<String>(ip);
    if (!nullToAbsent || accelerationX != null) {
      map['acceleration_x'] = Variable<double>(accelerationX);
    }
    if (!nullToAbsent || accelerationY != null) {
      map['acceleration_y'] = Variable<double>(accelerationY);
    }
    if (!nullToAbsent || accelerationZ != null) {
      map['acceleration_z'] = Variable<double>(accelerationZ);
    }
    if (!nullToAbsent || gyroskopX != null) {
      map['gyroskop_x'] = Variable<double>(gyroskopX);
    }
    if (!nullToAbsent || gyroskopY != null) {
      map['gyroskop_y'] = Variable<double>(gyroskopY);
    }
    if (!nullToAbsent || gyroskopZ != null) {
      map['gyroskop_z'] = Variable<double>(gyroskopZ);
    }
    if (!nullToAbsent || magnetometerX != null) {
      map['magnetometer_x'] = Variable<double>(magnetometerX);
    }
    if (!nullToAbsent || magnetometerY != null) {
      map['magnetometer_y'] = Variable<double>(magnetometerY);
    }
    if (!nullToAbsent || magnetometerZ != null) {
      map['magnetometer_z'] = Variable<double>(magnetometerZ);
    }
    if (!nullToAbsent || barometer != null) {
      map['barometer'] = Variable<double>(barometer);
    }
    return map;
  }

  SensorCompanion toCompanion(bool nullToAbsent) {
    return SensorCompanion(
      id: Value(id),
      date: Value(date),
      ip: Value(ip),
      accelerationX:
          accelerationX == null && nullToAbsent
              ? const Value.absent()
              : Value(accelerationX),
      accelerationY:
          accelerationY == null && nullToAbsent
              ? const Value.absent()
              : Value(accelerationY),
      accelerationZ:
          accelerationZ == null && nullToAbsent
              ? const Value.absent()
              : Value(accelerationZ),
      gyroskopX:
          gyroskopX == null && nullToAbsent
              ? const Value.absent()
              : Value(gyroskopX),
      gyroskopY:
          gyroskopY == null && nullToAbsent
              ? const Value.absent()
              : Value(gyroskopY),
      gyroskopZ:
          gyroskopZ == null && nullToAbsent
              ? const Value.absent()
              : Value(gyroskopZ),
      magnetometerX:
          magnetometerX == null && nullToAbsent
              ? const Value.absent()
              : Value(magnetometerX),
      magnetometerY:
          magnetometerY == null && nullToAbsent
              ? const Value.absent()
              : Value(magnetometerY),
      magnetometerZ:
          magnetometerZ == null && nullToAbsent
              ? const Value.absent()
              : Value(magnetometerZ),
      barometer:
          barometer == null && nullToAbsent
              ? const Value.absent()
              : Value(barometer),
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
      accelerationX: serializer.fromJson<double?>(json['accelerationX']),
      accelerationY: serializer.fromJson<double?>(json['accelerationY']),
      accelerationZ: serializer.fromJson<double?>(json['accelerationZ']),
      gyroskopX: serializer.fromJson<double?>(json['gyroskopX']),
      gyroskopY: serializer.fromJson<double?>(json['gyroskopY']),
      gyroskopZ: serializer.fromJson<double?>(json['gyroskopZ']),
      magnetometerX: serializer.fromJson<double?>(json['magnetometerX']),
      magnetometerY: serializer.fromJson<double?>(json['magnetometerY']),
      magnetometerZ: serializer.fromJson<double?>(json['magnetometerZ']),
      barometer: serializer.fromJson<double?>(json['barometer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'ip': serializer.toJson<String>(ip),
      'accelerationX': serializer.toJson<double?>(accelerationX),
      'accelerationY': serializer.toJson<double?>(accelerationY),
      'accelerationZ': serializer.toJson<double?>(accelerationZ),
      'gyroskopX': serializer.toJson<double?>(gyroskopX),
      'gyroskopY': serializer.toJson<double?>(gyroskopY),
      'gyroskopZ': serializer.toJson<double?>(gyroskopZ),
      'magnetometerX': serializer.toJson<double?>(magnetometerX),
      'magnetometerY': serializer.toJson<double?>(magnetometerY),
      'magnetometerZ': serializer.toJson<double?>(magnetometerZ),
      'barometer': serializer.toJson<double?>(barometer),
    };
  }

  SensorData copyWith({
    int? id,
    DateTime? date,
    String? ip,
    Value<double?> accelerationX = const Value.absent(),
    Value<double?> accelerationY = const Value.absent(),
    Value<double?> accelerationZ = const Value.absent(),
    Value<double?> gyroskopX = const Value.absent(),
    Value<double?> gyroskopY = const Value.absent(),
    Value<double?> gyroskopZ = const Value.absent(),
    Value<double?> magnetometerX = const Value.absent(),
    Value<double?> magnetometerY = const Value.absent(),
    Value<double?> magnetometerZ = const Value.absent(),
    Value<double?> barometer = const Value.absent(),
  }) => SensorData(
    id: id ?? this.id,
    date: date ?? this.date,
    ip: ip ?? this.ip,
    accelerationX:
        accelerationX.present ? accelerationX.value : this.accelerationX,
    accelerationY:
        accelerationY.present ? accelerationY.value : this.accelerationY,
    accelerationZ:
        accelerationZ.present ? accelerationZ.value : this.accelerationZ,
    gyroskopX: gyroskopX.present ? gyroskopX.value : this.gyroskopX,
    gyroskopY: gyroskopY.present ? gyroskopY.value : this.gyroskopY,
    gyroskopZ: gyroskopZ.present ? gyroskopZ.value : this.gyroskopZ,
    magnetometerX:
        magnetometerX.present ? magnetometerX.value : this.magnetometerX,
    magnetometerY:
        magnetometerY.present ? magnetometerY.value : this.magnetometerY,
    magnetometerZ:
        magnetometerZ.present ? magnetometerZ.value : this.magnetometerZ,
    barometer: barometer.present ? barometer.value : this.barometer,
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
      gyroskopX: data.gyroskopX.present ? data.gyroskopX.value : this.gyroskopX,
      gyroskopY: data.gyroskopY.present ? data.gyroskopY.value : this.gyroskopY,
      gyroskopZ: data.gyroskopZ.present ? data.gyroskopZ.value : this.gyroskopZ,
      magnetometerX:
          data.magnetometerX.present
              ? data.magnetometerX.value
              : this.magnetometerX,
      magnetometerY:
          data.magnetometerY.present
              ? data.magnetometerY.value
              : this.magnetometerY,
      magnetometerZ:
          data.magnetometerZ.present
              ? data.magnetometerZ.value
              : this.magnetometerZ,
      barometer: data.barometer.present ? data.barometer.value : this.barometer,
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
          ..write('accelerationZ: $accelerationZ, ')
          ..write('gyroskopX: $gyroskopX, ')
          ..write('gyroskopY: $gyroskopY, ')
          ..write('gyroskopZ: $gyroskopZ, ')
          ..write('magnetometerX: $magnetometerX, ')
          ..write('magnetometerY: $magnetometerY, ')
          ..write('magnetometerZ: $magnetometerZ, ')
          ..write('barometer: $barometer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    ip,
    accelerationX,
    accelerationY,
    accelerationZ,
    gyroskopX,
    gyroskopY,
    gyroskopZ,
    magnetometerX,
    magnetometerY,
    magnetometerZ,
    barometer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorData &&
          other.id == this.id &&
          other.date == this.date &&
          other.ip == this.ip &&
          other.accelerationX == this.accelerationX &&
          other.accelerationY == this.accelerationY &&
          other.accelerationZ == this.accelerationZ &&
          other.gyroskopX == this.gyroskopX &&
          other.gyroskopY == this.gyroskopY &&
          other.gyroskopZ == this.gyroskopZ &&
          other.magnetometerX == this.magnetometerX &&
          other.magnetometerY == this.magnetometerY &&
          other.magnetometerZ == this.magnetometerZ &&
          other.barometer == this.barometer);
}

class SensorCompanion extends UpdateCompanion<SensorData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> ip;
  final Value<double?> accelerationX;
  final Value<double?> accelerationY;
  final Value<double?> accelerationZ;
  final Value<double?> gyroskopX;
  final Value<double?> gyroskopY;
  final Value<double?> gyroskopZ;
  final Value<double?> magnetometerX;
  final Value<double?> magnetometerY;
  final Value<double?> magnetometerZ;
  final Value<double?> barometer;
  const SensorCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.ip = const Value.absent(),
    this.accelerationX = const Value.absent(),
    this.accelerationY = const Value.absent(),
    this.accelerationZ = const Value.absent(),
    this.gyroskopX = const Value.absent(),
    this.gyroskopY = const Value.absent(),
    this.gyroskopZ = const Value.absent(),
    this.magnetometerX = const Value.absent(),
    this.magnetometerY = const Value.absent(),
    this.magnetometerZ = const Value.absent(),
    this.barometer = const Value.absent(),
  });
  SensorCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String ip,
    this.accelerationX = const Value.absent(),
    this.accelerationY = const Value.absent(),
    this.accelerationZ = const Value.absent(),
    this.gyroskopX = const Value.absent(),
    this.gyroskopY = const Value.absent(),
    this.gyroskopZ = const Value.absent(),
    this.magnetometerX = const Value.absent(),
    this.magnetometerY = const Value.absent(),
    this.magnetometerZ = const Value.absent(),
    this.barometer = const Value.absent(),
  }) : date = Value(date),
       ip = Value(ip);
  static Insertable<SensorData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? ip,
    Expression<double>? accelerationX,
    Expression<double>? accelerationY,
    Expression<double>? accelerationZ,
    Expression<double>? gyroskopX,
    Expression<double>? gyroskopY,
    Expression<double>? gyroskopZ,
    Expression<double>? magnetometerX,
    Expression<double>? magnetometerY,
    Expression<double>? magnetometerZ,
    Expression<double>? barometer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (ip != null) 'ip': ip,
      if (accelerationX != null) 'acceleration_x': accelerationX,
      if (accelerationY != null) 'acceleration_y': accelerationY,
      if (accelerationZ != null) 'acceleration_z': accelerationZ,
      if (gyroskopX != null) 'gyroskop_x': gyroskopX,
      if (gyroskopY != null) 'gyroskop_y': gyroskopY,
      if (gyroskopZ != null) 'gyroskop_z': gyroskopZ,
      if (magnetometerX != null) 'magnetometer_x': magnetometerX,
      if (magnetometerY != null) 'magnetometer_y': magnetometerY,
      if (magnetometerZ != null) 'magnetometer_z': magnetometerZ,
      if (barometer != null) 'barometer': barometer,
    });
  }

  SensorCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? ip,
    Value<double?>? accelerationX,
    Value<double?>? accelerationY,
    Value<double?>? accelerationZ,
    Value<double?>? gyroskopX,
    Value<double?>? gyroskopY,
    Value<double?>? gyroskopZ,
    Value<double?>? magnetometerX,
    Value<double?>? magnetometerY,
    Value<double?>? magnetometerZ,
    Value<double?>? barometer,
  }) {
    return SensorCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      ip: ip ?? this.ip,
      accelerationX: accelerationX ?? this.accelerationX,
      accelerationY: accelerationY ?? this.accelerationY,
      accelerationZ: accelerationZ ?? this.accelerationZ,
      gyroskopX: gyroskopX ?? this.gyroskopX,
      gyroskopY: gyroskopY ?? this.gyroskopY,
      gyroskopZ: gyroskopZ ?? this.gyroskopZ,
      magnetometerX: magnetometerX ?? this.magnetometerX,
      magnetometerY: magnetometerY ?? this.magnetometerY,
      magnetometerZ: magnetometerZ ?? this.magnetometerZ,
      barometer: barometer ?? this.barometer,
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
    if (gyroskopX.present) {
      map['gyroskop_x'] = Variable<double>(gyroskopX.value);
    }
    if (gyroskopY.present) {
      map['gyroskop_y'] = Variable<double>(gyroskopY.value);
    }
    if (gyroskopZ.present) {
      map['gyroskop_z'] = Variable<double>(gyroskopZ.value);
    }
    if (magnetometerX.present) {
      map['magnetometer_x'] = Variable<double>(magnetometerX.value);
    }
    if (magnetometerY.present) {
      map['magnetometer_y'] = Variable<double>(magnetometerY.value);
    }
    if (magnetometerZ.present) {
      map['magnetometer_z'] = Variable<double>(magnetometerZ.value);
    }
    if (barometer.present) {
      map['barometer'] = Variable<double>(barometer.value);
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
          ..write('accelerationZ: $accelerationZ, ')
          ..write('gyroskopX: $gyroskopX, ')
          ..write('gyroskopY: $gyroskopY, ')
          ..write('gyroskopZ: $gyroskopZ, ')
          ..write('magnetometerX: $magnetometerX, ')
          ..write('magnetometerY: $magnetometerY, ')
          ..write('magnetometerZ: $magnetometerZ, ')
          ..write('barometer: $barometer')
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

class $MetadataTable extends Metadata
    with TableInfo<$MetadataTable, MetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataData(
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $MetadataTable createAlias(String alias) {
    return $MetadataTable(attachedDatabase, alias);
  }
}

class MetadataData extends DataClass implements Insertable<MetadataData> {
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MetadataData({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MetadataCompanion toCompanion(bool nullToAbsent) {
    return MetadataCompanion(
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataData(
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MetadataData copyWith({
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MetadataData(
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MetadataData copyWithCompanion(MetadataCompanion data) {
    return MetadataData(
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataData(')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataData &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MetadataCompanion extends UpdateCompanion<MetadataData> {
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MetadataCompanion({
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataCompanion.insert({
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MetadataData> custom({
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataCompanion copyWith({
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MetadataCompanion(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataCompanion(')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $MetadataTable metadata = $MetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sensor,
    note,
    identification,
    metadata,
  ];
}

typedef $$SensorTableCreateCompanionBuilder =
    SensorCompanion Function({
      Value<int> id,
      required DateTime date,
      required String ip,
      Value<double?> accelerationX,
      Value<double?> accelerationY,
      Value<double?> accelerationZ,
      Value<double?> gyroskopX,
      Value<double?> gyroskopY,
      Value<double?> gyroskopZ,
      Value<double?> magnetometerX,
      Value<double?> magnetometerY,
      Value<double?> magnetometerZ,
      Value<double?> barometer,
    });
typedef $$SensorTableUpdateCompanionBuilder =
    SensorCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> ip,
      Value<double?> accelerationX,
      Value<double?> accelerationY,
      Value<double?> accelerationZ,
      Value<double?> gyroskopX,
      Value<double?> gyroskopY,
      Value<double?> gyroskopZ,
      Value<double?> magnetometerX,
      Value<double?> magnetometerY,
      Value<double?> magnetometerZ,
      Value<double?> barometer,
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

  ColumnFilters<double> get gyroskopX => $composableBuilder(
    column: $table.gyroskopX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroskopY => $composableBuilder(
    column: $table.gyroskopY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroskopZ => $composableBuilder(
    column: $table.gyroskopZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnetometerX => $composableBuilder(
    column: $table.magnetometerX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnetometerY => $composableBuilder(
    column: $table.magnetometerY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnetometerZ => $composableBuilder(
    column: $table.magnetometerZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get barometer => $composableBuilder(
    column: $table.barometer,
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

  ColumnOrderings<double> get gyroskopX => $composableBuilder(
    column: $table.gyroskopX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroskopY => $composableBuilder(
    column: $table.gyroskopY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroskopZ => $composableBuilder(
    column: $table.gyroskopZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnetometerX => $composableBuilder(
    column: $table.magnetometerX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnetometerY => $composableBuilder(
    column: $table.magnetometerY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnetometerZ => $composableBuilder(
    column: $table.magnetometerZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get barometer => $composableBuilder(
    column: $table.barometer,
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

  GeneratedColumn<double> get gyroskopX =>
      $composableBuilder(column: $table.gyroskopX, builder: (column) => column);

  GeneratedColumn<double> get gyroskopY =>
      $composableBuilder(column: $table.gyroskopY, builder: (column) => column);

  GeneratedColumn<double> get gyroskopZ =>
      $composableBuilder(column: $table.gyroskopZ, builder: (column) => column);

  GeneratedColumn<double> get magnetometerX => $composableBuilder(
    column: $table.magnetometerX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get magnetometerY => $composableBuilder(
    column: $table.magnetometerY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get magnetometerZ => $composableBuilder(
    column: $table.magnetometerZ,
    builder: (column) => column,
  );

  GeneratedColumn<double> get barometer =>
      $composableBuilder(column: $table.barometer, builder: (column) => column);
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
                Value<double?> accelerationX = const Value.absent(),
                Value<double?> accelerationY = const Value.absent(),
                Value<double?> accelerationZ = const Value.absent(),
                Value<double?> gyroskopX = const Value.absent(),
                Value<double?> gyroskopY = const Value.absent(),
                Value<double?> gyroskopZ = const Value.absent(),
                Value<double?> magnetometerX = const Value.absent(),
                Value<double?> magnetometerY = const Value.absent(),
                Value<double?> magnetometerZ = const Value.absent(),
                Value<double?> barometer = const Value.absent(),
              }) => SensorCompanion(
                id: id,
                date: date,
                ip: ip,
                accelerationX: accelerationX,
                accelerationY: accelerationY,
                accelerationZ: accelerationZ,
                gyroskopX: gyroskopX,
                gyroskopY: gyroskopY,
                gyroskopZ: gyroskopZ,
                magnetometerX: magnetometerX,
                magnetometerY: magnetometerY,
                magnetometerZ: magnetometerZ,
                barometer: barometer,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String ip,
                Value<double?> accelerationX = const Value.absent(),
                Value<double?> accelerationY = const Value.absent(),
                Value<double?> accelerationZ = const Value.absent(),
                Value<double?> gyroskopX = const Value.absent(),
                Value<double?> gyroskopY = const Value.absent(),
                Value<double?> gyroskopZ = const Value.absent(),
                Value<double?> magnetometerX = const Value.absent(),
                Value<double?> magnetometerY = const Value.absent(),
                Value<double?> magnetometerZ = const Value.absent(),
                Value<double?> barometer = const Value.absent(),
              }) => SensorCompanion.insert(
                id: id,
                date: date,
                ip: ip,
                accelerationX: accelerationX,
                accelerationY: accelerationY,
                accelerationZ: accelerationZ,
                gyroskopX: gyroskopX,
                gyroskopY: gyroskopY,
                gyroskopZ: gyroskopZ,
                magnetometerX: magnetometerX,
                magnetometerY: magnetometerY,
                magnetometerZ: magnetometerZ,
                barometer: barometer,
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
typedef $$MetadataTableCreateCompanionBuilder =
    MetadataCompanion Function({
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MetadataTableUpdateCompanionBuilder =
    MetadataCompanion Function({
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MetadataTableFilterComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetadataTable,
          MetadataData,
          $$MetadataTableFilterComposer,
          $$MetadataTableOrderingComposer,
          $$MetadataTableAnnotationComposer,
          $$MetadataTableCreateCompanionBuilder,
          $$MetadataTableUpdateCompanionBuilder,
          (
            MetadataData,
            BaseReferences<_$AppDatabase, $MetadataTable, MetadataData>,
          ),
          MetadataData,
          PrefetchHooks Function()
        > {
  $$MetadataTableTableManager(_$AppDatabase db, $MetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataCompanion(
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MetadataCompanion.insert(
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
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

typedef $$MetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetadataTable,
      MetadataData,
      $$MetadataTableFilterComposer,
      $$MetadataTableOrderingComposer,
      $$MetadataTableAnnotationComposer,
      $$MetadataTableCreateCompanionBuilder,
      $$MetadataTableUpdateCompanionBuilder,
      (
        MetadataData,
        BaseReferences<_$AppDatabase, $MetadataTable, MetadataData>,
      ),
      MetadataData,
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
  $$MetadataTableTableManager get metadata =>
      $$MetadataTableTableManager(_db, _db.metadata);
}
