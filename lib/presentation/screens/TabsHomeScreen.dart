import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/services/ConnectionToRecipient.dart';
import 'package:sensorvisualization/data/services/ConnectionToSender.dart';
import 'package:sensorvisualization/presentation/screens/QrIpScreen.dart';
import 'package:sensorvisualization/presentation/widgets/SensorMessPage.dart';
import 'package:sensorvisualization/presentation/screens/ChartsHomeScreen.dart';

class TabsHomeScreen extends StatefulWidget {
  const TabsHomeScreen({super.key});

  @override
  State<TabsHomeScreen> createState() => _TabsHomeScreenState();
}

class _TabsHomeScreenState extends State<TabsHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SensorMessPage(),
    const ChartsHomeScreen(),
    const QrIpScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Messung'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Visualisierung',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: "QR-Code Creator",
          ),
        ],
      ),
    );
  }
}
