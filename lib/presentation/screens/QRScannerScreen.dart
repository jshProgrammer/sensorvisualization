import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

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
                }
              },
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedCode ?? 'Scanne einen QR-Code',
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
