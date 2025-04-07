import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';

class QrIpScreen extends StatefulWidget {
  const QrIpScreen({super.key});

  @override
  _QrIpScreenState createState() => _QrIpScreenState();
}

class _QrIpScreenState extends State<QrIpScreen> {
  String? _ipAddress;

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  Future<void> _loadIp() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP(); // lokale IP im WLAN
    setState(() {
      _ipAddress = ip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR mit IP-Adresse")),
      body: Center(
        child:
            _ipAddress == null
                ? CircularProgressIndicator()
                : QrImageView(
                  data: _ipAddress!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
      ),
    );
  }
}
