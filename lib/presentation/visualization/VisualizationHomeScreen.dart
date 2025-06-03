import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/controller/visualization/VisualizationHomeController.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/EditTabNameDialog.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/LexikonDialog.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/ConnectedDevicesDialog.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/QRCodeDialog.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/SettingsDialog.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/StartAlarmDialog.dart';
import 'package:sensorvisualization/presentation/visualization/dialogs/StopAlarmDialog.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/ChartPage.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/ChartSelectorTabMulti.dart';

class VisualizationHomeScreen extends StatefulWidget {
  const VisualizationHomeScreen({super.key});

  @override
  State<VisualizationHomeScreen> createState() =>
      _VisualizationHomeScreenState();
}

class _VisualizationHomeScreenState extends State<VisualizationHomeScreen> {
  late VisualizationHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VisualizationHomeController(context: context);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Sensor visualization (THW)'),
      actions: [
        _buildSettingsButton(),
        _buildDevicesButton(),
        _buildQRButton(),
        _buildLexikonButton(),
        _buildAlarmButton(),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed:
          () => showDialog(
            context: context,
            builder:
                (BuildContext context) =>
                    SettingsDialog(controller: _controller),
          ),
    );
  }

  Widget _buildDevicesButton() {
    return IconButton(
      icon: const Icon(Icons.smartphone),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const ConnectedDevicesDialog(),
        );
      },
    );
  }

  Widget _buildQRButton() {
    return IconButton(
      icon: const Icon(Icons.qr_code),
      onPressed:
          () => showDialog(
            context: context,
            builder:
                (BuildContext context) => QRCodeDialog(controller: _controller),
          ),
    );
  }

  Widget _buildLexikonButton() {
    return IconButton(
      icon: const Icon(Icons.book),
      tooltip: "Lexikon",
      onPressed: () {
        showDialog(
          context: context,
          builder:
              (context) =>
                  LexikonDialog(entries: _controller.model.lexikonEntries),
        );
      },
    );
  }

  //TODO: Textfeld für Alarm Message einfügen
  Widget _buildAlarmButton() {
    return IconButton(
      icon: Consumer<ConnectionProvider>(
        builder: (context, provider, child) {
          return Icon(
            Icons.warning,
            color: provider.isAlarmActive ? Colors.red : null,
          );
        },
      ),
      onPressed:
          () => _controller.handleAlarmAction(
            () => showDialog(
              context: context,
              builder: (context) => StopAlarmDialog(controller: _controller),
            ),
            () => showDialog(
              context: context,
              builder: (context) => StartAlarmDialog(controller: _controller),
            ),
          ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabSelector(),
        _buildTabActions(),
        _buildChartsContent(),
      ],
    );
  }

  Widget _buildTabSelector() {
    return ChartSelectorTabMulti(
      selectedIndex: _controller.selectedTabIndex,
      tabTitles: _controller.model.tabTitles,
      onTabSelected: (index) => _controller.selectTab(index),
    );
  }

  Widget _buildTabActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Neues Diagramm im aktuellen Tab hinzufügen',
            onPressed: () => _controller.addNewChartToCurrentTab(),
          ),
          IconButton(
            icon: const Icon(Icons.tab),
            tooltip: 'Neuen Tab hinzufügen',
            onPressed: () => _controller.addNewChartTab(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Aktuellen Tab umbenennen',
            onPressed:
                () => showDialog(
                  context: context,
                  builder:
                      (BuildContext context) =>
                          EditTabNameDialog(controller: _controller),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Aktuellen Tab löschen',
            onPressed: () => _controller.deleteCurrentTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsContent() {
    return Expanded(
      child:
          !_controller.model.hasCharts
              ? const Center(child: Text('Keine Diagramme vorhanden'))
              : ListView.builder(
                itemCount: _controller.model.activeCharts.length,
                itemBuilder: (context, index) {
                  final chart = _controller.model.activeCharts[index];
                  return Column(
                    children: [
                      SizedBox(
                        height: 500,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ChartPage.withSelectedValues(
                            chartConfig: chart,
                            selectedValues:
                                _controller.chartSelections[chart.id] ?? {},
                            onSelectedValuesChanged: (newSel) {
                              _controller.updateChartSelections(
                                chart.id,
                                newSel,
                              );
                            },
                          ),
                        ),
                      ),
                      if (_controller.model.activeCharts.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Diagramm löschen',
                          onPressed: () => _controller.deleteChart(index),
                        ),
                    ],
                  );
                },
              ),
    );
  }

  //TODO: Werte aller Dialogs werden auch bei Klicken auf Abbrechen gespeichert

  //TODO: war vorher nicht Tab bei IOS deaktiviert?!
}
