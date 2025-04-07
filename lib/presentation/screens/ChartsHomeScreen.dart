import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:sensorvisualization/data/services/SampleData.dart';
import 'package:sensorvisualization/presentation/widgets/ChartSelectorTab.dart';
import '../../data/models/ChartConfig.dart';
import '../widgets/ChartPage.dart';
import 'package:sensorvisualization/presentation/widgets/ChartPage.dart';

class ChartsHomeScreen extends StatefulWidget {
  const ChartsHomeScreen({super.key});

  @override
  State<ChartsHomeScreen> createState() => _ChartsHomeScreenState();
}

class _ChartsHomeScreenState extends State<ChartsHomeScreen> {
  final List<ChartConfig> charts = [];
  int selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    _addNewChart();
  }

  void _addNewChart() {
    setState(() {
      final newIndex = charts.length;
      final newChart = ChartConfig(
        id: 'chart_$newIndex',
        title: 'Diagramm ${newIndex + 1}',
        dataPoints: {},
        color: Colors.primaries[newIndex % Colors.primaries.length],
      );
      charts.add(newChart);
      selectedChartIndex = charts.length - 1;
    });
  }

  void _deleteChart(int index) {
    if (charts.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens ein Diagramm muss bestehen bleiben'),
        ),
      );
      return;
    }

    setState(() {
      charts.removeAt(index);
      if (selectedChartIndex >= charts.length) {
        selectedChartIndex = charts.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor visualization (THW)'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () async {
              final info = NetworkInfo();
              final ip = await info.getWifiIP();
              showDialog(
                context: context,
                builder:
                    (BuildContext context) => AlertDialog(
                      title: Text('QR-Code der IP-Adresse'),
                      content: PrettyQrView.data(data: ip!),
                      actions: [
                        TextButton(
                          child: Text('Schließen'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ChartSelectorTab(
            charts: charts,
            selectedChartIndex: selectedChartIndex,
          ),
          Expanded(
            child:
                charts.isEmpty
                    ? const Center(child: Text('Keine Diagramme vorhanden'))
                    : ChartPage(chartConfig: charts[selectedChartIndex]),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Diagramm löschen',
            onPressed: () => _deleteChart(selectedChartIndex),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewChart,
        tooltip: 'Neues Diagramm hinzufügen',
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
