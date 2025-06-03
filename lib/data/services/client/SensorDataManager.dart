import 'dart:async';
import 'dart:convert';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/settingsModels/NetworkCommands.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';

class SensorDataManger {
  late StreamSubscription accelerometerSub;
  late StreamSubscription gyroscopeSub;
  late StreamSubscription magnetometerSub;
  late StreamSubscription barometerSub;

  Duration sensorInterval = Duration(seconds: 1);
  bool _isPaused = false;

  Function(Map<String, dynamic>) onSensorData;
  String localIP;

  SensorDataManger({required this.onSensorData, required this.localIP});

  bool get isPaused => _isPaused;

  Future<void> startSensorStream() async {
    accelerometerSub = accelerometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((AccelerometerEvent event) {
      if (!_isPaused) {
        final now = event.timestamp;
        onSensorData({
          'ip': localIP,
          'sensor': SensorType.accelerometer.displayName,
          'timestamp': now.toString(),
          'x': event.x,
          'y': event.y,
          'z': event.z,
        });
      }
    });

    gyroscopeSub = gyroscopeEventStream(samplingPeriod: sensorInterval).listen((
      GyroscopeEvent event,
    ) {
      if (!_isPaused) {
        final now = event.timestamp;
        onSensorData({
          'ip': localIP,
          'sensor': SensorType.gyroscope.displayName,
          'timestamp': now.toString(),
          'x': event.x,
          'y': event.y,
          'z': event.z,
        });
      }
    });

    magnetometerSub = magnetometerEventStream(
      samplingPeriod: sensorInterval,
    ).listen((MagnetometerEvent event) {
      if (!_isPaused) {
        final now = event.timestamp;
        onSensorData({
          'ip': localIP,
          'sensor': SensorType.magnetometer.displayName,
          'timestamp': now.toString(),
          'x': event.x,
          'y': event.y,
          'z': event.z,
        });
      }
    });

    barometerSub = barometerEventStream(samplingPeriod: sensorInterval).listen((
      BarometerEvent event,
    ) {
      if (!_isPaused) {
        final now = event.timestamp;
        onSensorData({
          'ip': localIP,
          'sensor': SensorType.barometer.displayName,
          'timestamp': now.toString(),
          'pressure': event.pressure,
        });
      }
    });
  }

  void sendNullMeasurementAverage(Map<String, Object> averageValues) {
    onSensorData(averageValues);
  }

  Future<void> pauseMeasurement() async {
    if (!_isPaused) {
      _isPaused = true;

      onSensorData({
        "command": NetworkCommands.PauseMeasurementOnDevice.command,
        "ip": localIP,
        "timestamp": DateTime.now().toString(),
      });
    }
  }

  Future<void> resumeMeasurement() async {
    if (_isPaused) {
      _isPaused = false;

      onSensorData({
        "command": NetworkCommands.ResumeMeasurementOnDevice.command,
        "ip": localIP,
        "timestamp": DateTime.now().toString(),
      });
    }
  }

  Future<void> stopSensorStream() async {
    await accelerometerSub.cancel();
    await gyroscopeSub.cancel();
    await magnetometerSub.cancel();
    await barometerSub.cancel();

    onSensorData({
      "command": NetworkCommands.StopMeasurementOnDevice.command,
      "ip": localIP,
    });
  }
}
