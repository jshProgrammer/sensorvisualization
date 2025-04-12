import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';

import 'package:sensorvisualization/data/services/ConnectionToSender.dart';
import 'package:sensorvisualization/data/services/SampleData.dart';
import 'package:sensorvisualization/data/services/SensorData.dart';
import 'package:sensorvisualization/presentation/widgets/MultiSelectDialogWidget.dart';
import 'package:sensorvisualization/presentation/widgets/WarningLevelsSelection.dart';
import '../../data/models/ChartConfig.dart';
import '../../data/services/BackgroundColorPainter.dart';
import '../../data/models/ColorSettings.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';

class ChartPage extends StatefulWidget {
  final ChartConfig chartConfig;

  const ChartPage({super.key, required this.chartConfig});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  double baselineX = 0.0;
  double baselineY = 0.0;

  final TextEditingController _noteController = TextEditingController();

  late TransformationController _transformationController;

  int? selectedPointIndex;

  Set<MultiSelectDialogItem> selectedValues = Set<MultiSelectDialogItem>();

  final GlobalKey _chartKey = GlobalKey();

  late ConnectionToSender server;

  late DateTime _startTime;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

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
      onMeasurementStopped: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Messung wurde gestoppt"),
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    //TODO: only when running on computer (not in browser!)
    server.startServer();
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

  void _showWarnLevelSelection(BuildContext context) async {
    final result = await showDialog<Set<MultiSelectDialogItem>>(
      context: context,
      builder: (BuildContext context) {
        return Warninglevelsselection();
      },
    );

    /*if (result != null) {
      setState(() {
        selectedValues = result;
      });
    }*/

    print(selectedValues);
  }

  List<Widget> buildAppBarActions() {
    return [
      ElevatedButton(
        child: Text("Warnschwellen"),
        onPressed: () {
          _showWarnLevelSelection(context);
        },
      ),
      SizedBox(width: 8),
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

            var currentZoom = _transformationController.value.clone();
            if (currentZoom.getMaxScaleOnAxis() > 1.0) {
              currentZoom.multiply(zoom);
              if (currentZoom.getMaxScaleOnAxis() < 1.0) {
                currentZoom = Matrix4.identity();
              }
              _transformationController.value = currentZoom;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Weiteres Herauszoomen nicht erlaubt'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
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
      IconButton(
        icon: const Icon(Icons.picture_as_pdf),
        onPressed: () async {
          final exporter = ChartExporter(_chartKey);
          final path = await exporter.exportToPDF("Diagramm_Export");
          if (!mounted) return;
          if (path == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Fehler beim Exportieren des Diagramms'),
                duration: Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF gespeichert: $path'),
                duration: Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          ;
        },
        tooltip: 'Diagramm als PDF exportieren',
      ),
    ];
  }

  void addNote(int index) {
    TextEditingController controller = TextEditingController();

    if (widget.chartConfig.notes.containsKey(index)) {
      controller.text = widget.chartConfig.notes[index]!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Notiz für Punkt $index"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Notiz eingeben..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.chartConfig.notes[index] = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
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
          addNote(index);
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
                  // _buildBackgroundPainter(),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0, right: 18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Slider(
                                    value: baselineY,
                                    onChanged: (newValue) {
                                      setState(() {
                                        baselineY = newValue;
                                      });
                                    },
                                    min: -10,
                                    max: 10,
                                  ),
                                ),
                                Expanded(
                                  child: Sensordata(
                                    selectedLines: selectedValues,
                                    chartConfig: widget.chartConfig,
                                  ).getLineChart(
                                    baselineX,
                                    (20 - (baselineY + 10)) - 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: baselineX,
                            onChanged: (newValue) {
                              setState(() {
                                baselineX = newValue;
                              });
                            },
                            min: -10,
                            max: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
