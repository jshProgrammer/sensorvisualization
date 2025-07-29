import 'package:fl_chart/fl_chart.dart';
import 'package:sensorvisualization/data/services/SensorDataTransformation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';

//NEU NEU NEU
//Sensor Data kapselt die Parameter der Add Data Point Methode der ChartConfig Klasse
class SensorDataDBTransfomration {
  final String ip;
  //final DateTime date;
  final SensorType sensorType;
  final SensorOrientation orientation;
  final FlSpot spot;
  //final double value;

  SensorDataDBTransfomration({
    required this.ip,
    //required this.date,
    required this.sensorType,
    required this.orientation,
    required this.spot,
    //required this.value,
  });

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is DateTime) {
      return dateValue;
    } else {
      throw Exception('Unbekannter DateTime-Typ: ${dateValue.runtimeType}');
    }
  }

  // Factory für alle Messwerte aus einer Zeile
  static List<SensorDataDBTransfomration> fromDbRow(Map<String, dynamic> json) {
    print('json contents: $json');
    print('date type: ${json['date'].runtimeType}');
    print('date value: ${json['date']}');
    final ip = json['ip'] as String;
    final date = _parseDateTime(json['date']);

    //final date = DateTime.parse(json['date']! as String);
    final List<SensorDataDBTransfomration> result = [];

    // Mapping für alle Spalten
    final mapping = [
      ['acceleration_x', SensorType.accelerometer, SensorOrientation.x],
      ['acceleration_y', SensorType.accelerometer, SensorOrientation.y],
      ['acceleration_z', SensorType.accelerometer, SensorOrientation.z],
      ['gyroskopX', SensorType.gyroscope, SensorOrientation.x],
      ['gyroskopY', SensorType.gyroscope, SensorOrientation.y],
      ['gyroskopZ', SensorType.gyroscope, SensorOrientation.z],
      ['magnetometerX', SensorType.magnetometer, SensorOrientation.x],
      ['magnetometerY', SensorType.magnetometer, SensorOrientation.y],
      ['magnetometerZ', SensorType.magnetometer, SensorOrientation.z],
      ['barometer', SensorType.barometer, SensorOrientation.pressure],
    ];

    for (var entry in mapping) {
      final key = entry[0];
      final type = entry[1] as SensorType;
      final orientation = entry[2] as SensorOrientation;
      final value = json[key];
      if (value != null) {
        result.add(
          SensorDataDBTransfomration(
            ip: ip,
            //date: date,
            sensorType: type,
            orientation: orientation,
            spot: FlSpot(
              SensorDataTransformation.transformDateTimeToSecondsAsDouble(date),
              value as double,
            ),
            //value: value as double,
          ),
        );
      }
    }
    return result;
  }
}

