import 'package:drift/drift.dart';

class Sensor extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get ip => text()();
  //TextColumn get sensorName => text()();
  RealColumn get accelerationX => real()();
  RealColumn get accelerationY => real()();
  RealColumn get accelerationZ => real()();
}
