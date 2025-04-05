//TODO: not working on browser
import 'dart:io';

class ConnectionToSender {
  void startServer() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 3001);
    print('Listening on port 3001');

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          ws.listen((data) {
            print('Received: $data');
          });
        });
      }
    }
  }
}
