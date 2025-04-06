import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';

class Multiselectdialogwidget extends StatefulWidget {
  const Multiselectdialogwidget({
    Key? key,
    required this.items,
    required this.initialSelectedValues,
  }) : super(key: key);

  final List<MultiSelectDialogItem> items;
  final Set<MultiSelectDialogItem> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<Multiselectdialogwidget> {
  var _selectedSensors = <MultiSelectDialogItem>{};

  @override
  void initState() {
    super.initState();
    _selectedSensors = widget.initialSelectedValues;
  }

  void _onItemCheckedChange(MultiSelectDialogItem sensor, bool checked) {
    setState(() {
      if (checked) {
        _selectedSensors.add(sensor);
      } else {
        _selectedSensors.remove(sensor);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedSensors);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sensorauswahl'),
      contentPadding: const EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(children: widget.items.map(_buildItem).toList()),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(onPressed: _onCancelTap, child: const Text('CANCEL')),
        ElevatedButton(onPressed: _onSubmitTap, child: const Text('OK')),
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem item) {
    final checked = _selectedSensors.contains(item);
    return item.type == ItemType.data
        ? CheckboxListTile(
          value: checked,
          title: Text(item.attribute!),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) => _onItemCheckedChange(item, checked!),
        )
        : Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              item.sensorName,
              style: TextStyle(color: Color.fromARGB(255, 91, 91, 91)),
            ),
          ),
        );
  }
}
