import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sensors_plus/sensors_plus.dart';

class ConnectionToRecipient {
  late IO.Socket socket;
  Duration sensorInterval = SensorInterval.normalInterval;

  void initSocket() {
    //TODO: run 'ipconfig getifaddr en0'
    String ip = "192.168.2.135";
    socket = IO.io('http://${ip}:3001', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.onError((error) {
      print('Error: $error');
    });

    accelerometerEventStream(samplingPeriod: sensorInterval).listen((
      AccelerometerEvent event,
    ) {
      socket.emit('sensorData', {'x': event.timestamp, 'y': 1, 'z': 1});
    });
  }
}
