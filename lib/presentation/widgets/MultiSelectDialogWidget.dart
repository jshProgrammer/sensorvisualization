import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/models/SensorOrientation.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';

class Multiselectdialogwidget extends StatefulWidget {
  const Multiselectdialogwidget({Key? key, required this.initialSelectedValues})
    : super(key: key);

  final Map<String, Set<MultiSelectDialogItem>>
  initialSelectedValues; // device name => (multiple) sensors

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<Multiselectdialogwidget> {
  Map<String, Set<MultiSelectDialogItem>> _selectedSensors = {};
  late String _currentSelectedDevice; // ip-address

  @override
  void initState() {
    super.initState();
    _selectedSensors = widget.initialSelectedValues;

    final devices =
        Provider.of<ConnectionProvider>(
          context,
          listen: false,
        ).connectedDevices;
    _currentSelectedDevice =
        devices.keys.isNotEmpty
            ? devices.keys.first
            : SensorType.simulatedData.displayName;
  }

  void _onItemCheckedChange(MultiSelectDialogItem sensor, bool checked) {
    setState(() {
      if (checked) {
        _selectedSensors.putIfAbsent(
          _currentSelectedDevice,
          () => <MultiSelectDialogItem>{},
        );
        _selectedSensors[_currentSelectedDevice]!.add(sensor);
      } else {
        _selectedSensors[_currentSelectedDevice]!.remove(sensor);
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
    final connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );
    final deviceEntries = connectionProvider.connectedDevices.entries.toList();

    final dropdownItems = [
      DropdownMenuItem<String>(
        value: SensorType.simulatedData.displayName,
        child: Text(SensorType.simulatedData.displayName),
      ),
      ...deviceEntries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key, // z. B. "192.168.1.5"
          child: Text('${entry.value} (${entry.key})'),
        );
      }),
    ];

    return AlertDialog(
      title: const Text('Sensorauswahl'),
      contentPadding: const EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButton<String>(
              value: _currentSelectedDevice,
              hint: const Text('Sensor auswählen'),
              items: dropdownItems,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSelectedDevice = newValue ?? _currentSelectedDevice;
                });
              },
            ),
            const SizedBox(height: 20.0),
            ListTileTheme(
              contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
              child: ListBody(
                children:
                    getSensorChoices(
                      _currentSelectedDevice ==
                              SensorType.simulatedData.displayName
                          ? SensorType.simulatedData
                          : SensorType.accelerometer,
                    ).map(_buildItem).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(onPressed: _onCancelTap, child: const Text('CANCEL')),
        ElevatedButton(onPressed: _onSubmitTap, child: const Text('OK')),
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem item) {
    final selectedSet = _selectedSensors[_currentSelectedDevice] ?? {};
    final checked = selectedSet.contains(item);

    return item.type == ItemType.data
        ? CheckboxListTile(
          value: checked,
          title: Text(item.attribute!.displayName),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) => _onItemCheckedChange(item, checked!),
        )
        : Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              item.sensorName.displayName,
              style: TextStyle(color: Color.fromARGB(255, 91, 91, 91)),
            ),
          ),
        );
  }

  List<MultiSelectDialogItem> getSensorChoices(SensorType sensorName) {
    if (sensorName == SensorType.simulatedData) {
      return [
        MultiSelectDialogItem(
          sensorName: SensorType.simulatedData,
          type: ItemType.seperator,
        ),
        MultiSelectDialogItem(
          sensorName: SensorType.simulatedData,
          attribute: SensorOrientation.x,
          type: ItemType.data,
        ),
        MultiSelectDialogItem(
          sensorName: SensorType.simulatedData,
          attribute: SensorOrientation.y,
          type: ItemType.data,
        ),
        MultiSelectDialogItem(
          sensorName: SensorType.simulatedData,
          attribute: SensorOrientation.z,
          type: ItemType.data,
        ),
      ];
    }
    return <MultiSelectDialogItem>[
      MultiSelectDialogItem(
        sensorName: SensorType.accelerometer,
        type: ItemType.seperator,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.accelerometer,
        attribute: SensorOrientation.x,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.accelerometer,
        attribute: SensorOrientation.y,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.accelerometer,
        attribute: SensorOrientation.z,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.deviationTo90Degrees,
        type: ItemType.seperator,
      ),

      MultiSelectDialogItem(
        sensorName: SensorType.deviationTo90Degrees,
        attribute: SensorOrientation.degree,
        type: ItemType.data,
      ),

      MultiSelectDialogItem(
        sensorName: SensorType.displacementOneMeter,
        type: ItemType.seperator,
      ),

      MultiSelectDialogItem(
        sensorName: SensorType.displacementOneMeter,
        attribute: SensorOrientation.displacement,
        type: ItemType.data,
      ),

      MultiSelectDialogItem(
        sensorName: SensorType.gyroscope,
        type: ItemType.seperator,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.gyroscope,
        attribute: SensorOrientation.x,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.gyroscope,
        attribute: SensorOrientation.y,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.gyroscope,
        attribute: SensorOrientation.z,
        type: ItemType.data,
      ),

      MultiSelectDialogItem(
        sensorName: SensorType.magnetometer,
        type: ItemType.seperator,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.magnetometer,
        attribute: SensorOrientation.x,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.magnetometer,
        attribute: SensorOrientation.y,
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: SensorType.magnetometer,
        attribute: SensorOrientation.z,
        type: ItemType.data,
      ),
    ];
  }
}
