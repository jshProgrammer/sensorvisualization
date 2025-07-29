import 'package:sensorvisualization/data/settingsModels/ChartConfig.dart';
import 'package:sensorvisualization/data/settingsModels/ChartTab.dart';
import 'package:sensorvisualization/data/settingsModels/LexikonEntry.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/LexikonDialog.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';

class VisualizationHomeModel {
  final List<ChartTab> _tabs = [];
  final Map<String, Map<String, Set<MultiSelectDialogItem>>> _chartSelections =
      {};
  int _selectedTabIndex = 0;
  int _selectedChartIndex = 0;

  final Firebasesync _firebaseSync = Firebasesync();

  int _selectedTimeChoice = TimeChoice.timestamp.value;
  int _selectedAbsRelData = AbsRelDataChoice.relative.value;
  int _selectedTimeUnit = TimeUnitChoice.seconds.value;
  bool _selectedGridChoice = false;
  bool isPerformanceModeActive = true;

  final List<LexikonEntry> _lexikonEntries = [
    LexikonEntry(
      title: 'Accelerometer',
      description:
          'Einheit: m/s^2. Gemessen wird die Beschleunigung inklusive der Erdbeschleunigung.',
      url: 'https://pub.dev/packages/sensors_plus',
    ),
    LexikonEntry(
      title: 'Gyroskop',
      description:
          'Einheit: rad/s. Misst die Winkelgeschwindigkeit eines Objekts.',
      url:
          'https://developer.android.com/reference/android/hardware/SensorEvent#values',
    ),
    LexikonEntry(
      title: 'Magnetometer',
      description:
          'Einheit: μT (Mikrotesla). Misst die Stärke und Richtung des Magnetfelds.',
      url:
          'https://developer.android.com/reference/android/hardware/SensorEvent#values',
    ),
    LexikonEntry(
      title: 'Barometer',
      description:
          'Einheit: hPa (Hektopascal). Misst den Luftdruck, der auf die Höhe des Objekts schließen lässt.',
      url: 'https://pub.dev/packages/sensors_plus',
    ),
    LexikonEntry(
      title: 'Deviation',
      description:
          'Einheit: °. Berechnet mithilfe des Accelerometers die Abweichung von der vertikalen Ausrichtung.',
      url:
          'https://www.mathworks.com/help/fusion/ug/estimate-orientation-through-inertial-sensor-fusion.html',
    ),
    LexikonEntry(
      title: 'Displacement',
      description:
          'Einheit: mm. Berechnet die Bewegung der geraden in mm auf einen Meter Distanz.',
      url: 'https://mbientlab.com/tutorials/SensorFusion.html',
    ),
    LexikonEntry(
      title: 'Entwickler',
      description: 'Jasmin Wander',
      url: 'https://github.com/xjasx4',
    ),
    LexikonEntry(
      title: 'Entwickler',
      description: 'Sebastian Nagles',
      url: 'https://github.com/SebasN12',
    ),
    LexikonEntry(
      title: 'Entwickler',
      description: 'Joshua Pfennig',
      url: 'https://github.com/jshProgrammer',
    ),
    LexikonEntry(
      title: 'Entwickler',
      description: 'Tom Knoblach',
      url: 'https://github.com/Gottschalk125',
    ),
  ];

  List<ChartTab> get tabs => List.unmodifiable(_tabs);
  Map<String, Map<String, Set<MultiSelectDialogItem>>> get chartSelections =>
      Map.unmodifiable(_chartSelections);
  int get selectedTabIndex => _selectedTabIndex;
  int get selectedChartIndex => _selectedChartIndex;
  Firebasesync get firebaseSync => _firebaseSync;
  int get selectedTimeChoice => _selectedTimeChoice;
  int get selectedAbsRelData => _selectedAbsRelData;
  int get selectedTimeUnit => _selectedTimeUnit;
  bool get selectedGridChoice => _selectedGridChoice;
  set selectedGridChoice(bool value) {
    _selectedGridChoice = value;
  }

  List<LexikonEntry> get lexikonEntries => List.unmodifiable(_lexikonEntries);

  List<ChartConfig> get activeCharts {
    return _tabs.isNotEmpty ? _tabs[_selectedTabIndex].charts : [];
  }

  List<String> get tabTitles {
    return _tabs.map((tab) => tab.title).toList();
  }

  bool get hasCharts {
    return _tabs.isNotEmpty && _tabs[_selectedTabIndex].charts.isNotEmpty;
  }

  void addTab(ChartTab tab) {
    _tabs.add(tab);
    _selectedTabIndex = _tabs.length - 1;

    for (final chart in tab.charts) {
      _chartSelections[chart.id] = {};
    }
  }

  void deleteCurrentTab() {
    if (_tabs.length <= 1) return;

    final removedTab = _tabs.removeAt(_selectedTabIndex);

    for (final chart in removedTab.charts) {
      _chartSelections.remove(chart.id);
    }

    _selectedTabIndex = (_selectedTabIndex - 1).clamp(0, _tabs.length - 1);
  }

  void setSelectedTabIndex(int index) {
    if (index >= 0 && index < _tabs.length) {
      _selectedTabIndex = index;
    }
  }

  void renameCurrentTab(String newName) {
    if (_selectedTabIndex < _tabs.length && newName.isNotEmpty) {
      _tabs[_selectedTabIndex].title = newName;
    }
  }

  void addChartToCurrentTab(ChartConfig chart) {
    if (_selectedTabIndex < _tabs.length) {
      _tabs[_selectedTabIndex].charts.add(chart);
      _chartSelections[chart.id] = {};
    }
  }

  void deleteChart(int chartIndex) {
    if (_selectedTabIndex < _tabs.length) {
      final charts = _tabs[_selectedTabIndex].charts;
      if (chartIndex >= 0 && chartIndex < charts.length && charts.length > 1) {
        final removedChart = charts.removeAt(chartIndex);
        _chartSelections.remove(removedChart.id);
      }
    }
  }

  void updateChartSelections(
    String chartId,
    Map<String, Set<MultiSelectDialogItem>> newSelections,
  ) {
    _chartSelections[chartId] = newSelections;
  }

  void setSelectedTimeChoice(int choice) {
    _selectedTimeChoice = choice;
  }

  void setSelectedAbsRelData(int choice) {
    _selectedAbsRelData = choice;
  }

  void setSelectedTimeUnit(int unit) {
    _selectedTimeUnit = unit;
  }

  bool canDeleteTab() {
    return _tabs.length > 1;
  }

  bool canDeleteChart(int chartIndex) {
    if (_selectedTabIndex >= _tabs.length) return false;
    final charts = _tabs[_selectedTabIndex].charts;
    return charts.length > 1 && chartIndex >= 0 && chartIndex < charts.length;
  }

  bool isValidTabIndex(int index) {
    return index >= 0 && index < _tabs.length;
  }

  ChartConfig? getChartById(String chartId) {
    for (final tab in _tabs) {
      for (final chart in tab.charts) {
        if (chart.id == chartId) {
          return chart;
        }
      }
    }
    return null;
  }

  int getTabIndexByTitle(String title) {
    return _tabs.indexWhere((tab) => tab.title == title);
  }

  void reset() {
    _tabs.clear();
    _chartSelections.clear();
    _selectedTabIndex = 0;
    _selectedChartIndex = 0;
    _selectedTimeChoice = TimeChoice.timestamp.value;
    _selectedAbsRelData = AbsRelDataChoice.relative.value;
    _selectedTimeUnit = TimeUnitChoice.seconds.value;
  }
}
