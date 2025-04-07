import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/services/SampleData.dart';
import 'package:sensorvisualization/presentation/widgets/ChartSelectorTab.dart';
import '../../data/models/ChartConfig.dart';
import '../widgets/ChartPage.dart';

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

  void _addNote(int index) {
    if (selectedChartIndex < 0 || selectedChartIndex >= charts.length) return;

    final chartConfig = charts[selectedChartIndex];
    if (index < 0 || index >= chartConfig.dataPoints.length) return;

    TextEditingController controller = TextEditingController();

    if (chartConfig.notes.containsKey(index)) {
      controller.text = chartConfig.notes[index]!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Notiz für Punkt $index"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Notiz eingeben..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  chartConfig.notes[index] = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor visualization (THW)'),
        actions: [],
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
                    : ChartPage(
                      chartConfig: charts[selectedChartIndex],
                      onPointTap: _addNote,
                    ),
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
