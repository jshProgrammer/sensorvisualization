import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:sensorvisualization/presentation/screens/TabsHomeScreen.dart';
import 'package:sensorvisualization/presentation/screens/SensorMeasurement/SensorMessScreen.dart';
import 'presentation/screens/ChartsHomeScreen.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:sensorvisualization/fireDB/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!Platform.isWindows) {
    _initializeNotifications();
  }
  final appDatabase = AppDatabase.instance;
  final dbOps = Databaseoperations(appDatabase);

  final firebaseSync = Firebasesync();
  await firebaseSync.initializeApp(appDatabase);

  runApp(
    MultiProvider(
      providers: [
        Provider<Databaseoperations>.value(value: dbOps),
        ChangeNotifierProvider(create: (_) => ConnectionProvider(dbOps)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Notification-Plugin initialisieren
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final appDatabase = AppDatabase.instance;
  late Databaseoperations _databaseOperations;
  bool _isExporting = false;
  String? noteCSVPath;
  String? sensorCSVPath;
  String? identificationCSVPath;

  final firebaseSync = Firebasesync();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _databaseOperations = Provider.of<Databaseoperations>(
        context,
        listen: false,
      );
      _checkAndShowPreviousExportDialog();
    });

    _checkAndShowPreviousExportDialog();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //Tabellen löschen und beenden der Synchronistation zur Cloud DB
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      firebaseSync.stopSyncTimer();
      _exportAndDeleteDatabase();
    }
  }

  Future<void> _exportAndDeleteDatabase() async {
    if (_isExporting) return;
    _isExporting = true;

    try {
      noteCSVPath = await _databaseOperations.exportNoteDataCSV(context);
      sensorCSVPath = await _databaseOperations.exportSensorDataCSV(context);
      identificationCSVPath = await _databaseOperations
          .exportIdentificationDataCSV(context);

      await _databaseOperations.deleteIdentificationData();
      await _databaseOperations.deleteSensorData();
      await _databaseOperations.deleteNoteData();

      // Speicherpfade für spätere Anzeige merken oder Benachrichtigung erzeugen
      _showExportNotification();
    } catch (e) {
      print('Fehler beim Export oder Löschen der Datenbank: $e');
    } finally {
      _isExporting = false;
    }
  }

  void _showExportNotification() async {
    // Lokale Benachrichtigung
    try {
      // Android-spezifische Konfiguration
      const androidDetails = AndroidNotificationDetails(
        'database_export_channel',
        'Datenbank Export',
        channelDescription: 'Benachrichtigungen über Datenbank-Exporte',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'app_icon', // Stelle sicher, dass dieses Icon existiert
      );

      // iOS-spezifische Konfiguration
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Plattformspezifische Details zusammenfassen
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Benachrichtigung anzeigen
      await flutterLocalNotificationsPlugin.show(
        0, // Benachrichtigungs-ID
        'Datenbank Export erfolgreich',
        'Daten wurden exportiert und die Datenbank wurde bereinigt.',
        notificationDetails,
        payload: 'export_completed',
      );
    } catch (e) {
      print('Fehler beim Anzeigen der Benachrichtigung: $e');
    }

    // Speichern für nächsten Start
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_export_note_path', noteCSVPath ?? '');
      prefs.setString('last_export_sensor_path', sensorCSVPath ?? '');
      prefs.setString(
        'last_export_identification_path',
        identificationCSVPath ?? '',
      );
      prefs.setBool('show_export_dialog_next_start', true);
      prefs.setString('export_timestamp', DateTime.now().toString());
    } catch (e) {
      print('Fehler beim Speichern der Export-Informationen: $e');
    }
  }

  void _checkAndShowPreviousExportDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('show_export_dialog_next_start') == true) {
        // Flag zurücksetzen, damit der Dialog nicht bei jedem Start erscheint
        prefs.setBool('show_export_dialog_next_start', false);

        // Exportierte Dateipfade auslesen
        String notePath = prefs.getString('last_export_note_path') ?? '';
        String sensorPath = prefs.getString('last_export_sensor_path') ?? '';
        String idPath =
            prefs.getString('last_export_identification_path') ?? '';
        String timestamp = prefs.getString('export_timestamp') ?? 'Unbekannt';

        // Kurzen Delay einfügen, damit die UI vollständig geladen ist
        await Future.delayed(const Duration(milliseconds: 500));

        // Dialog anzeigen, wenn der Kontext verfügbar ist
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Datenbank-Export Information'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bei der letzten Nutzung wurden folgende Dateien exportiert:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Zeitpunkt: $timestamp'),
                      const SizedBox(height: 16),
                      Text('Notizen: $notePath'),
                      const SizedBox(height: 4),
                      Text('Sensor-Daten: $sensorPath'),
                      const SizedBox(height: 4),
                      Text('Identifikations-Daten: $idPath'),
                      const SizedBox(height: 16),
                      Text(
                        'Die Datenbank wurde nach dem Export geleert.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Fehler beim Überprüfen oder Anzeigen des Export-Dialogs: $e');
    }
  }

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
