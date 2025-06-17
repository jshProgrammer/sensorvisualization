import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/controller/visualization/SensorDataController.dart';
import 'package:sensorvisualization/data/services/DangerDetector.dart';
import 'package:sensorvisualization/data/services/DangerNavigationController.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/model/visualization/ChartConfigurationModel.dart';
import 'package:sensorvisualization/model/visualization/VisualizationSensorDataModel.dart';

import 'package:sensorvisualization/presentation/visualization/widgets/SensorChartView.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/MultiSelectDialogWidget.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/WarningLevelsSelection.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/settingsModels/ChartConfig.dart';
import '../../../data/settingsModels/ColorSettings.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';
import 'package:sensorvisualization/data/services/SensorDataSimulator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:sensorvisualization/database/DatabaseOperations.dart';

class ChartPage extends StatefulWidget {
  final ChartConfig chartConfig;

  final Map<String, Set<MultiSelectDialogItem>>? selectedValues;

  final void Function(Map<String, Set<MultiSelectDialogItem>>)?
  onSelectedValuesChanged;

  const ChartPage({super.key, required this.chartConfig})
    : selectedValues = null,
      onSelectedValuesChanged = null;

  const ChartPage.withSelectedValues({
    super.key,
    required this.chartConfig,
    required this.selectedValues,
    required this.onSelectedValuesChanged,
  });

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>
    with AutomaticKeepAliveClientMixin {
  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  bool get wantKeepAlive => true;

  bool _isEditingTitle = false;

  late TextEditingController _titleController;

  late FocusNode _focusNode;

  double baselineX = 0.0;

  bool autoFollowLatestData = true;
  bool _isPanEnabled = false;

  final TextEditingController _noteController = TextEditingController();

  late TransformationController _transformationController;

  int? selectedPointIndex;

  Map<String, Set<MultiSelectDialogItem>> selectedValues = {};
  Map<String, Map<MultiSelectDialogItem, Color>> selectedColors = {};

  final GlobalKey _chartKey = GlobalKey();

  late StreamSubscription _dataSubscription;

  late DateTime _startTime;

  List<DateTime> _allDangerTimestamps = [];

  late SensorDataSimulator simulator;
  bool isSimulationRunning = false;

  DangerNavigationController dangerNavigationController =
      DangerNavigationController();
  late DateTime defaultTime;
  final textController = TextEditingController();
  late final TextEditingController timeController;
  List<DateTime> allDangerTimes = [];
  int localIndex = 0;

  late DangerDetector _dangerDetector;

  // Map<String, List<WarningRange>> warningRanges = {
  //   'green': [],
  //   'yellow': [],
  //   'red': [],
  // };

  late Databaseoperations _databaseOperations;

  //Only for Simulation
  @override
  void initState() {
    super.initState();

    selectedValues =
        widget.selectedValues != null
            ? Map<String, Set<MultiSelectDialogItem>>.from(
              widget.selectedValues!,
            )
            : {};
    _transformationController = TransformationController();

    _titleController = TextEditingController(text: widget.chartConfig.title);

    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditingTitle) {
        setState(() {
          _titleController.text = widget.chartConfig.title;
          _isEditingTitle = false;
        });
      }
    });

    _startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _databaseOperations = Provider.of<Databaseoperations>(
        context,
        listen: false,
      );
    });
    defaultTime =
        dangerNavigationController.current ?? truncateToSeconds(DateTime.now());
    timeController = TextEditingController(text: formatter.format(defaultTime));

    // Safely initialize allDangerTimes and localIndex
    allDangerTimes = dangerNavigationController.all;
    if (allDangerTimes.isEmpty) {
      allDangerTimes = [defaultTime]; // Provide a default if list is empty
    }
    localIndex = dangerNavigationController.all.indexOf(
      dangerNavigationController.current ?? defaultTime,
    );
    if (localIndex < 0) localIndex = 0; // Safety check

    _dataSubscription = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    ).dataStream.listen(_handleSensorData);

    Provider.of<ConnectionProvider>(
      context,
      listen: false,
    ).measurementStopped.listen((deviceName) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Messung von $deviceName wurde gestoppt"),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    _transformationController = TransformationController();
    _transformationController.addListener(_handleTransformationChange);

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

            widget.chartConfig.addDataPoint(
              SensorDataSimulator.simulatedIPAddress,
              SensorType.simulatedData,
              SensorOrientation.x,
              FlSpot(timestamp, x),
            );
            widget.chartConfig.addDataPoint(
              SensorDataSimulator.simulatedIPAddress,
              SensorType.simulatedData,
              SensorOrientation.y,
              FlSpot(timestamp, y),
            );
            widget.chartConfig.addDataPoint(
              SensorDataSimulator.simulatedIPAddress,
              SensorType.simulatedData,
              SensorOrientation.z,
              FlSpot(timestamp, z),
            );

            final dateTime = _startTime.add(
              Duration(milliseconds: (timestamp * 1000).toInt()),
            );

            // final newDangers = DangerDetector.findDangerTimestamps(
            //   points: [
            //     FlSpot(timestamp, x),
            //     FlSpot(timestamp, y),
            //     FlSpot(timestamp, z),
            //   ],
            //   timestamps: [dateTime, dateTime, dateTime],
            //   warningLevels: warningRanges,
            // );

            List<FlSpot> selectedPoints = [];
            List<DateTime> selectedTimestamps = [];

            for (final device in selectedValues.keys) {
              for (final sensorItem in selectedValues[device]!) {
                if (sensorItem.attribute != null) {
                  double val;
                  switch (sensorItem.attribute!) {
                    case SensorOrientation.x:
                      val = x;
                      break;
                    case SensorOrientation.y:
                      val = y;
                      break;
                    case SensorOrientation.z:
                      val = z;
                      break;
                    case SensorOrientation.pressure:
                      continue;
                    case SensorOrientation.degree:
                      continue;
                    case SensorOrientation.displacement:
                      continue;
                  }
                  selectedPoints.add(FlSpot(timestamp, val));
                  selectedTimestamps.add(dateTime);
                }
              }
            }

            selectedTimestamps.sort();

            final newDangers = DangerDetector.findDangerTimestamps(
              points: selectedPoints,
              timestamps: selectedTimestamps,
              warningLevels: widget.chartConfig.ranges,
            );

            final formattedNewDangers =
                newDangers.map((dt) => truncateToSeconds(dt)).toList();

            for (final t in formattedNewDangers) {
              if (!_allDangerTimestamps.contains(t)) {
                _allDangerTimestamps.add(t);
              }
            }

            _allDangerTimestamps.sort();

            _dangerDetector = DangerDetector(_allDangerTimestamps);

            if (formattedNewDangers.isNotEmpty) {
              dangerNavigationController.setCurrent(formattedNewDangers.first);
            }

            if (autoFollowLatestData) {
              baselineX = timestamp;
            }
          });
        }
      },
    );
    simulator.init();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    _dataSubscription.cancel();
    simulator.stopSimulation();
    super.dispose();
  }

  void _handleSensorData(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        var jsonData = SensorDataTransformation.returnAbsoluteSensorDataAsJson(
          data,
        );

        double timestampAsDouble =
            SensorDataTransformation.transformDateTimeToSecondsAsDouble(
              jsonData["timestamp"],
            );

        if (jsonData.containsKey('sensor') &&
            jsonData['sensor'] != null &&
            jsonData['sensor'] == SensorType.accelerometer &&
            jsonData.containsKey('x') &&
            jsonData['x'] != null &&
            jsonData.containsKey('y') &&
            jsonData['y'] != null &&
            jsonData.containsKey('z') &&
            jsonData['z'] != null) {
          try {
            double deviation = SensorDataTransformation.deviationTo90Degrees(
              jsonData['x'] as double,
              jsonData['y'] as double,
              jsonData['z'] as double,
            );

            widget.chartConfig.addDataPoint(
              jsonData['ip'],
              SensorType.deviationTo90Degrees,
              SensorOrientation.degree,
              FlSpot(timestampAsDouble, deviation),
            );
          } catch (e) {
            print('Fehler bei der Berechnung der Abweichung zu 90 Grad: $e');
          }
        }

        if (jsonData.containsKey('sensor') &&
            jsonData['sensor'] != null &&
            jsonData['sensor'] == SensorType.accelerometer &&
            jsonData.containsKey('x') &&
            jsonData['x'] != null &&
            jsonData.containsKey('y') &&
            jsonData['y'] != null &&
            jsonData.containsKey('z') &&
            jsonData['z'] != null) {
          try {
            double deviation = SensorDataTransformation.deviationTo90Degrees(
              jsonData['x'] as double,
              jsonData['y'] as double,
              jsonData['z'] as double,
            );
            double displacement = SensorDataTransformation.topPointDisplacement(
              deviation,
            );

            widget.chartConfig.addDataPoint(
              jsonData['ip'],
              SensorType.displacementOneMeter,
              SensorOrientation.displacement,
              FlSpot(timestampAsDouble, displacement),
            );
          } catch (e) {
            print('Fehler bei der Berechnung der Abweichung zu 90 Grad: $e');
          }
        }

        if (jsonData.containsKey('x') && jsonData['x'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['ip'],
            jsonData['sensor'],
            SensorOrientation.x,
            FlSpot(timestampAsDouble, jsonData['x'] as double),
          );
        }
        if (jsonData.containsKey('y') && jsonData['y'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['ip'],
            jsonData['sensor'],
            SensorOrientation.y,
            FlSpot(timestampAsDouble, jsonData['y'] as double),
          );
        }
        if (jsonData.containsKey('z') && jsonData['z'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['ip'],
            jsonData['sensor'],
            SensorOrientation.z,
            FlSpot(timestampAsDouble, jsonData['z'] as double),
          );
        }
        if (jsonData.containsKey('pressure') && jsonData['pressure'] != null) {
          widget.chartConfig.addDataPoint(
            jsonData['ip'],
            jsonData['sensor'],
            SensorOrientation.pressure,
            FlSpot(timestampAsDouble, jsonData['pressure'] as double),
          );
        }

        double timestamp = timestampAsDouble;
        final dateTime = DateTime.fromMillisecondsSinceEpoch(
          (timestamp * 1000).toInt(),
        );

        double x =
            (jsonData.containsKey('x') && jsonData['x'] != null)
                ? jsonData['x'] as double
                : 0.0;
        double y =
            (jsonData.containsKey('y') && jsonData['y'] != null)
                ? jsonData['y'] as double
                : 0.0;
        double z =
            (jsonData.containsKey('z') && jsonData['z'] != null)
                ? jsonData['z'] as double
                : 0.0;

        List<FlSpot> selectedPoints = [];
        List<DateTime> selectedTimestamps = [];

        for (final device in selectedValues.keys) {
          for (final sensorItem in selectedValues[device]!) {
            if (sensorItem.attribute != null) {
              double val;
              switch (sensorItem.attribute!) {
                case SensorOrientation.x:
                  val = x;
                  break;
                case SensorOrientation.y:
                  val = y;
                  break;
                case SensorOrientation.z:
                  val = z;
                  break;
                case SensorOrientation.pressure:
                  continue;
                case SensorOrientation.degree:
                  continue;
                case SensorOrientation.displacement:
                  continue;
              }
              selectedPoints.add(FlSpot(timestamp, val));
              selectedTimestamps.add(dateTime);
            }
          }
        }

        selectedTimestamps.sort();

        final newDangers = DangerDetector.findDangerTimestamps(
          points: selectedPoints,
          timestamps: selectedTimestamps,
          warningLevels: widget.chartConfig.ranges,
        );

        final formattedNewDangers =
            newDangers.map((dt) => truncateToSeconds(dt)).toList();

        for (final t in formattedNewDangers) {
          if (!_allDangerTimestamps.contains(t)) {
            _allDangerTimestamps.add(t);
          }
        }

        _allDangerTimestamps.sort();

        _dangerDetector = DangerDetector(_allDangerTimestamps);

        if (formattedNewDangers.isNotEmpty) {
          dangerNavigationController.setCurrent(formattedNewDangers.first);
        }

        if (autoFollowLatestData) {
          baselineX = timestamp;
        }
      });
    }
  }

  DateTime truncateToSeconds(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  @override
  void didUpdateWidget(covariant ChartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues &&
        widget.selectedValues != null) {
      setState(() {
        selectedValues = Map<String, Set<MultiSelectDialogItem>>.from(
          widget.selectedValues!,
        );
      });
    }
  }

  void _updateSelectedValues(
    Map<String, Set<MultiSelectDialogItem>> newValues,
  ) {
    setState(() {
      selectedValues = newValues;
    });

    if (widget.onSelectedValuesChanged != null) {
      widget.onSelectedValuesChanged!(newValues);
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Multiselectdialogwidget(
          initialSelectedValues: selectedValues,
          initialSelectedColors: selectedColors,
        );
      },
    );

    if (result != null) {
      if (result['sensors'] != null) {
        final sensors =
            result['sensors'] as Map<String, Set<MultiSelectDialogItem>>;
        setState(() {
          selectedValues = sensors;
        });
      }
      if (result['colors'] != null) {
        final colors =
            result['colors'] as Map<String, Map<MultiSelectDialogItem, Color>>;
        setState(() {
          selectedColors = colors;
        });
      }
    }
  }

  void _showWarnLevelSelection(BuildContext context) async {
    final result = await showDialog<Map<String, List<WarningRange>>>(
      context: context,
      builder: (BuildContext context) {
        return Warninglevelsselection(initialValues: widget.chartConfig.ranges);
      },
    );

    if (result != null) {
      setState(() {
        widget.chartConfig.ranges = {
          for (var entry in result.entries)
            entry.key: List<WarningRange>.from(entry.value),
        };
      });
    }
  }

  void updateTimeField() {
    timeController.text = allDangerTimes[localIndex].toString();
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
        icon: const Icon(Icons.archive),
        onPressed: _showMetadataHistory,
        tooltip: 'Archivierte Daten exportieren',
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.save_alt),
        tooltip: 'Diagramm exportieren',
        onSelected: (value) async {
          if (value == 'pdf') {
            await Future.delayed(Duration.zero);
            final exporter = ChartExporter(_chartKey, getLegendData());
            final path = await exporter.exportToPDF("Diagramm_Export");

            if (!context.mounted) return;

            if (path == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fehler beim Exportieren des Diagramms'),
                  duration: Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else if (value == 'csv') {
            final path = await _databaseOperations.exportSensorDataCSV(context);

            if (!context.mounted) return;

            if (path == "Fehler") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fehler beim Exportieren der CSV-Datei'),
                  duration: Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
                    child: Text('CSV gespeichert: $path'),
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Text('Als PDF exportieren'),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Text('Sensor-Daten als CSV exportieren'),
              ),
            ],
      ),

      /*IconButton(
        icon: const Icon(Icons.add_comment),
        onPressed: () {
          addNote(initialTime: _dangerNavigationController.current);
        },
        tooltip: 'Notiz hinzufügen',
      ),*/
      ElevatedButton(
        child: Text(
          isSimulationRunning ? "Simulation stoppen" : "Simulation start",
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
      .expand((map) => map.values)
      .expand((list) => list)
      .fold(
        0.0,
        (prev, spot) => spot.x > prev ? spot.x : prev,
      ); // calculated in milliseconds * 1000 since epoch

  double get maxY => widget.chartConfig.dataPoints.values
      .expand((map) => map.values)
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

  void _handleTransformationChange() {
    final scale = _transformationController.value.getMaxScaleOnAxis();

    if (scale > 1.0 && !_isPanEnabled) {
      setState(() {
        _isPanEnabled = true;
      });
    } else if (scale <= 1.0 && _isPanEnabled) {
      setState(() {
        _isPanEnabled = false;
      });
    }
  }

  void _showMetadataHistory() async {
    final dates = await _databaseOperations.getCreateDates();
    int currentIndex = 0;
    final firebasesync = Firebasesync();
    final tables = await firebasesync.getAvailableTables();

    if (tables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine archivierten Daten gefunden')),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentTable = tables[currentIndex];
            return AlertDialog(
              title: const Text('Archivierte Daten'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed:
                            currentIndex > 0
                                ? () {
                                  setState(() {
                                    currentIndex--;
                                  });
                                }
                                : null,
                      ),
                      Expanded(
                        child: Text(
                          '${currentTable['name']}\n${currentTable['last_updated']}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed:
                            currentIndex < tables.length - 1
                                ? () {
                                  setState(() {
                                    currentIndex++;
                                  });
                                }
                                : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        String paths = await firebasesync
                            .exportTableByNameAndDate(
                              currentTable['name'],
                              DateTime.parse(currentTable['last_updated']),
                            );

                        Navigator.pop(context);

                        if (paths.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: GestureDetector(
                                onTap: () async {
                                  final uri = Uri.file(paths);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Konnte Datei nicht öffnen.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'CSV-Datei exportiert: $paths',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              duration: const Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fehler beim Export: $e'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Als CSV exportieren'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Schließen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    List<DateTime> currentDangerTimes = List<DateTime>.from(
      dangerNavigationController.all,
    );
    if (currentDangerTimes.isEmpty) {
      currentDangerTimes.add(truncateToSeconds(DateTime.now()));
    }

    if (localIndex < 0 || localIndex >= currentDangerTimes.length) {
      localIndex = 0;
    }

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title:
              _isEditingTitle
                  ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      autofocus: true,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            widget.chartConfig.title = value.trim();
                            _isEditingTitle = false;
                          });
                        } else {
                          setState(() {
                            _titleController.text = widget.chartConfig.title;
                            _isEditingTitle = false;
                          });
                        }
                      },
                    ),
                  )
                  : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingTitle = true;
                      });
                    },
                    child: Text(
                      widget.chartConfig.title,
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
          actions: buildAppBarActions(),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      panEnabled: _isPanEnabled,
                      minScale: 0.1,
                      maxScale: 10.0,
                      boundaryMargin: const EdgeInsets.all(20.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: RepaintBoundary(
                          key: _chartKey,
                          child:
                          // _buildBackgroundPainter(),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 18.0,
                              right: 18.0,
                            ),

                            child: SensorChartView(
                              configModel: ChartConfigurationModel(
                                borderColor: widget.chartConfig.color,
                                showGrid: settingsProvider.showGrid,
                                scrollingSeconds:
                                    settingsProvider.scrollingSeconds,
                                selectedTimeFormat: 'timestamp',
                                baselineX: baselineX,
                                autoFollowLatestData: autoFollowLatestData,
                              ),

                              //TODO: ChartConfig doch jetzt eig unnötig?!
                              sensorDataModel: VisualizationSensorDataModel(
                                dataPoints: widget.chartConfig.dataPoints,
                                notes: widget.chartConfig.notes,
                                selectedSensors: selectedValues,
                                warningRanges: widget.chartConfig.ranges /* {
                                  'green': [WarningRange(1, 2)],
                                }*/,
                              ),
                              selectedColors: selectedColors,
                            ),

                            /*SensorChartView(
                              selectedLines: selectedValues,
                              chartConfig: widget.chartConfig,
                              autoFollowLatestData: autoFollowLatestData,
                              baselineX: baselineX,
                              warningRanges: widget.chartConfig.ranges,
                              settingsProvider: Provider.of<SettingsProvider>(
                                context,
                                listen: false,
                              ),
                              connectionProvider:
                                  Provider.of<ConnectionProvider>(
                                    context,
                                    listen: false,
                                  ),
                              timeController: timeController,
                            ).getLineChart(context, baselineX),*/
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
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
                                  getSliderMinMax(settingsProvider).item1,
                                  getSliderMinMax(settingsProvider).item2,
                                );
                              });
                            },
                            min: getSliderMinMax(settingsProvider).item1,
                            max: getSliderMinMax(settingsProvider).item2,
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
                              autoFollowLatestData = !autoFollowLatestData;
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
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildLegendItems(),
                    ),
                  ),

                  SizedBox(height: 10),

                  Divider(),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed:
                            currentDangerTimes.length > 1 && localIndex > 0
                                ? () {
                                  setState(() {
                                    localIndex--;
                                    timeController.text = formatter.format(
                                      currentDangerTimes[localIndex],
                                    );
                                  });
                                }
                                : null,
                      ),
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            labelText: "Zeit (z.B. 2025-04-29 13:45:00)",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed:
                            currentDangerTimes.length > 1 &&
                                    localIndex < currentDangerTimes.length - 1
                                ? () {
                                  setState(() {
                                    localIndex++;
                                    timeController.text = formatter.format(
                                      currentDangerTimes[localIndex],
                                    );
                                    // currentDangerTimes[localIndex]
                                    //     .toString();
                                  });
                                }
                                : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            localIndex = currentDangerTimes.length - 1;
                          });
                          timeController.text = formatter.format(
                            truncateToSeconds(DateTime.now()),
                          );
                        },
                        tooltip: "Aktuelle Uhrzeit",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Notiz eingeben...",
                    ),
                  ),

                  TextButton(
                    onPressed: () async {
                      try {
                        DateTime parsedTime = DateTime.parse(
                          timeController.text,
                        );
                        setState(() {
                          widget.chartConfig.notes[parsedTime] =
                              textController.text;
                        });
                        await _databaseOperations.insertNoteData(
                          NoteCompanion(
                            date: Value(parsedTime),
                            note: Value(textController.text),
                          ),
                        );

                        textController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Notiz erfolgreich gespeichert."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ungültiges Zeitformat."),
                          ),
                        );
                      }
                    },
                    child: const Text("Speichern"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getLegendData() {
    List<Map<String, dynamic>> legendData = [];
    int sensorIndex = 0;

    var connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );

    for (String device in selectedValues.keys) {
      for (MultiSelectDialogItem sensor in selectedValues[device]!) {
        legendData.add({
          'device': connectionProvider.connectedDevices[device] ?? "Simulator",
          'sensorName': sensor.sensorName.displayName,
          'attribute': sensor.attribute!.displayName,
          'color':
              selectedColors[device]?[sensor] ??
              SensorDataController.getSensorColor(
                sensor.attribute!.displayName,
              ),
        });

        sensorIndex++;
      }
    }

    return legendData;
  }

  List<Widget> _buildLegendItems() {
    List<Widget> rows = [];
    int sensorIndex = 0;

    var connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );

    for (String device in selectedValues.keys) {
      for (MultiSelectDialogItem sensor in selectedValues[device]!) {
        rows.add(
          Row(
            children: [
              CustomPaint(
                size: const Size(24, 12),
                painter: LineStylePainter(
                  color:
                      selectedColors[device]?[sensor] ??
                      SensorDataController.getSensorColor(
                        sensor.attribute!.displayName,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${connectionProvider.connectedDevices[device] ?? "Simulator"} – ${sensor.sensorName.displayName} -  ${sensor.attribute!.displayName}",
                ),
              ),
            ],
          ),
        );

        sensorIndex++;
      }
    }

    return rows;
  }
}

class LineStylePainter extends CustomPainter {
  final Color color;

  LineStylePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
