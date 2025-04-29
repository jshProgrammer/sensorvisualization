import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';

import 'package:sensorvisualization/data/services/SensorServer.dart';
import 'package:sensorvisualization/data/services/SampleData.dart';
import 'package:sensorvisualization/data/services/SensorData.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/presentation/widgets/MultiSelectDialogWidget.dart';
import 'package:sensorvisualization/presentation/widgets/WarningLevelsSelection.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/ChartConfig.dart';
import '../../data/models/ColorSettings.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';
import 'package:sensorvisualization/data/services/SensorDataSimulator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:sensorvisualization/database/DatabaseOperations.dart';

class ChartPage extends StatefulWidget {
  final ChartConfig chartConfig;

  const ChartPage({super.key, required this.chartConfig});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  double baselineX = 0.0;
  double baselineY = 0.0;
  bool autoFollowLatestData = true;

  final TextEditingController _noteController = TextEditingController();

  late TransformationController _transformationController;

  int? selectedPointIndex;

  Map<String, Set<MultiSelectDialogItem>> selectedValues = {};

  final GlobalKey _chartKey = GlobalKey();

  late StreamSubscription _dataSubscription;

  late DateTime _startTime;

  late SensorDataSimulator simulator;
  bool isSimulationRunning = false;

  Map<String, List<WarningRange>> warningRanges = {
    'green': [],
    'yellow': [],
    'red': [],
  };

  final _databaseOperations = Databaseoperations();

  //Only for Simulation
  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    _dataSubscription = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    ).dataStream.listen(_handleSensorData);

    Provider.of<ConnectionProvider>(
      context,
      listen: false,
    ).measurementStopped.listen((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Messung wurde gestoppt"),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    _transformationController = TransformationController();

    simulator = SensorDataSimulator(
      onDataGenerated: (data) {
        if (mounted) {
          setState(() {
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

            if (autoFollowLatestData) {
              baselineX = timestamp;
            }
          });
        }
      },
    );
    simulator.init();
  }

  //Working on real sceanario
  @override
  void dispose() {
    _transformationController.dispose();
    _noteController.dispose();
    _dataSubscription.cancel();
    simulator.stopSimulation();
    super.dispose();
  }

  void _handleSensorData(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        var jsonData = SensorDataTransformation.returnAbsoluteSensorDataAsJson(
          data,
          SensorTypeExtension.fromString(data["sensor"]),
        );

        double timestampAsDouble =
            SensorDataTransformation.transformDateTimeToSecondsAsDouble(
              jsonData["timestamp"],
            );

        if (jsonData.containsKey('x') && jsonData['x'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['sensor'] + 'x',
            FlSpot(timestampAsDouble, jsonData['x'] as double),
          );
        }
        if (jsonData.containsKey('y') && jsonData['y'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['sensor'] + 'y',
            FlSpot(timestampAsDouble, jsonData['y'] as double),
          );
        }
        if (jsonData.containsKey('z') && jsonData['z'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['sensor'] + 'z',
            FlSpot(timestampAsDouble, jsonData['z'] as double),
          );
        }
        if (jsonData.containsKey('pressure') && jsonData['pressure'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['sensor'] + '_pressure',
            FlSpot(timestampAsDouble, jsonData['pressure'] as double),
          );
        }
      });
    }
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
                            return ListTile(
                              title: Text('Zeit: ${entry.key.toLocal()}'),
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
    final result = await showDialog<Map<String, Set<MultiSelectDialogItem>>>(
      context: context,
      builder: (BuildContext context) {
        return Multiselectdialogwidget(initialSelectedValues: selectedValues);
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
    final result = await showDialog<Map<String, List<WarningRange>>>(
      context: context,
      builder: (BuildContext context) {
        return Warninglevelsselection(initialValues: warningRanges);
      },
    );

    if (result != null) {
      setState(() {
        warningRanges = result;
      });
    }
  }

  void addNote({String? initialText}) {
    DateTime defaultTime = DateTime.now();
    TextEditingController textController = TextEditingController(
      text: initialText,
    );
    TextEditingController timeController = TextEditingController(
      text: defaultTime.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notiz hinzufügen"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "Zeit (z.B. 2025-04-29 13:45:00)",
                ),
              ),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: "Notiz eingeben...",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  DateTime parsedTime = DateTime.parse(timeController.text);
                  setState(() {
                    widget.chartConfig.notes[parsedTime] = textController.text;
                  });
                  await _databaseOperations.insertNoteData(
                    NoteCompanion(
                      date: Value(parsedTime),
                      note: Value(textController.text),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ungültiges Zeitformat.")),
                  );
                }
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
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
                content: GestureDetector(
                  onTap: () async {
                    final uri = Uri.file(path, windows: Platform.isWindows);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Konnte Pfad nicht öffnen.'),
                        ),
                      );
                    }
                  },

                  child: Text('PDF gespeichert: $path'),
                ),
                duration: Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          ;
        },
        tooltip: 'Diagramm als PDF exportieren',
      ),
      IconButton(
        icon: const Icon(Icons.add_comment),
        onPressed: () {
          addNote();
        },
        tooltip: 'Notiz hinzufügen',
      ),
      ElevatedButton(
        child: Text(
          isSimulationRunning ? "Simulaton stoppen" : "Simulation start",
        ),
        onPressed: () {
          if (!isSimulationRunning) {
            simulator.startSimulation(intervalMs: 1000);
            _startTime = DateTime.now();
            isSimulationRunning = true;
          } else {
            isSimulationRunning = false;
            simulator.stopSimulation();
          }
        },
      ),
    ];
  }

  double get maxX => widget.chartConfig.dataPoints.values
      .expand((list) => list)
      .fold(
        0.0,
        (prev, spot) => spot.x > prev ? spot.x : prev,
      ); // calculated in milliseconds * 1000 since epoch

  double get maxY => widget.chartConfig.dataPoints.values
      .expand((list) => list)
      .fold(0.0, (prev, spot) => spot.y > prev ? spot.y : prev);

  Tuple2<double, double> getSliderMinMax(SettingsProvider settingsProvider) {
    double sliderMin;
    double sliderMax;

    if (settingsProvider.selectedTimeChoice ==
        TimeChoice.relativeToStart.value) {
      sliderMin = 0;
      sliderMax =
          maxX == 0
              ? settingsProvider.scrollingSeconds.toDouble()
              : SensorDataTransformation.transformDateTimeToSecondsSinceStart(
                DateTime.fromMillisecondsSinceEpoch((maxX * 1000).toInt()),
              ).toDouble();
    } else {
      sliderMin = SensorDataTransformation.transformDateTimeToSecondsAsDouble(
        GlobalStartTime().startTime,
      );
      sliderMax = maxX;
    }

    if (sliderMax < sliderMin) {
      // e.g. if no data has been sent yet
      sliderMax = sliderMin + 1;
    }

    return Tuple2(sliderMin, sliderMax);
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    return GestureDetector(
      onTapUp: (details) {
        final touchX = details.localPosition.dx;
        final chartWidth = MediaQuery.of(context).size.width - 32;
        final pointSpacing =
            chartWidth / (widget.chartConfig.dataPoints.length - 1);

        final index = (touchX / pointSpacing).round();

        if (index >= 0 && index < widget.chartConfig.dataPoints.length) {
          addNote();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chartConfig.title),
          actions: buildAppBarActions(),
        ),
        body: GestureDetector(
          child: InteractiveViewer(
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
                                      min: 0,
                                      max: maxY,
                                    ),
                                  ),
                                  Expanded(
                                    child: Sensordata(
                                      selectedLines: selectedValues,
                                      chartConfig: widget.chartConfig,
                                      autoFollowLatestData:
                                          autoFollowLatestData,
                                      baselineX: baselineX,
                                      warningRanges: warningRanges,
                                      settingsProvider:
                                          Provider.of<SettingsProvider>(
                                            context,
                                            listen: false,
                                          ),
                                    ).getLineChart(
                                      baselineX,
                                      (20 - (baselineY + 10)) - 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    //TODO: bei zeit ab start geht er bis -unlimited
                                    //TODO: Slider startet immer links?!
                                    value: baselineX.clamp(
                                      getSliderMinMax(settingsProvider).item1,
                                      getSliderMinMax(settingsProvider).item2,
                                    ),
                                    onChanged: (newValue) {
                                      setState(() {
                                        autoFollowLatestData = false;
                                        baselineX = newValue.clamp(
                                          getSliderMinMax(
                                            settingsProvider,
                                          ).item1,
                                          getSliderMinMax(
                                            settingsProvider,
                                          ).item2,
                                        );
                                      });
                                    },
                                    min:
                                        getSliderMinMax(settingsProvider).item1,
                                    max:
                                        getSliderMinMax(settingsProvider).item2,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    autoFollowLatestData
                                        ? Icons.lock_clock
                                        : Icons.lock_open,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      autoFollowLatestData =
                                          !autoFollowLatestData;
                                      if (autoFollowLatestData) {
                                        baselineX = maxX;
                                      }
                                    });
                                  },
                                  tooltip:
                                      autoFollowLatestData
                                          ? 'Automatische Verfolgung deaktivieren'
                                          : 'Automatische Verfolgung aktivieren',
                                ),
                              ],
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
      ),
    );
  }
}
