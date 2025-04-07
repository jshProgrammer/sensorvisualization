//TODO: not working on browser
import 'dart:convert';
import 'dart:io';

class ConnectionToSender {
  final void Function(Map<String, dynamic>) onDataReceived;

  ConnectionToSender({required this.onDataReceived});

  void startServer() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 3001);
    print('Listening on port 3001');

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          ws.listen((data) {
            print('Received: $data');

            try {
              final Map<String, dynamic> parsed = Map<String, dynamic>.from(
                data is String ? jsonDecode(data) : {},
              );
              final sensorData = {
                'sensor': parsed['sensor'],
                'timestamp': parsed['timestamp'],
                'x':
                    (parsed['x'] is String)
                        ? double.tryParse(parsed['x'])
                        : parsed['x'],
                'y':
                    (parsed['y'] is String)
                        ? double.tryParse(parsed['y'])
                        : parsed['y'],
                'z':
                    (parsed['z'] is String)
                        ? double.tryParse(parsed['z'])
                        : parsed['z'],
              };

              print("Sensor Data: $sensorData");

              onDataReceived(sensorData);
            } catch (e) {
              print('Error parsing data: $e');
            }
          });
        });
      }
    }
  }
}
