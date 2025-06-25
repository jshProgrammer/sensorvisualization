import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/settingsModels/ChartConfig.dart';
import 'package:sensorvisualization/data/settingsModels/ChartTab.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:sensorvisualization/model/visualization/VisualizationHomeModel.dart';

class VisualizationHomeController extends ChangeNotifier {
  final VisualizationHomeModel _model;
  final BuildContext context;

  final TextEditingController secondsController = TextEditingController();

  VisualizationHomeController({required this.context})
    : _model = VisualizationHomeModel() {
    _initializeController();
  }

  VisualizationHomeModel get model => _model;
  List<ChartTab> get tabs => _model.tabs;
  Map<String, Map<String, Set<MultiSelectDialogItem>>> get chartSelections =>
      _model.chartSelections;
  int get selectedTabIndex => _model.selectedTabIndex;
  int get selectedChartIndex => _model.selectedChartIndex;
  Firebasesync get firebaseSync => _model.firebaseSync;

  int get selectedTimeChoice => _model.selectedTimeChoice;
  int get selectedAbsRelData => _model.selectedAbsRelData;
  int get selectedTimeUnit => _model.selectedTimeUnit;
  bool get selectedGridChoice => _model.selectedGridChoice;


  void _initializeController() {
    addNewChartTab();
    GlobalStartTime().initializeStartTime();
  }

  void addNewChartToCurrentTab() {
    if (_model.selectedTabIndex >= _model.tabs.length) return;

    final tabCharts = _model.tabs[_model.selectedTabIndex].charts;
    final newIndex = tabCharts.length;
    final newChart = ChartConfig(
      id: 'mchart_${_model.selectedTabIndex}_$newIndex',
      title: 'Diagramm ${newIndex + 1}',
      dataPoints: {},
      color: Colors.primaries[newIndex % Colors.primaries.length],
    );

    _model.addChartToCurrentTab(newChart);
    notifyListeners();
  }

  void addNewChartTab() {
    final newChart = ChartConfig(
      id: 'mchart_${_model.tabs.length}_0',
      title: 'Diagramm 1',
      dataPoints: {},
      color: Colors.primaries[0],
    );
    final newTab = ChartTab(
      title: 'Tab ${_model.tabs.length + 1}',
      charts: [newChart],
    );

    _model.addTab(newTab);
    notifyListeners();
  }

  void deleteCurrentTab() {
    if (_model.tabs.length <= 1) {
      _showSnackBar('Mindestens ein Tab muss bestehen bleiben.');
      return;
    }

    _model.deleteCurrentTab();
    notifyListeners();
  }

  void selectTab(int index) {
    _model.setSelectedTabIndex(index);
    notifyListeners();
  }

  void deleteChart(int index) {
    if (_model.tabs[_model.selectedTabIndex].charts.length > 1) {
      _model.deleteChart(index);
      notifyListeners();
    } else {
      _showSnackBar('Mindestens ein Diagramm muss vorhanden sein.');
    }
  }

  void updateChartSelections(
    String chartId,
    Map<String, Set<MultiSelectDialogItem>> newSelections,
  ) {
    _model.updateChartSelections(chartId, newSelections);
    notifyListeners();
  }

  void updateTimeChoice(int choice) {
    _model.setSelectedTimeChoice(choice);
  }

  void updateAbsRelData(int choice) {
    _model.setSelectedAbsRelData(choice);
  }

  void updateTimeUnit(int unit) {
    _model.setSelectedTimeUnit(unit);
  }

  void updateFirebaseSyncStatus(bool isSyncing) {
    _model.firebaseSync.isSyncing = isSyncing;
  }

  void updateSyncInterval(int interval) {
    _model.firebaseSync.syncInterval = interval;
  }

  void toggleGridChoice() {
    _model.selectedGridChoice = !_model.selectedGridChoice;
  }

  void renameCurrentTab(String newName) {
    _model.renameCurrentTab(newName);
    notifyListeners();
  }

  Future<String?> getWifiIP() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

  void handleAlarmAction(
    Function() onShowStopAlarmDialog,
    final Function() onShowStartAlarmDialog,
  ) {
    final provider = Provider.of<ConnectionProvider>(context, listen: false);

    if (provider.isAlarmActive) {
      onShowStopAlarmDialog();
    } else {
      onShowStartAlarmDialog();
    }
  }

  void sendAlarm(String message) {
    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    provider.sendAlarmToAllClients(message);
  }

  void stopAlarm() {
    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    provider.stopAlarm();
  }

  void saveSettings() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (secondsController.text.isNotEmpty) {
      final value =
          int.tryParse(secondsController.text) ??
          SettingsProvider.DEFAULT_SCROLLING_SECONDS;
      final unitChoice = TimeUnitChoice.fromValue(_model.selectedTimeUnit);
      final seconds = _calculateSeconds(value, unitChoice);
      settingsProvider.setScrollingSeconds(seconds);
    }
    settingsProvider.setShowGrid(_model.selectedGridChoice);
    settingsProvider.setTimeChoice(_model.selectedTimeChoice);
    settingsProvider.setDataMode(_model.selectedAbsRelData);
  }

  int _calculateSeconds(int value, TimeUnitChoice unitChoice) {
    switch (unitChoice) {
      case TimeUnitChoice.seconds:
        return value;
      case TimeUnitChoice.minutes:
        return value * 60;
      case TimeUnitChoice.hours:
        return value * 3600;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void dispose() {
    secondsController.dispose();
  }
}
