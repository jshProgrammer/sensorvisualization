import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/SensorClient.dart';
import 'package:sensorvisualization/presentation/screens/SensorMeasurement/SensorMessScreen.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StartNullMeasurementScreen extends StatefulWidget {
  final SensorClient connection;

  const StartNullMeasurementScreen({required this.connection});

  @override
  State<StatefulWidget> createState() => _StartNullMeasurementScreenState();
}

class _StartNullMeasurementScreenState
    extends State<StartNullMeasurementScreen> {
  Duration sensorInterval = Duration(milliseconds: 100);

  static const int defaultMeasurementSeconds = 10;
  static int measurementSeconds = defaultMeasurementSeconds;

  final _accelData = <List<double>>[];
  final _gyroData = <List<double>>[];
  final _magnetData = <List<double>>[];
  final _baroData = <double>[];

  double progress = 0;
  late Timer _progressTimer;
  late DateTime _startTime;
  int remainingSeconds = measurementSeconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nullmessung'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openDurationSettings,
            tooltip: 'Messzeit einstellen',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Nullmessung starten"),
              onPressed: () {
                startNullMeasurement();
              },
            ),
            SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),

                Text(
                  '$remainingSeconds',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void startNullMeasurement() {
    _startTime = DateTime.now();

    final endTime = DateTime.now().add(Duration(seconds: measurementSeconds));

    _progressTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
      final totalMillis = measurementSeconds * 1000;

      setState(() {
        progress = elapsed / totalMillis;
        remainingSeconds = measurementSeconds - (elapsed / 1000).floor();
      });

      if (DateTime.now().isAfter(endTime)) {
        timer.cancel();
        _finishMeasurement();
      }
    });

    accelerometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _accelData.add([event.x, event.y, event.z]);
      }
    });

    gyroscopeEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _gyroData.add([event.x, event.y, event.z]);
      }
    });

    magnetometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _magnetData.add([event.x, event.y, event.z]);
      }
    });

    barometerEventStream(samplingPeriod: sensorInterval).listen((event) {
      if (DateTime.now().isBefore(endTime)) {
        _baroData.add(event.pressure);
      }
    });
  }

  Future<void> _finishMeasurement() async {
    await widget.connection.retrieveLocalIP();
    final result = {
      'ip': widget.connection.ownIPAddress,
      'sensor': 'Durchschnittswerte nach ${measurementSeconds}s',
      SensorType.accelerometer.displayName: _averageTriplet(_accelData),
      SensorType.gyroscope.displayName: _averageTriplet(_gyroData),
      SensorType.magnetometer.displayName: _averageTriplet(_magnetData),
      SensorType.barometer.displayName: _averageSingle(_baroData),
    };

    widget.connection.sendNullMeasurementAverage(result);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SensorMessScreen(connection: widget.connection),
      ),
    );
  }

  Map<String, double> _averageTriplet(List<List<double>> data) {
    if (data.isEmpty) return {'x': 0, 'y': 0, 'z': 0};
    final sum = List.filled(3, 0.0);
    for (var triplet in data) {
      for (int i = 0; i < 3; i++) {
        sum[i] += triplet[i];
      }
    }
    return {
      'x': sum[0] / data.length,
      'y': sum[1] / data.length,
      'z': sum[2] / data.length,
    };
  }

  double _averageSingle(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  void _openDurationSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedDuration = measurementSeconds;
        return AlertDialog(
          title: Text('Messzeit einstellen'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dauer der Nullmessung in Sekunden:'),
                  Slider(
                    value: selectedDuration.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 25,
                    label: selectedDuration.toString(),
                    onChanged: (double value) {
                      setState(() {
                        selectedDuration = value.round();
                      });
                    },
                  ),
                  Text('$selectedDuration Sekunden'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () {
                setState(() {
                  measurementSeconds = selectedDuration;
                  remainingSeconds = measurementSeconds;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
