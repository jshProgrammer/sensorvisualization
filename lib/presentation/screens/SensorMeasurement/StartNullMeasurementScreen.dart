import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/NetworkCommands.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
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

  TextEditingController _delayController = TextEditingController();
  int _selectedTimeUnit = TimeUnitChoice.seconds.value;
  bool activeDelay = false;

  bool _isMeasurementActive = false;
  bool _isDelayedMeasurementActive = false;

  @override
  void initState() {
    super.initState();

    widget.connection.commandHandler.onStartNullMeasurementReceived = (
      duration,
    ) {
      measurementSeconds = duration;
      startNullMeasurement();
    };

    widget.connection.commandHandler.onDelayedMeasurementReceived = (duration) {
      startDelayTimer(duration: duration);
    };
  }

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
              onPressed:
                  (_isMeasurementActive || _isDelayedMeasurementActive)
                      ? null
                      : () {
                        activeDelay
                            ? startDelayTimer()
                            : startNullMeasurement();
                      },
              child: Text(
                _isMeasurementActive
                    ? "Messung läuft"
                    : _isDelayedMeasurementActive
                    ? "Selbstauslöser aktiv"
                    : activeDelay
                    ? "Selbstauslöser starten"
                    : "Nullmessung starten",
              ),
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

  void startDelayTimer({int? duration}) {
    _isDelayedMeasurementActive = true;
    int amountOfSeconds;
    if (duration == null) {
      amountOfSeconds = int.tryParse(_delayController.text.trim()) ?? 0;
      amountOfSeconds =
          (TimeUnitChoice.fromValue(_selectedTimeUnit) == TimeUnitChoice.hours)
              ? amountOfSeconds * 3600
              : (TimeUnitChoice.fromValue(_selectedTimeUnit) ==
                  TimeUnitChoice.minutes)
              ? amountOfSeconds * 60
              : amountOfSeconds;
    } else {
      amountOfSeconds = duration;
    }

    widget.connection.sendDelayedMeasurement(amountOfSeconds);
    _setTimer(
      amountOfSeconds,
      DateTime.now().add(Duration(seconds: amountOfSeconds)),
      startNullMeasurement,
    );
  }

  void _setTimer(int duration, DateTime endTime, Function onFinish) {
    _startTime = DateTime.now();

    _progressTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
      final totalMillis = duration * 1000;

      setState(() {
        progress = elapsed / totalMillis;
        remainingSeconds = duration - (elapsed / 1000).floor();
      });

      if (DateTime.now().isAfter(endTime)) {
        timer.cancel();
        onFinish();
      }
    });
  }

  void startNullMeasurement() {
    _isMeasurementActive = true;

    widget.connection.sendStartingNullMeasurement(measurementSeconds);
    final DateTime endTime = DateTime.now().add(
      Duration(seconds: measurementSeconds),
    );
    _setTimer(measurementSeconds, endTime, _finishMeasurement);

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
      "command": NetworkCommands.AverageValues.command,
      'duration': measurementSeconds,
      'ip': widget.connection.ownIPAddress,
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

                  SizedBox(height: 10),

                  Divider(),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Text("Selbstauslöser"),
                      Spacer(),
                      Switch(
                        value: activeDelay,
                        activeColor: Colors.blue,
                        onChanged: (bool value) {
                          setState(() {
                            activeDelay = value;
                          });
                        },
                      ),
                    ],
                  ),

                  if (activeDelay)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _delayController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: false,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value:
                                  TimeUnitChoice.fromValue(
                                    _selectedTimeUnit,
                                  ).asString(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTimeUnit =
                                      TimeUnitChoice.values
                                          .firstWhere(
                                            (e) => e.asString() == newValue,
                                          )
                                          .value;
                                });
                              },
                              items:
                                  TimeUnitChoice.values
                                      .map((e) => e.asString())
                                      .toList()
                                      .map(
                                        (value) => DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  @override
  void dispose() {
    if (_progressTimer.isActive) {
      _progressTimer.cancel();
    }
    super.dispose();
  }
}
