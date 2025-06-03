class AlarmState {
  final bool isPlaying;
  final String? alarmMessage;

  AlarmState({this.isPlaying = false, this.alarmMessage});

  AlarmState copyWith({bool? isPlaying, String? alarmMessage}) {
    return AlarmState(
      isPlaying: isPlaying ?? this.isPlaying,
      alarmMessage: alarmMessage ?? this.alarmMessage,
    );
  }
}
