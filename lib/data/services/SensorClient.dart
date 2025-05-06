import 'dart:async';
import 'dart:convert';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';

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
      "type": "ConnectionRequest",
      "ip": await retrieveLocalIP(),
      "deviceName": deviceName,
    });
    channel.sink.add(initializationMessage);

    // wait for acknowledgement
    channel.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data);
          if (decoded['response'] == 'Connection accepted') {
            completer.complete(true);
          }
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

  Future<void> startSensorStream() async {
    final localIP = await retrieveLocalIP();
    accelerometerSub = accelerometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((AccelerometerEvent event) {
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
    });

    gyroscopeSub = gyroscopeEventStream(samplingPeriod: sensorInterval).listen((
      GyroscopeEvent event,
    ) {
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
    });

    magnetometerSub = magnetometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((MagnetometerEvent event) {
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
    });

    barometerSub = barometerEventStream(samplingPeriod: sensorInterval).listen((
      BarometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'ip': localIP,
        'sensor': SensorType.barometer.displayName,
        'timestamp': now.toString(),
        'pressure': event.pressure,
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
      jsonEncode({"command": "StopMeasurement", "ip": await retrieveLocalIP()}),
    );

    await channel.sink.close();
  }

  void sendNullMeasurementAverage(Map<String, Object> averageValues) {
    channel.sink.add(jsonEncode(averageValues));
  }
}
