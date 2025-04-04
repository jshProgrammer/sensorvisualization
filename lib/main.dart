import 'package:flutter/material.dart';
import 'package:sensorvisualization/presentation/screens/TabsHomeScreen.dart';
import 'package:sensorvisualization/presentation/widgets/SensorMessPage.dart';
import 'presentation/screens/ChartsHomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Visualization (THW)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TabsHomeScreen(),
    );
  }
}
