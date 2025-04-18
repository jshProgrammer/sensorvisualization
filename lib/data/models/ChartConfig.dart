import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartConfig {
  final String id;
  final String title;
  final Map<String, List<FlSpot>> dataPoints;
  final Map<int, String> notes = {};
  final Color color;

  ChartConfig({
    required this.id,
    required this.title,
    required this.dataPoints,
    required this.color,
  });

  void addDataPoint(String sensorName, FlSpot spot) {
    dataPoints.putIfAbsent(sensorName, () => []);
    dataPoints[sensorName]!.add(spot);
  }
}
