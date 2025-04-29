// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
