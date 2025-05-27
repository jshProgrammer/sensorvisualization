// connection_manager.dart

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:sensorvisualization/data/models/NetworkCommands.dart';
import 'package:tuple/tuple.dart';
import 'package:sensorvisualization/data/models/ConnectionDisplayState.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/models/SensorOrientation.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';

class ConnectionManager {
  final void Function()? onConnectionChanged;
  final void Function(String deviceIp)? onMeasurementStopped;

  static final Map<String, Map<SensorType, Map<SensorOrientation, double>>>
  nullMeasurementValues = {};

  //TODO: messung stoppen funktioniert nicht mehr
  //TODO: Anzeige ConnectionState (Nullmessung, Selbstauslöser) funktioniert nicht mehr

  final Map<String, String> connectedDevices = {}; // ip-address => device-name
  final Map<String, Tuple2<ConnectionDisplayState, DateTime?>>
  connectionStates =
      {}; // ip address => (connection state, optional: DateTime + durationInSeconds)
  final Map<String, int> batteryLevels = {}; // ip address => battery level

  final Map<String, WebSocket> activeConnections = {};

  ConnectionManager({this.onConnectionChanged, this.onMeasurementStopped});

  // Check if the data is a connection request sent by a client
  void handleConnectionRequest(Map<String, dynamic> decoded, WebSocket ws) {
    final senderIp = decoded['ip'];
    final deviceName = decoded['deviceName'];
    connectedDevices[senderIp] = deviceName;
    connectionStates[senderIp] = Tuple2(ConnectionDisplayState.connected, null);
    activeConnections[senderIp] = ws;
    onConnectionChanged?.call();

    // Send acknowledgement to the client
    ws.add(
      jsonEncode({
        "command": "ConnectionAccepted",
        "message": "Willkommen $deviceName!",
      }),
    );

    ws.done
        .then((_) {
          print('WebSocket closed for IP: $senderIp');
          _handleWebSocketDisconnection(senderIp);
        })
        .catchError((error) {
          print('WebSocket error for IP: $senderIp, Error: $error');
          _handleWebSocketDisconnection(senderIp);
        });
  }

  void _handleWebSocketDisconnection(String ip) {
    activeConnections.remove(ip);
    final deviceName = connectedDevices[ip];
    if (deviceName != null) {
      handleDisconnection(ip);
    }
  }

  void updateConnectionState(
    String ip,
    ConnectionDisplayState state,
    Map<String, dynamic> decoded,
  ) {
    DateTime? until;
    if (decoded.containsKey('timestamp') && decoded.containsKey('duration')) {
      until = DateTime.parse(
        decoded['timestamp'],
      ).add(Duration(seconds: decoded['duration']));
    }
    connectionStates[ip] = Tuple2(state, until);
    onConnectionChanged?.call();
  }

  void handleDisconnection(String ip) {
    final deviceName = connectedDevices.remove(ip) ?? ip;
    connectionStates[ip] = Tuple2(ConnectionDisplayState.disconnected, null);
    //activeConnections.remove(ip);
    onConnectionChanged?.call();
    onMeasurementStopped?.call(deviceName);
  }

  void storeNullMeasurementValues(Map<String, dynamic> data) {
    final ip = data['ip'];
    nullMeasurementValues[ip] = {
      SensorType.accelerometer: _mapToOrientationMap(data['accelerometer']),
      SensorType.gyroscope: _mapToOrientationMap(data['gyroscope']),
      SensorType.magnetometer: _mapToOrientationMap(data['magnetometer']),
      SensorType.barometer: {
        SensorOrientation.pressure: data['barometer'] ?? 0.0,
      },
    };
  }

  Map<SensorOrientation, double> _mapToOrientationMap(
    Map<String, dynamic> data,
  ) {
    return {
      for (var orientation in SensorOrientation.values)
        if (data.containsKey(orientation.displayName))
          orientation: data[orientation.displayName].toDouble(),
    };
  }

  void updateBatteryLevel(String ip, int level) {
    batteryLevels[ip] = level;
  }

  void setConnected(String ip) {
    connectionStates[ip] = Tuple2(ConnectionDisplayState.connected, null);
    onConnectionChanged?.call();
  }

  void setPaused(String ip) {
    connectionStates[ip] = Tuple2(ConnectionDisplayState.paused, null);
  }

  void setSending(String ip) {
    connectionStates[ip] = Tuple2(ConnectionDisplayState.sending, null);
    onConnectionChanged?.call();
  }

  ConnectionDisplayState getCurrentConnectionState(String ip) {
    return connectionStates[ip]?.item1 ?? ConnectionDisplayState.disconnected;
  }

  int? getRemainingConnectionDurationInSec(String ip) {
    final diff = connectionStates[ip]?.item2?.difference(DateTime.now());
    return diff != null ? (diff.inMilliseconds / 1000).ceil() : null;
  }

  String getIpAddressByDeviceName(String deviceName) {
    for (var entry in connectedDevices.entries) {
      if (entry.value == deviceName) {
        return entry.key;
      }
    }
    throw Exception("Device has not correctly been connected.");
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
}
