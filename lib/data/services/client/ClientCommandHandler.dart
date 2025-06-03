import 'package:sensorvisualization/data/settingsModels/NetworkCommands.dart';

class ClientCommandHandler {
  Function(String)? onAlarmReceived;
  Function()? onAlarmStopReceived;
  Function(int)? onStartNullMeasurementReceived;
  Function(int)? onDelayedMeasurementReceived;
  Function()? onMeasurementPaused;
  Function()? onMeasurementResumed;
  Function()? onMeasurementStopped;

  void handleCommand(NetworkCommands command, Map<String, dynamic> data) {
    switch (command) {
      case NetworkCommands.Alarm:
        if (onAlarmReceived != null) {
          onAlarmReceived!(data['message']);
        }
        break;

      case NetworkCommands.AlarmStop:
        if (onAlarmStopReceived != null) {
          onAlarmStopReceived!();
        }
        break;

      case NetworkCommands.StartNullMeasurementRemote:
        if (onStartNullMeasurementReceived != null) {
          onStartNullMeasurementReceived!(data['duration']);
        }
        break;

      case NetworkCommands.DelayedMeasurementRemote:
        if (onDelayedMeasurementReceived != null) {
          onDelayedMeasurementReceived!(data['duration']);
        }
        break;

      case NetworkCommands.PauseMeasurementRemote:
        if (onMeasurementPaused != null) {
          onMeasurementPaused!();
        }
        break;

      case NetworkCommands.ResumeMeasurementRemote:
        if (onMeasurementResumed != null) {
          onMeasurementResumed!();
        }
        break;

      case NetworkCommands.StopMeasurementRemote:
        if (onMeasurementStopped != null) {
          onMeasurementStopped!();
        }
        break;

      default:
        throw Exception("NetworkCommand not available");
    }
  }
}
