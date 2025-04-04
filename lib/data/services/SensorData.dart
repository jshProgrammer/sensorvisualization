import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/data/models/ColorSettings.dart';

class Sensordata {
  static List<LineChartBarData> getLineBarsData(
    Set<int> selectedLines,
    ChartConfig chartConfig,
  ) {
    List<LineChartBarData> toReturn = [];

    for (int id in selectedLines) {
      toReturn.add(_getCorrespondingLineChartBarData(chartConfig, id));
    }

    return toReturn;
  }

  static LineChartBarData _getCorrespondingLineChartBarData(
    ChartConfig chartConfig,
    int id,
  ) {
    return LineChartBarData(
      spots: chartConfig.dataPoints[id],
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
