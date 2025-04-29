import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/data/models/ColorSettings.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/presentation/widgets/WarningLevelsSelection.dart';

class Sensordata {
  late Map<String, Set<MultiSelectDialogItem>> selectedLines;
  late ChartConfig chartConfig;
  int secondsToDisplay = 10;
  double baselineX;
  bool autoFollowLatestData;

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
  }) {
    if (warningRanges != null) {
      ranges = warningRanges;
    }
  }

  List<FlSpot> getFilteredDataPoints(String sensorName, {int baselineY = 0}) {
    final double xMin;
    final double xMax;

    if (autoFollowLatestData) {
      xMin = _getMaxX() - secondsToDisplay;
      xMax = _getMaxX();
    } else {
      xMin = baselineX - secondsToDisplay;
      xMax = baselineX + secondsToDisplay;
    }

    List<FlSpot> filteredData = [];

    chartConfig.dataPoints.forEach((key, points) {
      if (key == sensorName) {
        filteredData =
            points.where((point) {
              return point.x >= xMin && point.x <= xMax;
            }).toList();
      }
    });

    return filteredData;
  }

  double _getExtremeValue(
    double Function(FlSpot spot) selector,
    bool Function(double a, double b) compare,
    double fallbackValue,
  ) {
    final Iterable<double> values = selectedLines.values
        .expand(
          (set) => set.expand(
            (item) =>
                chartConfig.dataPoints[item.sensorName + item.attribute!] ?? [],
          ),
        )
        .cast<FlSpot>()
        .map(selector);

    return values.isEmpty
        ? fallbackValue
        : values.reduce((a, b) => compare(a, b) ? a : b);
  }

  double _getMaxX() {
    return _getExtremeValue((spot) => spot.x, (a, b) => a > b, 10);
  }

  double _getMinY() {
    return _getExtremeValue((spot) => spot.y, (a, b) => a < b, 10);
  }

  double _getMaxY() {
    return _getExtremeValue((spot) => spot.y, (a, b) => a > b, 10);
  }

  LineChart getLineChart(double baselineX, double baselineY) {
    return LineChart(
      LineChartData(
        minX:
            autoFollowLatestData
                ? _getMaxX() < secondsToDisplay
                    ? 0
                    : _getMaxX() - secondsToDisplay
                : baselineX - secondsToDisplay,
        maxX:
            autoFollowLatestData
                ? _getMaxX() < secondsToDisplay
                    ? secondsToDisplay.toDouble()
                    : _getMaxX()
                : baselineX,
        minY: _getMinY(),
        maxY: (_getMaxY() - _getMinY()),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.5,
          verticalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color:
                  (value - baselineY).abs() < 0.1
                      ? ColorSettings.lineColor
                      : ColorSettings.lineColor,
              strokeWidth: (value - baselineY).abs() < 0.1 ? 2 : 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                if (value == 2.5) {
                  return Text(
                    'Grenze',
                    style: TextStyle(
                      color: ColorSettings.borderColor,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
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
        toReturn.add(_getCorrespondingLineChartBarData(sensor, index));
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

  Color _getSensorColor(String attribute) {
    final colorMap = {
      SensorOrientation.x.displayName: ColorSettings.sensorXAxisColor,
      SensorOrientation.y.displayName: ColorSettings.sensorYAxisColor,
      SensorOrientation.z.displayName: ColorSettings.sensorZAxisColor,
    };

    return colorMap[attribute] ?? Colors.grey;
  }

  LineChartBarData _getCorrespondingLineChartBarData(
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
      spots: getFilteredDataPoints(sensor.sensorName + sensor.attribute!),
      isCurved: true,
      color: _getSensorColor(sensor.attribute!),
      barWidth: 4,
      isStrokeCapRound: true,
      dashArray: dashPattern,
      belowBarData: BarAreaData(
        show: true,
        color: chartConfig.color.withAlpha(75),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final hasNote = chartConfig.notes.containsKey(index);
          return FlDotCirclePainter(
            radius: hasNote ? 8 : 6,
            color:
                hasNote
                    ? ColorSettings.pointWithNoteColor
                    : (spot.y >= 2.5
                        ? ColorSettings.pointCriticalColor
                        : ColorSettings.pointWithNoteColor),
            strokeWidth: 2,
            strokeColor: ColorSettings.pointStrokeColor,
          );
        },
      ),
    );
  }
}
