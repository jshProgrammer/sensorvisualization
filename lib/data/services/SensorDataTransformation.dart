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

  static double transformDateTimeToSecondsAsDouble(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch.toDouble() /
        1000; // Convert milliseconds to seconds
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
  }

  static Map<String, dynamic> returnAbsoluteSensorDataAsJson(
    Map<String, dynamic> receivedJsonData,
    SensorType? sensorType,
  ) {
    return {
      'sensor': receivedJsonData['sensor'],
      //TODO: hier vlt problem!!!
      'timestamp': receivedJsonData['timestamp'],
      'x': receivedJsonData[SensorOrientation.x.displayName],
      'y': receivedJsonData[SensorOrientation.y.displayName],
      'z': receivedJsonData[SensorOrientation.z.displayName],
    };
  }
}
