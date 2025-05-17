import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/data/models/MultiselectDialogItem.dart';
import 'package:sensorvisualization/presentation/widgets/ChartPage.dart';

class MultipleChartsPage extends StatelessWidget {
  final List<ChartConfig> chartPages;

  final Map<String, Map<String, Set<MultiSelectDialogItem>>> chartSelections;

    final void Function(String chartId, Map<String, Set<MultiSelectDialogItem>> newSelections) onSelectedValuesChanged;
  
  final void Function(int) onDeleteChart;

  const MultipleChartsPage({
    Key? key,
    required this.chartPages,
    required this.chartSelections,
    required this.onSelectedValuesChanged,
    required this.onDeleteChart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chartPages.length,
      itemBuilder: (context, index) {
        final chart = chartPages[index];
        return Column(
          children: [
            SizedBox(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ChartPage.withSelectedValues(
                  chartConfig: chart,
                  selectedValues: chartSelections[chart.id] ?? {},
                  onSelectedValuesChanged: (newSel) {
                    onSelectedValuesChanged(chart.id, newSel);
                  },
                ),
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