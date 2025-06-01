import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:sensorvisualization/controller/server/VisualizationHomeController.dart';

class QRCodeDialog extends StatefulWidget {
  final VisualizationHomeController controller;

  const QRCodeDialog({super.key, required this.controller});

  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: widget.controller.getWifiIP(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final ip = snapshot.data!;
        return AlertDialog(
          title: const Text('QR-Code der IP-Adresse'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrettyQrView.data(data: ip),
              const SizedBox(height: 10),
              Text('IP-Adresse: $ip', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Schließen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
