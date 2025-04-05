import 'package:sensors_plus/sensors_plus.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:sensors_plus/sensors_plus.dart';

class ConnectionToRecipient {
  late WebSocketChannel channel;
  Duration sensorInterval = Duration(seconds: 1);

  void initSocket() {
    //TODO: run 'lsof -i :3001' to check whether connection is successful
    //TODO: run 'ipconfig getifaddr en0'
    String ip = "192.168.2.135";
    channel = WebSocketChannel.connect(Uri.parse('ws://$ip:3001'));

    /*accelerometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      final message = {'x': event.x, 'y': event.y, 'z': event.z};
      channel.sink.add(message.toString());
    });*/

    /*channel.stream.listen((message) {
      print('Received from server: $message');
    });*/

    userAccelerometerEventStream(samplingPeriod: sensorInterval).listen((
      UserAccelerometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'UserAccelerometer',
        'timestamp': now,
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(message.toString());
    });

    accelerometerEventStream(samplingPeriod: sensorInterval).listen((
      AccelerometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Accelerometer',
        'timestamp': now,
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(message.toString());
    });

    gyroscopeEventStream(samplingPeriod: sensorInterval).listen((
      GyroscopeEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Gyroscope',
        'timestamp': now,
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(message.toString());
    });

    magnetometerEventStream(samplingPeriod: sensorInterval).listen((
      MagnetometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Magnetometer',
        'timestamp': now,
        'x': event.x,
        'y': event.y,
        'z': event.z,
      };
      channel.sink.add(message.toString());
    });

    barometerEventStream(samplingPeriod: sensorInterval).listen((
      BarometerEvent event,
    ) {
      final now = event.timestamp;
      final message = {
        'sensor': 'Barometer',
        'timestamp': now,
        'x': event.pressure,
      };
      channel.sink.add(message.toString());
    });
  }
}
