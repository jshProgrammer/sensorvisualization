import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:path_provider/path_provider.dart';

/*
For using Methods from this class, please have a look at the follwing example
1. Import: import 'package:sensorvisualization/database/SensorTable.dart';
2. Create an instance of the class: final _databaseOperations = Databaseoperations();
3. Call the method as shown below: 
    _databaseOperations.insertSensorData(
                    SensorCompanion(
                      date: Value(DateTime.parse(parsed['timestamp'])),
                      ip: Value(parsed['ip']),
                      accelerationX: Value(rawX),
                      accelerationY: Value(rawY),
                      accelerationZ: Value(rawZ),
                    ),
                  );
*/

class Databaseoperations {
  final AppDatabase _db = AppDatabase.instance;

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

  //export as CSV Methods
  Future<String> exportSensorDataCSV() async {
    final data = await _db.select(_db.sensor).get();

    List<List<dynamic>> csvData = [
      ['id', 'date', 'ip', 'accelerationX', 'accelerationY', 'accelerationZ'],
      ...data.map(
        (row) => [
          row.id,
          row.date.toIso8601String(),
          row.ip,
          row.accelerationX,
          row.accelerationY,
          row.accelerationZ,
        ],
      ),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sensor_export.csv';
    final file = File(path);

    await file.writeAsString(csv);

    print('CSV exportiert: $path');

    return path;
  }

  Future<String> exportNoteDataCSV() async {
    final data = await _db.select(_db.note).get();

    List<List<dynamic>> csvData = [
      ['id', 'date', 'note'],
      ...data.map((row) => [row.id, row.date.toIso8601String(), row.note]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/note_export.csv';
    final file = File(path);

    await file.writeAsString(csv);

    print('CSV exportiert: $path');

    return path;
  }

  Future<String> exportIdentificationDataCSV() async {
    final data = await _db.select(_db.identification).get();

    List<List<dynamic>> csvData = [
      ['ip', 'name'],
      ...data.map((row) => [row.ip, row.name]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/identification_export.csv';
    final file = File(path);

    await file.writeAsString(csv);

    print('CSV exportiert: $path');

    return path;
  }
}
