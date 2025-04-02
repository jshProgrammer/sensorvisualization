import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/ChartConfig.dart';
import '../../data/services/BackgroundColorPainter.dart';
import '../../data/models/ColorSettings.dart';

class ChartPage extends StatefulWidget {
  final ChartConfig chartConfig;
  final Function(int) onPointTap;

  const ChartPage({
    super.key,
    required this.chartConfig,
    required this.onPointTap,
  });

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final TextEditingController _noteController = TextEditingController();

  late TransformationController _transformationController;

  int? selectedPointIndex;

  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildBackgroundPainter() {
    return CustomPaint(painter: BackgroundColorPainter(), child: Container());
  }

  void _showAllNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alle Notizen'),
          content:
              widget.chartConfig.notes.isEmpty
                  ? const Text('Keine Notizen vorhanden')
                  : SingleChildScrollView(
                    child: ListBody(
                      children:
                          widget.chartConfig.notes.entries.map((entry) {
                            final spot = widget.chartConfig.dataPoints
                                .expand((innerList) => innerList)
                                .firstWhere((e) => e.x.toInt() == entry.key);
                            return ListTile(
                              title: Text(
                                'Punkt ${entry.key} (Wert: ${spot.y.toStringAsFixed(1)})',
                              ),
                              subtitle: Text(entry.value),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    widget.chartConfig.notes.remove(entry.key);
                                    Navigator.of(context).pop();
                                    _showAllNotes();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  List<bool> lineToDisplay = [true, true];

  List<Widget> buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.zoom_in),
        onPressed: () {
          setState(() {
            final scale = 1.2;
            final x = 0.0;
            final y = 0.0;
            final zoom =
                Matrix4.identity()
                  ..translate(x, y)
                  ..scale(scale)
                  ..translate(-x, -y);

            final currentZoom = _transformationController.value.clone();
            currentZoom.multiply(zoom);
            _transformationController.value = currentZoom;
          });
        },
        tooltip: 'Vergrößern',
      ),
      IconButton(
        icon: const Icon(Icons.zoom_out),
        onPressed: () {
          setState(() {
            final scale = 0.8;
            final x = 0.0;
            final y = 0.0;
            final zoom =
                Matrix4.identity()
                  ..translate(x, y)
                  ..scale(scale)
                  ..translate(-x, -y);

            final currentZoom = _transformationController.value.clone();
            currentZoom.multiply(zoom);
            _transformationController.value = currentZoom;
          });
        },
        tooltip: 'Verkleinern',
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _resetZoom,
        tooltip: 'Zoom zurücksetzen',
      ),
      IconButton(
        icon: const Icon(Icons.list),
        onPressed: _showAllNotes,
        tooltip: 'Alle Notizen anzeigen',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final touchX = details.localPosition.dx;
        final chartWidth = MediaQuery.of(context).size.width - 32;
        final pointSpacing =
            chartWidth / (widget.chartConfig.dataPoints.length - 1);

        final index = (touchX / pointSpacing).round();

        if (index >= 0 && index < widget.chartConfig.dataPoints.length) {
          widget.onPointTap(index);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chartConfig.title),
          actions: buildAppBarActions(),
        ),
        body: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 10.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RepaintBoundary(
              key: _chartKey,
              child: Stack(
                children: [
                  _buildBackgroundPainter(),
                  LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 10,
                      minY: -6,
                      maxY: 8,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 0.5,
                        verticalInterval: 0.5,
                        getDrawingHorizontalLine: (value) {
                          return value >= 2.5
                              ? FlLine(
                                color: ColorSettings.lineColor,
                                strokeWidth: 1,
                              )
                              : FlLine(
                                color: ColorSettings.lineColor,
                                strokeWidth: 1,
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
                        border: Border.all(
                          color: widget.chartConfig.color,
                          width: 2,
                        ),
                      ),
                      lineBarsData: [
                        if (lineToDisplay[0])
                          LineChartBarData(
                            spots: widget.chartConfig.dataPoints[0],
                            isCurved: true,
                            color: widget.chartConfig.color,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: widget.chartConfig.color.withAlpha(75),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final hasNote = widget.chartConfig.notes
                                    .containsKey(index);
                                return FlDotCirclePainter(
                                  radius: hasNote ? 8 : 6,
                                  color:
                                      hasNote
                                          ? ColorSettings.pointWithNoteColor
                                          : (spot.y >= 2.5
                                              ? ColorSettings.pointCriticalColor
                                              : ColorSettings
                                                  .pointWithNoteColor),
                                  strokeWidth: 2,
                                  strokeColor: ColorSettings.pointStrokeColor,
                                );
                              },
                            ),
                          ),

                        if (lineToDisplay[1])
                          LineChartBarData(
                            spots: widget.chartConfig.dataPoints[1],
                            isCurved: true,
                            color: widget.chartConfig.color,
                            barWidth: 2,
                            dashArray: [5, 2],
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: widget.chartConfig.color.withAlpha(75),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final hasNote = widget.chartConfig.notes
                                    .containsKey(index);
                                return FlDotCirclePainter(
                                  radius: hasNote ? 8 : 6,
                                  color:
                                      hasNote
                                          ? ColorSettings.pointWithNoteColor
                                          : (spot.y >= 2.5
                                              ? ColorSettings.pointCriticalColor
                                              : ColorSettings
                                                  .pointWithNoteColor),
                                  strokeWidth: 2,
                                  strokeColor: ColorSettings.pointStrokeColor,
                                );
                              },
                            ),
                          ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              final index = spot.x.toInt();
                              return LineTooltipItem(
                                widget.chartConfig.notes[index] ??
                                    "Keine Notiz",
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
