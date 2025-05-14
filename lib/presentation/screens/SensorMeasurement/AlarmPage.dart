import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Alarmpage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<Alarmpage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initNotifications();
    checkAlarmState();
    _timer = Timer.periodic(Duration(seconds: 5), (_) => checkAlarmState());
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> triggerAlarmNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Alarm',
          channelDescription: 'Lauter Alarm',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm'),
          enableVibration: true,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'alarm.mp3',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'ALARM',
      'Ein Alarm wurde ausgelöst!',
      details,
    );
  }

  Future<void> stopAlarmNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> checkAlarmState() async {
    try {
      final response =
      //Hier noch URL Anpassen
      await http.get(Uri.parse('https://dein-server.de/status.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool shouldPlayAlarm = data['alarm_state'] ?? false;

        if (shouldPlayAlarm && !isPlaying) {
          await triggerAlarmNotification();
          setState(() => isPlaying = true);
        } else if (!shouldPlayAlarm && isPlaying) {
          await stopAlarmNotification();
          setState(() => isPlaying = false);
        }
      } else {
        print("Fehler beim Laden: ${response.statusCode}");
      }
    } catch (e) {
      print("Fehler beim Abrufen: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text("Alarm Control")),
          body: Center(
            child: ElevatedButton(
              onPressed: checkAlarmState,
              child: Text(isPlaying ? "Alarm läuft" : "Kein Alarm"),
            ),
          ),
        ),
        if (isPlaying)
          Positioned.fill(
            child: Container(
              color: Colors.red.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 100, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'ALARM!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await stopAlarmNotification();
                        setState(() => isPlaying = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Alarm stoppen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
