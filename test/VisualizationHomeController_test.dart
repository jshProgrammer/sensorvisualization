import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensorvisualization/data/settingsModels/ChartConfig.dart';
import 'package:sensorvisualization/data/settingsModels/ChartTab.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('ChartConfig Tests', () {
    test('Should create ChartConfig with correct values', () {
      final chart = ChartConfig(
        id: 'test_id',
        title: 'Test Title',
        dataPoints: {
          'sensor1': {
            Tuple2(SensorType.accelerometer, SensorOrientation.x): [
              FlSpot(1, 2),
              FlSpot(2, 3),
            ],
          },
        },
        color: Colors.blue,
      );

      expect(chart.id, 'test_id');
      expect(chart.title, 'Test Title');
      expect(chart.dataPoints['sensor1']!.length, 1);
      expect(chart.color, Colors.blue);
    });

    test('Should handle empty dataPoints', () {
      final chart = ChartConfig(
        id: 'empty_chart',
        title: 'Empty Chart',
        dataPoints: {},
        color: Colors.red,
      );

      expect(chart.dataPoints.isEmpty, true);
    });
  });

  group('ChartTab Tests', () {
    test('Should create ChartTab with correct values', () {
      final charts = [
        ChartConfig(
          id: 'chart1',
          title: 'Chart 1',
          dataPoints: {},
          color: Colors.red,
        ),
      ];

      final tab = ChartTab(title: 'Test Tab', charts: charts);

      expect(tab.title, 'Test Tab');
      expect(tab.charts.length, 1);
      expect(tab.charts[0].id, 'chart1');
    });

    test('Should handle empty charts list', () {
      final tab = ChartTab(title: 'Empty Tab', charts: []);

      expect(tab.title, 'Empty Tab');
      expect(tab.charts.isEmpty, true);
    });

    test('Should handle multiple charts', () {
      final charts = [
        ChartConfig(
          id: 'chart1',
          title: 'Chart 1',
          dataPoints: {},
          color: Colors.red,
        ),
        ChartConfig(
          id: 'chart2',
          title: 'Chart 2',
          dataPoints: {},
          color: Colors.blue,
        ),
      ];

      final tab = ChartTab(title: 'Multi Chart Tab', charts: charts);

      expect(tab.charts.length, 2);
      expect(tab.charts[0].title, 'Chart 1');
      expect(tab.charts[1].title, 'Chart 2');
    });
  });

  group('Basic Logic Tests', () {
    test('Should calculate time units correctly', () {
      int calculateSeconds(int value, int unitChoice) {
        switch (unitChoice) {
          case 0:
            return value;
          case 1:
            return value * 60;
          case 2:
            return value * 3600;
          default:
            return value;
        }
      }

      expect(calculateSeconds(5, 0), 5);
      expect(calculateSeconds(5, 1), 300);
      expect(calculateSeconds(5, 2), 18000);
    });

    test('Should handle invalid time unit', () {
      int calculateSeconds(int value, int unitChoice) {
        switch (unitChoice) {
          case 0:
            return value;
          case 1:
            return value * 60;
          case 2:
            return value * 3600;
          default:
            return value;
        }
      }

      expect(calculateSeconds(10, 99), 10);
    });

    test('Should parse integers correctly', () {
      expect(int.tryParse('123'), 123);
      expect(int.tryParse('invalid'), null);
      expect(int.tryParse(''), null);
      expect(int.tryParse('0'), 0);
    });
  });
}
