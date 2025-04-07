import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/services/ConnectionToRecipient.dart';

class SensorMessPage extends StatefulWidget {
  const SensorMessPage({super.key, this.title});

  final String? title;

  @override
  State<SensorMessPage> createState() => _SensorMessPageState();
}

class _SensorMessPageState extends State<SensorMessPage> {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);

  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;
  BarometerEvent? _barometerEvent;

  DateTime? _userAccelerometerUpdateTime;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  DateTime? _barometerUpdateTime;

  int? _userAccelerometerLastInterval;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  int? _magnetometerLastInterval;
  int? _barometerLastInterval;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Duration sensorInterval = SensorInterval.normalInterval;

  final connection = ConnectionToRecipient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messung'), elevation: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  4: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    children: [
                      SizedBox.shrink(),
                      Text('X'),
                      Text('Y'),
                      Text('Z'),
                      Text('Intervall'),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('User Beschleunigungssensor'),
                      ),
                      Text(
                        _userAccelerometerEvent?.x.toStringAsFixed(1) ?? '?',
                      ),
                      Text(
                        _userAccelerometerEvent?.y.toStringAsFixed(1) ?? '?',
                      ),
                      Text(
                        _userAccelerometerEvent?.z.toStringAsFixed(1) ?? '?',
                      ),
                      Text(
                        '${_userAccelerometerLastInterval?.toString() ?? '?'} ms',
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Beschleunigungssensor'),
                      ),
                      Text(_accelerometerEvent?.x.toStringAsFixed(1) ?? '?'),
                      Text(_accelerometerEvent?.y.toStringAsFixed(1) ?? '?'),
                      Text(_accelerometerEvent?.z.toStringAsFixed(1) ?? '?'),
                      Text(
                        '${_accelerometerLastInterval?.toString() ?? '?'} ms',
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Gyroskop'),
                      ),
                      Text(_gyroscopeEvent?.x.toStringAsFixed(1) ?? '?'),
                      Text(_gyroscopeEvent?.y.toStringAsFixed(1) ?? '?'),
                      Text(_gyroscopeEvent?.z.toStringAsFixed(1) ?? '?'),
                      Text('${_gyroscopeLastInterval?.toString() ?? '?'} ms'),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Magnetometer'),
                      ),
                      Text(_magnetometerEvent?.x.toStringAsFixed(1) ?? '?'),
                      Text(_magnetometerEvent?.y.toStringAsFixed(1) ?? '?'),
                      Text(_magnetometerEvent?.z.toStringAsFixed(1) ?? '?'),
                      Text(
                        '${_magnetometerLastInterval?.toString() ?? '?'} ms',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    children: [
                      SizedBox.shrink(),
                      Text('Druck'),
                      Text('Intervall'),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Barometer'),
                      ),
                      Text(
                        '${_barometerEvent?.pressure.toStringAsFixed(1) ?? '?'} hPa',
                      ),
                      Text('${_barometerLastInterval?.toString() ?? '?'} ms'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Aktualisierungs-Intervall:'),
                SegmentedButton(
                  segments: [
                    ButtonSegment(
                      value: SensorInterval.gameInterval,
                      label: Text(
                        '${SensorInterval.gameInterval.inMilliseconds}ms',
                      ),
                    ),
                    ButtonSegment(
                      value: SensorInterval.normalInterval,
                      label: Text(
                        '${SensorInterval.normalInterval.inMilliseconds}ms',
                      ),
                    ),
                    const ButtonSegment(
                      value: Duration(seconds: 1),
                      label: Text('1s'),
                    ),
                  ],
                  selected: {sensorInterval},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) {
                    setState(() {
                      sensorInterval = value.first;
                      userAccelerometerEventStream(
                        samplingPeriod: sensorInterval,
                      );
                      accelerometerEventStream(samplingPeriod: sensorInterval);
                      gyroscopeEventStream(samplingPeriod: sensorInterval);
                      magnetometerEventStream(samplingPeriod: sensorInterval);
                      barometerEventStream(samplingPeriod: sensorInterval);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    //TODO: only when running on phone
    //connection.initSocket();

    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (UserAccelerometerEvent event) {
          final now = event.timestamp;
          setState(() {
            _userAccelerometerEvent = event;
            if (_userAccelerometerUpdateTime != null) {
              final interval = now.difference(_userAccelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _userAccelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _userAccelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor nicht gefunden"),
                content: Text(
                  "Dein Gerät scheint keinen User Beschleunigungssensor zu unterstützen",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (AccelerometerEvent event) {
          final now = event.timestamp;
          setState(() {
            _accelerometerEvent = event;
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor nicht gefunden"),
                content: Text(
                  "Dein Gerät scheint keinen Beschleunigungssensor zu unterstützen",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (GyroscopeEvent event) {
          final now = event.timestamp;
          setState(() {
            _gyroscopeEvent = event;
            if (_gyroscopeUpdateTime != null) {
              final interval = now.difference(_gyroscopeUpdateTime!);
              if (interval > _ignoreDuration) {
                _gyroscopeLastInterval = interval.inMilliseconds;
              }
            }
          });
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor nicht gefunden"),
                content: Text(
                  "Dein Gerät scheint kein Gyroskop zu unterstützen",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: sensorInterval).listen(
        (MagnetometerEvent event) {
          final now = event.timestamp;
          setState(() {
            _magnetometerEvent = event;
            if (_magnetometerUpdateTime != null) {
              final interval = now.difference(_magnetometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _magnetometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor nicht gefunden"),
                content: Text(
                  "Dein Gerät scheint kein Magnetometer zu unterstützen",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: sensorInterval).listen(
        (BarometerEvent event) {
          final now = event.timestamp;
          setState(() {
            _barometerEvent = event;
            if (_barometerUpdateTime != null) {
              final interval = now.difference(_barometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _barometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _barometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor Not Found"),
                content: Text(
                  "It seems that your device doesn't support Barometer Sensor",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
  }
}
