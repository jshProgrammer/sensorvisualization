import 'package:flutter/material.dart';
import '../../data/models/ChartConfig.dart';

class ChartSelectorTab extends StatefulWidget {
  final List<ChartConfig> charts;
  int selectedChartIndex;

  ChartSelectorTab({
    super.key,
    required this.charts,
    required this.selectedChartIndex,
  });

  @override
  State<ChartSelectorTab> createState() => _ChartSelectorTabState();
}

class _ChartSelectorTabState extends State<ChartSelectorTab> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.charts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(widget.charts[index].title),
              selected: widget.selectedChartIndex == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    widget.selectedChartIndex = index;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
