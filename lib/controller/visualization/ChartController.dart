import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/controller/visualization/SensorDataController.dart';
import 'package:sensorvisualization/data/services/DangerDetector.dart';
import 'package:sensorvisualization/data/services/DangerNavigationController.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';
import 'package:sensorvisualization/data/services/SensorDataSimulator.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/data/settingsModels/ChartConfig.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:sensorvisualization/model/visualization/ChartModel.dart';
import 'package:tuple/tuple.dart';

class ChartController extends ChangeNotifier {
  final ChartModel _chartModel;
  final BuildContext context;

  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  bool isEditingTitle = false;

  late TextEditingController titleController;
  final TextEditingController _noteController = TextEditingController();
  final TransformationController transformationController =
      TransformationController();

  final FocusNode focusNode = FocusNode();

  final firebasesync = Firebasesync();

  late SensorDataSimulator simulator;
  late StreamSubscription _dataSubscription;

  DangerNavigationController dangerNavigationController =
      DangerNavigationController();

  final textController = TextEditingController();
  late final TextEditingController timeController;

  late DangerDetector _dangerDetector;

  late Databaseoperations _databaseOperations;

  int localIndex = 0;

  ChartConfig chartConfig;
  Map<String, Set<MultiSelectDialogItem>>? selectedValues;
  final void Function(Map<String, Set<MultiSelectDialogItem>>)?
  onSelectedValuesChanged;
  final void Function()? onMeasurementStoppedReceived;

  Map<String, Map<MultiSelectDialogItem, Color>> get selectedColors =>
      _chartModel.selectedColors;

  set selectedColors(Map<String, Map<MultiSelectDialogItem, Color>> value) {
    _chartModel.selectedColors = value;
    notifyListeners();
  }

  double get baselineX => _chartModel.baselineX;
  set baselineX(double value) {
    _chartModel.baselineX = value;
    notifyListeners();
  }

  bool get isPanEnabled => _chartModel.isPanEnabled;

  bool get autoFollowLatestData => _chartModel.autoFollowLatestData;
  set autoFollowLatestData(bool value) {
    _chartModel.autoFollowLatestData = value;
    notifyListeners();
  }

  ChartController({
    required this.chartConfig,
    required this.selectedValues,
    required this.onSelectedValuesChanged,
    required this.context,
    required this.onMeasurementStoppedReceived,
  }) : _chartModel = ChartModel.withSelectedValues(
         chartConfig: chartConfig,
         selectedValues:
             onSelectedValuesChanged != null
                 ? Map<String, Set<MultiSelectDialogItem>>.from(selectedValues!)
                 : {},
         onSelectedValuesChanged: onSelectedValuesChanged,
       ) {
    _initControllers();

    _initProvidersAndDataSubscriptions();

    //TODO: evtl in Model?!
    if (dangerNavigationController.all.isEmpty) {
      _chartModel.allDangerTimes = [_chartModel.defaultTime];
    } else {
      _chartModel.allDangerTimes = dangerNavigationController.all;
    }
    localIndex = dangerNavigationController.all.indexOf(
      dangerNavigationController.current ?? _chartModel.defaultTime,
    );
    if (localIndex < 0) localIndex = 0;

    _startSensorDataSimulator();
  }

  void _initProvidersAndDataSubscriptions() {
    _databaseOperations = Provider.of<Databaseoperations>(
      context,
      listen: false,
    );

    _dataSubscription = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    ).dataStream.listen(_handleSensorData);

    Provider.of<ConnectionProvider>(
      context,
      listen: false,
    ).measurementStopped.listen((deviceName) {
      if (onMeasurementStoppedReceived != null) {
        onMeasurementStoppedReceived!();
      }
    });
  }

  void _initControllers() {
    focusNode.addListener(() {
      if (!focusNode.hasFocus && isEditingTitle) {
        titleController.text = chartConfig.title;
        isEditingTitle = false;
        notifyListeners();
      }
    });
    titleController = TextEditingController(text: chartConfig.title);

    _chartModel.defaultTime =
        dangerNavigationController.current ??
        _chartModel.truncateToSeconds(DateTime.now());
    timeController = TextEditingController(
      text: formatter.format(_chartModel.defaultTime),
    );

    transformationController.addListener(_handleTransformationChange);
  }

  void _handleTransformationChange() {
    final scale = transformationController.value.getMaxScaleOnAxis();

    if (scale > 1.0 && !_chartModel.isPanEnabled) {
      _chartModel.isPanEnabled = true;
    } else if (scale <= 1.0 && _chartModel.isPanEnabled) {
      _chartModel.isPanEnabled = false;
    }
    notifyListeners();
  }

  void _startSensorDataSimulator() {
    simulator = SensorDataSimulator(
      onDataGenerated: (data) {
        final double timestamp =
            data["timestamp"] != null
                ? DateTime.parse(
                  data["timestamp"].toString(),
                ).difference(_chartModel.startTime).inSeconds.toDouble()
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

        chartConfig.addDataPoint(
          SensorDataSimulator.simulatedIPAddress,
          SensorType.simulatedData,
          SensorOrientation.x,
          FlSpot(timestamp, x),
        );
        chartConfig.addDataPoint(
          SensorDataSimulator.simulatedIPAddress,
          SensorType.simulatedData,
          SensorOrientation.y,
          FlSpot(timestamp, y),
        );
        chartConfig.addDataPoint(
          SensorDataSimulator.simulatedIPAddress,
          SensorType.simulatedData,
          SensorOrientation.z,
          FlSpot(timestamp, z),
        );

        final dateTime = _chartModel.startTime.add(
          Duration(milliseconds: (timestamp * 1000).toInt()),
        );

        List<FlSpot> selectedPoints = [];
        List<DateTime> selectedTimestamps = [];

        //TODO: ! ergänzt!!!
        for (final device in selectedValues!.keys) {
          //TODO: ! ergänzt!!!
          for (final sensorItem in selectedValues![device]!) {
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
          warningLevels: chartConfig.ranges,
        );

        final formattedNewDangers =
            newDangers.map((dt) => _chartModel.truncateToSeconds(dt)).toList();

        for (final t in formattedNewDangers) {
          if (!_chartModel.allDangerTimestamps.contains(t)) {
            _chartModel.allDangerTimestamps.add(t);
          }
        }

        _chartModel.allDangerTimestamps.sort();

        _dangerDetector = DangerDetector(_chartModel.allDangerTimestamps);

        if (formattedNewDangers.isNotEmpty) {
          dangerNavigationController.setCurrent(formattedNewDangers.first);
        }

        if (_chartModel.autoFollowLatestData) {
          _chartModel.baselineX = timestamp;
        }
      },
    );

    simulator.init();
    notifyListeners();
  }

  //TODO: hier evtl noch Refactoring
  void _handleSensorData(Map<String, dynamic> data) {
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

        chartConfig.addDataPoint(
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

        chartConfig.addDataPoint(
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
      chartConfig.addDataPoint(
        jsonData['ip'],
        jsonData['sensor'],
        SensorOrientation.x,
        FlSpot(timestampAsDouble, jsonData['x'] as double),
      );
    }
    if (jsonData.containsKey('y') && jsonData['y'] != null) {
      chartConfig.addDataPoint(
        jsonData['ip'],
        jsonData['sensor'],
        SensorOrientation.y,
        FlSpot(timestampAsDouble, jsonData['y'] as double),
      );
    }
    if (jsonData.containsKey('z') && jsonData['z'] != null) {
      chartConfig.addDataPoint(
        jsonData['ip'],
        jsonData['sensor'],
        SensorOrientation.z,
        FlSpot(timestampAsDouble, jsonData['z'] as double),
      );
    }
    if (jsonData.containsKey('pressure') && jsonData['pressure'] != null) {
      chartConfig.addDataPoint(
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

    //TODO: hier ! ergänzt!!!
    for (final device in _chartModel.selectedValues!.keys) {
      //TODO: hier ! ergänzt!!!
      for (final sensorItem in selectedValues![device]!) {
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
      warningLevels: chartConfig.ranges,
    );

    final formattedNewDangers =
        newDangers.map((dt) => _chartModel.truncateToSeconds(dt)).toList();

    for (final t in formattedNewDangers) {
      if (!_chartModel.allDangerTimestamps.contains(t)) {
        _chartModel.allDangerTimestamps.add(t);
      }
    }

    _chartModel.allDangerTimestamps.sort();

    _dangerDetector = DangerDetector(_chartModel.allDangerTimestamps);

    if (formattedNewDangers.isNotEmpty) {
      dangerNavigationController.setCurrent(formattedNewDangers.first);
    }

    if (_chartModel.autoFollowLatestData) {
      _chartModel.baselineX = timestamp;
    }

    notifyListeners();
  }

  void resetZoom() {
    transformationController.value = Matrix4.identity();
    notifyListeners();
  }

  Matrix4 getCurrentZoom() {
    return transformationController.value.clone();
  }

  void setCurrentZoom(Matrix4 zoom) {
    transformationController.value = zoom;
  }

  void updateTimeField() {
    timeController.text =
        _chartModel.allDangerTimestamps[localIndex].toString();
  }

  Future<String> exportSensorDataCSV() {
    return _databaseOperations.exportSensorDataCSV(context);
  }

  Future<void> insertNoteData(DateTime parsedTime) async {
    await _databaseOperations.insertNoteData(
      NoteCompanion(date: Value(parsedTime), note: Value(textController.text)),
    );
  }

  List<Map<String, dynamic>> getLegendData() {
    List<Map<String, dynamic>> legendData = [];
    int sensorIndex = 0;

    var connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );

    for (String device in selectedValues!.keys) {
      for (MultiSelectDialogItem sensor in selectedValues![device]!) {
        legendData.add({
          'device': connectionProvider.connectedDevices[device] ?? "Simulator",
          'sensorName': sensor.sensorName.displayName,
          'attribute': sensor.attribute!.displayName,
          'color':
              _chartModel.selectedColors[device]?[sensor] ??
              SensorDataController.getSensorColor(
                sensor.attribute!.displayName,
              ),
        });

        sensorIndex++;
      }
    }

    return legendData;
  }

  Future<List<Map<String, dynamic>>> getAvailableFirebaseTables() async {
    return await firebasesync.getAvailableTables();
  }

  Future<String> exportTableByNameAndDate(
    String tableName,
    DateTime time,
  ) async {
    return await firebasesync.exportTableByNameAndDate(tableName, time);
  }

  double get maxX => chartConfig.dataPoints.values
      .expand((map) => map.values)
      .expand((list) => list)
      .fold(
        0.0,
        (prev, spot) => spot.x > prev ? spot.x : prev,
      ); // calculated in milliseconds * 1000 since epoch

  double get maxY => chartConfig.dataPoints.values
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

  DateTime truncateToSeconds(DateTime dateTime) {
    return _chartModel.truncateToSeconds(dateTime);
  }

  @override
  void dispose() {
    transformationController.dispose();
    _noteController.dispose();
    titleController.dispose();
    focusNode.dispose();
    _dataSubscription.cancel();
    simulator.stopSimulation();
    super.dispose();
  }
}
