import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/data/services/client/old_SensorClient.dart';
import 'package:sensorvisualization/presentation/screens/SensorMeasurement/StartNullMeasurementScreen.dart';
import 'package:sensorvisualization/presentation/screens/SensorMeasurement/SensorMessScreen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key, required this.deviceName});

  final String deviceName;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final String? code = barcodeCapture.barcodes.first.rawValue;
                if (code != null && code != scannedCode) {
                  setState(() {
                    scannedCode = code;
                  });
                  debugPrint('Scanned QR Code: $code');

                  var connection = SensorClient(
                    hostIPAddress: scannedCode!,
                    deviceName: widget.deviceName,
                  );
                  connection.initSocket().then((isConnected) {
                    if (isConnected) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StartNullMeasurementScreen(
                                connection: connection,
                              ),
                        ),
                      );
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
              },
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedCode ??
                    'Scanne den QR-Code, um die Sensordaten zu übermitteln',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
