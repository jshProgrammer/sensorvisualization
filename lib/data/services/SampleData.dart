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

  static List<MultiSelectDialogItem> getXYZ() {
    return <MultiSelectDialogItem>[
      MultiSelectDialogItem(
        name: 'Argentina',
        type: ItemType.seperator,
        value: 1,
      ),
      MultiSelectDialogItem(name: 'Cordoba', type: ItemType.data, value: 2),
      MultiSelectDialogItem(name: 'Chaco', type: ItemType.data, value: 3),
      MultiSelectDialogItem(
        name: 'Buenos Aires',
        type: ItemType.data,
        value: 4,
      ),
      MultiSelectDialogItem(name: 'USA', type: ItemType.seperator, value: 5),
      MultiSelectDialogItem(name: 'California', type: ItemType.data, value: 6),
      MultiSelectDialogItem(name: 'Florida', type: ItemType.data, value: 7),
    ];
  }
}
