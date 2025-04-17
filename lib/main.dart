import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/services/ConnectionProvider.dart';
import 'package:sensorvisualization/presentation/screens/TabsHomeScreen.dart';
import 'package:sensorvisualization/presentation/screens/SensorMeasurement/SensorMessScreen.dart';
import 'presentation/screens/ChartsHomeScreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ConnectionProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor Visualization (THW)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TabsHomeScreen(),
    );
  }
}
