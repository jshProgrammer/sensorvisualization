import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/*
For using Methods from this class, please have a look at the follwing example
1. Import: import 'package:sensorvisualization/database/DatabaseOperations.dart';
2. Create an instance of the class: final _databaseOperations = Databaseoperations();
3. Call the method as shown below: 
    _databaseOperations.insertSensorData(
                    SensorCompanion(
                      date: Value(DateTime.parse(parsed['timestamp'])),
                      ip: Value(parsed['ip']),
                      accelerationX: Value(rawX),
                      accelerationY: Value(rawY),
                      accelerationZ: Value(rawZ),
                      ...
                    ),
                  );
*/

class Databaseoperations {
  final AppDatabase _db = AppDatabase.instance;

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

  Future<String> exportToCSV(
    List<List<dynamic>> csvData,
    String fileName,
  ) async {
    try {
      // CSV-Daten in String umwandeln
      String csvContent = const ListToCsvConverter().convert(csvData);

      // Speicherort ermitteln
      final outputDir = await getApplicationDocumentsDirectory();
      final outputFile = File("${outputDir.path}/$fileName.csv");

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
}
