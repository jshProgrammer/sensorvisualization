import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';

import 'package:sensorvisualization/data/services/ConnectionToSender.dart';
import 'package:sensorvisualization/data/services/SampleData.dart';
import 'package:sensorvisualization/data/services/SensorData.dart';
import 'package:sensorvisualization/presentation/widgets/MultiSelectDialogWidget.dart';
import '../../data/models/ChartConfig.dart';
import '../../data/services/BackgroundColorPainter.dart';
import '../../data/models/ColorSettings.dart';

class ChartPage extends StatefulWidget {
  final ChartConfig chartConfig;
  final Function(int) onPointTap;

  const ChartPage({
    super.key,
    required this.chartConfig,
    required this.onPointTap,
  });

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final TextEditingController _noteController = TextEditingController();

  late TransformationController _transformationController;

  int? selectedPointIndex;

  Set<MultiSelectDialogItem> selectedValues = Set<MultiSelectDialogItem>();

  final GlobalKey _chartKey = GlobalKey();

  late ConnectionToSender server;

  late DateTime _startTime;

  Timer? _debugTimer;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    _debugTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final data = widget.chartConfig.dataPoints;
      print('[DEBUG TEST] Aktive Sensor-Daten:');
      data.forEach((key, value) {
        print('  $key: ${value.length} Punkte');
      });
    });

    server = ConnectionToSender(
      onDataReceived: (data) {
        if (mounted) {
          setState(() {
            //TODO: find out how exact timestamp should be displayed
            final double timestamp =
                data["timestamp"] != null
                    ? DateTime.parse(
                      data["timestamp"].toString(),
                    ).difference(_startTime).inSeconds.toDouble()
                    : 0.0;
            final double x =
                (data['x'] != null && data['x'] is num)
                    ? data['x'].toDouble()
                    : 0.0;
            final double y =
                (data['y'] != null && data['y'] is num)
                    ? data['y'].toDouble()
                    : 0.0;
            final double z =
                (data['z'] != null && data['z'] is num)
                    ? data['z'].toDouble()
                    : 0.0;

            print("timestamp: ${timestamp}");

            widget.chartConfig.addDataPoint(
              data["sensor"].toString() + "x",
              FlSpot(timestamp, x),
            );
            widget.chartConfig.addDataPoint(
              data["sensor"].toString() + "y",
              FlSpot(timestamp, y),
            );
            widget.chartConfig.addDataPoint(
              data["sensor"].toString() + "z",
              FlSpot(timestamp, z),
            );
          });
        }
      },
    );

    //TODO: only when running on computer (not in browser!)
    //server.startServer();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildBackgroundPainter() {
    return CustomPaint(painter: BackgroundColorPainter(), child: Container());
  }

  void _showAllNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alle Notizen'),
          content:
              widget.chartConfig.notes.isEmpty
                  ? const Text('Keine Notizen vorhanden')
                  : SingleChildScrollView(
                    child: ListBody(
                      children:
                          widget.chartConfig.notes.entries.map((entry) {
                            final spot = widget.chartConfig.dataPoints.values
                                .expand((innerList) => innerList)
                                .firstWhere((e) => e.x.toInt() == entry.key);
                            return ListTile(
                              title: Text(
                                'Punkt ${entry.key} (Wert: ${spot.y.toStringAsFixed(1)})',
                              ),
                              subtitle: Text(entry.value),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    widget.chartConfig.notes.remove(entry.key);
                                    Navigator.of(context).pop();
                                    _showAllNotes();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  void _showMultiSelect(BuildContext context) async {
    final result = await showDialog<Set<MultiSelectDialogItem>>(
      context: context,
      builder: (BuildContext context) {
        return Multiselectdialogwidget(
          items: SampleData.getSensorChoices(),
          initialSelectedValues: selectedValues,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedValues = result;
      });
    }

    print(selectedValues);
  }

  List<Widget> buildAppBarActions() {
    return [
      ElevatedButton(
        child: Text("Sensorwahl"),
        onPressed: () {
          _showMultiSelect(context);
        },
      ),
      IconButton(
        icon: const Icon(Icons.zoom_in),
        onPressed: () {
          setState(() {
            final scale = 1.2;
            final x = 0.0;
            final y = 0.0;
            final zoom =
                Matrix4.identity()
                  ..translate(x, y)
                  ..scale(scale)
                  ..translate(-x, -y);

            final currentZoom = _transformationController.value.clone();
            currentZoom.multiply(zoom);
            _transformationController.value = currentZoom;
          });
        },
        tooltip: 'Vergrößern',
      ),
      IconButton(
        icon: const Icon(Icons.zoom_out),
        onPressed: () {
          setState(() {
            final scale = 0.8;
            final x = 0.0;
            final y = 0.0;
            final zoom =
                Matrix4.identity()
                  ..translate(x, y)
                  ..scale(scale)
                  ..translate(-x, -y);

            final currentZoom = _transformationController.value.clone();
            currentZoom.multiply(zoom);
            _transformationController.value = currentZoom;
          });
        },
        tooltip: 'Verkleinern',
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _resetZoom,
        tooltip: 'Zoom zurücksetzen',
      ),
      IconButton(
        icon: const Icon(Icons.list),
        onPressed: _showAllNotes,
        tooltip: 'Alle Notizen anzeigen',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final touchX = details.localPosition.dx;
        final chartWidth = MediaQuery.of(context).size.width - 32;
        final pointSpacing =
            chartWidth / (widget.chartConfig.dataPoints.length - 1);

        final index = (touchX / pointSpacing).round();

        if (index >= 0 && index < widget.chartConfig.dataPoints.length) {
          widget.onPointTap(index);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chartConfig.title),
          actions: buildAppBarActions(),
        ),
        body: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 10.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RepaintBoundary(
              key: _chartKey,
              child: Stack(
                children: [
                  _buildBackgroundPainter(),
                  Sensordata(
                    selectedLines: selectedValues,
                    chartConfig: widget.chartConfig,
                  ).getLineChart(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
