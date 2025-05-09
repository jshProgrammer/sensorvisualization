import 'package:intl/intl.dart';
import 'package:sensorvisualization/data/models/SensorOrientation.dart';
import 'package:sensorvisualization/data/models/SensorType.dart';
import 'package:sensorvisualization/data/services/GlobalStartTime.dart';

class SensorDataTransformation {
  static double transformSingleAbsoluteToRelativeValue(
    double absoluteValue,
    double nullMeasurement,
  ) {
    return absoluteValue - nullMeasurement;
  }

  static int transformDateTimeToSecondsSinceStart(DateTime dateTime) {
    return dateTime.difference(GlobalStartTime().startTime).inSeconds;
  }

  // transformation necessary due to restriction of fl_chart (only num values for x-axis)
  static double transformDateTimeToSecondsAsDouble(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch.toDouble() / 1000.0;
  }

  static String transformDateTimeToNatoFormat(DateTime dateTime) {
    DateTime utc = dateTime.toUtc();

    String day = DateFormat('dd').format(utc);
    String time = DateFormat('HHmm').format(utc);
    String zone = 'J';
    String month = DateFormat('MMM', 'en_US').format(utc).toLowerCase();
    String year = DateFormat('yy').format(utc);

    return '$day $time $zone $month $year';
  }

  static Map<SensorOrientation, double> transformAbsoluteToRelativeValues(
    Map<SensorOrientation, double> nullMeasurementValues,
    Map<String, dynamic> absoluteSensorValues,
    SensorType? sensorType,
  ) {
    Map<SensorOrientation, double> relativeSensorValues = {};
    // barometer is the only sensor without x,y,z orientation
    if (sensorType == null || sensorType != SensorType.barometer) {
      for (SensorOrientation sensorOrientation in nullMeasurementValues.keys) {
        relativeSensorValues[sensorOrientation] =
            transformSingleAbsoluteToRelativeValue(
              (absoluteSensorValues[sensorOrientation.displayName] is String)
                  ? double.tryParse(
                    absoluteSensorValues[sensorOrientation.displayName],
                  )
                  : absoluteSensorValues[sensorOrientation.displayName],
              nullMeasurementValues[sensorOrientation] ?? 0.0,
            );
      }
    } else {
      //TODO: barometer
    }
    return relativeSensorValues;
  }

  /*
  static Map<String, dynamic> returnRelativeSensorDataAsJson(
    Map<SensorOrientation, double> nullMeasurementValues,
    Map<String, dynamic> receivedJsonData,
    SensorType? sensorType,
  ) {
    Map<SensorOrientation, double> relativeSensorValues =
        SensorDataTransformation.transformAbsoluteToRelativeValues(
          nullMeasurementValues,
          receivedJsonData,
          sensorType,
        );

    return {
      'sensor': receivedJsonData['sensor'],
      'timestamp': receivedJsonData['timestamp'],
      'x': relativeSensorValues[SensorOrientation.x],
      'y': relativeSensorValues[SensorOrientation.y],
      'z': relativeSensorValues[SensorOrientation.z],
    };
  }*/

  static Map<String, dynamic> returnAbsoluteSensorDataAsJson(
    Map<String, dynamic> receivedJsonData,
  ) {
    double? _parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    if (receivedJsonData['sensor'] == SensorType.barometer.displayName) {
      return {
        'ip': receivedJsonData['ip'],
        'sensor':
            receivedJsonData['sensor'] is String
                ? SensorTypeExtension.fromString(receivedJsonData['sensor'])
                : receivedJsonData['sensor'],
        'timestamp':
            receivedJsonData['timestamp'] is String
                ? DateTime.parse(receivedJsonData['timestamp'])
                : receivedJsonData['timestamp'],
        'pressure': _parseToDouble(receivedJsonData['pressure']),
      };
    } else {
      return {
        'ip': receivedJsonData['ip'],
        'sensor':
            receivedJsonData['sensor'] is String
                ? SensorTypeExtension.fromString(receivedJsonData['sensor'])
                : receivedJsonData['sensor'],
        'timestamp':
            receivedJsonData['timestamp'] is String
                ? DateTime.parse(receivedJsonData['timestamp'])
                : receivedJsonData['timestamp'],
        'x': _parseToDouble(receivedJsonData[SensorOrientation.x.displayName]),
        'y': _parseToDouble(receivedJsonData[SensorOrientation.y.displayName]),
        'z': _parseToDouble(receivedJsonData[SensorOrientation.z.displayName]),
      };
    }
  }
}
