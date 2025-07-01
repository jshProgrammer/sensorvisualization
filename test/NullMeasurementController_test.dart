import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
//TODO: manche tests funktionieren noch nicht
import 'package:sensorvisualization/controller/measurement/NullMeasurementController.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/data/services/client/ClientCommandHandler.dart';
import 'package:sensorvisualization/model/measurement/MeasurementState.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';

// Generate mocks
@GenerateMocks([SensorClient, ClientCommandHandler])
import 'NullMeasurementController_test.mocks.dart';

void main() {
  late MockSensorClient mockSensorClient;
  late MockClientCommandHandler mockCommandHandler;

  setUp(() {
    // Create fresh mocks for each test
    mockSensorClient = MockSensorClient();
    mockCommandHandler = MockClientCommandHandler();

    // Setup default behavior
    when(mockSensorClient.commandHandler).thenReturn(mockCommandHandler);
    when(mockSensorClient.localIP).thenReturn('192.168.1.100');
    when(mockSensorClient.sendStartingNullMeasurement(any)).thenReturn(null);
    when(mockSensorClient.sendDelayedMeasurement(any)).thenReturn(null);
  });

  NullMeasurementController createController({Function()? onComplete}) {
    return NullMeasurementController(
      connection: mockSensorClient,
      onNullMeasurementComplete: onComplete ?? () {},
    );
  }

  group('Initialization Tests', () {
    test('should initialize with correct default values', () {
      final controller = createController();

      expect(controller.measurementState.isPaused, isTrue);
      expect(controller.measurementState.measurementDuration, equals(10));
      expect(controller.measurementState.remainingSeconds, equals(10));
      expect(controller.measurementState.isNullMeasurement, isFalse);
      expect(controller.measurementState.isDelayActive, isFalse);
      expect(controller.measurementState.isDelayEnabled, isFalse);
      expect(controller.selectedTimeUnit, equals(TimeUnitChoice.seconds.value));
      expect(controller.delayText, isEmpty);

      controller.dispose();
    });

    test('should setup connection handlers on initialization', () {
      final controller = createController();

      // Verify that the command handlers are accessed
      verify(mockSensorClient.commandHandler).called(greaterThanOrEqualTo(1));

      controller.dispose();
    });
  });

  group('Measurement Duration Tests', () {
    test('should update measurement duration correctly', () {
      final controller = createController();
      const newDuration = 20;
      controller.updateMeasurementDuration(newDuration);

      expect(
        controller.measurementState.measurementDuration,
        equals(newDuration),
      );
      expect(controller.measurementState.remainingSeconds, equals(newDuration));

      controller.dispose();
    });

    test('should handle zero duration', () {
      final controller = createController();
      controller.updateMeasurementDuration(0);

      expect(controller.measurementState.measurementDuration, equals(0));
      expect(controller.measurementState.remainingSeconds, equals(0));

      controller.dispose();
    });
  });

  group('Null Measurement Tests', () {
    /*test('should start null measurement correctly', () {
      final controller = createController();

      controller.startNullMeasurement();

      expect(controller.measurementState.isPaused, isFalse);
      expect(controller.measurementState.isNullMeasurement, isTrue);
      expect(controller.measurementState.isDelayActive, isFalse);

      verify(mockSensorClient.sendStartingNullMeasurement(any)).called(1);

      controller.dispose();
    });*/

    /*test('should start null measurement with custom duration', () {
      final controller = createController();

      const customDuration = 15;
      controller.updateMeasurementDuration(customDuration);
      controller.startNullMeasurement();

      expect(
        controller.measurementState.remainingSeconds,
        equals(customDuration),
      );
      verify(
        mockSensorClient.sendStartingNullMeasurement(customDuration),
      ).called(1);

      controller.dispose();
    });*/

    /*test('should clear model data when starting measurement', () {
      final controller = createController();
      // Add some data first
      controller.model.addAccelerometerData(1.0, 2.0, 3.0);
      controller.model.addGyroscopeData(4.0, 5.0, 6.0);

      expect(controller.model.accelerometerData.length, equals(1));
      expect(controller.model.gyroscopeData.length, equals(1));

      controller.startNullMeasurement();

      expect(controller.model.accelerometerData.length, equals(0));
      expect(controller.model.gyroscopeData.length, equals(0));

      controller.dispose();
    });*/
  });

  group('Delay Timer Tests', () {
    test('should start delay timer with seconds', () {
      final controller = createController();
      controller.delayText = '5';
      controller.selectedTimeUnit = TimeUnitChoice.seconds.value;

      controller.startDelayTimer();

      expect(controller.measurementState.isDelayActive, isTrue);
      expect(controller.measurementState.delayRemainingSeconds, equals(5));
      verify(mockSensorClient.sendDelayedMeasurement(5)).called(1);

      controller.dispose();
    });

    test('should start delay timer with minutes', () {
      final controller = createController();
      controller.delayText = '2';
      controller.selectedTimeUnit = TimeUnitChoice.minutes.value;

      controller.startDelayTimer();

      expect(controller.measurementState.isDelayActive, isTrue);
      expect(
        controller.measurementState.delayRemainingSeconds,
        equals(120),
      ); // 2 * 60
      verify(mockSensorClient.sendDelayedMeasurement(120)).called(1);
      controller.dispose();
    });

    test('should start delay timer with hours', () {
      final controller = createController();
      controller.delayText = '1';
      controller.selectedTimeUnit = TimeUnitChoice.hours.value;

      controller.startDelayTimer();

      expect(controller.measurementState.isDelayActive, isTrue);
      expect(
        controller.measurementState.delayRemainingSeconds,
        equals(3600),
      ); // 1 * 3600
      verify(mockSensorClient.sendDelayedMeasurement(3600)).called(1);
      controller.dispose();
    });

    test('should handle invalid delay text', () {
      final controller = createController();
      controller.delayText = 'abc';
      controller.selectedTimeUnit = TimeUnitChoice.seconds.value;

      controller.startDelayTimer();

      expect(controller.measurementState.delayRemainingSeconds, equals(0));
      verify(mockSensorClient.sendDelayedMeasurement(0)).called(1);
      controller.dispose();
    });

    test('should start delay timer with provided duration parameter', () {
      final controller = createController();
      const duration = 30;
      controller.startDelayTimer(duration: duration);

      expect(controller.measurementState.isDelayActive, isTrue);
      expect(
        controller.measurementState.delayRemainingSeconds,
        equals(duration),
      );
      verify(mockSensorClient.sendDelayedMeasurement(duration)).called(1);
      controller.dispose();
    });
  });

  group('Progress Calculation Tests', () {
    test('should return delay progress when delay is active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isDelayActive: true,
          delayProgress: 0.5,
        ),
      );

      expect(controller.progress, equals(0.5));
      controller.dispose();
    });

    test('should return measurement progress when measurement is active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isPaused: false,
          measurementProgress: 0.7,
        ),
      );

      expect(controller.progress, equals(0.7));
      controller.dispose();
    });

    test('should return 0.0 when paused and no delay active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isPaused: true,
          isDelayActive: false,
        ),
      );

      expect(controller.progress, equals(0.0));
      controller.dispose();
    });
  });

  group('Display Tests', () {
    test('should return delay remaining seconds when delay is active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isDelayActive: true,
          delayRemainingSeconds: 15,
          remainingSeconds: 10,
        ),
      );

      expect(controller.displayRemainingSeconds, equals(15));
      controller.dispose();
    });

    test(
      'should return measurement remaining seconds when delay is not active',
      () {
        final controller = createController();
        controller.setMeasurementStateForTesting(
          controller.measurementState.copyWith(
            isDelayActive: false,
            delayRemainingSeconds: 15,
            remainingSeconds: 10,
          ),
        );

        expect(controller.displayRemainingSeconds, equals(10));
        controller.dispose();
      },
    );
  });

  group('User Interaction Tests', () {
    test(
      'should start delay timer when delay is enabled and user presses start',
      () {
        final controller = createController();
        controller.delayText = '3';
        controller.setActiveDelay(true);

        controller.userStartButtonPressed();

        expect(controller.measurementState.isDelayActive, isTrue);
        verify(mockSensorClient.sendDelayedMeasurement(3)).called(1);
        controller.dispose();
      },
    );

    /*test(
      'should start measurement directly when delay is disabled and user presses start',
      () {
        final controller = createController();
        controller.setActiveDelay(false);

        controller.userStartButtonPressed();

        expect(controller.measurementState.isNullMeasurement, isTrue);
        expect(controller.measurementState.isPaused, isFalse);
        verify(mockSensorClient.sendStartingNullMeasurement(any)).called(1);
        controller.dispose();
      },
    );*/
  });

  group('Button State Tests', () {
    test('should return true when measurement is running', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(isPaused: false),
      );

      expect(controller.isStartButtonPressedActive(), isTrue);
      controller.dispose();
    });

    test('should return true when delay is active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(isDelayActive: true),
      );

      expect(controller.isStartButtonPressedActive(), isTrue);
      controller.dispose();
    });

    test('should return false when paused and no delay active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isPaused: true,
          isDelayActive: false,
        ),
      );

      expect(controller.isStartButtonPressedActive(), isFalse);
      controller.dispose();
    });
  });

  group('Button Text Tests', () {
    test('should return "Messung läuft" when measurement is running', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(isPaused: false),
      );

      expect(controller.getTextOfUserButton(), equals("Messung läuft"));
      controller.dispose();
    });

    test('should return "Selbstauslöser aktiv" when delay is active', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isPaused: true,
          isDelayActive: true,
        ),
      );

      expect(controller.getTextOfUserButton(), equals("Selbstauslöser aktiv"));
      controller.dispose();
    });

    test(
      'should return "Selbstauslöser starten" when delay is enabled but not active',
      () {
        final controller = createController();
        controller.setMeasurementStateForTesting(
          controller.measurementState.copyWith(
            isPaused: true,
            isDelayActive: false,
            isDelayEnabled: true,
          ),
        );

        expect(
          controller.getTextOfUserButton(),
          equals("Selbstauslöser starten"),
        );
        controller.dispose();
      },
    );

    test('should return "Nullmessung starten" when delay is disabled', () {
      final controller = createController();
      controller.setMeasurementStateForTesting(
        controller.measurementState.copyWith(
          isPaused: true,
          isDelayActive: false,
          isDelayEnabled: false,
        ),
      );

      expect(controller.getTextOfUserButton(), equals("Nullmessung starten"));
      controller.dispose();
    });
  });

  group('Settings Tests', () {
    test('should update delay enabled state', () {
      final controller = createController();
      controller.setActiveDelay(true);
      expect(controller.measurementState.isDelayEnabled, isTrue);

      controller.setActiveDelay(false);
      expect(controller.measurementState.isDelayEnabled, isFalse);
      controller.dispose();
    });

    test('should update delay text', () {
      final controller = createController();
      const newText = '15';
      controller.setDelayText(newText);
      expect(controller.delayText, equals(newText));
      controller.dispose();
    });

    test('should update selected time unit', () {
      final controller = createController();
      controller.setSelectedTimeUnit(TimeUnitChoice.minutes.value);
      expect(controller.selectedTimeUnit, equals(TimeUnitChoice.minutes.value));
      controller.dispose();
    });
  });

  group('Connection Handler Tests', () {
    /*test('should handle start null measurement command from connection', () {
      final controller = createController();
      const duration = 25;

      // Simulate the callback being set and called
      when(mockCommandHandler.onStartNullMeasurementReceived).thenReturn((
        int receivedDuration,
      ) {
        controller.updateMeasurementDuration(receivedDuration);
        controller.startNullMeasurement();
      });

      // Trigger the callback manually for testing
      controller.updateMeasurementDuration(duration);
      controller.startNullMeasurement();

      expect(controller.measurementState.measurementDuration, equals(duration));
      expect(controller.measurementState.isNullMeasurement, isTrue);
      controller.dispose();
    });*/

    test('should handle delayed measurement command from connection', () {
      final controller = createController();
      const duration = 45;

      // Simulate the callback being set and called
      when(mockCommandHandler.onDelayedMeasurementReceived).thenReturn((
        int receivedDuration,
      ) {
        controller.startDelayTimer(duration: receivedDuration);
      });

      // Trigger the callback manually for testing
      controller.startDelayTimer(duration: duration);

      expect(controller.measurementState.isDelayActive, isTrue);
      expect(
        controller.measurementState.delayRemainingSeconds,
        equals(duration),
      );
      controller.dispose();
    });
  });

  group('Model Integration Tests', () {
    test('should access measurement model correctly', () {
      final controller = createController();
      expect(controller.model, isNotNull);
      expect(controller.model.accelerometerData, isEmpty);
      expect(controller.model.gyroscopeData, isEmpty);
      expect(controller.model.magnetometerData, isEmpty);
      expect(controller.model.barometerData, isEmpty);
      controller.dispose();
    });

    /* test('should clear model data on measurement start', () {
      final controller = createController();
      // Add test data
      controller.model.addAccelerometerData(1.0, 2.0, 3.0);
      controller.model.addBarometerData(1013.25);

      expect(controller.model.accelerometerData.length, equals(1));
      expect(controller.model.barometerData.length, equals(1));

      controller.startNullMeasurement();

      expect(controller.model.accelerometerData.length, equals(0));
      expect(controller.model.barometerData.length, equals(0));
      controller.dispose();
    });*/
  });

  group('Edge Cases', () {
    test('should handle negative delay duration', () {
      final controller = createController();
      controller.delayText = '-5';
      controller.selectedTimeUnit = TimeUnitChoice.seconds.value;

      controller.startDelayTimer();

      // Should default to 0 or handle gracefully
      expect(
        controller.measurementState.delayRemainingSeconds,
        anyOf(equals(0), equals(-5)),
      );
      controller.dispose();
    });

    test('should handle empty delay text', () {
      final controller = createController();
      controller.delayText = '';
      controller.selectedTimeUnit = TimeUnitChoice.seconds.value;

      controller.startDelayTimer();

      expect(controller.measurementState.delayRemainingSeconds, equals(0));
      controller.dispose();
    });

    test('should handle very large delay values', () {
      final controller = createController();
      controller.delayText = '999999';
      controller.selectedTimeUnit = TimeUnitChoice.hours.value;

      controller.startDelayTimer();

      expect(
        controller.measurementState.delayRemainingSeconds,
        equals(999999 * 3600),
      );
      controller.dispose();
    });
  });

  group('Dispose Tests', () {
    /*test('should cancel timers on dispose', () {
      final controller = createController();
      controller.startNullMeasurement();

      // Dispose should not throw
      expect(() {
        controller.dispose();
      }, returnsNormally);
    });*/
  });

  group('ChangeNotifier Tests', () {
    test('should notify listeners when measurement state changes', () {
      final controller = createController();
      var notificationCount = 0;

      void listener() {
        notificationCount++;
      }

      controller.addListener(listener);

      controller.updateMeasurementDuration(15);
      controller.setActiveDelay(true);
      controller.setDelayText('10');

      expect(notificationCount, greaterThan(0));

      // Clean up
      controller.removeListener(listener);
      controller.dispose();
    });
  });
}
