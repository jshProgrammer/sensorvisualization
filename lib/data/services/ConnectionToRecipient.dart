import 'dart:async';
import 'dart:convert';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ConnectionToRecipient {
  late WebSocketChannel channel;

  late StreamSubscription accelerometerSub;
  late StreamSubscription gyroscopeSub;
  late StreamSubscription magnetometerSub;
  late StreamSubscription barometerSub;

  final String hostIPAddress;
  final String deviceName;

  ConnectionToRecipient({
    required this.hostIPAddress,
    required this.deviceName,
  }) {
    channel = WebSocketChannel.connect(Uri.parse('ws://$hostIPAddress:3001'));
  }

  Future<String?> _retrieveLocalIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    return wifiIP;
  }

  Duration sensorInterval = Duration(seconds: 1);

  Future<void> initSocket() async {
    final initializationMessage = jsonEncode({
      "type": "ConnectionRequest",
      "ip": await _retrieveLocalIP(),
      "deviceName": deviceName,
    });
    channel.sink.add(initializationMessage);

    //TODO: wait for response if connection has been successful

    /*userAccelerometerEventStream(samplingPeriod: sensorInterval).listen((
      UserAccelerometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': SensorType.userAccelerometer.displayName,
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });*/

    accelerometerSub = accelerometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((AccelerometerEvent event) {
      final now = event.timestamp;
      final message = {
        'sensor': SensorType.accelerometer.displayName,
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });

    gyroscopeSub = gyroscopeEventStream(samplingPeriod: sensorInterval).listen((
      GyroscopeEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': SensorType.gyroscope.displayName,
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });

    magnetometerSub = magnetometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((MagnetometerEvent event) {
      final now = event.timestamp;
      final message = {
        'sensor': SensorType.magnetometer.displayName,
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });

    barometerSub = barometerEventStream(samplingPeriod: sensorInterval).listen((
      BarometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': SensorType.barometer.displayName,
        'timestamp': now.toString(),
        'x': event.pressure,
      };
      channel.sink.add(jsonEncode(message));
    });
  }

  Future<void> stopMeasurement() async {
    await accelerometerSub.cancel();
    await gyroscopeSub.cancel();
    await magnetometerSub.cancel();
    await barometerSub.cancel();

    channel.sink.add(
      jsonEncode({
        "command": "StopMeasurement",
        "ip": await _retrieveLocalIP(),
      }),
    );

    await channel.sink.close();
  }

  void sendNullMeasurementAverage(Map<String, Object> averageValues) {
    channel.sink.add(jsonEncode(averageValues));
  }
}
