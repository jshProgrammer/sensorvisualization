import 'package:flutter/material.dart';
import '../../data/models/ChartConfig.dart';

class ChartSelectorTab extends StatelessWidget {
  final List<ChartConfig> charts;
  final int selectedChartIndex;
  final ValueChanged<int> onTabSelected;

  const ChartSelectorTab({
    super.key,
    required this.charts,
    required this.selectedChartIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: charts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(charts[index].title),
              selected: selectedChartIndex == index,
              onSelected: (selected) {
                if (selected) {
                  onTabSelected(index);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
