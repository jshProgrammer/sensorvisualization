import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/settingsModels/ColorSettings.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/data/services/SensorDataSimulator.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/model/visualization/ChartConfigurationModel.dart';
import 'package:sensorvisualization/model/visualization/VisualizationSensorDataModel.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/WarningLevelsSelection.dart';

class SensorDataController {
  final VisualizationSensorDataModel _dataModel;
  final ChartConfigurationModel _configModel;
  final SettingsProvider _settingsProvider;
  final TextEditingController _timeController;
  final Map<String, Map<MultiSelectDialogItem, Color>> selectedColors;

  static final DateFormat _formatterNote = DateFormat('yyyy-MM-dd HH:mm:ss');

  List<LineTooltipItem> Function(
    List<LineBarSpot> touchedSpots,
    Map<DateTime, String> notes,
  )?
  onBuildToolItems;

  Widget Function(String) onTitlesDataText;

  SensorDataController({
    required VisualizationSensorDataModel dataModel,
    required ChartConfigurationModel configModel,
    required SettingsProvider settingsProvider,
    required TextEditingController timeController,
    required this.onTitlesDataText,
    required this.selectedColors,
  }) : _dataModel = dataModel,
       _configModel = configModel,
       _settingsProvider = settingsProvider,
       _timeController = timeController;

  List<FlSpot> getFilteredDataPoints(
    String ipAddress,
    SensorType sensorType,
    SensorOrientation orientation,
  ) {
    final bounds = _calculateXAxisBounds();
    final allPoints = _dataModel.getDataPointsForSensor(
      ipAddress,
      sensorType,
      orientation,
    );

    return allPoints
        .where((point) => point.x >= bounds.minX && point.x <= bounds.maxX)
        .toList();
  }

  ({double minX, double maxX}) _calculateXAxisBounds() {
    final currentMaxX = _getMaxX();

    if (_configModel.autoFollowLatestData) {
      return (
        minX: currentMaxX - _settingsProvider.scrollingSeconds,
        maxX: currentMaxX,
      );
    } else {
      return (
        minX: _configModel.baselineX - _settingsProvider.scrollingSeconds,
        maxX: _configModel.baselineX,
      );
    }
  }

  double _getMaxX() {
    return _getExtremeValue((spot) => spot.x, (a, b) => a > b, 10);
  }

  double _getMinY() {
    final bounds = _calculateXAxisBounds();
    return _getExtremeValue(
      (spot) => spot.y,
      (a, b) => a < b,
      0.0,
      filter: (spot) => spot.x >= bounds.minX && spot.x <= bounds.maxX,
    );
  }

  double _getMaxY() {
    final bounds = _calculateXAxisBounds();
    return _getExtremeValue(
      (spot) => spot.y,
      (a, b) => a > b,
      0.0,
      filter: (spot) => spot.x >= bounds.minX && spot.x <= bounds.maxX,
    );
  }

  double _getExtremeValue(
    double Function(FlSpot) selector,
    bool Function(double, double) compare,
    double fallbackValue, {
    bool Function(FlSpot)? filter,
  }) {
    final values = _dataModel.activeSelections
        .expand(
          (entry) => entry.value.expand((item) {
            final deviceIp =
                entry.key == SensorType.simulatedData.displayName
                    ? SensorDataSimulator.simulatedIPAddress
                    : entry.key;

            return _dataModel.getDataPointsForSensor(
              deviceIp,
              item.sensorName,
              item.attribute!,
            );
          }),
        )
        .where((spot) => filter == null || filter(spot))
        .map(selector);

    return values.isEmpty
        ? fallbackValue
        : values.reduce((a, b) => compare(a, b) ? a : b);
  }

  LineChartData buildChartData(BuildContext context) {
    final bounds = _calculateXAxisBounds();

    return LineChartData(
      minX: bounds.minX,
      maxX: bounds.maxX,
      minY: _getMinY(),
      maxY: _getMaxY(),
      gridData: _buildGridData(),
      titlesData: _buildTitlesData(),
      borderData: _buildBorderData(),
      lineBarsData: _buildLineBarsData(),
      lineTouchData: _buildTouchData(context),
      extraLinesData: _buildExtraLinesData(),
      rangeAnnotations: _buildRangeAnnotations(),
    );
  }

  //TODO: evtl Logik für Grid Interval einfügen
  FlGridData _buildGridData() {
    return FlGridData(
      show: _settingsProvider.showGrid,
      horizontalInterval: 0.5,
      verticalInterval: 0.5,
      getDrawingHorizontalLine:
          (value) => FlLine(
            color: ColorSettings.lineColor,
            strokeWidth: value.abs() < 0.1 ? 2 : 1,
          ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _settingsProvider.scrollingSeconds / 5,
          getTitlesWidget: (value, meta) {
            if (_settingsProvider.selectedTimeChoice ==
                TimeChoice.timestamp.value) {
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                value.toInt() * 1000,
              );

              final formatter = DateFormat('HH:mm:ss');

              String formattedTime = formatter.format(dateTime);

              return onTitlesDataText(formattedTime);
            } else if (_settingsProvider.selectedTimeChoice ==
                TimeChoice.natoFormat.value) {
              return onTitlesDataText(
                SensorDataTransformation.transformDateTimeToNatoFormat(
                  DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000),
                ),
              );
            }

            return onTitlesDataText(
              SensorDataTransformation.transformDateTimeToSecondsSinceStart(
                DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000),
              ).toStringAsFixed(1),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: _configModel.borderColor, width: 2),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    final lineBars = <LineChartBarData>[];
    int index = 0;

    for (final device in _dataModel.activeSelections) {
      for (final sensor in device.value) {
        final deviceIp =
            device.key == SensorType.simulatedData.displayName
                ? SensorDataSimulator.simulatedIPAddress
                : device.key;

        lineBars.add(_buildLineChartBarData(deviceIp, sensor, index));
        index++;
      }
    }

    return lineBars;
  }

  LineChartBarData _buildLineChartBarData(
    String deviceIp,
    MultiSelectDialogItem sensor,
    int index,
  ) {
    return LineChartBarData(
      spots: getFilteredDataPoints(
        deviceIp,
        sensor.sensorName,
        sensor.attribute!,
      ),
      isCurved: false,
      color:
          selectedColors[deviceIp]?[sensor] ??
          getSensorColor(sensor.attribute!.displayName),
      barWidth: 4,
      dotData: FlDotData(show: false),
    );
  }

  LineTouchData _buildTouchData(BuildContext context) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            final spotMillis = (spot.x * 1000).toInt();

            String? noteText;
            for (final entry in _dataModel.notes.entries) {
              final noteMillis = entry.key.millisecondsSinceEpoch;
              if ((noteMillis - spotMillis).abs() <= 200) {
                noteText =
                    "${_formatterNote.format(entry.key)}: ${entry.value}";
                break;
              }
            }

            return LineTooltipItem(
              noteText ?? "Keine Notiz",

              TextStyle(
                color:
                    spot.y >= 2.5
                        ? ColorSettings.pointHoverCritical
                        : ColorSettings.pointHoverDefault,
              ),
            );
          }).toList();
        },
      ),
      touchCallback:
          (event, response) => _handleTouch(event, response, context),
    );
  }

  void _handleTouch(
    FlTouchEvent event,
    LineTouchResponse? response,
    BuildContext context,
  ) {
    if (event is FlTapUpEvent && response?.lineBarSpots?.isNotEmpty == true) {
      final touchedSpot = response!.lineBarSpots!.first;
      final touchedTime = DateTime.fromMillisecondsSinceEpoch(
        touchedSpot.x.toInt() * 1000,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _timeController.text = _formatterNote.format(touchedTime);
        }
      });
    }
  }

  ExtraLinesData _buildExtraLinesData() {
    return ExtraLinesData(
      verticalLines:
          _dataModel.notes.entries.map((entry) {
            return VerticalLine(
              x: entry.key.millisecondsSinceEpoch.toDouble(),
              color: ColorSettings.noteLineColor,
              strokeWidth: 2,
              dashArray: [5, 10],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                direction: LabelDirection.vertical,
                labelResolver: (_) => entry.value,
              ),
            );
          }).toList(),
    );
  }

  RangeAnnotations _buildRangeAnnotations() {
    final horizontalAnnotations = <HorizontalRangeAnnotation>[];

    _dataModel.warningRanges.forEach((level, ranges) {
      final color = _getWarningColor(level);
      horizontalAnnotations.addAll(
        ranges.map(
          (range) => HorizontalRangeAnnotation(
            y1: range.lower,
            y2: range.upper,
            color: color.withOpacity(0.3),
          ),
        ),
      );
    });

    return RangeAnnotations(horizontalRangeAnnotations: horizontalAnnotations);
  }

  Color _getWarningColor(String level) {
    switch (level) {
      case 'green':
        return ColorSettings.warningLevelGreen;
      case 'yellow':
        return ColorSettings.warningLevelYellow;
      case 'red':
        return ColorSettings.warningLevelRed;
      default:
        return const Color.fromARGB(0, 0, 0, 0);
    }
  }

  static Color getSensorColor(String attribute) {
    final colorMap = {
      SensorOrientation.x.displayName: ColorSettings.sensorXAxisColor,
      SensorOrientation.y.displayName: ColorSettings.sensorYAxisColor,
      SensorOrientation.z.displayName: ColorSettings.sensorZAxisColor,
    };
    return colorMap[attribute] ?? Colors.grey;
  }

  void updateWarningRanges(String level, List<WarningRange> ranges) {
    _dataModel.updateWarningRanges(level, ranges);
  }

  void addNote(DateTime timestamp, String note) {
    _dataModel.addNote(timestamp, note);
  }

  void toggleSensorSelection(String device, MultiSelectDialogItem sensor) {
    _dataModel.toggleSensor(device, sensor);
  }
}
