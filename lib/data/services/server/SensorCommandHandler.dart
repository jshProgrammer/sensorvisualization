import 'dart:convert';
import 'dart:io';

import 'package:sensorvisualization/data/settingsModels/ConnectionDisplayState.dart';
import 'package:sensorvisualization/data/settingsModels/NetworkCommands.dart';
import 'package:sensorvisualization/data/services/server/ConnectionManager.dart';
import 'package:sensorvisualization/data/services/server/SensorDataProcessor.dart';

class SensorCommandHandler {
  final SensorDataProcessor dataProcessor;
  final ConnectionManager connectionManager;

  SensorCommandHandler({
    required this.dataProcessor,
    required this.connectionManager,
  });

  void handle(Map<String, dynamic> decoded, var data, WebSocket ws) {
    final ip = decoded['ip'];

    final command = decoded['command'];

    if (command != null) {
      switch (NetworkCommands.fromString(command)) {
        case NetworkCommands.ConnectionRequest:
          connectionManager.handleConnectionRequest(decoded, ws);
          dataProcessor.insertNewDevice(decoded['ip'], decoded['deviceName']);
          break;
        case NetworkCommands.StartNullMeasurementOnDevice:
          connectionManager.updateConnectionState(
            ip,
            ConnectionDisplayState.nullMeasurement,
            decoded,
          );
          break;
        case NetworkCommands.DelayedMeasurementOnDevice:
          connectionManager.updateConnectionState(
            ip,
            ConnectionDisplayState.delayedMeasurement,
            decoded,
          );
          break;
        case NetworkCommands.StopMeasurementOnDevice:
          connectionManager.handleDisconnection(ip);
          break;
        case NetworkCommands.AverageValues:
          connectionManager.storeNullMeasurementValues(decoded);
          connectionManager.setConnected(ip);
          break;
        case NetworkCommands.PauseMeasurementOnDevice:
          connectionManager.setPaused(ip);
          break;
        case NetworkCommands.ResumeMeasurementOnDevice:
          connectionManager.setSending(ip);
          break;
        case NetworkCommands.BatteryLevel:
          connectionManager.updateBatteryLevel(ip, decoded['level']);
          break;
        default:
          throw Exception("Illegal command received");
      }
    } else {
      dataProcessor.process(decoded);
      connectionManager.setSending(ip);
    }
  }
}
