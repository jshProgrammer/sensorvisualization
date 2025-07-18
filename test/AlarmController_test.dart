import 'package:flutter_test/flutter_test.dart';
import 'package:sensorvisualization/model/measurement/AlarmState.dart';

void main() {
  group('AlarmState Tests', () {
    test('AlarmState should have correct default values', () {
      final state = AlarmState();

      expect(state.isPlaying, false);
      expect(state.alarmMessage, null);
    });

    test('AlarmState should accept custom values', () {
      final state = AlarmState(isPlaying: true, alarmMessage: "Test Alarm");

      expect(state.isPlaying, true);
      expect(state.alarmMessage, "Test Alarm");
    });

    test('copyWith should update only specified fields', () {
      final state = AlarmState(
        isPlaying: false,
        alarmMessage: "Original Message",
      );

      final newState = state.copyWith(isPlaying: true);

      expect(newState.isPlaying, true);
      expect(newState.alarmMessage, "Original Message");
    });

    test('copyWith should update alarmMessage', () {
      final state = AlarmState(isPlaying: true);
      final newState = state.copyWith(alarmMessage: "New Message");

      expect(newState.isPlaying, true);
      expect(newState.alarmMessage, "New Message");
    });

    test('copyWith should update both fields', () {
      final state = AlarmState();
      final newState = state.copyWith(
        isPlaying: true,
        alarmMessage: "Both Changed",
      );

      expect(newState.isPlaying, true);
      expect(newState.alarmMessage, "Both Changed");
    });

    test('original state should remain unchanged after copyWith', () {
      final state = AlarmState(isPlaying: false, alarmMessage: "Original");

      final newState = state.copyWith(isPlaying: true, alarmMessage: "Changed");

      expect(state.isPlaying, false);
      expect(state.alarmMessage, "Original");

      expect(newState.isPlaying, true);
      expect(newState.alarmMessage, "Changed");
    });
    test('copyWith with null isPlaying should keep original value', () {
      final state = AlarmState(isPlaying: true, alarmMessage: "Has Message");
      final newState = state.copyWith(isPlaying: null);

      expect(newState.isPlaying, true);
      expect(newState.alarmMessage, "Has Message");
    });

    test('copyWith with null message should keep original value', () {
      final state = AlarmState(alarmMessage: "Has Message");
      final newState = state.copyWith(alarmMessage: null);

      expect(newState.alarmMessage, "Has Message");
      expect(newState.isPlaying, false);
    });
  });
}
