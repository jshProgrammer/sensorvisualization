//TODO: not working on browser
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/NetworkCommands.dart';
import 'package:sensorvisualization/data/models/SensorOrientation.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:sensorvisualization/database/SensorTable.dart';
import 'package:sensorvisualization/data/models/ConnectionDisplayState.dart';
import 'package:tuple/tuple.dart';

class SensorServer {
  final void Function(Map<String, dynamic>) onDataReceived;
  final void Function(String deviceIp)? onMeasurementStopped;
  final void Function()? onConnectionChanged;
  late Databaseoperations _databaseOperations;

  static final Map<String, Map<SensorType, Map<SensorOrientation, double>>>
  nullMeasurementValues = {};

  final Map<String, WebSocket> activeConnections = {};

  SensorServer({
    required this.onDataReceived,
    this.onMeasurementStopped,
    this.onConnectionChanged,
    required Databaseoperations databaseOperations,
  }) : _databaseOperations = databaseOperations;

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
  Map<String, Tuple2<ConnectionDisplayState, DateTime?>> connectionStates =
      {}; // ip address => (connection state, optional: DateTime + durationInSeconds)

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

              if (decoded == null) {
                return;
              }

              // Check if the data is a connection request sent by a client
              if (decoded['command'] != null) {
                if (decoded['command'] ==
                    NetworkCommands.ConnectionRequest.command) {
                  final senderIp = decoded['ip'];
                  final deviceName = decoded['deviceName'];

                  activeConnections[senderIp] = ws;

                  print('Neue Verbindung von $deviceName mit IP $senderIp');
                  //Writing to Database
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
                      "command": NetworkCommands.ConnectionAccepted.command,
                      "message": "Willkommen $deviceName!",
                    }),
                  );

                  connectionStates[decoded['ip']!] = Tuple2(
                    ConnectionDisplayState.connected,
                    null,
                  );
                } else if (decoded['command'] ==
                    NetworkCommands.StartNullMeasurementOnDevice.command) {
                  connectionStates[decoded['ip']!] = Tuple2(
                    ConnectionDisplayState.nullMeasurement,
                    DateTime.parse(
                      decoded['timestamp'],
                    ).add(Duration(seconds: decoded['duration'] as int)),
                  );
                  onConnectionChanged?.call();
                } else if (decoded['command'] ==
                    NetworkCommands.DelayedMeasurementOnDevice.command) {
                  connectionStates[decoded['ip']!] = Tuple2(
                    ConnectionDisplayState.delayedMeasurement,
                    DateTime.parse(
                      decoded['timestamp'],
                    ).add(Duration(seconds: decoded['duration'] as int)),
                  );
                  onConnectionChanged?.call();
                } else if (decoded['command'] ==
                    NetworkCommands.StopMeasurementOnDevice.command) {
                  final deviceName =
                      connectedDevices[decoded['ip']] ?? decoded['ip'];

                  connectionStates[decoded['ip']!] = Tuple2(
                    ConnectionDisplayState.disconnected,
                    null,
                  );
                  connectedDevices.remove(decoded['ip']);

                  onConnectionChanged?.call();
                  onMeasurementStopped?.call(deviceName);
                } else if (decoded['command'] ==
                    NetworkCommands.AverageValues.command) {
                  final Map<String, dynamic> parsed = Map<String, dynamic>.from(
                    data is String ? decoded : {},
                  );
                  _storeNullMeasurementValues(parsed);
                  connectionStates[decoded['ip']!] = Tuple2(
                    ConnectionDisplayState.connected,
                    null,
                  );
                  onConnectionChanged?.call();
                } else if (decoded['command'] ==
                    NetworkCommands.PauseMeasurementOnDevice.command) {
                  connectionStates[decoded['ip']!] = Tuple2(
                    ConnectionDisplayState.paused,
                    null,
                  );
                }
              } else {
                final Map<String, dynamic> parsed = Map<String, dynamic>.from(
                  data is String ? decoded : {},
                );

                connectionStates[decoded['ip']!] = Tuple2(
                  ConnectionDisplayState.sending,
                  null,
                );

                onConnectionChanged?.call();
                final sensorType = SensorTypeExtension.fromString(
                  parsed['sensor'],
                );
                //Writing to database
                //TODO: macht noch Probleme da noch nicht alle Daten komplett als Paket gesendet werden
                _databaseOperations.insertSensorData(
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
                  SensorDataTransformation.returnAbsoluteSensorDataAsJson(
                    parsed,
                  ),
                );
              }
            } catch (e) {
              print('Error parsing data: $e');
            }
          });
          ws.done.then((_) {
            activeConnections.removeWhere((key, value) => value == ws);
            print('Connection closed');
          });
        });
      }
    }
  }

  void sendAlarmToAllClients(String alarmMessage) {
    final alarmData = jsonEncode({
      "command": NetworkCommands.Alarm.command,
      "message": alarmMessage,
      "timestamp": DateTime.now().toIso8601String(),
    });

    for (var ws in activeConnections.values) {
      ws.add(alarmData);
    }
  }

  void sendAlarmStopToAllClients() {
    final alarmData = jsonEncode({
      "command": NetworkCommands.AlarmStop.command,
      "timestamp": DateTime.now().toIso8601String(),
    });

    for (var ws in activeConnections.values) {
      ws.add(alarmData);
    }
  }

  void sendStartNullMeasurementToClient(String ipAddress, int duration) {
    activeConnections[ipAddress]!.add(
      jsonEncode({
        "command": NetworkCommands.StartNullMeasurementRemote.command,
        "duration": duration,
      }),
    );
  }

  void sendStartDelayedMeasurementToClient(String ipAddress, int duration) {
    activeConnections[ipAddress]!.add(
      jsonEncode({
        "command": NetworkCommands.DelayedMeasurementRemote.command,
        "duration": duration,
      }),
    );
  }

  void sendPauseMeasurementToClient(String ipAddress) {
    activeConnections[ipAddress]!.add(
      jsonEncode({"command": NetworkCommands.PauseMeasurementRemote.command}),
    );
  }

  void sendResumeMeasurementToClient(String ipAddress) {
    activeConnections[ipAddress]!.add(
      jsonEncode({"command": NetworkCommands.ResumeMeasurementRemote.command}),
    );
  }

  void sendStopMeasurementToClient(String ipAddress) {
    activeConnections[ipAddress]!.add(
      jsonEncode({"command": NetworkCommands.StopMeasurementRemote.command}),
    );
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

  ConnectionDisplayState getCurrentConnectionState(String ipAddress) {
    return connectionStates[ipAddress] == null
        ? ConnectionDisplayState.disconnected
        : connectionStates[ipAddress]!.item1;
  }

  int? getRemainingConnectionDurationInSec(String ipAddress) {
    final diff = connectionStates[ipAddress]?.item2?.difference(DateTime.now());
    return diff != null ? (diff.inMilliseconds / 1000).ceil() : null;
  }
}
