import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/WarningLevelsSelection.dart';
import 'package:tuple/tuple.dart';

class VisualizationSensorDataModel {
  final Map<String, Map<Tuple2<SensorType, SensorOrientation>, List<FlSpot>>>
  dataPoints;
  final Map<DateTime, String> notes;
  final Map<String, List<WarningRange>> warningRanges;

  final Map<String, Set<MultiSelectDialogItem>> selectedSensors;

  VisualizationSensorDataModel({
    required this.dataPoints,
    required this.notes,
    Map<String, List<WarningRange>>? warningRanges,

    required this.selectedSensors,
  }) : warningRanges = warningRanges ?? {'green': [], 'yellow': [], 'red': []};

  List<FlSpot> getDataPointsForSensor(
    String ipAddress,
    SensorType sensorType,
    SensorOrientation orientation,
  ) {
    return dataPoints[ipAddress]?[Tuple2(sensorType, orientation)] ?? [];
  }

  void addDataPoint(
    String ipAddress,
    SensorType sensorType,
    SensorOrientation orientation,
    FlSpot point,
  ) {
    dataPoints.putIfAbsent(ipAddress, () => {});
    dataPoints[ipAddress]!.putIfAbsent(
      Tuple2(sensorType, orientation),
      () => [],
    );
    dataPoints[ipAddress]![Tuple2(sensorType, orientation)]!.add(point);
  }

  void addNote(DateTime timestamp, String note) {
    notes[timestamp] = note;
  }

  void updateWarningRanges(String level, List<WarningRange> ranges) {
    warningRanges[level] = ranges;
  }

  bool isSensorSelected(String device, MultiSelectDialogItem sensor) {
    return selectedSensors[device]?.contains(sensor) ?? false;
  }

  void toggleSensor(String device, MultiSelectDialogItem sensor) {
    selectedSensors.putIfAbsent(device, () => {});
    if (selectedSensors[device]!.contains(sensor)) {
      selectedSensors[device]!.remove(sensor);
    } else {
      selectedSensors[device]!.add(sensor);
    }
  }

  List<MultiSelectDialogItem> getSelectedSensorsForDevice(String device) {
    return selectedSensors[device]?.toList() ?? [];
  }

  Iterable<MapEntry<String, Set<MultiSelectDialogItem>>> get activeSelections {
    return selectedSensors.entries.where((entry) => entry.key.isNotEmpty);
  }
}
