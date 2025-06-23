class MeasurementState {
  final bool isPaused;
  final bool isNullMeasurement;
  final bool isDelayActive;
  final bool isDelayEnabled;
  final int? measurementDuration;
  final int? remainingSeconds;
  final int? delayRemainingSeconds;

  final double? measurementProgress;
  final double? delayProgress;

  const MeasurementState({
    this.isPaused = false,
    this.isNullMeasurement = false,
    this.isDelayActive = false,
    this.isDelayEnabled = false,
    this.measurementDuration,
    this.remainingSeconds,
    this.delayRemainingSeconds,
    this.measurementProgress,
    this.delayProgress,
  });

  MeasurementState copyWith({
    bool? isPaused,
    bool? isNullMeasurement,
    bool? isDelayActive,
    bool? isDelayEnabled,
    int? measurementDuration,
    int? remainingSeconds,
    int? delayRemainingSeconds,
    double? measurementProgress,
    double? delayProgress,
  }) {
    return MeasurementState(
      isPaused: isPaused ?? this.isPaused,
      isNullMeasurement: isNullMeasurement ?? this.isNullMeasurement,
      isDelayActive: isDelayActive ?? this.isDelayActive,
      isDelayEnabled: isDelayEnabled ?? this.isDelayEnabled,
      measurementDuration: measurementDuration ?? this.measurementDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      delayRemainingSeconds:
          delayRemainingSeconds ?? this.delayRemainingSeconds,
      measurementProgress: measurementProgress ?? this.measurementProgress,
      delayProgress: delayProgress ?? this.delayProgress,
    );
  }
}
