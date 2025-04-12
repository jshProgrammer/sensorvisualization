import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensorvisualization/data/models/ChartConfig.dart';
import 'package:sensorvisualization/presentation/widgets/ChartPage.dart';

class MultipleChartsPage extends StatelessWidget {
  final List<Widget> chartPages;

  const MultipleChartsPage({Key? key, required this.chartPages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mehrere Diagramme'),
      ),
      body: ListView.builder(
        itemCount: chartPages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: chartPages[index],
          );
        },
      ),
    );
  }
}