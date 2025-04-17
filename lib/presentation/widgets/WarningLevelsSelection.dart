import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Warninglevelsselection extends StatefulWidget {
  const Warninglevelsselection({super.key});

  @override
  State<StatefulWidget> createState() => _WarningLevelSelectionState();
}

class _WarningLevelSelectionState extends State<Warninglevelsselection> {
  final TextEditingController greenController1 = TextEditingController();
  final TextEditingController greenController2 = TextEditingController();

  List<Map<String, TextEditingController>> yellowControllers = [];
  List<Map<String, TextEditingController>> redControllers = [];

  @override
  void initState() {
    super.initState();
    _addYellowField();
    _addRedField();
  }

  void _addYellowField() {
    setState(() {
      yellowControllers.add({
        'lower': TextEditingController(),
        'upper': TextEditingController(),
      });
    });
  }

  void _addRedField() {
    setState(() {
      redControllers.add({
        'lower': TextEditingController(),
        'upper': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Warnschwellen'),
      contentPadding: const EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: [
              const Center(child: Text('Nur Zahlen und , erlaubt')),

              _getTextFields(
                'Grüner Bereich',
                greenController1,
                greenController2,
              ),

              ...yellowControllers.asMap().entries.map((entry) {
                int index = entry.key;
                var controllerPair = entry.value;
                return _getTextFields(
                  'Gelber Bereich',
                  controllerPair['lower']!,
                  controllerPair['upper']!,
                  showAddButton: index == 0 && yellowControllers.length < 2,
                  onAdd: _addYellowField,
                  addButtonColor: Colors.amber,
                );
              }),

              ...redControllers.asMap().entries.map((entry) {
                int index = entry.key;
                var controllerPair = entry.value;
                return _getTextFields(
                  'Roter Bereich',
                  controllerPair['lower']!,
                  controllerPair['upper']!,
                  showAddButton: index == 0 && redControllers.length < 2,
                  onAdd: _addRedField,
                  addButtonColor: Colors.red,
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            var ranges = _collectValues();
            Navigator.of(context).pop(ranges);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _getTextFields(
    String headline,
    TextEditingController controller1,
    TextEditingController controller2, {
    VoidCallback? onAdd,
    bool showAddButton = false,
    Color? addButtonColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                headline,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showAddButton) ...[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: addButtonColor ?? Colors.black,
                  onPressed: onAdd,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller1,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Unterer Wert',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text('-', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller2,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Oberer Wert',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, List<WarningRange>> _collectValues() {
    List<WarningRange> greenRanges = [
      WarningRange(
        double.tryParse(greenController1.text.replaceAll(',', '.')) ?? 0.0,
        double.tryParse(greenController2.text.replaceAll(',', '.')) ?? 0.0,
      ),
    ];

    List<WarningRange> yellowRanges =
        yellowControllers.map((controllers) {
          return WarningRange(
            double.tryParse(controllers['lower']!.text.replaceAll(',', '.')) ??
                0.0,
            double.tryParse(controllers['upper']!.text.replaceAll(',', '.')) ??
                0.0,
          );
        }).toList();

    List<WarningRange> redRanges =
        redControllers.map((controllers) {
          return WarningRange(
            double.tryParse(controllers['lower']!.text.replaceAll(',', '.')) ??
                0.0,
            double.tryParse(controllers['upper']!.text.replaceAll(',', '.')) ??
                0.0,
          );
        }).toList();

    return {'green': greenRanges, 'yellow': yellowRanges, 'red': redRanges};
  }
}

class WarningRange {
  final double lower;
  final double upper;

  WarningRange(this.lower, this.upper);

  @override
  String toString() => '[$lower, $upper]';
}
