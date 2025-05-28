import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/model/client/MeasurementState.dart';
import 'package:sensorvisualization/model/client/NullMeasurementModel.dart';
import 'package:sensorvisualization/model/client/SensorDataModel.dart';

class SensorMeasurementController extends ChangeNotifier {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);

  final SensorClient connection;
  final Function(String)? onAlarmReceived;
  final Function(String)? onErrorReceived;
  final VoidCallback? onMeasurementStopped;

  SensorDataModel _sensorData = SensorDataModel();
  SensorDataModel get sensorData => _sensorData;

  MeasurementState _measurementState = MeasurementState();
  MeasurementState get measurementState => _measurementState;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  final Duration accelerometerSensorInterval = SensorInterval.fastestInterval;
  final Duration standardSensorInterval = SensorInterval.normalInterval;

  SensorMeasurementController({
    required this.connection,
    this.onAlarmReceived,
    this.onMeasurementStopped,
    this.onErrorReceived,
  }) {
    _measurementState = _measurementState.copyWith(
      isPaused: connection.isPaused,
    );
    _setupConnectionHandlers();
  }

  void _setupConnectionHandlers() {
    connection.commandHandler.onAlarmReceived = (String alarmMessage) {
      onAlarmReceived?.call(alarmMessage);
    };

    connection.commandHandler.onMeasurementPaused = () async {
      await connection.pauseMeasurement();
      _updateMeasurementState(_measurementState.copyWith(isPaused: true));
    };

    connection.commandHandler.onMeasurementResumed = () async {
      await connection.resumeMeasurement();
      _updateMeasurementState(_measurementState.copyWith(isPaused: false));
    };

    connection.commandHandler.onMeasurementStopped = () async {
      await connection.stopMeasurement();
      onMeasurementStopped?.call();
    };
  }

  void startSensorStreams() {
    connection.startSensorStream();
    _setupSensorStreams();
  }

  void _setupSensorStreams() {
    _streamSubscriptions.add(
      userAccelerometerEventStream(
        samplingPeriod: accelerometerSensorInterval,
      ).listen(
        (UserAccelerometerEvent event) {
          _updateUserAccelerometerData(event);
        },
        onError: (e) => _showSensorError("User Beschleunigungssensor"),
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      accelerometerEventStream(
        samplingPeriod: accelerometerSensorInterval,
      ).listen(
        (AccelerometerEvent event) {
          _updateAccelerometerData(event);
        },
        onError: (e) => _showSensorError("Beschleunigungssensor"),
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: standardSensorInterval).listen(
        (GyroscopeEvent event) {
          _updateGyroscopeData(event);
        },
        onError: (e) => _showSensorError("Gyroskop"),
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: standardSensorInterval).listen(
        (MagnetometerEvent event) {
          _updateMagnetometerData(event);
        },
        onError: (e) => _showSensorError("Magnetometer"),
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: standardSensorInterval).listen(
        (BarometerEvent event) {
          _updateBarometerData(event);
        },
        onError: (e) => _showSensorError("Barometer"),
        cancelOnError: true,
      ),
    );
  }

  void _updateUserAccelerometerData(UserAccelerometerEvent event) {
    final now = event.timestamp;
    int? interval;

    if (_sensorData.userAccelerometerUpdateTime != null) {
      final intervalDuration = now.difference(
        _sensorData.userAccelerometerUpdateTime!,
      );
      if (intervalDuration > _ignoreDuration) {
        interval = intervalDuration.inMilliseconds;
      }
    }

    _updateSensorData(
      _sensorData.copyWith(
        userAccelerometerEvent: event,
        userAccelerometerUpdateTime: now,
        userAccelerometerLastInterval: interval,
      ),
    );
  }

  void _updateAccelerometerData(AccelerometerEvent event) {
    final now = event.timestamp;
    int? interval;

    if (_sensorData.accelerometerUpdateTime != null) {
      final intervalDuration = now.difference(
        _sensorData.accelerometerUpdateTime!,
      );
      if (intervalDuration > _ignoreDuration) {
        interval = intervalDuration.inMilliseconds;
      }
    }

    _updateSensorData(
      _sensorData.copyWith(
        accelerometerEvent: event,
        accelerometerUpdateTime: now,
        accelerometerLastInterval: interval,
      ),
    );
  }

  void _updateGyroscopeData(GyroscopeEvent event) {
    final now = event.timestamp;
    int? interval;

    if (_sensorData.gyroscopeUpdateTime != null) {
      final intervalDuration = now.difference(_sensorData.gyroscopeUpdateTime!);
      if (intervalDuration > _ignoreDuration) {
        interval = intervalDuration.inMilliseconds;
      }
    }

    _updateSensorData(
      _sensorData.copyWith(
        gyroscopeEvent: event,
        gyroscopeUpdateTime: now,
        gyroscopeLastInterval: interval,
      ),
    );
  }

  void _updateMagnetometerData(MagnetometerEvent event) {
    final now = event.timestamp;
    int? interval;

    if (_sensorData.magnetometerUpdateTime != null) {
      final intervalDuration = now.difference(
        _sensorData.magnetometerUpdateTime!,
      );
      if (intervalDuration > _ignoreDuration) {
        interval = intervalDuration.inMilliseconds;
      }
    }

    _updateSensorData(
      _sensorData.copyWith(
        magnetometerEvent: event,
        magnetometerUpdateTime: now,
        magnetometerLastInterval: interval,
      ),
    );
  }

  void _updateBarometerData(BarometerEvent event) {
    final now = event.timestamp;
    int? interval;

    if (_sensorData.barometerUpdateTime != null) {
      final intervalDuration = now.difference(_sensorData.barometerUpdateTime!);
      if (intervalDuration > _ignoreDuration) {
        interval = intervalDuration.inMilliseconds;
      }
    }

    _updateSensorData(
      _sensorData.copyWith(
        barometerEvent: event,
        barometerUpdateTime: now,
        barometerLastInterval: interval,
      ),
    );
  }

  void _showSensorError(String sensorName) {
    onErrorReceived?.call(
      "Dein Gerät scheint keinen $sensorName zu unterstützen",
    );
  }

  void _updateSensorData(SensorDataModel newData) {
    _sensorData = newData;
    notifyListeners();
  }

  void _updateMeasurementState(MeasurementState newState) {
    _measurementState = newState;
    notifyListeners();
  }

  Future<void> pauseMeasurement() async {
    await connection.pauseMeasurement();
    _updateMeasurementState(_measurementState.copyWith(isPaused: true));
  }

  Future<void> resumeMeasurement() async {
    await connection.resumeMeasurement();
    _updateMeasurementState(_measurementState.copyWith(isPaused: false));
  }

  Future<void> stopMeasurement() async {
    await connection.stopMeasurement();
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
