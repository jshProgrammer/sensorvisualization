import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:sensorvisualization/data/models/NetworkCommands.dart';

class DeviceInfoManager {
  final Battery _battery = Battery();
  late String localIP;
  bool _localIPInitialized = false;
  Timer? _batteryTimer;

  final Function(Map<String, dynamic>) onDeviceInfo;

  DeviceInfoManager({required this.onDeviceInfo});

  void startBatteryMonitoring() {
    sendBatteryInformation();

    _batteryTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      await sendBatteryInformation();
    });
  }

  Future<void> sendBatteryInformation() async {
    onDeviceInfo({
      "ip": await retrieveLocalIP(),
      "command": NetworkCommands.BatteryLevel.command,
      "level": await _battery.batteryLevel,
    });
  }

  void stopBatteryMonitoring() {
    _batteryTimer?.cancel();
    _batteryTimer = null;
  }

  Future<String?> retrieveLocalIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    if (!_localIPInitialized) {
      localIP = wifiIP ?? '';
      _localIPInitialized = true;
    }

    return wifiIP;
  }
}
