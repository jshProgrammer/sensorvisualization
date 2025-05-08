import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/models/ConnectionDisplayState.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/SampleData.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:sensorvisualization/presentation/widgets/ChartSelectorTab.dart';
import 'package:tuple/tuple.dart';
import '../../data/models/ChartConfig.dart';
import 'package:sensorvisualization/presentation/widgets/ChartPage.dart';
import '../widgets/MultipleChartsPage.dart';

class ChartsHomeScreen extends StatefulWidget {
  const ChartsHomeScreen({super.key});

  @override
  State<ChartsHomeScreen> createState() => _ChartsHomeScreenState();
}

class _ChartsHomeScreenState extends State<ChartsHomeScreen> {
  final List<ChartConfig> charts = [];
  int selectedChartIndex = 0;
  bool useMultipleCharts = false;

  final firebaseSync = Firebasesync();

  @override
  void initState() {
    super.initState();
    _addNewChart();

    GlobalStartTime().initializeStartTime();
  }

  void _addNewChart() {
    setState(() {
      final newIndex = charts.length;
      final newChart = ChartConfig(
        id: 'chart_$newIndex',
        title: 'Diagramm ${newIndex + 1}',
        dataPoints: {},
        color: Colors.primaries[newIndex % Colors.primaries.length],
      );
      charts.add(newChart);
      selectedChartIndex = charts.length - 1;
    });
  }

  void _deleteChart(int index) {
    if (charts.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens ein Diagramm muss bestehen bleiben'),
        ),
      );
      return;
    }

    setState(() {
      charts.removeAt(index);
      if (selectedChartIndex >= charts.length) {
        selectedChartIndex = charts.length - 1;
      }
    });
  }

  int _selectedTimeChoice = TimeChoice.timestamp.value;
  int _selectedAbsRelData = AbsRelDataChoice.relative.value;
  int _selectedTimeUnit = TimeUnitChoice.seconds.value;

  TextEditingController _secondsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor visualization (THW)'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showSettingsDialog();
            },
          ),

          IconButton(
            icon: Icon(Icons.smartphone),
            onPressed: () {
              showConnectedDevicesDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () async {
              showQRCodeDialog();
            },
          ),
          Row(
            children: [
              Text(
                'Mehrere Diagramme',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              Switch(
                value: useMultipleCharts,
                onChanged: (value) {
                  setState(() {
                    useMultipleCharts = value;
                  });
                },
                activeColor: Colors.blue,
                inactiveTrackColor: const Color.fromARGB(255, 70, 70, 70),
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          ChartSelectorTab(
            charts: charts,
            selectedChartIndex: selectedChartIndex,
          ),
          Expanded(
            child:
                charts.isEmpty
                    ? const Center(child: Text('Keine Diagramme vorhanden'))
                    : useMultipleCharts
                    ? MultipleChartsPage(chartPages: charts)
                    : ChartPage(chartConfig: charts[selectedChartIndex]),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Diagramm löschen',
            onPressed: () => _deleteChart(selectedChartIndex),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewChart,
        tooltip: 'Neues Diagramm hinzufügen',
        child: const Icon(Icons.add_chart),
      ),
    );
  }

  Future<void> showQRCodeDialog() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text('QR-Code der IP-Adresse'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrettyQrView.data(data: ip!),
                SizedBox(height: 10),
                Text('IP-Adresse: $ip', style: TextStyle(fontSize: 16)),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Schließen'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einstellungen"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Mitlaufende Sekunden:"),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _secondsController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            decoration: InputDecoration(
                              labelText:
                                  'default: ${SettingsProvider.DEFAULT_SCROLLING_SECONDS} s',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value:
                              TimeUnitChoice.fromValue(
                                _selectedTimeUnit,
                              ).asString(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
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
                      ],
                    ),
                    Divider(color: Colors.grey, thickness: 1, height: 20),
                    Text("Zeiteinstellung:"),
                    SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(
                          value: TimeChoice.timestamp.value,
                          label: Text('Systemzeit'),
                        ),
                        ButtonSegment<int>(
                          value: TimeChoice.relativeToStart.value,
                          label: Text('Zeit ab Start'),
                        ),
                      ],
                      selected: {_selectedTimeChoice},
                      onSelectionChanged: (Set<int> newSelection) {
                        setStateDialog(() {
                          _selectedTimeChoice = newSelection.first;
                        });
                      },
                    ),
                    Divider(color: Colors.grey, thickness: 1, height: 20),
                    Text("Sensordaten:"),
                    SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(
                          value: AbsRelDataChoice.relative.value,
                          label: Text('Relative Werte'),
                        ),
                        ButtonSegment<int>(
                          value: AbsRelDataChoice.absolute.value,
                          label: Text('Absolute Werte'),
                        ),
                      ],
                      selected: {_selectedAbsRelData},
                      onSelectionChanged: (Set<int> newSelection) {
                        setStateDialog(() {
                          _selectedAbsRelData = newSelection.first;
                        });
                      },
                    ),
                    Divider(color: Colors.grey, thickness: 1, height: 20),
                    Text("Datenbank Synchronisation:"),
                    SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Synchronisieren'),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Nicht synchronisieren'),
                        ),
                      ],
                      selected: {firebaseSync.isSyncing},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setStateDialog(() {
                          firebaseSync.isSyncing = newSelection.first;
                        });
                      },
                    ),
                    if (firebaseSync.isSyncing) ...[
                      SizedBox(height: 8),
                      Text("Synchronisationfrequenz (in Minuten):"),
                      Slider(
                        value: firebaseSync.syncInterval.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: '${firebaseSync.syncInterval} Minuten',
                        onChanged: (double value) {
                          setStateDialog(() {
                            firebaseSync.syncInterval = value.round();
                          });
                        },
                      ),
                    ],
                    Divider(color: Colors.grey, thickness: 1, height: 20),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Schließen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () {
                if (_secondsController.text.isNotEmpty) {
                  final value =
                      int.tryParse(_secondsController.text) ??
                      SettingsProvider.DEFAULT_SCROLLING_SECONDS;
                  TimeUnitChoice unitChoice = TimeUnitChoice.fromValue(
                    _selectedTimeUnit,
                  );
                  final seconds =
                      (unitChoice == TimeUnitChoice.seconds
                          ? value
                          : unitChoice == TimeUnitChoice.minutes
                          ? value * 60
                          : value * 3600);
                  Provider.of<SettingsProvider>(
                    context,
                    listen: false,
                  ).setScrollingSeconds(seconds);
                }

                Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).setTimeChoice(_selectedTimeChoice);
                Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).setDataMode(_selectedAbsRelData);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showConnectedDevicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //TODO: Timer
        return Consumer<ConnectionProvider>(
          builder: (context, provider, _) {
            return StatefulBuilder(
              builder: (context, setState) {
                final connectedDevices = provider.connectedDevices;

                return AlertDialog(
                  title: Text("Verbundene Geräte"),
                  content:
                      connectedDevices.isEmpty
                          ? Text("Keine Geräte verbunden")
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                connectedDevices.entries.map((entry) {
                                  final state = provider
                                      .getCurrentConnectionState(entry.key);
                                  int? remainingSeconds = provider
                                      .getRemainingConnectionDurationInSec(
                                        entry.key,
                                      );

                                  Timer.periodic(Duration(seconds: 1), (timer) {
                                    setState(() {
                                      remainingSeconds = provider
                                          .getRemainingConnectionDurationInSec(
                                            entry.key,
                                          );
                                      if (remainingSeconds == null ||
                                          remainingSeconds != null &&
                                              remainingSeconds! <= 0) {
                                        timer.cancel();
                                      }
                                    });
                                  });

                                  return ListTile(
                                    title: Text(entry.value),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: state.iconColor,
                                              size: 12,
                                            ),
                                            SizedBox(width: 10),
                                            Text(state.displayName),
                                            if (state ==
                                                    ConnectionDisplayState
                                                        .nullMeasurement ||
                                                state ==
                                                    ConnectionDisplayState
                                                        .delayedMeasurement)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Text(
                                                  remainingSeconds != null &&
                                                          remainingSeconds! >= 0
                                                      ? "Noch $remainingSeconds s"
                                                      : "",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Text(entry.key),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                  actions: [
                    TextButton(
                      child: Text('Schließen'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
