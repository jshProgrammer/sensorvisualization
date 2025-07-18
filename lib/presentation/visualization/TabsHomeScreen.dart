import 'package:flutter/material.dart';
import 'package:sensorvisualization/presentation/measurement/QRScannerScreen.dart';

import 'package:sensorvisualization/presentation/measurement/ScannerEntryScreen.dart';
import 'package:sensorvisualization/presentation/visualization/VisualizationHomeScreen.dart';

class TabsHomeScreen extends StatefulWidget {
  const TabsHomeScreen({super.key});

  @override
  State<TabsHomeScreen> createState() => _TabsHomeScreenState();
}

class _TabsHomeScreenState extends State<TabsHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ScannerEntryScreen(),
    const VisualizationHomeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar:
          screenWidth >= 600
              ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sensors),
                    label: 'Messung',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart),
                    label: 'Visualisierung',
                  ),
                ],
              )
              : null,
    );
  }
}
