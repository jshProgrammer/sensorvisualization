import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/controller/visualization/ChartController.dart';
import 'package:sensorvisualization/controller/visualization/SensorDataController.dart';
import 'package:sensorvisualization/data/services/ChartExporter.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/data/settingsModels/ChartConfig.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/model/visualization/ChartConfigurationModel.dart';
import 'package:sensorvisualization/model/visualization/VisualizationSensorDataModel.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/LineStylePainter.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/MultiSelectDialogWidget.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/SensorChartView.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/WarningLevelsSelection.dart';
import 'package:url_launcher/url_launcher.dart';

class ChartView extends StatefulWidget {
  final ChartConfig chartConfig;
  final Map<String, Set<MultiSelectDialogItem>> selectedValues;
  final ValueChanged<Map<String, Set<MultiSelectDialogItem>>>
  onSelectedValuesChanged;

  const ChartView({
    Key? key,
    required this.chartConfig,
    required this.selectedValues,
    required this.onSelectedValuesChanged,
  }) : super(key: key);
  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  late ChartController _chartController;

  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _chartController = ChartController(
      chartConfig: widget.chartConfig,
      selectedValues: widget.selectedValues,
      onSelectedValuesChanged: widget.onSelectedValuesChanged,
      context: context,
      onMeasurementStoppedReceived: () => onMeasurementStoppedReceived,
    );
    _chartController.addListener(_onControllerUpdate);
  }

  void onMeasurementStoppedReceived(String deviceName) {
    if (mounted) {
      _showSnackBarInformation(
        "Messung von $deviceName wurde gestoppt",
        context,
      );
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant ChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_chartController.selectedValues != oldWidget.selectedValues &&
        _chartController.selectedValues != null) {
      setState(() {
        _chartController
            .selectedValues = Map<String, Set<MultiSelectDialogItem>>.from(
          _chartController.selectedValues!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    List<DateTime> currentDangerTimes = List<DateTime>.from(
      _chartController.dangerNavigationController.all,
    );
    if (currentDangerTimes.isEmpty) {
      currentDangerTimes.add(
        _chartController.truncateToSeconds(DateTime.now()),
      );
    }

    if (_chartController.localIndex < 0 ||
        _chartController.localIndex >= currentDangerTimes.length) {
      _chartController.localIndex = 0;
    }

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title:
              _chartController.isEditingTitle
                  ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _chartController.titleController,
                      focusNode: _chartController.focusNode,
                      autofocus: true,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            widget.chartConfig.title = value.trim();
                            _chartController.isEditingTitle = false;
                          });
                        } else {
                          setState(() {
                            _chartController.titleController.text =
                                widget.chartConfig.title;
                            _chartController.isEditingTitle = false;
                          });
                        }
                      },
                    ),
                  )
                  : GestureDetector(
                    onTap: () {
                      setState(() {
                        _chartController.isEditingTitle = true;
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
                      transformationController:
                          _chartController.transformationController,
                      panEnabled: _chartController.isPanEnabled,
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
                                baselineX: _chartController.baselineX,
                                autoFollowLatestData:
                                    _chartController.autoFollowLatestData,
                              ),

                              //TODO: ChartConfig doch jetzt eig unnötig?!
                              sensorDataModel: VisualizationSensorDataModel(
                                dataPoints: widget.chartConfig.dataPoints,
                                notes: widget.chartConfig.notes,
                                selectedSensors:
                                    _chartController.selectedValues!,
                                warningRanges: widget.chartConfig.ranges,
                              ),
                              selectedColors: _chartController.selectedColors,
                            ),
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
                            value: _chartController.baselineX.clamp(
                              _chartController
                                  .getSliderMinMax(settingsProvider)
                                  .item1,
                              _chartController
                                  .getSliderMinMax(settingsProvider)
                                  .item2,
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                _chartController.autoFollowLatestData = false;
                                _chartController.baselineX = newValue.clamp(
                                  _chartController
                                      .getSliderMinMax(settingsProvider)
                                      .item1,
                                  _chartController
                                      .getSliderMinMax(settingsProvider)
                                      .item2,
                                );
                              });
                            },
                            min:
                                _chartController
                                    .getSliderMinMax(settingsProvider)
                                    .item1,
                            max:
                                _chartController
                                    .getSliderMinMax(settingsProvider)
                                    .item2,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _chartController.autoFollowLatestData
                                ? Icons.lock_clock
                                : Icons.lock_open,
                          ),
                          onPressed: () {
                            setState(() {
                              _chartController.autoFollowLatestData =
                                  !_chartController.autoFollowLatestData;
                              if (_chartController.autoFollowLatestData) {
                                _chartController.baselineX =
                                    _chartController.maxX;
                              }
                            });
                          },
                          tooltip:
                              _chartController.autoFollowLatestData
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
                      children: _buildLegendItems(context),
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
                            currentDangerTimes.length > 1 &&
                                    _chartController.localIndex > 0
                                ? () {
                                  setState(() {
                                    _chartController.localIndex--;
                                    _chartController.timeController.text =
                                        _chartController.formatter.format(
                                          currentDangerTimes[_chartController
                                              .localIndex],
                                        );
                                  });
                                }
                                : null,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _chartController.timeController,
                          decoration: const InputDecoration(
                            labelText: "Zeit (z.B. 2025-04-29 13:45:00)",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed:
                            currentDangerTimes.length > 1 &&
                                    _chartController.localIndex <
                                        currentDangerTimes.length - 1
                                ? () {
                                  setState(() {
                                    _chartController.localIndex++;
                                    _chartController.timeController.text =
                                        _chartController.formatter.format(
                                          currentDangerTimes[_chartController
                                              .localIndex],
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
                            _chartController.localIndex =
                                currentDangerTimes.length - 1;
                          });
                          _chartController
                              .timeController
                              .text = _chartController.formatter.format(
                            _chartController.truncateToSeconds(DateTime.now()),
                          );
                        },
                        tooltip: "Aktuelle Uhrzeit",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _chartController.textController,
                    decoration: const InputDecoration(
                      hintText: "Notiz eingeben...",
                    ),
                  ),

                  TextButton(
                    onPressed: () async {
                      try {
                        DateTime parsedTime = DateTime.parse(
                          _chartController.timeController.text,
                        );
                        setState(() {
                          widget.chartConfig.notes[parsedTime] =
                              _chartController.textController.text;
                        });

                        await _chartController.insertNoteData(parsedTime);

                        _chartController.textController.clear();
                        _showSnackBarInformation(
                          "Notiz erfolgreich gespeichert.",
                          context,
                        );
                      } catch (e) {
                        _showSnackBarInformation(
                          "Ungültiges Zeitformat.",
                          context,
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

  void _showMultiSelect(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Multiselectdialogwidget(
          initialSelectedValues: _chartController.selectedValues ?? {},
          initialSelectedColors: _chartController.selectedColors,
        );
      },
    );

    if (result != null) {
      if (result['sensors'] != null) {
        final sensors =
            result['sensors'] as Map<String, Set<MultiSelectDialogItem>>;
        setState(() {
          _chartController.selectedValues = sensors;
        });
      }
      if (result['colors'] != null) {
        final colors =
            result['colors'] as Map<String, Map<MultiSelectDialogItem, Color>>;
        setState(() {
          _chartController.selectedColors = colors;
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
            final currentZoom = _chartController.getCurrentZoom();
            currentZoom.multiply(zoom);
            _chartController.setCurrentZoom(currentZoom);
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

            var currentZoom = _chartController.getCurrentZoom();
            if (currentZoom.getMaxScaleOnAxis() > 1.0) {
              currentZoom.multiply(zoom);
              if (currentZoom.getMaxScaleOnAxis() < 1.0) {
                currentZoom = Matrix4.identity();
              }
              _chartController.setCurrentZoom(currentZoom);
            } else {
              _showSnackBarInformation(
                'Weiteres Herauszoomen nicht erlaubt',
                context,
              );
            }
          });
        },
        tooltip: 'Verkleinern',
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _chartController.resetZoom,
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
            final exporter = ChartExporter(
              _chartKey,
              _chartController.getLegendData(),
            );
            final path = await exporter.exportToPDF("Diagramm_Export");

            if (!context.mounted) return;

            if (path == null) {
              _showSnackBarInformation(
                'Fehler beim Exportieren des Diagramms',
                context,
              );
            } else {
              _showSnackBarClickableWithPath(
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.file(path, windows: Platform.isWindows);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      _showSnackBarInformation(
                        'Konnte Pfad nicht öffnen.',
                        context,
                      );
                    }
                  },
                  child: Text('PDF gespeichert: $path'),
                ),
                context,
              );
            }
          } else if (value == 'csv') {
            final path = await _chartController.exportSensorDataCSV();

            if (!context.mounted) return;

            if (path == "Fehler") {
              _showSnackBarInformation(
                'Fehler beim Exportieren der CSV-Datei',
                context,
              );
            } else {
              _showSnackBarClickableWithPath(
                GestureDetector(
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
                context,
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
      ElevatedButton(
        child: Text(
          _chartController.isSimulationRunning
              ? "Simulaton stoppen"
              : "Simulation start",
        ),
        onPressed: () {
          if (!_chartController.isSimulationRunning) {
            _chartController.simulator.startSimulation(intervalMs: 1000);
            _chartController.startTime = DateTime.now();
            _chartController.isSimulationRunning = true;
          } else {
            _chartController.isSimulationRunning = false;
            _chartController.simulator.stopSimulation();
          }
        },
      ),
    ];
  }

  void _showSnackBarInformation(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSnackBarClickableWithPath(Widget content, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: content));
  }

  List<Widget> _buildLegendItems(BuildContext context) {
    List<Widget> rows = [];

    var connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );

    for (String device in _chartController.selectedValues!.keys) {
      for (MultiSelectDialogItem sensor
          in _chartController.selectedValues![device]!) {
        rows.add(
          Row(
            children: [
              CustomPaint(
                size: const Size(24, 12),
                painter: LineStylePainter(
                  color:
                      _chartController.selectedColors[device]?[sensor] ??
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
      }
    }

    return rows;
  }

  //TODO auslagern in controller
  void _showMetadataHistory() async {
    int currentIndex = 0;
    final tables = await _chartController.getAvailableFirebaseTables();

    if (tables.isEmpty) {
      _showSnackBarInformation('Keine archivierten Daten gefunden', context);
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
                        String paths = await _chartController
                            .exportTableByNameAndDate(
                              currentTable['name'],
                              DateTime.parse(currentTable['last_updated']),
                            );

                        Navigator.pop(context);

                        if (paths.isNotEmpty) {
                          _showSnackBarClickableWithPath(
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.file(paths);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  _showSnackBarInformation(
                                    'Konnte Datei nicht öffnen.',
                                    context,
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
                            context,
                          );
                        }
                      } catch (e) {
                        _showSnackBarInformation(
                          'Fehler beim Export: $e',
                          context,
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
}
