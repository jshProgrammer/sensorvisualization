enum SensorOrientation { x, y, z, pressure }

extension SensorOrientationExtension on SensorOrientation {
  String get displayName {
    switch (this) {
      case SensorOrientation.x:
        return 'x';
      case SensorOrientation.y:
        return 'y';
      case SensorOrientation.z:
        return 'z';
      case SensorOrientation.pressure:
        return 'pressure';
    }
  }
}
