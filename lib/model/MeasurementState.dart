class MeasurementState {
  final bool isPaused;
  final bool isNullMeasurement;
  final bool isDelayActive;
  final int? measurementDuration;
  final int? remainingSeconds;
  final int? delayRemainingSeconds;

  const MeasurementState({
    this.isPaused = false,
    this.isNullMeasurement = false,
    this.isDelayActive = false,
    this.measurementDuration,
    this.remainingSeconds,
    this.delayRemainingSeconds,
  });

  MeasurementState copyWith({
    bool? isPaused,
    bool? isNullMeasurement,
    bool? isDelayActive,
    int? measurementDuration,
    int? remainingSeconds,
    int? delayRemainingSeconds,
  }) {
    return MeasurementState(
      isPaused: isPaused ?? this.isPaused,
      isNullMeasurement: isNullMeasurement ?? this.isNullMeasurement,
      isDelayActive: isDelayActive ?? this.isDelayActive,
      measurementDuration: measurementDuration ?? this.measurementDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      delayRemainingSeconds:
          delayRemainingSeconds ?? this.delayRemainingSeconds,
    );
  }
}
