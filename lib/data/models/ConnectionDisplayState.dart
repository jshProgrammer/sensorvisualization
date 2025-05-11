import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ConnectionDisplayState {
  connected,
  disconnected,
  nullMeasurement,
  delayedMeasurement,
}

extension ConnectionDisplayStateExtension on ConnectionDisplayState {
  String get displayName {
    switch (this) {
      case ConnectionDisplayState.connected:
        return 'Verbunden';
      case ConnectionDisplayState.disconnected:
        return 'Getrennt';
      case ConnectionDisplayState.nullMeasurement:
        return 'Nullmessung';
      case ConnectionDisplayState.delayedMeasurement:
        return 'Selbstauslöser';
    }
  }

  Color get iconColor {
    switch (this) {
      case ConnectionDisplayState.connected:
        return Colors.green;

      case ConnectionDisplayState.disconnected:
        return Colors.red;

      case ConnectionDisplayState.nullMeasurement:
        return Colors.yellow;

      case ConnectionDisplayState.delayedMeasurement:
        return Colors.blueGrey;
    }
  }
}
