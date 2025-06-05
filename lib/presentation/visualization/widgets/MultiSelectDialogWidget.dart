import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SensorSelectionWithColor {
  final MultiSelectDialogItem sensor;
  final Color color;

  SensorSelectionWithColor({required this.sensor, required this.color});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensorSelectionWithColor && other.sensor == sensor;
  }

  @override
  int get hashCode => sensor.hashCode;
}

class Multiselectdialogwidget extends StatefulWidget {
  const Multiselectdialogwidget({
    Key? key,
    required this.initialSelectedValues,
    this.initialSelectedColors = const {},
  }) : super(key: key);

  final Map<String, Set<MultiSelectDialogItem>> initialSelectedValues;
  final Map<String, Map<MultiSelectDialogItem, Color>> initialSelectedColors;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<Multiselectdialogwidget> {
  Map<String, Set<MultiSelectDialogItem>> _selectedSensors = {};
  Map<String, Map<MultiSelectDialogItem, Color>> _selectedColors = {};
  late String _currentSelectedDevice;

  final List<Color> _predefinedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _selectedSensors = Map.from(widget.initialSelectedValues);
    _selectedColors = Map.from(widget.initialSelectedColors);

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

        _selectedColors.putIfAbsent(_currentSelectedDevice, () => {});
        if (!_selectedColors[_currentSelectedDevice]!.containsKey(sensor)) {
          _selectedColors[_currentSelectedDevice]![sensor] =
              _getNextAvailableColor();
        }
      } else {
        _selectedSensors[_currentSelectedDevice]?.remove(sensor);
        _selectedColors[_currentSelectedDevice]?.remove(sensor);
      }
    });
  }

  Color _getNextAvailableColor() {
    final usedColors =
        _selectedColors[_currentSelectedDevice]?.values.toSet() ?? {};
    for (Color color in _predefinedColors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }
    return Colors.primaries[DateTime.now().millisecond %
        Colors.primaries.length];
  }

  void _showColorPicker(MultiSelectDialogItem sensor) {
    Color pickerColor =
        _selectedColors[_currentSelectedDevice]?[sensor] ?? Colors.red;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Farbe für ${sensor.attribute?.displayName ?? sensor.sensorName.displayName}',
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedColors.putIfAbsent(_currentSelectedDevice, () => {});
                  _selectedColors[_currentSelectedDevice]![sensor] =
                      pickerColor;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Übernehmen'),
            ),
          ],
        );
      },
    );
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, {
      'sensors': _selectedSensors,
      'colors': _selectedColors,
    });
  }

  Map<String, Map<MultiSelectDialogItem, Color>> getSelectedColors() {
    return _selectedColors;
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
          value: entry.key,
          child: Text('${entry.value} (${entry.key})'),
        );
      }),
    ];

    return AlertDialog(
      title: const Text('Sensorauswahl'),
      contentPadding: const EdgeInsets.all(20.0),
      content: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
    final itemColor = _selectedColors[_currentSelectedDevice]?[item];

    return item.type == ItemType.data
        ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: checked,
                  title: Text(item.attribute!.displayName),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) => _onItemCheckedChange(item, checked!),
                ),
              ),
              if (checked) ...[
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: itemColor ?? Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.palette, size: 20),
                  onPressed: () => _showColorPicker(item),
                  tooltip: 'Farbe ändern',
                ),
              ] else
                const SizedBox(width: 64),
            ],
          ),
        )
        : Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              item.sensorName.displayName,
              style: const TextStyle(
                color: Color.fromARGB(255, 91, 91, 91),
                fontWeight: FontWeight.bold,
              ),
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
