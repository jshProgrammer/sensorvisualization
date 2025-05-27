import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';

class Alarmpage extends StatefulWidget {
  final Function? onAlarmStopReceived;
  final SensorClient connection;
  const Alarmpage({
    Key? key,
    this.onAlarmStopReceived,
    required this.connection,
  }) : super(key: key);
  @override
  AlarmPageState createState() => AlarmPageState();
}

class AlarmPageState extends State<Alarmpage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initNotifications();
    _loadAudio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      triggerAlarmNotification();
    });
    widget.connection.commandHandler.onAlarmStopReceived = () {
      stopAlarmNotification();
    };
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentSound: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped with payload: ${details.payload}');
      },
    );
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
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
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
    try {
      await _audioPlayer.play();
    } catch (e) {
      print("Fehler beim Abspielen: $e");
    }
    setState(() {
      isPlaying = true;
      print("Alarm gestartet");
    });
  }

  Future<void> stopAlarmNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      print("Alarm gestoppt");
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    widget.onAlarmStopReceived?.call();
  }

  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setAsset('audio/alarm.mp3');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      print("Fehler beim Laden der Audiodatei: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
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
                setState(() {
                  isPlaying = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Alarm abbrechen', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
