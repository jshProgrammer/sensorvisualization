import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/data/models/ColorSettings.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';

class Sensordata {
  late Set<MultiSelectDialogItem> selectedLines;
  late ChartConfig chartConfig;

  double baselineX;
  double baselineY;

  Sensordata({
    required this.selectedLines,
    required this.chartConfig,
    this.baselineX = 0.0,
    this.baselineY = 0.0,
  });

  double _getExtremeValue(
    double Function(FlSpot spot) selector,
    bool Function(double a, double b) compare,
    double fallbackValue,
  ) {
    final Iterable<double> values = selectedLines
        .expand(
          (item) =>
              chartConfig.dataPoints[item.sensorName + item.attribute!] ?? [],
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
        minX: 0.0,
        baselineX: baselineX,
        maxX: _getMaxX(),
        minY: _getMinY(),
        baselineY: baselineY,
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
            HorizontalRangeAnnotation(
              y1: 0,
              y2: 2,
              color: Colors.green.withValues(alpha: 0.3),
            ),
            HorizontalRangeAnnotation(
              y1: 2,
              y2: 4,
              color: Colors.orange.withValues(alpha: 0.3),
            ),
            HorizontalRangeAnnotation(
              y1: 4,
              y2: 10,
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData() {
    List<LineChartBarData> toReturn = [];

    for (MultiSelectDialogItem sensor in selectedLines) {
      toReturn.add(_getCorrespondingLineChartBarData(sensor));
    }

    return toReturn;
  }

  List<VerticalLine> _getNotesVerticalLines() {
    List<VerticalLine> toReturn = [];

    chartConfig.notes.forEach((noteTime, noteString) {
      toReturn.add(
        VerticalLine(
          x: noteTime.toDouble(),
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

  LineChartBarData _getCorrespondingLineChartBarData(
    MultiSelectDialogItem sensor,
  ) {
    return LineChartBarData(
      spots:
          chartConfig.dataPoints[sensor.sensorName + sensor.attribute!] ?? [],
      isCurved: true,
      color:
          sensor.attribute! == SensorOrientation.x.displayName
              ? ColorSettings.sensorXAxisColor
              : sensor.attribute! == SensorOrientation.y.displayName
              ? ColorSettings.sensorYAxisColor
              : ColorSettings.sensorZAxisColor,
      barWidth: 4,
      isStrokeCapRound: true,
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
