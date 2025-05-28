import 'package:fl_chart/fl_chart.dart';
import '../../presentation/widgets/WarningLevelsSelection.dart';

class DangerDetector {
  final List<DateTime> dangerTimestamps;
  int _currentIndex = -1;

  DangerDetector(this.dangerTimestamps) {
    reset();
  }

  static List<DateTime> findDangerTimestamps({
    required List<FlSpot> points,
    required List<DateTime> timestamps,
    required Map<String, List<WarningRange>> warningLevels,
    Duration minSeparation = const Duration(seconds: 2),
  }) {
    final yellow = warningLevels['yellow'] ?? [];
    final red = warningLevels['red'] ?? [];

    bool inDanger(double y) {
      for (final range in [...yellow, ...red]) {
        if (y >= range.lower && y <= range.upper) return true;
      }
      return false;
    }

    final List<DateTime> result = [];
    DateTime? lastDanger;

    for (int i = 0; i < points.length; i++) {
      if (inDanger(points[i].y)) {
        final ts = truncateToSeconds(timestamps[i]);
        if (lastDanger == null ||
            ts.difference(lastDanger).abs() >= minSeparation) {
          result.add(ts);
          lastDanger = ts;
        }
      }
    }

    return result;
  }

  DateTime? get current {
    if (_currentIndex >= 0 && _currentIndex < dangerTimestamps.length) {
      return dangerTimestamps[_currentIndex];
    }
    return null;
  }

  void reset() {
    _currentIndex = dangerTimestamps.isNotEmpty ? 0 : -1;
  }

  static truncateToSeconds(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }
}
