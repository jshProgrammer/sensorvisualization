import 'dart:async';
import 'dart:convert';

import 'package:sensorvisualization/data/settingsModels/NetworkCommands.dart';
import 'package:sensorvisualization/data/services/client/ClientCommandHandler.dart';
import 'package:sensorvisualization/data/services/client/DeviceInfoManager.dart';
import 'package:sensorvisualization/data/services/client/SensorDataManager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SensorClient {
  late WebSocketChannel channel;

  late final SensorDataManger _sensorDataManager;
  late final DeviceInfoManager _deviceInfoManager;
  late final ClientCommandHandler commandHandler;

  final String hostIPAddress;
  final String deviceName;
  late final String localIP;

  bool get isPaused => _sensorDataManager.isPaused;
  int get sensorInterval => _sensorDataManager.sensorInterval.inSeconds;

  SensorClient({required this.hostIPAddress, required this.deviceName}) {
    channel = WebSocketChannel.connect(Uri.parse('ws://$hostIPAddress:3001'));

    _initializeComponents();
  }

  void _initializeComponents() async {
    _deviceInfoManager = DeviceInfoManager(onDeviceInfo: sendJson);

    localIP = (await _deviceInfoManager.retrieveLocalIP())!;

    _sensorDataManager = SensorDataManger(
      onSensorData: sendJson,
      localIP: localIP,
    );

    commandHandler = ClientCommandHandler();
  }

  Future<bool> initSocket() async {
    final completer = Completer<bool>();

    // send connection request including ip and custom device name to server
    final initializationMessage = jsonEncode({
      "command": NetworkCommands.ConnectionRequest.command,
      "ip": await _deviceInfoManager.retrieveLocalIP(),
      "deviceName": deviceName,
    });
    channel.sink.add(initializationMessage);

    // wait for acknowledgement
    channel.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data);
          if (decoded['command'] ==
              NetworkCommands.ConnectionAccepted.command) {
            completer.complete(true);

            _deviceInfoManager.startBatteryMonitoring();

            return;
          }

          _handleIncomingCommand(decoded);
        } catch (e) {
          completer.complete(false);
        }
      },
      onError: (err) {
        completer.complete(false);
      },
    );

    return completer.future;
  }

  void _handleIncomingCommand(Map<String, dynamic> decoded) {
    final commandString = decoded['command'] as String?;
    if (commandString == null) return;

    commandHandler.handleCommand(
      NetworkCommands.fromString(commandString),
      decoded,
    );
  }

  // public API methods
  void sendJson(Map<String, dynamic> json) {
    channel.sink.add(jsonEncode(json));
  }

  Future<void> startSensorStream() async {
    await _sensorDataManager.startSensorStream();
  }

  Future<void> pauseMeasurement() async {
    _sensorDataManager.pauseMeasurement();
  }

  Future<void> resumeMeasurement() async {
    _sensorDataManager.resumeMeasurement();
  }

  Future<void> stopMeasurement() async {
    await _sensorDataManager.stopSensorStream();
    await channel.sink.close();
  }

  void sendStartingNullMeasurement(int durationInSeconds) async {
    channel.sink.add(
      jsonEncode({
        "command": NetworkCommands.StartNullMeasurementOnDevice.command,
        "duration": durationInSeconds,
        "timestamp": DateTime.now().toString(),
        "ip": await _deviceInfoManager.retrieveLocalIP(),
      }),
    );
  }

  void sendDelayedMeasurement(int duration) async {
    final message = {
      'command': NetworkCommands.DelayedMeasurementOnDevice.command,
      'ip': await _deviceInfoManager.retrieveLocalIP(),
      'timestamp': DateTime.now().toString(),
      'duration': duration,
    };
    channel.sink.add(jsonEncode(message));
  }

  void sendNullMeasurementAverage(Map<String, Object> averageValues) {
    _sensorDataManager.sendNullMeasurementAverage(averageValues);
  }

  Future<void> disconnect() async {
    _deviceInfoManager.stopBatteryMonitoring();
    await _sensorDataManager.stopSensorStream();
  }
}
