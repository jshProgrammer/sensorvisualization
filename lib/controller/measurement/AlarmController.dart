import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/main.dart';
import 'package:sensorvisualization/model/measurement/AlarmState.dart';

class AlarmController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SensorClient connection;
  final Function? onAlarmStopReceived;

  Timer? _timer;

  AlarmState _state = AlarmState();
  AlarmState get state => _state;

  AlarmController({required this.connection, this.onAlarmStopReceived}) {
    _initNotifications();
    _loadAudio();

    connection.commandHandler.onAlarmStopReceived = () {
      stopAlarmNotification();
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      triggerAlarmNotification();
    });
  }

  Future<void> _initNotifications() async {
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

    _updateState(_state.copyWith(isPlaying: true));
  }

  Future<void> stopAlarmNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    await _audioPlayer.stop();

    _updateState(_state.copyWith(isPlaying: false));
    onAlarmStopReceived?.call();
  }

  Future<void> _loadAudio() async {
    try {
      if (Platform.isWindows) {
        await _audioPlayer.setFilePath('assets/windows/alarm.wav');
      } else {
        await _audioPlayer.setAsset('audio/alarm.mp3');
        await _audioPlayer.setLoopMode(LoopMode.all);
        await _audioPlayer.setVolume(1.0);
      }
    } catch (e) {
      print("Fehler beim Laden der Audiodatei: $e");
    }
  }

  void _updateState(AlarmState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
