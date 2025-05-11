enum SensorType {
  accelerometer,
  gyroscope,
  magnetometer,
  barometer,
  userAccelerometer,
  simulatedData,
}

extension SensorTypeExtension on SensorType {
  String get displayName {
    switch (this) {
      case SensorType.accelerometer:
        return 'Beschleunigungssensor';
      case SensorType.gyroscope:
        return 'Gyroskop';
      case SensorType.magnetometer:
        return 'Magnetometer';
      case SensorType.barometer:
        return 'Barometer';
      case SensorType.userAccelerometer:
        return 'User Beschleunigungssensor';
      case SensorType.simulatedData:
        return 'Simulierte Daten';
    }
  }

  static SensorType? fromString(String name) {
    switch (name.toLowerCase()) {
      case 'beschleunigungssensor':
        return SensorType.accelerometer;
      case 'gyroskop':
        return SensorType.gyroscope;
      case 'magnetometer':
        return SensorType.magnetometer;
      case 'barometer':
        return SensorType.barometer;
      case 'simulierte daten':
        return SensorType.simulatedData;
      default:
        return null;
    }
  }
}
