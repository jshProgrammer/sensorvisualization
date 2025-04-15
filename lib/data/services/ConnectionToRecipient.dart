import 'dart:async';
import 'dart:convert';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectionToRecipient {
  late WebSocketChannel channel;

  late StreamSubscription accelerometerSub;
  late StreamSubscription gyroscopeSub;
  late StreamSubscription magnetometerSub;
  late StreamSubscription barometerSub;

  final String ipAddress;

  ConnectionToRecipient({required this.ipAddress}) {
    channel = WebSocketChannel.connect(Uri.parse('ws://$ipAddress:3001'));
  }

  Duration sensorInterval = Duration(seconds: 1);

  void initSocket() {
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

    channel.sink.add({"command": "StopMeasurement"});

    await channel.sink.close();
  }

  void sendNullMeasurementAverage(Map<String, Object> averageValues) {
    channel.sink.add(jsonEncode(averageValues));
  }
}
