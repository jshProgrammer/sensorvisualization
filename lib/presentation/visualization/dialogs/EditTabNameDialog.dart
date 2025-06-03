import 'package:flutter/material.dart';
import 'package:sensorvisualization/controller/visualization/VisualizationHomeController.dart';

class EditTabNameDialog extends StatefulWidget {
  final VisualizationHomeController controller;

  const EditTabNameDialog({super.key, required this.controller});

  @override
  State<EditTabNameDialog> createState() => _EditTabNameDialogState();
}

class _EditTabNameDialogState extends State<EditTabNameDialog> {
  @override
  Widget build(BuildContext context) {
    final currentTitle =
        widget.controller.tabs[widget.controller.selectedTabIndex].title;
    final controller = TextEditingController(text: currentTitle);

    return AlertDialog(
      title: const Text('Tab umbenennen'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Neuer Name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) {
              widget.controller.renameCurrentTab(value);
              Navigator.pop(context, value);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
