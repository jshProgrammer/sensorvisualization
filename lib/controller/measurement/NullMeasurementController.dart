import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/settingsModels/NetworkCommands.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/model/measurement/MeasurementState.dart';
import 'package:sensorvisualization/model/measurement/NullMeasurementModel.dart';

class NullMeasurementController extends ChangeNotifier {
  final SensorClient connection;
  final Duration sensorInterval = Duration(milliseconds: 100);

  static const int defaultMeasurementSeconds = 10;
  final NullMeasurementModel _model = NullMeasurementModel();
  MeasurementState _measurementState = MeasurementState(
    isPaused: true,
    measurementDuration: defaultMeasurementSeconds,
    remainingSeconds: defaultMeasurementSeconds,
  );

  MeasurementState get measurementState => _measurementState;
  NullMeasurementModel get model => _model;

  int measurementSeconds = defaultMeasurementSeconds;
  int remainingSeconds = defaultMeasurementSeconds;
  bool isMeasurementActive = false;
  bool isDelayedMeasurementActive = false;

  int selectedTimeUnit = TimeUnitChoice.seconds.value;
  String delayText = "";

  Timer? _delayTimer;
  Timer? _progressTimer;

  Function() onNullMeasurementComplete;

  NullMeasurementController({
    required this.connection,
    required this.onNullMeasurementComplete,
  }) {
    _setupConnectionHandlers();
  }

  double get progress {
    if (_measurementState.measurementDuration == null ||
        _measurementState.remainingSeconds == null) {
      return 0.0;
    }
    final total = _measurementState.measurementDuration!;
    final remaining = _measurementState.remainingSeconds!;
    return (total - remaining) / total;
  }

  bool get isDelayEnabled => _measurementState.isDelayEnabled;

  void _setupConnectionHandlers() {
    connection.commandHandler.onStartNullMeasurementReceived = (duration) {
      updateMeasurementDuration(duration);
      startNullMeasurement();
    };

    connection.commandHandler.onDelayedMeasurementReceived = (duration) {
      startDelayTimer(duration: duration);
    };
  }

  void updateMeasurementDuration(int duration) {
    _updateMeasurementState(
      _measurementState.copyWith(
        measurementDuration: duration,
        remainingSeconds: duration,
      ),
    );
  }

  void startNullMeasurement() {
    final duration =
        _measurementState.measurementDuration ?? defaultMeasurementSeconds;

    _updateMeasurementState(
      _measurementState.copyWith(
        isPaused: false,
        isNullMeasurement: true,
        isDelayActive: false,
        remainingSeconds: duration,
      ),
    );

    _model.clearAllData();

    connection.sendStartingNullMeasurement(duration);

    _startSensorDataCollection(duration);

    _startProgressTimer(duration, _finishMeasurement);
  }

  void startDelayTimer({int? duration}) {
    int amountOfSeconds;
    if (duration == null) {
      amountOfSeconds = int.tryParse(delayText.trim()) ?? 0;
      amountOfSeconds =
          (TimeUnitChoice.fromValue(selectedTimeUnit) == TimeUnitChoice.hours)
              ? amountOfSeconds * 3600
              : (TimeUnitChoice.fromValue(selectedTimeUnit) ==
                  TimeUnitChoice.minutes)
              ? amountOfSeconds * 60
              : amountOfSeconds;
    } else {
      amountOfSeconds = duration;
    }

    _updateMeasurementState(
      _measurementState.copyWith(
        isDelayActive: true,
        delayRemainingSeconds: amountOfSeconds,
      ),
    );

    connection.sendDelayedMeasurement(amountOfSeconds);

    _startProgressTimer(amountOfSeconds, startNullMeasurement, isDelay: true);
  }

  void _startProgressTimer(
    int duration,
    Function onFinish, {
    bool isDelay = false,
  }) {
    DateTime startTime = DateTime.now();
    DateTime endTime = startTime.add(Duration(seconds: duration));

    _progressTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final newRemainingSeconds = duration - (elapsed / 1000).floor();

      if (isDelay) {
        _updateMeasurementState(
          _measurementState.copyWith(
            delayRemainingSeconds: newRemainingSeconds.clamp(0, duration),
          ),
        );
      } else {
        _updateMeasurementState(
          _measurementState.copyWith(
            remainingSeconds: newRemainingSeconds.clamp(0, duration),
          ),
        );
      }

      if (DateTime.now().isAfter(endTime)) {
        timer.cancel();
        onFinish();
      }
    });
  }

  void _startSensorDataCollection(int duration) {
    final endTime = DateTime.now().add(Duration(seconds: duration));

    accelerometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _model.addAccelerometerData(event.x, event.y, event.z);
      }
    });

    gyroscopeEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _model.addGyroscopeData(event.x, event.y, event.z);
      }
    });

    magnetometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _model.addMagnetometerData(event.x, event.y, event.z);
      }
    });

    barometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _model.addBarometerData(event.pressure);
      }
    });
  }

  Future<void> _finishMeasurement() async {
    _updateMeasurementState(
      _measurementState.copyWith(
        isPaused: true,
        isNullMeasurement: false,
        remainingSeconds: 0,
      ),
    );

    final result = {
      "command": NetworkCommands.AverageValues.command,
      'duration': _measurementState.measurementDuration,
      'ip': connection.localIP,
      ..._model.getAllAverages(),
    };

    connection.sendNullMeasurementAverage(result.cast<String, Object>());

    onNullMeasurementComplete();

    notifyListeners();
  }

  void _updateMeasurementState(MeasurementState newState) {
    _measurementState = newState;
    notifyListeners();
  }

  int get displayRemainingSeconds {
    if (_measurementState.isDelayActive) {
      return _measurementState.delayRemainingSeconds ?? 0;
    } else {
      return _measurementState.remainingSeconds ?? 0;
    }
  }

  void userStartButtonPressed() {
    if (_measurementState.isDelayEnabled) {
      startDelayTimer();
    } else {
      startNullMeasurement();
    }
  }

  bool isStartButtonPressedActive() {
    return (measurementState.isDelayActive || !measurementState.isPaused);
  }

  String getTextOfUserButton() {
    return !measurementState.isPaused
        ? "Messung läuft"
        : measurementState.isDelayActive
        ? "Selbstauslöser aktiv"
        : _measurementState.isDelayEnabled
        ? "Selbstauslöser starten"
        : "Nullmessung starten";
  }

  void setActiveDelay(bool active) {
    _updateMeasurementState(_measurementState.copyWith(isDelayEnabled: active));
    notifyListeners();
  }

  void setDelayText(String text) {
    delayText = text;
    notifyListeners();
  }

  void setSelectedTimeUnit(int unit) {
    selectedTimeUnit = unit;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _progressTimer?.cancel();
    _delayTimer?.cancel();
  }
}
