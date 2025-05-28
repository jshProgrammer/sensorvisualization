import 'package:sensors_plus/sensors_plus.dart';

class SensorDataModel {
  final UserAccelerometerEvent? userAccelerometerEvent;
  final AccelerometerEvent? accelerometerEvent;
  final GyroscopeEvent? gyroscopeEvent;
  final MagnetometerEvent? magnetometerEvent;
  final BarometerEvent? barometerEvent;

  final DateTime? userAccelerometerUpdateTime;
  final DateTime? accelerometerUpdateTime;
  final DateTime? gyroscopeUpdateTime;
  final DateTime? magnetometerUpdateTime;
  final DateTime? barometerUpdateTime;

  final int? userAccelerometerLastInterval;
  final int? accelerometerLastInterval;
  final int? gyroscopeLastInterval;
  final int? magnetometerLastInterval;
  final int? barometerLastInterval;

  const SensorDataModel({
    this.userAccelerometerEvent,
    this.accelerometerEvent,
    this.gyroscopeEvent,
    this.magnetometerEvent,
    this.barometerEvent,
    this.userAccelerometerUpdateTime,
    this.accelerometerUpdateTime,
    this.gyroscopeUpdateTime,
    this.magnetometerUpdateTime,
    this.barometerUpdateTime,
    this.userAccelerometerLastInterval,
    this.accelerometerLastInterval,
    this.gyroscopeLastInterval,
    this.magnetometerLastInterval,
    this.barometerLastInterval,
  });

  SensorDataModel copyWith({
    UserAccelerometerEvent? userAccelerometerEvent,
    AccelerometerEvent? accelerometerEvent,
    GyroscopeEvent? gyroscopeEvent,
    MagnetometerEvent? magnetometerEvent,
    BarometerEvent? barometerEvent,
    DateTime? userAccelerometerUpdateTime,
    DateTime? accelerometerUpdateTime,
    DateTime? gyroscopeUpdateTime,
    DateTime? magnetometerUpdateTime,
    DateTime? barometerUpdateTime,
    int? userAccelerometerLastInterval,
    int? accelerometerLastInterval,
    int? gyroscopeLastInterval,
    int? magnetometerLastInterval,
    int? barometerLastInterval,
  }) {
    return SensorDataModel(
      userAccelerometerEvent:
          userAccelerometerEvent ?? this.userAccelerometerEvent,
      accelerometerEvent: accelerometerEvent ?? this.accelerometerEvent,
      gyroscopeEvent: gyroscopeEvent ?? this.gyroscopeEvent,
      magnetometerEvent: magnetometerEvent ?? this.magnetometerEvent,
      barometerEvent: barometerEvent ?? this.barometerEvent,
      userAccelerometerUpdateTime:
          userAccelerometerUpdateTime ?? this.userAccelerometerUpdateTime,
      accelerometerUpdateTime:
          accelerometerUpdateTime ?? this.accelerometerUpdateTime,
      gyroscopeUpdateTime: gyroscopeUpdateTime ?? this.gyroscopeUpdateTime,
      magnetometerUpdateTime:
          magnetometerUpdateTime ?? this.magnetometerUpdateTime,
      barometerUpdateTime: barometerUpdateTime ?? this.barometerUpdateTime,
      userAccelerometerLastInterval:
          userAccelerometerLastInterval ?? this.userAccelerometerLastInterval,
      accelerometerLastInterval:
          accelerometerLastInterval ?? this.accelerometerLastInterval,
      gyroscopeLastInterval:
          gyroscopeLastInterval ?? this.gyroscopeLastInterval,
      magnetometerLastInterval:
          magnetometerLastInterval ?? this.magnetometerLastInterval,
      barometerLastInterval:
          barometerLastInterval ?? this.barometerLastInterval,
    );
  }
}
