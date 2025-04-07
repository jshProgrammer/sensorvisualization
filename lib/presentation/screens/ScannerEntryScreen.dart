import 'package:flutter/material.dart';
import 'package:sensorvisualization/presentation/widgets/SensorMessPage.dart';
import 'QRScannerScreen.dart';

class ScannerEntryScreen extends StatefulWidget {
  const ScannerEntryScreen({super.key});

  @override
  State<ScannerEntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<ScannerEntryScreen> {
  final TextEditingController _ipController = TextEditingController();

  void _navigateToSensorPage(String ipAddress) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SensorMessPage(ipAddress: ipAddress),
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
            ElevatedButton.icon(
              onPressed: () async {
                final scannedCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );

                if (scannedCode != null) {
                  _navigateToSensorPage(scannedCode);
                }
              },
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
                if (_ipController.text.isNotEmpty) {
                  _navigateToSensorPage(_ipController.text.trim());
                }
              },
              child: const Text('Weiter zur Messung'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
