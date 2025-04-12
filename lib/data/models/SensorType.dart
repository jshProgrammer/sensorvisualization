enum SensorType {
  accelerometer,
  gyroscope,
  magnetometer,
  barometer,
  userAccelerometer,
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
      default:
        return null;
    }
  }
}

enum SensorOrientation { x, y, z }

extension SensorOrientationExtension on SensorOrientation {
  String get displayName {
    switch (this) {
      case SensorOrientation.x:
        return 'x';
      case SensorOrientation.y:
        return 'y';
      case SensorOrientation.z:
        return 'z';
    }
  }
}
