import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';

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

  static List<MultiSelectDialogItem> getSensorChoices() {
    return <MultiSelectDialogItem>[
      MultiSelectDialogItem(
        sensorName: 'Beschleunigungs-Sensor',
        type: ItemType.seperator,
      ),
      MultiSelectDialogItem(
        sensorName: 'Beschleunigungs-Sensor',
        attribute: 'x',
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: 'Beschleunigungs-Sensor',
        attribute: 'y',
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: 'Beschleunigungs-Sensor',
        attribute: 'z',
        type: ItemType.data,
      ),

      MultiSelectDialogItem(sensorName: 'Gyroskop', type: ItemType.seperator),
      MultiSelectDialogItem(
        sensorName: 'Gyroskop',
        attribute: 'x',
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: 'Gyroskop',
        attribute: 'y',
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: 'Gyroskop',
        attribute: 'z',
        type: ItemType.data,
      ),

      MultiSelectDialogItem(
        sensorName: 'Magnetometer',
        type: ItemType.seperator,
      ),
      MultiSelectDialogItem(
        sensorName: 'Magnetometer',
        attribute: 'x',
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: 'Magnetometer',
        attribute: 'y',
        type: ItemType.data,
      ),
      MultiSelectDialogItem(
        sensorName: 'Magnetometer',
        attribute: 'z',
        type: ItemType.data,
      ),
    ];
  }
}
