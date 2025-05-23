import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/data/models/ColorSettings.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/models/SensorOrientation.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/SensorDataSimulator.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/services/SensorServer.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/presentation/widgets/WarningLevelsSelection.dart';
import 'package:tuple/tuple.dart';

class Sensordata {
  late Map<String, Set<MultiSelectDialogItem>> selectedLines;
  late ChartConfig chartConfig;

  double baselineX;
  bool autoFollowLatestData;
  final SettingsProvider settingsProvider;
  final ConnectionProvider connectionProvider;

  Map<String, List<WarningRange>> ranges = {
    'green': [],
    'yellow': [],
    'red': [],
  };

  Sensordata({
    required this.selectedLines,
    required this.chartConfig,
    required this.baselineX,
    required this.autoFollowLatestData,
    Map<String, List<WarningRange>>? warningRanges,
    required this.settingsProvider,
    required this.connectionProvider,
  }) {
    if (warningRanges != null) {
      ranges = warningRanges;
    }
  }

  List<FlSpot> getFilteredDataPoints(
    String ipAddress,
    SensorType sensorName,
    SensorOrientation attribute, {
    //TODO: to be implemented
    int baselineY = 0,
  }) {
    final double xMin;
    final double xMax;
    final double currentMaxX = _getMaxX();

    if (autoFollowLatestData) {
      xMin = currentMaxX - settingsProvider.scrollingSeconds;
      xMax = currentMaxX;
    } else {
      xMin = baselineX - settingsProvider.scrollingSeconds;
      xMax = baselineX;
    }

    List<FlSpot> filteredData = [];

    if (chartConfig.dataPoints.containsKey(ipAddress)) {
      final key = Tuple2(sensorName, attribute);
      final allPoints = chartConfig.dataPoints[ipAddress]![key]!;

      filteredData =
          allPoints //.values
              //.expand((points) => points)
              .where((point) => point.x >= xMin && point.x <= xMax)
              .toList();
    }

    return filteredData;
  }

  double _getExtremeValue(
    double Function(FlSpot spot) selector,
    bool Function(double a, double b) compare,
    double fallbackValue, {
    bool Function(FlSpot spot)? filter,
  }) {
    final Iterable<double> values = selectedLines.entries
        .where((entry) => entry.key.isNotEmpty)
        .expand(
          (entry) => entry.value.expand((item) {
            final deviceIp =
                entry.key == SensorType.simulatedData.displayName
                    ? SensorDataSimulator.simualtedIpAddress
                    : entry.key;

            return chartConfig.dataPoints[deviceIp]?[Tuple2(
                  item.sensorName,
                  item.attribute!,
                )] ??
                [];
          }),
        )
        .cast<FlSpot>()
        .where((spot) => filter == null || filter(spot))
        .map(selector);

    return values.isEmpty
        ? fallbackValue
        : values.reduce((a, b) => compare(a, b) ? a : b);
  }

  double _getMaxX() {
    return _getExtremeValue((spot) => spot.x, (a, b) => a > b, 10);
  }

  double _getMinY() {
    final double minX =
        autoFollowLatestData
            ? _getMaxX() - settingsProvider.scrollingSeconds
            : baselineX - settingsProvider.scrollingSeconds;
    final double maxX = autoFollowLatestData ? _getMaxX() : baselineX;

    return _getExtremeValue(
      (spot) => spot.y,
      (a, b) => a < b,
      0.0,
      filter: (spot) => spot.x >= minX && spot.x <= maxX,
    );
  }

  double _getMaxY() {
    final double minX =
        autoFollowLatestData
            ? _getMaxX() - settingsProvider.scrollingSeconds
            : baselineX - settingsProvider.scrollingSeconds;
    final double maxX = autoFollowLatestData ? _getMaxX() : baselineX;

    return _getExtremeValue(
      (spot) => spot.y,
      (a, b) => a > b,
      0.0,
      filter: (spot) => spot.x >= minX && spot.x <= maxX,
    );
  }

  LineChart getLineChart(double baselineX) {
    return LineChart(
      duration: Duration.zero,
      LineChartData(
        minX:
            autoFollowLatestData
                ? _getMaxX() - settingsProvider.scrollingSeconds
                : baselineX - settingsProvider.scrollingSeconds,
        maxX: autoFollowLatestData ? _getMaxX() : baselineX,
        minY: _getMinY(),
        maxY: _getMaxY(),

        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.5,
          verticalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color:
                  value.abs() < 0.1
                      ? ColorSettings.lineColor
                      : ColorSettings.lineColor,
              strokeWidth: value.abs() < 0.1 ? 2 : 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: settingsProvider.scrollingSeconds / 5,
              getTitlesWidget: (value, meta) {
                if (settingsProvider.selectedTimeChoice ==
                    TimeChoice.timestamp.value) {
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt() * 1000,
                  );

                  final formatter = DateFormat('HH:mm:ss');
                  String formattedTime = formatter.format(dateTime);

                  return Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                } else if (settingsProvider.selectedTimeChoice ==
                    TimeChoice.natoFormat.value) {
                  return Text(
                    SensorDataTransformation.transformDateTimeToNatoFormat(
                      DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000),
                    ),
                    style: const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                }

                return Text(
                  SensorDataTransformation.transformDateTimeToSecondsSinceStart(
                    DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000),
                  ).toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xff68737d),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: chartConfig.color, width: 2),
        ),
        lineBarsData: _getLineBarsData(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                return LineTooltipItem(
                  chartConfig.notes[index] ?? "Keine Notiz",
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
        ),
        extraLinesData: ExtraLinesData(verticalLines: _getNotesVerticalLines()),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            if (ranges['green'] != null && ranges['green']!.isNotEmpty)
              ...ranges['green']!.map(
                (range) => HorizontalRangeAnnotation(
                  y1: range.lower,
                  y2: range.upper,
                  color: Colors.green.withOpacity(0.3),
                ),
              ),

            if (ranges['yellow'] != null && ranges['yellow']!.isNotEmpty)
              ...ranges['yellow']!.map(
                (range) => HorizontalRangeAnnotation(
                  y1: range.lower,
                  y2: range.upper,
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),

            if (ranges['red'] != null && ranges['red']!.isNotEmpty)
              ...ranges['red']!.map(
                (range) => HorizontalRangeAnnotation(
                  y1: range.lower,
                  y2: range.upper,
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData() {
    List<LineChartBarData> toReturn = [];
    int index = 0;

    for (String device in selectedLines.keys) {
      if (selectedLines[device] == null) {
        continue;
      }
      for (MultiSelectDialogItem sensor in selectedLines[device]!) {
        toReturn.add(
          _getCorrespondingLineChartBarData(
            device == SensorType.simulatedData.displayName
                ? SensorDataSimulator.simualtedIpAddress
                : device,
            sensor,
            index,
          ),
        );
        index++;
      }
    }

    return toReturn;
  }

  List<VerticalLine> _getNotesVerticalLines() {
    List<VerticalLine> toReturn = [];

    chartConfig.notes.forEach((noteTime, noteString) {
      toReturn.add(
        VerticalLine(
          x: noteTime.millisecondsSinceEpoch.toDouble(),
          color: ColorSettings.noteLineColor,
          strokeWidth: 2,
          dashArray: [5, 10],
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(left: 5, bottom: 5),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            direction: LabelDirection.vertical,
            labelResolver: (line) => noteString,
          ),
        ),
      );
    });

    return toReturn;
  }

  static Color getSensorColor(String attribute) {
    final colorMap = {
      SensorOrientation.x.displayName: ColorSettings.sensorXAxisColor,
      SensorOrientation.y.displayName: ColorSettings.sensorYAxisColor,
      SensorOrientation.z.displayName: ColorSettings.sensorZAxisColor,
    };

    return colorMap[attribute] ?? Colors.grey;
  }

  LineChartBarData _getCorrespondingLineChartBarData(
    String deviceIp,
    MultiSelectDialogItem sensor,
    int sensorIndex,
  ) {
    List<List<int>?> dashPatterns = [
      null, // solid
      [10, 5], // dashed
      [2, 4], // dotted
      [15, 5, 5, 5], // dash-dot
      [8, 3, 2, 3], // short-dash-dot
      [20, 5, 5, 5, 5, 5], // complex pattern
    ];

    final dashPattern = dashPatterns[sensorIndex % dashPatterns.length];

    return LineChartBarData(
      spots: getFilteredDataPoints(
        deviceIp,
        sensor.sensorName,
        sensor.attribute!,
      ),
      isCurved: false,
      color: getSensorColor(sensor.attribute!.displayName),
      barWidth: 4,
      isStrokeCapRound: false,
      dashArray: dashPattern,
      dotData: FlDotData(show: false),
    );
  }
}
