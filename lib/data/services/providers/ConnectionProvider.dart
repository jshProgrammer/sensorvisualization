import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/ConnectionDisplayState.dart';
import 'package:sensorvisualization/data/services/server/ConnectionManager.dart';
import 'package:sensorvisualization/data/services/server/SensorCommandHandler.dart';
import 'package:sensorvisualization/data/services/server/SensorDataProcessor.dart';
import 'package:sensorvisualization/data/services/server/SensorWebSocketServer.dart';
import 'package:tuple/tuple.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'dart:async';

class ConnectionProvider extends ChangeNotifier {
  late SensorWebSocketServer _connectionToSender;
  final Map<String, dynamic> _latestData = {};
  final Databaseoperations _databaseOperations;
  bool _isAlarmActive = false;

  bool get isAlarmActive => _isAlarmActive;

  ConnectionProvider(this._databaseOperations) {
    _connectionToSender = SensorWebSocketServer(
      commandHandler: SensorCommandHandler(
        dataProcessor: SensorDataProcessor(
          databaseOperations: _databaseOperations,
          onDataReceived: _handleDataReceived,
        ),
        connectionManager: ConnectionManager(
          onConnectionChanged: _handleConnectionChanged,
          onMeasurementStopped: _handleMeasurementStopped,
        ),
      ),
    );
    _connectionToSender.startServer();
  }

  String getIpAddressByDeviceName(String deviceName) {
    return _connectionToSender.commandHandler.connectionManager
        .getIpAddressByDeviceName(deviceName);
  }

  ConnectionDisplayState getCurrentConnectionState(String ipAddress) {
    return _connectionToSender.commandHandler.connectionManager
        .getCurrentConnectionState(ipAddress);
  }

  int? getRemainingConnectionDurationInSec(String ipAddress) {
    return _connectionToSender.commandHandler.connectionManager
        .getRemainingConnectionDurationInSec(ipAddress);
  }

  final _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  final _connectionChangedController = StreamController<void>.broadcast();
  Stream<void> get connectionChanged => _connectionChangedController.stream;

  Map<String, String> get connectedDevices =>
      _connectionToSender.commandHandler.connectionManager.connectedDevices;

  Map<String, Tuple2<ConnectionDisplayState, DateTime?>> get connectionStates =>
      _connectionToSender.commandHandler.connectionManager.connectionStates;

  Map<String, int> get batteryLevels =>
      _connectionToSender.commandHandler.connectionManager.batteryLevels;

  final _measurementStoppedController =
      StreamController<String>.broadcast(); // String = device-name (NOT ip!)
  Stream<String> get measurementStopped => _measurementStoppedController.stream;

  void _handleDataReceived(Map<String, dynamic> data) {
    _latestData.addAll(data);
    _dataStreamController.add(data);
    notifyListeners();
  }

  void _handleConnectionChanged() {
    _connectionChangedController.add(null);
    notifyListeners();
  }

  void _handleMeasurementStopped(String deviceName) {
    _measurementStoppedController.add(deviceName);
    notifyListeners();
  }

  void sendAlarmToAllClients(String alarmMessage) {
    _isAlarmActive = true;
    _connectionToSender.commandHandler.connectionManager.sendAlarmToAllClients(
      alarmMessage,
    );
    notifyListeners();
  }

  Future<void> stopAlarm() async {
    _isAlarmActive = false;
    _connectionToSender.commandHandler.connectionManager
        .sendAlarmStopToAllClients();
    notifyListeners();
  }

  void sendStartNullMeasurementToClient(String ipAddress, int duration) {
    _connectionToSender.commandHandler.connectionManager
        .sendStartNullMeasurementToClient(ipAddress, duration);
  }

  void sendPauseMeasurementToClient(String ipAddress) {
    _connectionToSender.commandHandler.connectionManager
        .sendPauseMeasurementToClient(ipAddress);
  }

  void sendResumeMeasurementToClient(String ipAddress) {
    _connectionToSender.commandHandler.connectionManager
        .sendResumeMeasurementToClient(ipAddress);
  }

  void sendStopMeasurementToClient(String ipAddress) {
    _connectionToSender.commandHandler.connectionManager
        .sendStopMeasurementToClient(ipAddress);
  }

  void sendStartDelayedMeasurementToClient(String ipAddress, int duration) {
    _connectionToSender.commandHandler.connectionManager
        .sendStartDelayedMeasurementToClient(ipAddress, duration);
  }

  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }
}
