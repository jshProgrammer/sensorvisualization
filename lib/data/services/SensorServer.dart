//TODO: not working on browser
import 'dart:convert';
import 'dart:io';

import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';

class SensorServer {
  final void Function(Map<String, dynamic>) onDataReceived;
  final void Function()? onMeasurementStopped;
  final void Function()? onConnectionChanged;

  static final Map<SensorType, Map<SensorOrientation, double>>
  nullMeasurementValues = {};

  SensorServer({
    required this.onDataReceived,
    this.onMeasurementStopped,
    this.onConnectionChanged,
  });

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

                if (parsed['sensor'].contains("Durchschnittswert")) {
                  _storeNullMeasurementValues(parsed);
                } else {
                  final sensorType = SensorTypeExtension.fromString(
                    parsed['sensor'],
                  );

                  onDataReceived(
                    SensorDataTransformation.returnAbsoluteSensorDataAsJson(
                      parsed,
                      sensorType,
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
    nullMeasurementValues.putIfAbsent(
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
    nullMeasurementValues.putIfAbsent(
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

    nullMeasurementValues.putIfAbsent(
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

    nullMeasurementValues.putIfAbsent(
      SensorType.barometer,
      () => {
        SensorOrientation.pressure:
            nullMeasurement[SensorType.barometer.displayName],
      },
    );
  }
}
