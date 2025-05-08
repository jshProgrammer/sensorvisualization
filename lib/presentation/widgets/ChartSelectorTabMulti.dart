import 'package:flutter/material.dart';
import '../../data/models/ChartConfig.dart';

class ChartSelectorTabMulti extends StatelessWidget {
  final int selectedIndex;
  final int tabCount;
  final ValueChanged<int> onTabSelected;

  const ChartSelectorTabMulti({
    super.key,
    required this.selectedIndex,
    required this.tabCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text('Tab ${index + 1}'),
              selected: selectedIndex == index,
              onSelected: (_) => onTabSelected(index),
            ),
          );
        },
      ),
    );
  }
}
