import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/models/SensorOrientation.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';

class SampleData {
  static List<FlSpot> getPoints1(int newIndex) {
    return [
      FlSpot(0, 1 + (newIndex * 0.5)),
      FlSpot(1, 3 - (newIndex * 0.3)),
      FlSpot(2, 2 + (newIndex * 0.2)),
      FlSpot(3, 1.5 - (newIndex * 0.1)),
      FlSpot(4, 2.5 + (newIndex * 0.4)),
      FlSpot(5, 3 - (newIndex * 0.5)),
      FlSpot(6, 2 + (newIndex * 0.3)),
    ];
  }

  static List<FlSpot> getPoints2(int newIndex) {
    return [
      FlSpot(0, 2 + (newIndex * 0.5)),
      FlSpot(1, 4 - (newIndex * 0.3)),
      FlSpot(2, 3 + (newIndex * 0.2)),
      FlSpot(3, 3.5 - (newIndex * 0.1)),
      FlSpot(4, 1.5 + (newIndex * 0.4)),
      FlSpot(5, 4 - (newIndex * 0.5)),
      FlSpot(6, 3 + (newIndex * 0.3)),
    ];
  }

  //TODO: move to another file
  static List<MultiSelectDialogItem> getSensorChoices(SensorType sensorName) {
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
