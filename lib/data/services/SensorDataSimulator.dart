import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SensorDataSimulator {
  final void Function(Map<String, dynamic>) onDataGenerated;
  late Timer _timer;
  final Random _random = Random();
  late WebSocketChannel channel;
  final info = NetworkInfo();
  late String? ipAddress;

  SensorDataSimulator({required this.onDataGenerated});

  Future<void> init() async {
    try {
      ipAddress = await info.getWifiIP();
      channel = WebSocketChannel.connect(Uri.parse('ws://$ipAddress:3001'));
      print('WebSocket-Verbindung hergestellt');
    } catch (e) {
      print('Fehler beim Herstellen der WebSocket-Verbindung: $e');
    }
  }

  void startSimulation({int intervalMs = 1000}) {
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      final simulatedData = {
        'sensor': SensorType.simulatedData.displayName,
        'timestamp': DateTime.now().toIso8601String(),
        'x': _random.nextDouble() * 10 - 5, // Werte zwischen -5 und 5
        'y': _random.nextDouble() * 10 - 5,
        'z': _random.nextDouble() * 10 - 5,
      };

      // Daten an den Server senden
      try {
        channel.sink.add(jsonEncode(simulatedData));
        print('Generated Data: $simulatedData');
      } catch (e) {
        print('Fehler beim Senden der Daten: $e');
      }

      // Callback aufrufen
      onDataGenerated(simulatedData);
    });
  }

  void stopSimulation() {
    _timer.cancel();
    try {
      print('WebSocket-Verbindung geschlossen');
    } catch (e) {
      print('Fehler beim Schließen der WebSocket-Verbindung: $e');
    }
  }
}
