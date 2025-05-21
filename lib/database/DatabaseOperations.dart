import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Databaseoperations {
  final AppDatabase _db;
  final firebassync = Firebasesync();

  Databaseoperations(this._db);

  //Insert Methods

  Future<void> insertSensorData(SensorCompanion sensor) async {
    try {
      await _db.into(_db.sensor).insert(sensor);
    } catch (e) {
      print("Fehler beim Einfügen der Sensordaten: $e");
    }
  }

  Future<void> insertNoteData(NoteCompanion note) async {
    try {
      await _db.into(_db.note).insert(note);
    } catch (e) {
      print("Fehler beim Einfügen der Notizdaten: $e");
    }
  }

  Future<void> insertIdentificationData(
    IdentificationCompanion identification,
  ) async {
    try {
      await _db.into(_db.identification).insert(identification);
    } catch (e) {
      print("Fehler beim Einfügen der Identifikationsdaten: $e");
    }
  }

  Future<void> insertMetadata(MetadataCompanion metadata) async {
    try {
      print('Versuche Metadata einzufügen...');
      await _db.into(_db.metadata).insert(metadata);
      print('Metadata erfolgreich eingefügt: ${metadata.toString()}');

      await firebassync.syncToFirestore(metadata);
    } catch (e) {
      print('Fehler beim Einfügen von Metadata: $e');
      rethrow;
    }
  }

  //Update Methods
  Future<void> updateMetadata(String tableName, DateTime createdAt) async {
    try {
      print('Versuche Metadata zu aktualisieren...');
      final updatedAt = DateTime.now();

      await _db
          .update(_db.metadata)
          .replace(
            MetadataCompanion(
              updatedAt: Value(updatedAt),
              createdAt: Value(createdAt),
              name: Value(tableName),
            ),
          );

      print('Metadata erfolgreich aktualisiert');

      await firebassync.syncToFirestore(
        MetadataCompanion(
          updatedAt: Value(updatedAt),
          createdAt: Value(createdAt),
          name: Value(tableName),
        ),
      );
    } catch (e) {
      print('Fehler beim Aktualisieren von Metadata: $e');
      rethrow;
    }
  }

  //Read Method
  Future<List<Map<String, dynamic>>> readTableData(String tableName) async {
    final result = await _db.customSelect('SELECT * FROM $tableName').get();

    return result.map((row) => row.data).toList();
  }

  Future<List<String>> getCreateDates() async {
    try {
      await ensureMetadataTable();

      final result =
          await _db.customSelect('''
      SELECT DISTINCT createdAt 
      FROM metadata 
      ORDER BY createdAt DESC
    ''').get();

      return result.map((row) => row.data['createdAt'] as String).toList();
    } catch (e) {
      print('Fehler bei getCreateDates: $e');
      return [];
    }
  }

  Future<void> ensureMetadataTable() async {
    try {
      await debugCheckTables();

      await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt DATETIME NOT NULL,
        updatedAt DATETIME NOT NULL
      )
    ''');

      final check =
          await _db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='metadata'",
              )
              .get();

      if (check.isEmpty) {
        print('Fehler: Metadata-Tabelle konnte nicht erstellt werden');
      } else {
        print('Metadata-Tabelle erfolgreich erstellt/gefunden');
      }
    } catch (e) {
      print('Fehler bei ensureMetadataTable: $e');
      rethrow;
    }
  }

  Future<void> debugCheckTables() async {
    final result =
        await _db
            .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
            .get();

    print('Vorhandene Tabellen:');
    for (var row in result) {
      print('- ${row.data['name']}');
    }
  }

  //Delete Methods
  Future<void> deleteSensorData() async {
    await _db.delete(_db.sensor).go();
  }

  Future<void> deleteNoteData() async {
    await _db.delete(_db.note).go();
  }

  Future<void> deleteIdentificationData() async {
    await _db.delete(_db.identification).go();
  }

  Future<void> deleteMetadataEntry(String tableName, DateTime createdAt) async {
    await _db.customStatement(
      'DELETE FROM metadata WHERE name = ? AND createdAt = ?',
      [tableName, createdAt.toIso8601String()],
    );
  }

  Future<String> exportToCSV(
    List<List<dynamic>> csvData,
    String fileName,
  ) async {
    try {
      // CSV-Daten in String umwandeln
      String csvContent = const ListToCsvConverter().convert(csvData);

      // Speicherort ermitteln
      final outputDir = await getApplicationDocumentsDirectory();
      final outputFile = File("${outputDir.path}/$fileName");

      // CSV-Datei speichern
      await outputFile.writeAsString(csvContent);

      print("CSV gespeichert: ${outputFile.path}");
      return outputFile.path;
    } catch (e) {
      print("Fehler beim Exportieren der CSV-Datei: $e");
      return "Fehler";
    }
  }

  Future<String> exportSensorDataCSV(BuildContext? context) async {
    final data = await _db.select(_db.sensor).get();

    List<List<dynamic>> csvData = [
      [
        'id',
        'date',
        'ip',
        'accelerationX',
        'accelerationY',
        'accelerationZ',
        'gyroskopX',
        'gyroskopY',
        'gyroskopZ',
        'magnetometerX',
        'magnetometerY',
        'magnetometerZ',
        'barometer',
      ],
      ...data.map(
        (row) => [
          row.id,
          row.date.toIso8601String(),
          row.ip,
          row.accelerationX,
          row.accelerationY,
          row.accelerationZ,
          row.gyroskopX,
          row.gyroskopY,
          row.gyroskopZ,
          row.magnetometerX,
          row.magnetometerY,
          row.magnetometerZ,
          row.barometer,
        ],
      ),
    ];

    return exportToCSV(csvData, 'sensor_export.csv');
  }

  Future<String> exportNoteDataCSV(BuildContext? context) async {
    final data = await _db.select(_db.note).get();

    List<List<dynamic>> csvData = [
      ['id', 'date', 'note'],
      ...data.map((row) => [row.id, row.date.toIso8601String(), row.note]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    return exportToCSV(csvData, 'note_export.csv');
  }

  Future<String> exportIdentificationDataCSV(BuildContext? context) async {
    final data = await _db.select(_db.identification).get();

    List<List<dynamic>> csvData = [
      ['ip', 'name'],
      ...data.map((row) => [row.ip, row.name]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    return exportToCSV(csvData, 'identification_export.csv');
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    return await _db
        .customSelect('SELECT * FROM $tableName')
        .get()
        .then((rows) => rows.map((row) => row.data).toList());
  }
}
