import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/controller/visualization/SensorDataController.dart';
import 'package:sensorvisualization/data/settingsModels/ColorSettings.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/model/visualization/ChartConfigurationModel.dart';
import 'package:sensorvisualization/model/visualization/VisualizationSensorDataModel.dart';

class SensorChartView extends StatefulWidget {
  final ChartConfigurationModel configModel;
  final VisualizationSensorDataModel sensorDataModel;
  final Map<String, Map<MultiSelectDialogItem, Color>> selectedColors;
  final TextEditingController timeController;

  SensorChartView({
    Key? key,
    required this.configModel,
    required this.sensorDataModel,
    required this.selectedColors,
    required this.timeController,
  }) : super(
         key: ValueKey([
           sensorDataModel.warningRanges.hashCode,
           configModel.baselineX.hashCode,
         ]),
       );

  @override
  State<SensorChartView> createState() => _SensorChartViewState();
}

class _SensorChartViewState extends State<SensorChartView> {
  late SensorDataController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SensorDataController(
      dataModel: widget.sensorDataModel,
      configModel: widget.configModel,
      settingsProvider: context.read<SettingsProvider>(),
      timeController: widget.timeController,
      onTitlesDataText: onTitlesDataTest,
      selectedColors: widget.selectedColors,
    );
  }

  Widget onTitlesDataTest(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xff68737d),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      _controller.buildChartData(context),
      duration: Duration.zero,
    );
  }
}
