import 'package:flutter/material.dart';
import 'package:sensorvisualization/controller/measurement/SensorMeasurementController.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/presentation/measurement/AlarmView.dart';
import 'package:sensorvisualization/presentation/measurement/ScannerEntryScreen.dart';

class SensorMeasurementView extends StatefulWidget {
  const SensorMeasurementView({
    super.key,
    this.title,
    required this.connection,
  });

  final String? title;
  final SensorClient connection;

  @override
  State<SensorMeasurementView> createState() => _SensorMeasurementViewState();
}

class _SensorMeasurementViewState extends State<SensorMeasurementView> {
  late SensorMeasurementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SensorMeasurementController(
      connection: widget.connection,
      onAlarmReceived: _showAlarmPage,
      onMeasurementStopped: _navigateToScanner,
      onErrorReceived: _showSensorError,
    );
    _controller.addListener(_onControllerUpdate);
    _controller.startSensorStreams();
  }

  @override
  Widget build(BuildContext context) {
    final sensorData = _controller.sensorData;
    final measurementState = _controller.measurementState;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messung'),
          elevation: 4,
          automaticallyImplyLeading: false,
        ),
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
                    _buildSensorRow(
                      SensorType.userAccelerometer.displayName,
                      sensorData.userAccelerometerEvent?.x,
                      sensorData.userAccelerometerEvent?.y,
                      sensorData.userAccelerometerEvent?.z,
                      sensorData.userAccelerometerLastInterval,
                    ),
                    _buildSensorRow(
                      SensorType.accelerometer.displayName,
                      sensorData.accelerometerEvent?.x,
                      sensorData.accelerometerEvent?.y,
                      sensorData.accelerometerEvent?.z,
                      sensorData.accelerometerLastInterval,
                    ),
                    _buildSensorRow(
                      SensorType.gyroscope.displayName,
                      sensorData.gyroscopeEvent?.x,
                      sensorData.gyroscopeEvent?.y,
                      sensorData.gyroscopeEvent?.z,
                      sensorData.gyroscopeLastInterval,
                    ),
                    _buildSensorRow(
                      SensorType.magnetometer.displayName,
                      sensorData.magnetometerEvent?.x,
                      sensorData.magnetometerEvent?.y,
                      sensorData.magnetometerEvent?.z,
                      sensorData.magnetometerLastInterval,
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
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(SensorType.barometer.displayName),
                        ),
                        Text(
                          '${sensorData.barometerEvent?.pressure.toStringAsFixed(1) ?? '?'} hPa',
                        ),
                        Text(
                          '${sensorData.barometerLastInterval?.toString() ?? '?'} ms',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  measurementState.isPaused
                      ? "Messung fortsetzen"
                      : "Messung pausieren",
                ),
                onPressed: () async {
                  if (measurementState.isPaused) {
                    await _controller.resumeMeasurement();
                  } else {
                    await _controller.pauseMeasurement();
                  }
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: const Text("Messung stoppen"),
                onPressed: _showStopConfirmationDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildSensorRow(
    String sensorName,
    double? x,
    double? y,
    double? z,
    int? interval,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(sensorName),
        ),
        Text(x?.toStringAsFixed(1) ?? '?'),
        Text(y?.toStringAsFixed(1) ?? '?'),
        Text(z?.toStringAsFixed(1) ?? '?'),
        Text('${interval?.toString() ?? '?'} ms'),
      ],
    );
  }

  void _showAlarmPage(String alarmMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlarmView(connection: widget.connection);
      },
    );
  }

  void _showSensorError(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sensor $errorMessage nicht gefunden"),
          content: Text(errorMessage),
        );
      },
    );
  }

  Future<void> _showStopConfirmationDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Messung stoppen'),
          content: const Text(
            'Sind Sie sicher, dass Sie die Messung stoppen möchten? '
            'Die Netzwerkverbindung wird unwiderruflich getrennt. Alle bisher gesendeten Daten sind gespeichert.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Stoppen'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.connection.stopMeasurement();

      _navigateToScanner();
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToScanner() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ScannerEntryScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }
}
