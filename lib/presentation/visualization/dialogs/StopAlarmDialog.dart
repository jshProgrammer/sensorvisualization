import 'package:flutter/material.dart';
import 'package:sensorvisualization/controller/visualization/VisualizationHomeController.dart';

class StopAlarmDialog extends StatefulWidget {
  final VisualizationHomeController controller;

  const StopAlarmDialog({super.key, required this.controller});

  @override
  State<StopAlarmDialog> createState() => _StopAlarmDialogState();
}

class _StopAlarmDialogState extends State<StopAlarmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Aktiver Alarm"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, color: Colors.red, size: 50),
          SizedBox(height: 16),
          Text(
            "Es ist ein Alarm aktiv. Möchten Sie den Alarm für alle Geräte beenden?",
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.controller.stopAlarm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text("Alarm beenden"),
        ),
      ],
    );
  }
}
