enum NetworkCommands {
  ConnectionRequest("ConnectionRequest"),
  ConnectionAccepted("ConnectionAccepted"),
  StartNullMeasurement("StartNullMeasurement"),
  StopMeasurement("StopMeasurement"),
  DelayedMeasurement('DelayedMeasurement'),
  Alarm('Alarm'),
  AverageValues('AverageValues');

  final String command;

  const NetworkCommands(this.command);

  @override
  String toString() => command;
}
