import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sensorvisualization/database/MetadataTable.dart';
import 'package:sensorvisualization/database/SensorTable.dart';
import 'package:sensorvisualization/database/NoteTable.dart';
import 'package:sensorvisualization/database/IdentificationTable.dart';

part 'AppDatabase.g.dart';

@DriftDatabase(tables: [Sensor, Note, Identification, Metadata])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print('Erstelle Datenbank-Tabellen...');
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
