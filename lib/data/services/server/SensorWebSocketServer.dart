import 'dart:convert';
import 'dart:io';
import 'package:sensorvisualization/data/services/server/SensorCommandHandler.dart';

class SensorWebSocketServer {
  final SensorCommandHandler commandHandler;

  SensorWebSocketServer({required this.commandHandler});

  void startServer() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 3001);

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          ws.listen((data) {
            try {
              var decoded = jsonDecode(data);
              commandHandler.handle(decoded, data, ws);
            } catch (e) {
              print('Error parsing data: $e');
            }
          });
        });
      }
    }
  }
}
