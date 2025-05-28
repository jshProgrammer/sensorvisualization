import 'package:drift/drift.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';

class SensorDataProcessor {
  final Databaseoperations databaseOperations;
  final void Function(Map<String, dynamic>) onDataReceived;

  SensorDataProcessor({
    required this.databaseOperations,
    required this.onDataReceived,
  });

  void insertNewDevice(String senderIp, String deviceName) {
    databaseOperations.insertIdentificationData(
      IdentificationCompanion(ip: Value(senderIp), name: Value(deviceName)),
    );
  }

  void process(Map<String, dynamic> parsed) {
    databaseOperations.insertSensorData(
      SensorCompanion(
        date: Value(DateTime.parse(parsed['timestamp'])),
        ip: Value(parsed['ip']),
        accelerationX: Value(parsed['x']),
        accelerationY: Value(parsed['y']),
        accelerationZ: Value(parsed['z']),
        gyroskopX: Value(parsed['gyroscopeX']),
        gyroskopY: Value(parsed['gyroscopeY']),
        gyroskopZ: Value(parsed['gyroscopeZ']),
        magnetometerX: Value(parsed['magnetometerX']),
        magnetometerY: Value(parsed['magnetometerY']),
        magnetometerZ: Value(parsed['magnetometerZ']),
        barometer: Value(parsed['barometer']),
      ),
    );

    onDataReceived(
      SensorDataTransformation.returnAbsoluteSensorDataAsJson(parsed),
    );
  }
}
