import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/data/services/client/ClientCommandHandler.dart';
import 'package:sensorvisualization/controller/measurement/SensorMeasurementController.dart';
import 'package:sensorvisualization/model/measurement/MeasurementState.dart';
import 'package:sensorvisualization/model/measurement/MeasurementSensorDataModel.dart';
import 'SensorMeasurementController_test.mocks.dart';

@GenerateMocks([SensorClient, ClientCommandHandler])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SensorMeasurementController Tests', () {
    late SensorMeasurementController controller;
    late MockSensorClient mockSensorClient;
    late MockClientCommandHandler mockCommandHandler;

    String? receivedAlarm;
    String? receivedError;
    bool measurementStoppedCalled = false;

    setUp(() {
      mockSensorClient = MockSensorClient();
      mockCommandHandler = MockClientCommandHandler();

      when(mockSensorClient.commandHandler).thenReturn(mockCommandHandler);
      when(mockSensorClient.isPaused).thenReturn(false);
      when(mockSensorClient.sensorInterval).thenReturn(1);

      when(mockSensorClient.startSensorStream()).thenAnswer((_) async {});
      when(mockSensorClient.pauseMeasurement()).thenAnswer((_) async {});
      when(mockSensorClient.resumeMeasurement()).thenAnswer((_) async {});
      when(mockSensorClient.stopMeasurement()).thenAnswer((_) async {});

      receivedAlarm = null;
      receivedError = null;
      measurementStoppedCalled = false;

      controller = SensorMeasurementController(
        connection: mockSensorClient,
        onAlarmReceived: (alarm) => receivedAlarm = alarm,
        onErrorReceived: (error) => receivedError = error,
        onMeasurementStopped: () => measurementStoppedCalled = true,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialisierung', () {
      test('sollte initial state korrekt setzen', () {
        expect(controller.measurementState.isPaused, isFalse);
        expect(controller.measurementState.isNullMeasurement, isFalse);
        expect(controller.measurementState.isDelayActive, isFalse);
        expect(controller.measurementState.isDelayEnabled, isFalse);
        expect(controller.measurementState.measurementDuration, isNull);
        expect(controller.measurementState.remainingSeconds, isNull);
        expect(controller.measurementState.delayRemainingSeconds, isNull);
        expect(controller.sensorData, isA<MeasurementSensorDataModel>());
      });

      test('sollte isPaused vom SensorClient übernehmen', () {
        when(mockSensorClient.isPaused).thenReturn(true);

        final pausedController = SensorMeasurementController(
          connection: mockSensorClient,
        );

        expect(pausedController.measurementState.isPaused, isTrue);
        pausedController.dispose();
      });

      test('sollte CommandHandler korrekt konfigurieren', () {
        verify(mockSensorClient.commandHandler).called(greaterThan(0));
      });

      test('sollte initial leere SensorData haben', () {
        final sensorData = controller.sensorData;

        expect(sensorData.userAccelerometerEvent, isNull);
        expect(sensorData.accelerometerEvent, isNull);
        expect(sensorData.gyroscopeEvent, isNull);
        expect(sensorData.magnetometerEvent, isNull);
        expect(sensorData.barometerEvent, isNull);

        expect(sensorData.userAccelerometerUpdateTime, isNull);
        expect(sensorData.accelerometerUpdateTime, isNull);
        expect(sensorData.gyroscopeUpdateTime, isNull);
        expect(sensorData.magnetometerUpdateTime, isNull);
        expect(sensorData.barometerUpdateTime, isNull);

        expect(sensorData.userAccelerometerLastInterval, isNull);
        expect(sensorData.accelerometerLastInterval, isNull);
        expect(sensorData.gyroscopeLastInterval, isNull);
        expect(sensorData.magnetometerLastInterval, isNull);
        expect(sensorData.barometerLastInterval, isNull);
      });
    });

    group('Measurement Control', () {
      test('pauseMeasurement sollte Messung pausieren', () async {
        when(mockSensorClient.pauseMeasurement()).thenAnswer((_) async {});

        await controller.pauseMeasurement();

        verify(mockSensorClient.pauseMeasurement()).called(1);
        expect(controller.measurementState.isPaused, isTrue);
      });

      test('resumeMeasurement sollte Messung fortsetzen', () async {
        when(mockSensorClient.resumeMeasurement()).thenAnswer((_) async {});

        await controller.resumeMeasurement();

        verify(mockSensorClient.resumeMeasurement()).called(1);
        expect(controller.measurementState.isPaused, isFalse);
      });

      test('stopMeasurement sollte Messung stoppen', () async {
        when(mockSensorClient.stopMeasurement()).thenAnswer((_) async {});

        await controller.stopMeasurement();

        verify(mockSensorClient.stopMeasurement()).called(1);
      });
    });

    //TODO: funktioniert noch nicht (versucht auf echte Streams zuzugreifen?)
    group('CommandHandler Callbacks', () {
      /*test('onAlarmReceived sollte Alarm-Callback auslösen', () {
        const alarmMessage = "Test-Alarm";

        final onAlarmCallback =
            controller.connection.commandHandler.onAlarmReceived;
        if (onAlarmCallback != null) {
          onAlarmCallback(alarmMessage);
        }

        expect(receivedAlarm, equals(alarmMessage));
      });*/

      /* test('onMeasurementPaused sollte Messung pausieren', () async {
        final onPausedCallback =
            controller.connection.commandHandler.onMeasurementPaused;
        if (onPausedCallback != null) {
          await onPausedCallback();
        }

        verify(mockSensorClient.pauseMeasurement()).called(1);
        expect(controller.measurementState.isPaused, isTrue);
      });*/

      /*test('onMeasurementResumed sollte Messung fortsetzen', () async {
        final onResumedCallback =
            controller.connection.commandHandler.onMeasurementResumed;
        if (onResumedCallback != null) {
          await onResumedCallback();
        }

        verify(mockSensorClient.resumeMeasurement()).called(1);
        expect(controller.measurementState.isPaused, isFalse);
      });*/

      /* test('onMeasurementStopped sollte Stop-Callback auslösen', () async {
        final onStoppedCallback =
            controller.connection.commandHandler.onMeasurementStopped;
        if (onStoppedCallback != null) {
          await onStoppedCallback();
        }

        verify(mockSensorClient.stopMeasurement()).called(1);
        expect(measurementStoppedCalled, isTrue);
      });*/
    });

    group('Sensor Stream Setup', () {
      /* test('startSensorStreams sollte SensorClient starten', () {
        controller.startSensorStreams();

        verify(mockSensorClient.startSensorStream()).called(1);
      });*/
    });

    group('Sensor Data Updates', () {
      test('sollte UserAccelerometer-Daten korrekt aktualisieren', () {
        final now = DateTime.now();
        final event = UserAccelerometerEvent(1.0, 2.0, 3.0, now);

        controller.updateUserAccelerometerData(event);

        expect(controller.sensorData.userAccelerometerEvent, equals(event));
        expect(controller.sensorData.userAccelerometerUpdateTime, equals(now));
      });

      test('sollte Accelerometer-Daten korrekt aktualisieren', () {
        final now = DateTime.now();
        final event = AccelerometerEvent(1.0, 2.0, 3.0, now);

        controller.updateAccelerometerData(event);

        expect(controller.sensorData.accelerometerEvent, equals(event));
        expect(controller.sensorData.accelerometerUpdateTime, equals(now));
      });

      test('sollte Gyroscope-Daten korrekt aktualisieren', () {
        final now = DateTime.now();
        final event = GyroscopeEvent(1.0, 2.0, 3.0, now);

        controller.updateGyroscopeData(event);

        expect(controller.sensorData.gyroscopeEvent, equals(event));
        expect(controller.sensorData.gyroscopeUpdateTime, equals(now));
      });

      test('sollte Magnetometer-Daten korrekt aktualisieren', () {
        final now = DateTime.now();
        final event = MagnetometerEvent(1.0, 2.0, 3.0, now);

        controller.updateMagnetometerData(event);

        expect(controller.sensorData.magnetometerEvent, equals(event));
        expect(controller.sensorData.magnetometerUpdateTime, equals(now));
      });

      test('sollte Barometer-Daten korrekt aktualisieren', () {
        final now = DateTime.now();
        final event = BarometerEvent(1013.25, now);

        controller.updateBarometerData(event);

        expect(controller.sensorData.barometerEvent, equals(event));
        expect(controller.sensorData.barometerUpdateTime, equals(now));
      });
    });

    group('Interval Berechnung', () {
      test('sollte Intervall korrekt berechnen', () {
        final firstTime = DateTime.now();
        final secondTime = firstTime.add(const Duration(milliseconds: 100));

        final firstEvent = UserAccelerometerEvent(1.0, 2.0, 3.0, firstTime);
        final secondEvent = UserAccelerometerEvent(1.0, 2.0, 3.0, secondTime);

        controller.updateUserAccelerometerData(firstEvent);
        expect(controller.sensorData.userAccelerometerLastInterval, isNull);

        controller.updateUserAccelerometerData(secondEvent);
        expect(
          controller.sensorData.userAccelerometerLastInterval,
          equals(100),
        );
      });

      test('sollte kurze Intervalle ignorieren', () {
        final firstTime = DateTime.now();
        final secondTime = firstTime.add(const Duration(milliseconds: 10));

        final firstEvent = UserAccelerometerEvent(1.0, 2.0, 3.0, firstTime);
        final secondEvent = UserAccelerometerEvent(1.0, 2.0, 3.0, secondTime);

        controller.updateUserAccelerometerData(firstEvent);

        controller.updateUserAccelerometerData(secondEvent);
        expect(controller.sensorData.userAccelerometerLastInterval, isNull);
      });
    });

    group('Error Handling', () {
      test('sollte Sensor-Fehler korrekt behandeln', () {
        const sensorName = "Beschleunigungssensor";

        controller.showSensorError(sensorName);

        expect(receivedError, contains(sensorName));
      });
    });

    group('MeasurementSensorDataModel copyWith Tests', () {
      test('copyWith sollte neue Instanz mit geänderten Werten erstellen', () {
        final originalData = MeasurementSensorDataModel();
        final now = DateTime.now();
        final event = UserAccelerometerEvent(1.0, 2.0, 3.0, now);

        final newData = originalData.copyWith(
          userAccelerometerEvent: event,
          userAccelerometerUpdateTime: now,
          userAccelerometerLastInterval: 100,
        );

        expect(newData.userAccelerometerEvent, equals(event));
        expect(newData.userAccelerometerUpdateTime, equals(now));
        expect(newData.userAccelerometerLastInterval, equals(100));

        expect(originalData.userAccelerometerEvent, isNull);
        expect(originalData.userAccelerometerUpdateTime, isNull);
        expect(originalData.userAccelerometerLastInterval, isNull);
      });

      test('copyWith sollte unveränderte Werte beibehalten', () {
        final now = DateTime.now();
        final event = AccelerometerEvent(5.0, 6.0, 7.0, now);

        final originalData = MeasurementSensorDataModel(
          accelerometerEvent: event,
          accelerometerUpdateTime: now,
          accelerometerLastInterval: 50,
        );

        final newData = originalData.copyWith(
          userAccelerometerLastInterval: 100,
        );

        expect(newData.userAccelerometerLastInterval, equals(100));

        expect(newData.accelerometerEvent, equals(event));
        expect(newData.accelerometerUpdateTime, equals(now));
        expect(newData.accelerometerLastInterval, equals(50));
      });
    });

    group('MeasurementState copyWith Tests', () {
      test('copyWith sollte neue Instanz mit geänderten Werten erstellen', () {
        const originalState = MeasurementState();

        final newState = originalState.copyWith(
          isPaused: true,
          isNullMeasurement: true,
          measurementDuration: 300,
          remainingSeconds: 250,
        );

        expect(newState.isPaused, isTrue);
        expect(newState.isNullMeasurement, isTrue);
        expect(newState.measurementDuration, equals(300));
        expect(newState.remainingSeconds, equals(250));

        expect(originalState.isPaused, isFalse);
        expect(originalState.isNullMeasurement, isFalse);
        expect(originalState.measurementDuration, isNull);
        expect(originalState.remainingSeconds, isNull);
      });

      test('copyWith sollte default Werte korrekt handhaben', () {
        const originalState = MeasurementState(
          isPaused: true,
          isDelayActive: true,
          measurementDuration: 500,
        );

        final newState = originalState.copyWith(isNullMeasurement: true);

        expect(newState.isNullMeasurement, isTrue);

        expect(newState.isPaused, isTrue);
        expect(newState.isDelayActive, isTrue);
        expect(newState.measurementDuration, equals(500));

        expect(newState.isDelayEnabled, isFalse);
      });
    });

    test('sollte Listener bei Sensor-Daten-Update benachrichtigen', () {
      bool notified = false;
      controller.addListener(() => notified = true);

      final event = UserAccelerometerEvent(1.0, 2.0, 3.0, DateTime.now());
      controller.updateUserAccelerometerData(event);

      expect(notified, isTrue);
    });

    test('sollte Listener bei Measurement-State-Update benachrichtigen', () {
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.updateMeasurementState(
        controller.measurementState.copyWith(isPaused: true),
      );

      expect(notified, isTrue);
    });

    //TODO: funktioniert noch nicht
    /* group('Dispose', () {
      /* test('sollte alle Subscriptions korrekt canceln', () {
        expect(() => controller.dispose(), returnsNormally);
      });*/
    });*/

    group('Error Handling & Exceptions', () {
      test('sollte mit SensorClient-Fehlern umgehen können', () async {
        when(
          mockSensorClient.pauseMeasurement(),
        ).thenThrow(Exception('Connection failed'));

        expect(
          () async => await controller.pauseMeasurement(),
          throwsException,
        );
      });

      test('sollte mit WebSocket-Fehlern umgehen können', () async {
        when(
          mockSensorClient.stopMeasurement(),
        ).thenThrow(StateError('WebSocket already closed'));

        expect(
          () async => await controller.stopMeasurement(),
          throwsStateError,
        );
      });

      test('sollte Sensor-Fehler korrekt behandeln', () {
        const sensorName = "Beschleunigungssensor";

        controller.showSensorError(sensorName);

        expect(receivedError, contains(sensorName));
        expect(receivedError, contains("scheint keinen"));
      });

      test('sollte verschiedene Sensor-Fehlermeldungen generieren', () {
        final sensorNames = [
          "User Beschleunigungssensor",
          "Beschleunigungssensor",
          "Gyroskop",
          "Magnetometer",
          "Barometer",
        ];

        for (final sensorName in sensorNames) {
          controller.showSensorError(sensorName);
          expect(receivedError, contains(sensorName));
        }
      });
    });

    group('Integration Tests', () {
      //TODO: funktioniert noch nicht
      /* test('sollte kompletten Mess-Zyklus korrekt durchlaufen', () async {
        controller.startSensorStreams();
        verify(mockSensorClient.startSensorStream()).called(1);

        await controller.pauseMeasurement();
        verify(mockSensorClient.pauseMeasurement()).called(1);
        expect(controller.measurementState.isPaused, isTrue);

        await controller.resumeMeasurement();
        verify(mockSensorClient.resumeMeasurement()).called(1);
        expect(controller.measurementState.isPaused, isFalse);

        await controller.stopMeasurement();
        verify(mockSensorClient.stopMeasurement()).called(1);
      });*/

      test('sollte Sensor-Daten-Updates mit Callbacks kombinieren', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        final event = UserAccelerometerEvent(1.0, 2.0, 3.0, DateTime.now());
        controller.updateUserAccelerometerData(event);

        expect(notified, isTrue);
        expect(controller.sensorData.userAccelerometerEvent, equals(event));
      });
    });

    test('sollte mit null Callbacks umgehen können', () {
      final controllerWithoutCallbacks = SensorMeasurementController(
        connection: mockSensorClient,
      );

      expect(
        () => controllerWithoutCallbacks.showSensorError("Test"),
        returnsNormally,
      );

      controllerWithoutCallbacks.dispose();
    });

    test('sollte mit mehrfachen dispose() Aufrufen umgehen', () {
      final separateController = SensorMeasurementController(
        connection: mockSensorClient,
      );

      expect(() => separateController.dispose(), returnsNormally);

      expect(() => separateController.dispose(), throwsFlutterError);
    });

    test('sollte nach dispose() nicht mehr verwendbar sein', () {
      final separateController = SensorMeasurementController(
        connection: mockSensorClient,
      );

      separateController.dispose();

      expect(() => separateController.addListener(() {}), throwsFlutterError);
    });
  });
}
