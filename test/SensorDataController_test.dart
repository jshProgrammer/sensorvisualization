import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tuple/tuple.dart';

import 'package:sensorvisualization/data/settingsModels/SensorOrientation.dart';
import 'package:sensorvisualization/data/settingsModels/SensorType.dart';
import 'package:sensorvisualization/data/settingsModels/MultiselectDialogItem.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/model/visualization/ChartConfigurationModel.dart';
import 'package:sensorvisualization/model/visualization/VisualizationSensorDataModel.dart';
import 'package:sensorvisualization/presentation/visualization/widgets/WarningLevelsSelection.dart';
import 'package:sensorvisualization/controller/visualization/SensorDataController.dart';

@GenerateMocks([SettingsProvider])
import 'SensorDataController_test.mocks.dart';

void main() {
  group('SensorDataController Tests', () {
    late SensorDataController controller;
    late VisualizationSensorDataModel dataModel;
    late ChartConfigurationModel configModel;
    late MockSettingsProvider settingsProvider;
    late TextEditingController timeController;
    late Map<String, Map<MultiSelectDialogItem, Color>> selectedColors;

    final testIpAddress = '192.168.1.100';
    final testSensorType = SensorType.accelerometer;
    final testOrientation = SensorOrientation.x;
    final testDataPoints = [
      FlSpot(10.0, 1.0),
      FlSpot(15.0, 2.0),
      FlSpot(25.0, 3.0),
      FlSpot(35.0, 2.5),
    ];

    setUp(() {
      settingsProvider = MockSettingsProvider();
      when(settingsProvider.scrollingSeconds).thenReturn(20);
      when(settingsProvider.showGrid).thenReturn(true);
      when(
        settingsProvider.selectedTimeChoice,
      ).thenReturn(TimeChoice.timestamp.value);

      timeController = TextEditingController();

      selectedColors = {};

      final dataPoints =
          <String, Map<Tuple2<SensorType, SensorOrientation>, List<FlSpot>>>{
            testIpAddress: {
              Tuple2(testSensorType, testOrientation): testDataPoints,
            },
          };

      final notes = <DateTime, String>{
        DateTime(2024, 1, 1, 12, 0, 0): 'Test Note 1',
        DateTime(2024, 1, 1, 12, 30, 0): 'Test Note 2',
      };

      final selectedSensors = <String, Set<MultiSelectDialogItem>>{
        testIpAddress: {
          MultiSelectDialogItem(
            sensorName: testSensorType,
            attribute: testOrientation,
            type: ItemType.data,
          ),
        },
      };

      dataModel = VisualizationSensorDataModel(
        dataPoints: dataPoints,
        notes: notes,
        selectedSensors: selectedSensors,
        warningRanges: {
          'green': [WarningRange(0.0, 1.0)],
          'yellow': [WarningRange(1.0, 2.0)],
          'red': [WarningRange(2.0, 3.0)],
        },
      );

      configModel = ChartConfigurationModel(
        borderColor: Colors.blue,
        showGrid: true,
        scrollingSeconds: 20,
        selectedTimeFormat: 'HH:mm:ss',
        baselineX: 30.0,
        autoFollowLatestData: true,
      );

      controller = SensorDataController(
        dataModel: dataModel,
        configModel: configModel,
        settingsProvider: settingsProvider,
        timeController: timeController,
        onTitlesDataText: (text) => Text(text),
        selectedColors: selectedColors,
      );
    });

    group('getFilteredDataPoints', () {
      test(
        'should return filtered data points within time bounds when autoFollowLatestData is true',
        () {
          when(settingsProvider.scrollingSeconds).thenReturn(20);

          final result = controller.getFilteredDataPoints(
            testIpAddress,
            testSensorType,
            testOrientation,
          );

          expect(result.length, equals(3)); // 15.0, 25.0, 35.0
          expect(result.first.x, equals(15.0));
          expect(result.last.x, equals(35.0));
        },
      );

      test(
        'should return filtered data points based on baselineX when autoFollowLatestData is false',
        () {
          final configModelFixed = configModel.copyWith(
            autoFollowLatestData: false,
          );
          final controllerFixed = SensorDataController(
            dataModel: dataModel,
            configModel: configModelFixed,
            settingsProvider: settingsProvider,
            timeController: timeController,
            onTitlesDataText: (text) => Text(text),
            selectedColors: selectedColors,
          );
          when(settingsProvider.scrollingSeconds).thenReturn(20);

          final result = controllerFixed.getFilteredDataPoints(
            testIpAddress,
            testSensorType,
            testOrientation,
          );

          expect(result.length, equals(3)); // 10.0, 15.0, 25.0
          expect(result.first.x, equals(10.0));
          expect(result.last.x, equals(25.0));
        },
      );

      test('should return empty list for non-existent sensor', () {
        final result = controller.getFilteredDataPoints(
          'non-existent-ip',
          testSensorType,
          testOrientation,
        );

        expect(result, isEmpty);
      });
    });

    group('buildChartData', () {
      test('should build complete chart data with all components', () {
        final context = MockBuildContext();

        final result = controller.buildChartData(context);

        expect(result, isA<LineChartData>());
        expect(result.lineBarsData.length, equals(1));
        expect(result.gridData.show, equals(true));
        expect(result.titlesData.show, equals(true));
        expect(result.borderData.show, equals(true));
        expect(result.extraLinesData.verticalLines.length, equals(2));
        expect(
          result.rangeAnnotations.horizontalRangeAnnotations.length,
          equals(3),
        );
      });

      test('should calculate correct axis bounds', () {
        final context = MockBuildContext();
        when(settingsProvider.scrollingSeconds).thenReturn(20);

        final result = controller.buildChartData(context);

        expect(result.maxX, equals(35.0));
        expect(result.minX, equals(15.0)); // 35.0 - 20
        expect(result.minY, equals(2.0));
        expect(result.maxY, equals(3.0));
      });
    });

    group('getSensorColor', () {
      test('should return correct colors for sensor orientations', () {
        expect(
          SensorDataController.getSensorColor(SensorOrientation.x.displayName),
          equals(Colors.green),
        );
        expect(
          SensorDataController.getSensorColor(SensorOrientation.y.displayName),
          equals(Colors.red),
        );
        expect(
          SensorDataController.getSensorColor(SensorOrientation.z.displayName),
          equals(Colors.blue),
        );
      });

      test('should return grey for unknown orientation', () {
        final result = SensorDataController.getSensorColor('unknown');

        expect(result, equals(Colors.grey));
      });
    });

    group('updateWarningRanges', () {
      test('should update warning ranges in data model', () {
        final newRanges = [WarningRange(0.5, 1.5), WarningRange(2.5, 3.5)];

        controller.updateWarningRanges('green', newRanges);

        expect(dataModel.warningRanges['green'], equals(newRanges));
      });
    });

    group('addNote', () {
      test('should add note to data model', () {
        final timestamp = DateTime(2024, 1, 1, 15, 0, 0);
        const noteText = 'New test note';

        controller.addNote(timestamp, noteText);

        expect(dataModel.notes[timestamp], equals(noteText));
        expect(dataModel.notes.length, equals(3));
      });
    });

    group('toggleSensorSelection', () {
      test('should toggle sensor selection in data model', () {
        final newSensor = MultiSelectDialogItem(
          sensorName: SensorType.gyroscope,
          attribute: SensorOrientation.y,
          type: ItemType.data,
        );

        controller.toggleSensorSelection(testIpAddress, newSensor);

        expect(dataModel.isSensorSelected(testIpAddress, newSensor), isTrue);
        expect(dataModel.selectedSensors[testIpAddress]?.length, equals(2));
      });

      test('should deselect already selected sensor', () {
        final existingSensor = MultiSelectDialogItem(
          sensorName: testSensorType,
          attribute: testOrientation,
          type: ItemType.data,
        );

        controller.toggleSensorSelection(testIpAddress, existingSensor);

        expect(
          dataModel.isSensorSelected(testIpAddress, existingSensor),
          isFalse,
        );
        expect(dataModel.selectedSensors[testIpAddress]?.length, equals(0));
      });
    });

    group('Edge Cases', () {
      test('should handle empty data points', () {
        final emptyDataModel = VisualizationSensorDataModel(
          dataPoints: {},
          notes: {},
          selectedSensors: {},
        );
        final emptyController = SensorDataController(
          dataModel: emptyDataModel,
          configModel: configModel,
          settingsProvider: settingsProvider,
          timeController: timeController,
          onTitlesDataText: (text) => Text(text),
          selectedColors: selectedColors,
        );

        final result = emptyController.getFilteredDataPoints(
          testIpAddress,
          testSensorType,
          testOrientation,
        );

        expect(result, isEmpty);
      });

      test('should handle data points outside time bounds', () {
        when(settingsProvider.scrollingSeconds).thenReturn(5);

        final result = controller.getFilteredDataPoints(
          testIpAddress,
          testSensorType,
          testOrientation,
        );

        expect(result.length, equals(1));
        expect(result.first.x, equals(35.0));
      });

      test('should handle multiple devices and sensors', () {
        final multiDeviceModel = VisualizationSensorDataModel(
          dataPoints: {
            '192.168.1.100': {
              Tuple2(SensorType.accelerometer, SensorOrientation.x): [
                FlSpot(10, 1),
              ],
              Tuple2(SensorType.accelerometer, SensorOrientation.y): [
                FlSpot(15, 2),
              ],
            },
            '192.168.1.101': {
              Tuple2(SensorType.gyroscope, SensorOrientation.z): [
                FlSpot(20, 3),
              ],
            },
          },
          notes: {},
          selectedSensors: {
            '192.168.1.100': {
              MultiSelectDialogItem(
                sensorName: SensorType.accelerometer,
                attribute: SensorOrientation.x,
                type: ItemType.data,
              ),
              MultiSelectDialogItem(
                sensorName: SensorType.accelerometer,
                attribute: SensorOrientation.y,
                type: ItemType.data,
              ),
            },
            '192.168.1.101': {
              MultiSelectDialogItem(
                sensorName: SensorType.gyroscope,
                attribute: SensorOrientation.z,
                type: ItemType.data,
              ),
            },
          },
        );

        final multiController = SensorDataController(
          dataModel: multiDeviceModel,
          configModel: configModel,
          settingsProvider: settingsProvider,
          timeController: timeController,
          onTitlesDataText: (text) => Text(text),
          selectedColors: selectedColors,
        );

        final context = MockBuildContext();
        final result = multiController.buildChartData(context);

        expect(result.lineBarsData.length, equals(3));
      });
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
