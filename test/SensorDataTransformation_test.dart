// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';

import 'package:sensorvisualization/main.dart';

void main() {
  test('test transformSingleAbsoluteToRelativeValue', () {
    double absolute = 5.0;
    double nullMeasure = 0.7;

    double result =
        SensorDataTransformation.transformSingleAbsoluteToRelativeValue(
          absolute,
          nullMeasure,
        );

    expect(4.3, result);
  });

  test('test transformDateTimeToSecondsSinceStart', () {
    GlobalStartTime().initializeStartTime();
    DateTime dateTime = DateTime.now().add(Duration(minutes: 5));

    int result = SensorDataTransformation.transformDateTimeToSecondsSinceStart(
      dateTime,
    );

    expect(300, result);
  });

  test('test transformDateTimeToSecondsAsDouble', () {
    DateTime dateTime = DateTime(2025, 2, 3, 10, 0, 0, 0, 0);

    double result = SensorDataTransformation.transformDateTimeToSecondsAsDouble(
      dateTime,
    );

    expect(1738573200.0, result);
  });

  test('test transformAbsoluteToRelativeValues', () {
    final nullMeasurement = {
      SensorOrientation.x: -24.285791397094727,
      SensorOrientation.y: -244.5594904763358,
      SensorOrientation.z: -820.3019812447684,
    };

    final absoluteSensorValues = {
      'x': -14.925460815429688,
      'y': -249.3329315185547,
      'z': -820.397216796875,
    };

    final result = SensorDataTransformation.transformAbsoluteToRelativeValues(
      nullMeasurement,
      absoluteSensorValues,
      SensorType.magnetometer,
    );

    expect(result[SensorOrientation.x], closeTo(9.36, 0.01));
    expect(result[SensorOrientation.y], closeTo(-4.77, 0.01));
    expect(result[SensorOrientation.z], closeTo(-0.10, 0.01));
  });

  group('test returnAbsoluteSensorDataAsJson', () {
    test('barometer test', () {
      final input = {
        'sensor': 'Barometer',
        'timestamp': '2025-05-03 15:36:31.455146',
        'pressure': '977.4253845214844',
      };

      final result = SensorDataTransformation.returnAbsoluteSensorDataAsJson(
        input,
      );

      expect(result['sensor'], 'Barometer');
      expect(result['pressure'], closeTo(977.4253845, 0.0001));
      expect(result['timestamp'], isA<DateTime>());
      expect(result['timestamp'].toString(), '2025-05-03 15:36:31.455146');
    });

    test('test for data with x, y, z', () {
      final input = {
        'sensor': 'Magnetometer',
        'timestamp': '2025-05-03 15:36:27.037277',
        'x': '-15.96807861328125',
        'y': '-248.13999938964844',
        'z': '-821.0382080078125',
      };

      final result = SensorDataTransformation.returnAbsoluteSensorDataAsJson(
        input,
      );

      expect(result['sensor'], 'Magnetometer');
      expect(result['x'], closeTo(-15.9681, 0.0001));
      expect(result['y'], closeTo(-248.14, 0.0001));
      expect(result['z'], closeTo(-821.0382, 0.0001));
      expect(result['timestamp'], isA<DateTime>());
      expect(result['timestamp'].toString(), '2025-05-03 15:36:27.037277');
    });
  });
}
