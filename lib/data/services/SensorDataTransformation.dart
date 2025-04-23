import 'package:sensorvisualization/data/models/SensorType.dart';

class SensorDataTransformation {
  static double _transformSingleAbsoluteToRelativeValue(
    double absoluteValue,
    double nullMeasurement,
  ) {
    return absoluteValue - nullMeasurement;
  }

  static Map<SensorOrientation, double> _transformAbsoluteToRelativeValues(
    Map<SensorOrientation, double> nullMeasurementValues,
    Map<String, dynamic> absoluteSensorValues,
    SensorType? sensorType,
  ) {
    Map<SensorOrientation, double> relativeSensorValues = {};
    // barometer is the only sensor without x,y,z orientation
    if (sensorType == null || sensorType != SensorType.barometer) {
      for (SensorOrientation sensorOrientation in nullMeasurementValues.keys) {
        relativeSensorValues[sensorOrientation] =
            _transformSingleAbsoluteToRelativeValue(
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
        SensorDataTransformation._transformAbsoluteToRelativeValues(
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

  //TODO: vlt noch returnAbsoluteValues-Methode?!
}
