//TODO: not working on browser
import 'dart:convert';
import 'dart:io';

import 'package:sensorvisualization/data/models/SensorType.dart';

class ConnectionToSender {
  final void Function(Map<String, dynamic>) onDataReceived;
  final void Function()? onMeasurementStopped;

  final Map<SensorType, Map<SensorOrientation, double>> nullMeasurementValues =
      {};

  ConnectionToSender({required this.onDataReceived, this.onMeasurementStopped});

  void startServer() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 3001);
    print('Listening on port 3001');

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          ws.listen((data) {
            print('Received: $data');

            try {
              if (jsonDecode(data) == "StopMeasurement") {
                onMeasurementStopped?.call();
              } else {
                final Map<String, dynamic> parsed = Map<String, dynamic>.from(
                  data is String ? jsonDecode(data) : {},
                );

                if (parsed['sensor'].contains("Durchschnittswert")) {
                  _storeNullMeasurementValues(parsed);
                } else {
                  final rawX =
                      (parsed['x'] is String)
                          ? double.tryParse(parsed['x'])
                          : parsed['x'];
                  final rawY =
                      (parsed['y'] is String)
                          ? double.tryParse(parsed['y'])
                          : parsed['y'];
                  final rawZ =
                      (parsed['z'] is String)
                          ? double.tryParse(parsed['z'])
                          : parsed['z'];

                  final sensorType = SensorTypeExtension.fromString(
                    parsed['sensor'],
                  );

                  final nulls = nullMeasurementValues[sensorType];

                  //TODO: Barometer is ignored yet
                  final calibratedX =
                      rawX != null && nulls != null
                          ? rawX - (nulls[SensorOrientation.x] ?? 0.0)
                          : rawX;
                  final calibratedY =
                      rawY != null && nulls != null
                          ? rawY - (nulls[SensorOrientation.y] ?? 0.0)
                          : rawY;
                  final calibratedZ =
                      rawZ != null && nulls != null
                          ? rawZ - (nulls[SensorOrientation.z] ?? 0.0)
                          : rawZ;

                  final sensorData = {
                    'sensor': parsed['sensor'],
                    'timestamp': parsed['timestamp'],
                    'x': calibratedX,
                    'y': calibratedY,
                    'z': calibratedZ,
                  };

                  print("Sensor Data: $sensorData");
                  onDataReceived(sensorData);
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
            nullMeasurement[SensorType.accelerometer.displayName]['x'],
        SensorOrientation.y:
            nullMeasurement[SensorType.accelerometer.displayName]['y'],
        SensorOrientation.z:
            nullMeasurement[SensorType.accelerometer.displayName]['z'],
      },
    );
    nullMeasurementValues.putIfAbsent(
      SensorType.gyroscope,
      () => {
        SensorOrientation.x:
            nullMeasurement[SensorType.gyroscope.displayName]['x'],
        SensorOrientation.y:
            nullMeasurement[SensorType.gyroscope.displayName]['y'],
        SensorOrientation.z:
            nullMeasurement[SensorType.gyroscope.displayName]['z'],
      },
    );

    nullMeasurementValues.putIfAbsent(
      SensorType.magnetometer,
      () => {
        SensorOrientation.x:
            nullMeasurement[SensorType.magnetometer.displayName]['x'],
        SensorOrientation.y:
            nullMeasurement[SensorType.magnetometer.displayName]['y'],
        SensorOrientation.z:
            nullMeasurement[SensorType.magnetometer.displayName]['z'],
      },
    );

    nullMeasurementValues.putIfAbsent(
      SensorType.barometer,
      nullMeasurement[SensorType.barometer.displayName],
    );
  }
}
