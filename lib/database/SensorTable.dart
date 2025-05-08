import 'package:drift/drift.dart';

class Sensor extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get ip => text()();
  //TextColumn get sensorName => text()();
  RealColumn get accelerationX => real().nullable()();
  RealColumn get accelerationY => real().nullable()();
  RealColumn get accelerationZ => real().nullable()();
  RealColumn get gyroskopX => real().nullable()();
  RealColumn get gyroskopY => real().nullable()();
  RealColumn get gyroskopZ => real().nullable()();
  RealColumn get magnetometerX => real().nullable()();
  RealColumn get magnetometerY => real().nullable()();
  RealColumn get magnetometerZ => real().nullable()();
  RealColumn get barometer => real().nullable()();
}
