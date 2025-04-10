import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Warninglevelsselection extends StatefulWidget {
  const Warninglevelsselection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WarningLevelSelectionState();
}

class _WarningLevelSelectionState extends State<Warninglevelsselection> {
  //TODO: Gelber & Roter Bereich: Möglichkeit für 2. Bereich + evtl Rahmenfarben
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
              Center(child: Text('Nur Zahlen und , erlaubt')),
              _getTextFields('Grüner Bereich'),
              _getTextFields('Gelber Bereich'),
              _getTextFields('Roter Bereich'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _getTextFields(String headline) {
  final TextEditingController _controller = TextEditingController();
  return Padding(
    padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
    child: Column(
      children: [
        Text(headline),
        SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Zwei Kommazahlen eingeben',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
          ],
        ),
      ],
    ),
  );
}
