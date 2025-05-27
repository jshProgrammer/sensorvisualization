import 'dart:async';
import 'dart:convert';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/models/NetworkCommands.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/client/ClientCommandHandler.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/presentation/screens/SensorMeasurement/AlarmPage.dart';
import 'package:battery_plus/battery_plus.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:network_info_plus/network_info_plus.dart';

class SensorClient {
  late WebSocketChannel channel;

  late StreamSubscription accelerometerSub;
  late StreamSubscription gyroscopeSub;
  late StreamSubscription magnetometerSub;
  late StreamSubscription barometerSub;

  final String hostIPAddress;
  final String deviceName;
  late final String ownIPAddress;
  bool _ownIPAddressInitialized = false;

  var battery = Battery();

  bool _isPaused = false;

  ClientCommandHandler commandHandler = ClientCommandHandler();

  Timer? _batteryTimer;

  SensorClient({required this.hostIPAddress, required this.deviceName}) {
    channel = WebSocketChannel.connect(Uri.parse('ws://$hostIPAddress:3001'));
  }

  Future<String?> retrieveLocalIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    if (!_ownIPAddressInitialized) {
      ownIPAddress = wifiIP ?? '';
      _ownIPAddressInitialized = true;
    }

    return wifiIP;
  }

  Duration sensorInterval = Duration(seconds: 1);

  Future<bool> initSocket() async {
    final completer = Completer<bool>();

    // send connection request including ip and custom device name to server
    final initializationMessage = jsonEncode({
      "command": NetworkCommands.ConnectionRequest.command,
      "ip": await retrieveLocalIP(),
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

            startBatteryMonitoring();

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

  void startBatteryMonitoring() {
    sendBatteryInformation();

    _batteryTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      await sendBatteryInformation();
    });
  }

  Future<void> sendBatteryInformation() async {
    channel.sink.add(
      jsonEncode({
        "ip": ownIPAddress,
        "command": NetworkCommands.BatteryLevel.command,
        "level": await battery.batteryLevel,
      }),
    );
  }

  void sendStartingNullMeasurement(int durationInSeconds) {
    channel.sink.add(
      jsonEncode({
        "command": NetworkCommands.StartNullMeasurementOnDevice.command,
        "duration": durationInSeconds,
        "timestamp": DateTime.now().toString(),
        "ip": ownIPAddress,
      }),
    );
  }

  void sendDelayedMeasurement(int duration) {
    final message = {
      'command': NetworkCommands.DelayedMeasurementOnDevice.command,
      'ip': ownIPAddress,
      'timestamp': DateTime.now().toString(),
      'duration': duration,
    };
    channel.sink.add(jsonEncode(message));
  }

  Future<void> startSensorStream() async {
    final localIP = await retrieveLocalIP();
    _isPaused = false;

    accelerometerSub = accelerometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((AccelerometerEvent event) {
      if (!_isPaused) {
        final now = event.timestamp;
        final message = {
          'ip': localIP,
          'sensor': SensorType.accelerometer.displayName,
          'timestamp': now.toString(),
          'x': event.x,
          'y': event.y,
          'z': event.z,
        };
        channel.sink.add(jsonEncode(message));
      }
    });

    gyroscopeSub = gyroscopeEventStream(samplingPeriod: sensorInterval).listen((
      GyroscopeEvent event,
    ) {
      if (!_isPaused) {
        final now = event.timestamp;
        final message = {
          'ip': localIP,
          'sensor': SensorType.gyroscope.displayName,
          'timestamp': now.toString(),
          'x': event.x,
          'y': event.y,
          'z': event.z,
        };
        channel.sink.add(jsonEncode(message));
      }
    });

    magnetometerSub = magnetometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((MagnetometerEvent event) {
      if (!_isPaused) {
        final now = event.timestamp;
        final message = {
          'ip': localIP,
          'sensor': SensorType.magnetometer.displayName,
          'timestamp': now.toString(),
          'x': event.x,
          'y': event.y,
          'z': event.z,
        };
        channel.sink.add(jsonEncode(message));
      }
    });

    barometerSub = barometerEventStream(samplingPeriod: sensorInterval).listen((
      BarometerEvent event,
    ) {
      if (!_isPaused) {
        final now = event.timestamp;
        final message = {
          'ip': localIP,
          'sensor': SensorType.barometer.displayName,
          'timestamp': now.toString(),
          'pressure': event.pressure,
        };
        channel.sink.add(jsonEncode(message));
      }
    });
  }

  Future<void> pauseMeasurement() async {
    if (!_isPaused) {
      _isPaused = true;

      channel.sink.add(
        jsonEncode({
          "command": NetworkCommands.PauseMeasurementOnDevice.command,
          "ip": await retrieveLocalIP(),
          "timestamp": DateTime.now().toString(),
        }),
      );

      print("Messung pausiert - Verbindung bleibt bestehen");
    }
  }

  Future<void> resumeMeasurement() async {
    if (_isPaused) {
      _isPaused = false;

      channel.sink.add(
        jsonEncode({
          "command": NetworkCommands.ResumeMeasurementOnDevice.command,
          "ip": await retrieveLocalIP(),
          "timestamp": DateTime.now().toString(),
        }),
      );

      print("Messung fortgesetzt");
    }
  }

  Future<void> stopMeasurement() async {
    await accelerometerSub.cancel();
    await gyroscopeSub.cancel();
    await magnetometerSub.cancel();
    await barometerSub.cancel();

    channel.sink.add(
      jsonEncode({
        "command": NetworkCommands.StopMeasurementOnDevice.command,
        "ip": await retrieveLocalIP(),
      }),
    );

    await channel.sink.close();
  }

  void sendNullMeasurementAverage(Map<String, Object> averageValues) {
    channel.sink.add(jsonEncode(averageValues));
  }

  bool get isPaused => _isPaused;
}
