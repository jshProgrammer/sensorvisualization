import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/data/models/ColorSettings.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';

class Sensordata {
  static LineChart getLineChart(
    Set<MultiSelectDialogItem> selectedLines,
    ChartConfig chartConfig,
  ) {
    print(
      "Ausgewählte Linien: ${selectedLines.map((e) => e.sensorName + e.attribute!).join(', ')}",
    );
    return LineChart(
      LineChartData(
        minX: 0,
        maxX:
            chartConfig.dataPoints["Gyroscopex"]
                ?.map((spot) => spot.x)
                .reduce((a, b) => a > b ? a : b) ??
            10,
        minY:
            chartConfig.dataPoints["Gyroscopex"]
                ?.map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b) ??
            -2,
        maxY:
            chartConfig.dataPoints["Gyroscopex"]
                ?.map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b) ??
            2,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.5,
          verticalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return value >= 2.5
                ? FlLine(color: ColorSettings.lineColor, strokeWidth: 1)
                : FlLine(color: ColorSettings.lineColor, strokeWidth: 1);
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
        lineBarsData: _getLineBarsData(selectedLines, chartConfig),
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
      ),
    );
  }

  static List<LineChartBarData> _getLineBarsData(
    Set<MultiSelectDialogItem> selectedLines,
    ChartConfig chartConfig,
  ) {
    List<LineChartBarData> toReturn = [];

    for (MultiSelectDialogItem sensor in selectedLines) {
      toReturn.add(_getCorrespondingLineChartBarData(chartConfig, sensor));
    }

    return toReturn;
  }

  static LineChartBarData _getCorrespondingLineChartBarData(
    ChartConfig chartConfig,
    MultiSelectDialogItem sensor,
  ) {
    print("TEST: ${chartConfig.dataPoints}");
    return LineChartBarData(
      spots:
          chartConfig
              .dataPoints["Gyroscopex" /*sensor.sensorName + sensor.attribute!*/] ??
          [],
      isCurved: true,
      color: chartConfig.color,
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
