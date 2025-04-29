class GlobalStartTime {
  static final GlobalStartTime _instance = GlobalStartTime._internal();

  late DateTime startTime;

  factory GlobalStartTime() {
    return _instance;
  }

  GlobalStartTime._internal();

  void initializeStartTime() {
    startTime = DateTime.now();
  }
}
