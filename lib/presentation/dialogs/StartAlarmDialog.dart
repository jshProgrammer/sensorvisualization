import 'package:flutter/material.dart';
import 'package:sensorvisualization/controller/server/VisualizationHomeController.dart';

class StartAlarmDialog extends StatefulWidget {
  final VisualizationHomeController controller;

  const StartAlarmDialog({super.key, required this.controller});

  @override
  State<StartAlarmDialog> createState() => _StartAlarmDialogState();
}

class _StartAlarmDialogState extends State<StartAlarmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Alarm auslösen"),
      content: TextField(
        decoration: InputDecoration(
          labelText: "Alarmmeldung",
          hintText: "Geben Sie eine Nachricht ein",
        ),
        onSubmitted: (value) {
          widget.controller.sendAlarm(value);
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.controller.sendAlarm("Alarm!");
            Navigator.pop(context);
          },
          child: Text("Alarm auslösen"),
        ),
      ],
    );
  }
}
