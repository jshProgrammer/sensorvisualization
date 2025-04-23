import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Warninglevelsselection extends StatefulWidget {
  final Map<String, List<WarningRange>>? initialValues;

  const Warninglevelsselection({super.key, this.initialValues});

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

    if (widget.initialValues != null) {
      if (widget.initialValues!['green'] != null &&
          widget.initialValues!['green']!.isNotEmpty) {
        final greenRange = widget.initialValues!['green']![0];
        if (greenRange.lower != 0.0 || greenRange.upper != 0.0) {
          greenController1.text = greenRange.lower.toString();
          greenController2.text = greenRange.upper.toString();
        }
      }

      if (widget.initialValues!['yellow'] != null &&
          widget.initialValues!['yellow']!.isNotEmpty) {
        for (var range in widget.initialValues!['yellow']!) {
          if (range.lower != 0.0 || range.upper != 0.0) {
            yellowControllers.add({
              'lower': TextEditingController(text: range.lower.toString()),
              'upper': TextEditingController(text: range.upper.toString()),
            });
          }
        }
      }

      // Rote Bereiche
      if (widget.initialValues!['red'] != null &&
          widget.initialValues!['red']!.isNotEmpty) {
        for (var range in widget.initialValues!['red']!) {
          if (range.lower != 0.0 || range.upper != 0.0) {
            redControllers.add({
              'lower': TextEditingController(text: range.lower.toString()),
              'upper': TextEditingController(text: range.upper.toString()),
            });
          }
        }
      }
    }

    if (yellowControllers.isEmpty) {
      _addYellowField();
    }

    if (redControllers.isEmpty) {
      _addRedField();
    }
  }

  Map<String, List<WarningRange>> _collectValues() {
    List<WarningRange> greenRanges = [];

    if (greenController1.text.isNotEmpty && greenController2.text.isNotEmpty) {
      greenRanges.add(
        WarningRange(
          double.tryParse(greenController1.text.replaceAll(',', '.')) ?? 0.0,
          double.tryParse(greenController2.text.replaceAll(',', '.')) ?? 0.0,
        ),
      );
    }

    List<WarningRange> yellowRanges =
        yellowControllers
            .where(
              (controllers) =>
                  controllers['lower']!.text.isNotEmpty &&
                  controllers['upper']!.text.isNotEmpty,
            )
            .map((controllers) {
              return WarningRange(
                double.tryParse(
                      controllers['lower']!.text.replaceAll(',', '.'),
                    ) ??
                    0.0,
                double.tryParse(
                      controllers['upper']!.text.replaceAll(',', '.'),
                    ) ??
                    0.0,
              );
            })
            .toList();

    List<WarningRange> redRanges =
        redControllers
            .where(
              (controllers) =>
                  controllers['lower']!.text.isNotEmpty &&
                  controllers['upper']!.text.isNotEmpty,
            )
            .map((controllers) {
              return WarningRange(
                double.tryParse(
                      controllers['lower']!.text.replaceAll(',', '.'),
                    ) ??
                    0.0,
                double.tryParse(
                      controllers['upper']!.text.replaceAll(',', '.'),
                    ) ??
                    0.0,
              );
            })
            .toList();

    return {'green': greenRanges, 'yellow': yellowRanges, 'red': redRanges};
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
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s, -]')),
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
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s, -]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WarningRange {
  final double lower;
  final double upper;

  WarningRange(this.lower, this.upper);

  @override
  String toString() => '[$lower, $upper]';
}
