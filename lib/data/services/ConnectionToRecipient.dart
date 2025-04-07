import 'dart:convert';

import 'package:sensors_plus/sensors_plus.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectionToRecipient {
  late WebSocketChannel channel;

  final String ipAddress;

  ConnectionToRecipient({required this.ipAddress});

  Duration sensorInterval = Duration(seconds: 1);

  void initSocket() {
    //TODO: run 'lsof -i :3001' to check whether connection is successful
    //TODO: run 'ipconfig getifaddr en0'
    //String ip = "192.168.2.135";
    channel = WebSocketChannel.connect(Uri.parse('ws://$ipAddress:3001'));

    /*userAccelerometerEventStream(samplingPeriod: sensorInterval).listen((
      UserAccelerometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'UserAccelerometer',
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });*/

    accelerometerEventStream(samplingPeriod: sensorInterval).listen((
      AccelerometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Beschleunigungs-Sensor',
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });

    gyroscopeEventStream(samplingPeriod: sensorInterval).listen((
      GyroscopeEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Gyroskop',
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });

    magnetometerEventStream(samplingPeriod: sensorInterval).listen((
      MagnetometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Magnetometer',
        'timestamp': now.toString(),
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(jsonEncode(message));
    });

    barometerEventStream(samplingPeriod: sensorInterval).listen((
      BarometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Barometer',
        'timestamp': now.toString(),
        'x': event.pressure,
      };
      channel.sink.add(jsonEncode(message));
    });
  }
}
