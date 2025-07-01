import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/WarningLevelsSelection.dart';
import 'package:tuple/tuple.dart';
import 'MultiselectDialogItem.dart';

class ChartConfig {
  final String id;
  String title;
  final Map<String, Map<Tuple2<SensorType, SensorOrientation>, List<FlSpot>>>
  dataPoints; // ip-address of device -> sensor type and orientation -> data points
  final Map<DateTime, String> notes = {};
  final Color color;
  Map<String, Set<MultiSelectDialogItem>> selectedValues = {};
  Map<String, Map<MultiSelectDialogItem, Color>> selectedColors = {};

  Map<String, List<WarningRange>> ranges = {
    'green': [],
    'yellow': [],
    'red': [],
  };

  ChartConfig({
    required this.id,
    required this.title,
    required this.dataPoints,
    required this.color,
  });

  void addDataPoint(
    String ipAddress,
    SensorType sensorType,
    SensorOrientation sensorOrientation,
    FlSpot spot,
  ) {
    dataPoints.putIfAbsent(ipAddress, () => {});
    dataPoints[ipAddress]!.putIfAbsent(
      Tuple2(sensorType, sensorOrientation),
      () => [],
    );
    dataPoints[ipAddress]![Tuple2(sensorType, sensorOrientation)]!.add(spot);
  }

  void addNote(DateTime time, String noteText) {
    notes[time] = noteText;
  }
}
