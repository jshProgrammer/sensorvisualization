import 'dart:ui';

class ChartConfigurationModel {
  final Color borderColor;
  final bool showGrid;
  final int scrollingSeconds;
  final String selectedTimeFormat;
  final double baselineX;
  final bool autoFollowLatestData;

  ChartConfigurationModel({
    required this.borderColor,
    required this.showGrid,
    required this.scrollingSeconds,
    required this.selectedTimeFormat,
    required this.baselineX,
    required this.autoFollowLatestData,
  });

  ChartConfigurationModel copyWith({
    Color? borderColor,
    bool? showGrid,
    int? scrollingSeconds,
    String? selectedTimeFormat,
    double? baselineX,
    bool? autoFollowLatestData,
  }) {
    return ChartConfigurationModel(
      borderColor: borderColor ?? this.borderColor,
      showGrid: showGrid ?? this.showGrid,
      scrollingSeconds: scrollingSeconds ?? this.scrollingSeconds,
      selectedTimeFormat: selectedTimeFormat ?? this.selectedTimeFormat,
      baselineX: baselineX ?? this.baselineX,
      autoFollowLatestData: autoFollowLatestData ?? this.autoFollowLatestData,
    );
  }
}
