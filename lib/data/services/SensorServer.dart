//TODO: not working on browser
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:sensorvisualization/database/SensorTable.dart';

class SensorServer {
  final void Function(Map<String, dynamic>) onDataReceived;
  final void Function()? onMeasurementStopped;
  final void Function()? onConnectionChanged;
  final _databaseOperations = Databaseoperations();

  static final Map<String, Map<SensorType, Map<SensorOrientation, double>>>
  nullMeasurementValues = {};

  SensorServer({
    required this.onDataReceived,
    this.onMeasurementStopped,
    this.onConnectionChanged,
  });

  String getIpAddressByDeviceName(String deviceName) {
    for (var entry in connectedDevices.entries) {
      if (entry.value == deviceName) {
        return entry.key;
      }
    }
    //TODO: improve error-handling
    return "";
  }

  Map<String, String> connectedDevices = {}; // ip-address => device-name

  void startServer() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 3001);
    print('Listening on port 3001');

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          ws.listen((data) {
            print('Received: $data');

            try {
              var decoded = jsonDecode(data);
              // Check if the data is a connection request sent by a client
              if (decoded is Map<String, dynamic> &&
                  decoded['type'] == 'ConnectionRequest') {
                final senderIp = decoded['ip'];
                final deviceName = decoded['deviceName'];

                print('Neue Verbindung von $deviceName mit IP $senderIp');

                _databaseOperations.insertIdentificationData(
                  IdentificationCompanion(
                    ip: Value(senderIp),
                    name: Value(deviceName),
                  ),
                );

                connectedDevices.putIfAbsent(senderIp, () => deviceName);
                onConnectionChanged?.call();

                // Send acknowledgement to the client
                ws.add(
                  jsonEncode({
                    "response": "Connection accepted",
                    "message": "Willkommen $deviceName!",
                  }),
                );
              } else if (decoded['command'] == "StopMeasurement") {
                connectedDevices.remove(decoded['ip']);
                onConnectionChanged?.call();
                onMeasurementStopped?.call();
              } else {
                final Map<String, dynamic> parsed = Map<String, dynamic>.from(
                  data is String ? decoded : {},
                );

                //TODO: improve json handling here
                if (parsed['sensor'].contains("Durchschnittswert")) {
                  _storeNullMeasurementValues(parsed);
                } else {
                  /*final sensorType = SensorTypeExtension.fromString(
                    parsed['sensor'],
                  );*/
                  //Writing to database
                  //TODO: macht noch Probleme da noch nicht alle Daten komplett als Paket gesendet werden
                  /*_databaseOperations.insertSensorData(
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
                  );*/

                  onDataReceived(
                    SensorDataTransformation.returnAbsoluteSensorDataAsJson(
                      parsed,
                    ),
                  );
                }
              }
            } catch (e) {
              print('Error parsing data: $e');
            }
          });
        });
      }
    }
  }

  void _storeNullMeasurementValues(Map<String, dynamic> nullMeasurement) {
    nullMeasurementValues.putIfAbsent(nullMeasurement['ip'], () => {});
    nullMeasurementValues['ip']!.putIfAbsent(
      SensorType.accelerometer,
      () => {
        SensorOrientation.x:
            nullMeasurement[SensorType
                .accelerometer
                .displayName][SensorOrientation.x.displayName],
        SensorOrientation.y:
            nullMeasurement[SensorType
                .accelerometer
                .displayName][SensorOrientation.y.displayName],
        SensorOrientation.z:
            nullMeasurement[SensorType
                .accelerometer
                .displayName][SensorOrientation.z.displayName],
      },
    );
    nullMeasurementValues['ip']!.putIfAbsent(
      SensorType.gyroscope,
      () => {
        SensorOrientation.x:
            nullMeasurement[SensorType.gyroscope.displayName][SensorOrientation
                .x
                .displayName],
        SensorOrientation.y:
            nullMeasurement[SensorType.gyroscope.displayName][SensorOrientation
                .y
                .displayName],
        SensorOrientation.z:
            nullMeasurement[SensorType.gyroscope.displayName][SensorOrientation
                .z
                .displayName],
      },
    );

    nullMeasurementValues['ip']!.putIfAbsent(
      SensorType.magnetometer,
      () => {
        SensorOrientation.x:
            nullMeasurement[SensorType
                .magnetometer
                .displayName][SensorOrientation.x.displayName],
        SensorOrientation.y:
            nullMeasurement[SensorType
                .magnetometer
                .displayName][SensorOrientation.y.displayName],
        SensorOrientation.z:
            nullMeasurement[SensorType
                .magnetometer
                .displayName][SensorOrientation.z.displayName],
      },
    );

    nullMeasurementValues['ip']!.putIfAbsent(
      SensorType.barometer,
      () => {
        SensorOrientation.pressure:
            nullMeasurement[SensorType.barometer.displayName],
      },
    );
  }
}
