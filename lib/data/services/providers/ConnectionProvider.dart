import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/ConnectionDisplayState.dart';
import 'package:tuple/tuple.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'dart:async';
import '../SensorServer.dart';

class ConnectionProvider extends ChangeNotifier {
  late SensorServer _connectionToSender;
  final Map<String, dynamic> _latestData = {};
  final Databaseoperations _databaseOperations;
  bool _isAlarmActive = false;

  bool get isAlarmActive => _isAlarmActive;

  ConnectionProvider(this._databaseOperations) {
    _connectionToSender = SensorServer(
      onDataReceived: _handleDataReceived,
      onMeasurementStopped: _handleMeasurementStopped,
      onConnectionChanged: _handleConnectionChanged,
      databaseOperations: _databaseOperations,
    );
    _connectionToSender.startServer();
  }

  String getIpAddressByDeviceName(String deviceName) {
    return _connectionToSender.getIpAddressByDeviceName(deviceName);
  }

  ConnectionDisplayState getCurrentConnectionState(String ipAddress) {
    return _connectionToSender.getCurrentConnectionState(ipAddress);
  }

  int? getRemainingConnectionDurationInSec(String ipAddress) {
    return _connectionToSender.getRemainingConnectionDurationInSec(ipAddress);
  }

  final _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  final _connectionChangedController = StreamController<void>.broadcast();
  Stream<void> get connectionChanged => _connectionChangedController.stream;

  Map<String, String> get connectedDevices =>
      _connectionToSender.connectedDevices;

  Map<String, Tuple2<ConnectionDisplayState, DateTime?>> get connectionStates =>
      _connectionToSender.connectionStates;

  Map<String, int> get batteryLevels => _connectionToSender.batteryLevels;

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
    _connectionToSender.sendAlarmToAllClients(alarmMessage);
    notifyListeners();
  }

  Future<void> stopAlarm() async {
    _isAlarmActive = false;
    _connectionToSender.sendAlarmStopToAllClients();
    notifyListeners();
  }

  void sendStartNullMeasurementToClient(String ipAddress, int duration) {
    _connectionToSender.sendStartNullMeasurementToClient(ipAddress, duration);
  }

  void sendPauseMeasurementToClient(String ipAddress) {
    _connectionToSender.sendPauseMeasurementToClient(ipAddress);
  }

  void sendResumeMeasurementToClient(String ipAddress) {
    _connectionToSender.sendResumeMeasurementToClient(ipAddress);
  }

  void sendStopMeasurementToClient(String ipAddress) {
    _connectionToSender.sendStopMeasurementToClient(ipAddress);
  }

  void sendStartDelayedMeasurementToClient(String ipAddress, int duration) {
    _connectionToSender.sendStartDelayedMeasurementToClient(
      ipAddress,
      duration,
    );
  }

  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }
}
