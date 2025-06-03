import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/presentation/measurement/StartNullMeasurementView.dart';

import 'QRScannerScreen.dart';

class ScannerEntryScreen extends StatefulWidget {
  const ScannerEntryScreen({super.key});

  @override
  State<ScannerEntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<ScannerEntryScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();

  bool _isDeviceNameEntered = false;
  late SensorClient connection;

  @override
  void initState() {
    super.initState();
    _deviceNameController.addListener(() {
      setState(() {
        _isDeviceNameEntered = _deviceNameController.text.trim().isNotEmpty;
      });
    });
  }

  void _navigateToStartMeasurementPage(String ipAddress) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StartNullMeasurementView(connection: connection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensorverbindung wählen')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Anzuzeigender Gerätename',
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _handleQRCodeScan(),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR-Code scannen'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Oder IP-Adresse manuell eingeben:'),
            const SizedBox(height: 10),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'IP-Adresse',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _handleManualIPInput();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Weiter zur Messung'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQRCodeScan() async {
    if (_isDeviceNameEntered) {
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder:
              (context) => QRScannerScreen(
                deviceName: _deviceNameController.text.trim(),
              ),
        ),
      );
      if (scannedCode != null) {
        _navigateToStartMeasurementPage(scannedCode);
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Fehlender Gerätename'),
              content: const Text('Bitte gib zuerst einen Gerätenamen ein.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void _handleManualIPInput() {
    if (_isDeviceNameEntered) {
      if (_ipController.text.isNotEmpty) {
        connection = SensorClient(
          hostIPAddress: _ipController.text.trim(),
          deviceName: _deviceNameController.text.trim(),
        );
        connection.initSocket().then((isConnected) {
          if (isConnected) {
            _navigateToStartMeasurementPage(_ipController.text.trim());
          } else {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Verbindungsfehler'),
                    content: const Text(
                      'Die Verbindung zum Sensor konnte nicht hergestellt werden. Bitte überprüfe die IP-Adresse.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        });
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Fehlender Gerätename'),
              content: const Text('Bitte gib zuerst einen Gerätenamen ein.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}
