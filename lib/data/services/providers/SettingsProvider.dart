import 'package:flutter/foundation.dart';

class SettingsProvider with ChangeNotifier {
  static int DEFAULT_SCROLLING_SECONDS = 20;
  int _scrollingSeconds = DEFAULT_SCROLLING_SECONDS;
  int _selectedTimeChoice = TimeChoice.timestamp.value;
  int _selectedAbsRelData = AbsRelDataChoice.relative.value;

  int get scrollingSeconds => _scrollingSeconds;
  int get selectedTimeChoice => _selectedTimeChoice;
  int get selectedAbsRelData => _selectedAbsRelData;

  void setScrollingSeconds(int seconds) {
    _scrollingSeconds = seconds;
    notifyListeners();
  }

  void setTimeChoice(int choice) {
    _selectedTimeChoice = choice;
    notifyListeners();
  }

  void setDataMode(int mode) {
    _selectedAbsRelData = mode;
    notifyListeners();
  }
}

enum TimeChoice {
  timestamp(0),
  relativeToStart(1);

  final int value;
  const TimeChoice(this.value);

  static TimeChoice fromValue(int value) {
    return TimeChoice.values.firstWhere(
      (choice) => choice.value == value,
      orElse: () => TimeChoice.timestamp,
    );
  }
}

enum AbsRelDataChoice {
  relative(0),
  absolute(1);

  final int value;
  const AbsRelDataChoice(this.value);

  static AbsRelDataChoice fromValue(int value) {
    return AbsRelDataChoice.values.firstWhere(
      (choice) => choice.value == value,
      orElse: () => AbsRelDataChoice.absolute,
    );
  }
}
