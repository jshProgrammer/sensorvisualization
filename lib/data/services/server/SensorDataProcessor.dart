import 'package:drift/drift.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
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
        accelerationX:
            parsed["sensor"] == SensorType.accelerometer.displayName
                ? Value(parsed['x'])
                : Value(null),
        accelerationY:
            parsed["sensor"] == SensorType.accelerometer.displayName
                ? Value(parsed['y'])
                : Value(null),
        accelerationZ:
            parsed["sensor"] == SensorType.accelerometer.displayName
                ? Value(parsed['z'])
                : Value(null),
        gyroskopX:
            parsed["sensor"] == SensorType.gyroscope.displayName
                ? Value(parsed['x'])
                : Value(null),
        gyroskopY:
            parsed["sensor"] == SensorType.gyroscope.displayName
                ? Value(parsed['y'])
                : Value(null),
        gyroskopZ:
            parsed["sensor"] == SensorType.gyroscope.displayName
                ? Value(parsed['z'])
                : Value(null),
        magnetometerX:
            parsed["sensor"] == SensorType.magnetometer.displayName
                ? Value(parsed['x'])
                : Value(null),
        magnetometerY:
            parsed["sensor"] == SensorType.magnetometer.displayName
                ? Value(parsed['y'])
                : Value(null),
        magnetometerZ:
            parsed["sensor"] == SensorType.magnetometer.displayName
                ? Value(parsed['z'])
                : Value(null),
        barometer:
            parsed["sensor"] == SensorType.barometer.displayName
                ? Value(parsed['pressure'])
                : Value(null),
      ),
    );

    onDataReceived(
      SensorDataTransformation.returnAbsoluteSensorDataAsJson(parsed),
    );
  }
}
