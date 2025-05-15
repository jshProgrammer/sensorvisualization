import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/presentation/widgets/ChartPage.dart';

class MultipleChartsPage extends StatelessWidget {
  final List<ChartConfig> chartPages;
  
  final void Function(int) onDeleteChart;

  const MultipleChartsPage({Key? key, required this.chartPages, required this.onDeleteChart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chartPages.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ChartPage(chartConfig: chartPages[index]),
              ),
            ),
            if (chartPages.length > 1)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Diagramm löschen',
                onPressed: () => onDeleteChart(index),
              ),
          ],
        );
      },
    );
  }
}