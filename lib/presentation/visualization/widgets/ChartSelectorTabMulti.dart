import 'package:flutter/material.dart';
import '../../../data/settingsModels/ChartConfig.dart';

class ChartSelectorTabMulti extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabTitles;
  final ValueChanged<int> onTabSelected;

  const ChartSelectorTabMulti({
    super.key,
    required this.selectedIndex,
    required this.tabTitles,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(tabTitles[index]),
              selected: selectedIndex == index,
              onSelected: (_) => onTabSelected(index),
            ),
          );
        },
      ),
    );
  }
}
