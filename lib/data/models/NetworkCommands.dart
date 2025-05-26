enum NetworkCommands {
  ConnectionRequest("ConnectionRequest"),
  ConnectionAccepted("ConnectionAccepted"),

  StartNullMeasurementOnDevice("StartNullMeasurementOnDevice"),
  StartNullMeasurementRemote("StartNullMeasurementRemote"),

  StopMeasurementOnDevice("StopMeasurementOnDevice"),
  StopMeasurementRemote("StopMeasurementRemote"),
  PauseMeasurementOnDevice("PauseMeasurementOnDevice"),
  PauseMeasurementRemote("PauseMeasurementRemote"),
  ResumeMeasurementOnDevice("ResumeMeasurementOnDevice"),
  ResumeMeasurementRemote("ResumeMeasurementRemote"),

  DelayedMeasurementOnDevice('DelayedMeasurementOnDevice'),
  DelayedMeasurementRemote("DelayedMeasurementRemote"),

  Alarm('Alarm'),
  AlarmStop('AlarmStop'),

  AverageValues('AverageValues');

  final String command;

  const NetworkCommands(this.command);

  @override
  String toString() => command;

  static NetworkCommands fromString(String value) {
    return NetworkCommands.values.firstWhere(
      (e) => e.command == value,
      orElse: () => throw ArgumentError('Invalid command: $value'),
    );
  }
}
