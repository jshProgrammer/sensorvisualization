import 'package:flutter/material.dart';

class ColorSettings {
  static final Color lineColor = Colors.black.withOpacity(0.5);
  static final Color borderColor = Colors.orange.withOpacity(0.7);
  //TODO: add stroke color for points with notes instead of whole point
  static final Color pointHoverCritical = Colors.orange;
  static final Color pointHoverDefault = Colors.white;
  static final Color sensorXAxisColor = Colors.green;
  static final Color sensorYAxisColor = Colors.red;
  static final Color sensorZAxisColor = Colors.blue;
  static final Color noteLineColor = Colors.purple;

  static final Color warningLevelGreen = Colors.green;
  static final Color warningLevelYellow = Colors.yellow;
  static final Color warningLevelRed = Colors.red;
}
