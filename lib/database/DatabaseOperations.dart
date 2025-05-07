import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
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

  Databaseoperations(this._db);

  //Insert Methods

  Future<void> insertSensorData(SensorCompanion sensor) async {
    await _db.into(_db.sensor).insert(sensor);
  }

  Future<void> insertNoteData(NoteCompanion note) async {
    await _db.into(_db.note).insert(note);
  }

  Future<void> insertIdentificationData(
    IdentificationCompanion identification,
  ) async {
    await _db.into(_db.identification).insert(identification);
  }

  Future<void> insertMetadata(MetadataCompanion metadata) async {
    await _db.into(_db.metadata).insert(metadata);
  }

  //Update Methods
  Future<void> updateMetadata(String tableName, DateTime createdAt) async {
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
  }

  //Read Method
  Future<List<Map<String, dynamic>>> readTableData(String tableName) async {
    final result = await _db.customSelect('SELECT * FROM $tableName').get();

    return result.map((row) => row.data).toList();
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
