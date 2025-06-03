import 'package:sensorvisualization/data/settingsModels/SensorType.dart';

class NullMeasurementModel {
  final List<List<double>> _accelerometerData = [];
  final List<List<double>> _gyroscopeData = [];
  final List<List<double>> _magnetometerData = [];
  final List<double> _barometerData = [];

  List<List<double>> get accelerometerData =>
      List.unmodifiable(_accelerometerData);
  List<List<double>> get gyroscopeData => List.unmodifiable(_gyroscopeData);
  List<List<double>> get magnetometerData =>
      List.unmodifiable(_magnetometerData);
  List<double> get barometerData => List.unmodifiable(_barometerData);

  void addAccelerometerData(double x, double y, double z) {
    _accelerometerData.add([x, y, z]);
  }

  void addGyroscopeData(double x, double y, double z) {
    _gyroscopeData.add([x, y, z]);
  }

  void addMagnetometerData(double x, double y, double z) {
    _magnetometerData.add([x, y, z]);
  }

  void addBarometerData(double pressure) {
    _barometerData.add(pressure);
  }

  void clearAllData() {
    _accelerometerData.clear();
    _gyroscopeData.clear();
    _magnetometerData.clear();
    _barometerData.clear();
  }

  Map<String, double> calculateAverageTriplet(List<List<double>> data) {
    if (data.isEmpty) return {'x': 0, 'y': 0, 'z': 0};
    final sum = List.filled(3, 0.0);
    for (var triplet in data) {
      for (int i = 0; i < 3; i++) {
        sum[i] += triplet[i];
      }
    }
    return {
      'x': sum[0] / data.length,
      'y': sum[1] / data.length,
      'z': sum[2] / data.length,
    };
  }

  double calculateAverageSingle(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  Map<String, dynamic> getAllAverages() {
    return {
      SensorType.accelerometer.displayName: calculateAverageTriplet(
        _accelerometerData,
      ),
      SensorType.gyroscope.displayName: calculateAverageTriplet(_gyroscopeData),
      SensorType.magnetometer.displayName: calculateAverageTriplet(
        _magnetometerData,
      ),
      SensorType.barometer.displayName: calculateAverageSingle(_barometerData),
    };
  }
}
