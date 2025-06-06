import 'dart:ui';

import 'package:sensorvisualization/data/services/SensorDataSimulator.dart';
import 'package:sensorvisualization/data/settingsModels/ChartConfig.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';

class ChartModel {
  final ChartConfig chartConfig;

  final Map<String, Set<MultiSelectDialogItem>>? selectedValues;
  Map<String, Map<MultiSelectDialogItem, Color>> selectedColors = {};

  double baselineX = 0.0;

  bool autoFollowLatestData = true;
  bool isPanEnabled = false;

  int? selectedPointIndex;

  late DateTime startTime;
  late DateTime defaultTime;

  List<DateTime> allDangerTimestamps = [];
  late SensorDataSimulator simulator;
  bool isSimulationRunning = false;

  final void Function(Map<String, Set<MultiSelectDialogItem>>)?
  onSelectedValuesChanged;

  ChartModel({required this.chartConfig})
    : selectedValues = null,
      onSelectedValuesChanged = null {
    startTime = DateTime.now();
  }

  ChartModel.withSelectedValues({
    required this.chartConfig,
    required this.selectedValues,
    required this.onSelectedValuesChanged,
  }) {
    startTime = DateTime.now();
  }

  set allDangerTimes(List<DateTime> allDangerTimes) {}

  DateTime truncateToSeconds(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }
}
