enum NetworkCommands {
  ConnectionRequest("ConnectionRequest"),
  ConnectionAccepted("ConnectionAccepted"),
  StartNullMeasurement("StartNullMeasurement"),
  StopMeasurement("StopMeasurement"),
  PauseMeasureMent("PauseMeasurement"),
  ResumeMeasureMent("ResumeMeasurement"),
  DelayedMeasurement('DelayedMeasurement'),
  Alarm('Alarm'),
  AverageValues('AverageValues'),
  AlarmStop('AlarmStop');

  final String command;

  const NetworkCommands(this.command);

  @override
  String toString() => command;
}
