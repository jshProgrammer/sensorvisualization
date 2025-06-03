import 'package:flutter/material.dart';
import 'package:sensorvisualization/controller/measurement/NullMeasurementController.dart';
import 'package:sensorvisualization/controller/measurement/SensorMeasurementController.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';
import 'package:sensorvisualization/presentation/measurement/SensorMeasurementView.dart';

class StartNullMeasurementView extends StatefulWidget {
  final SensorClient connection;

  const StartNullMeasurementView({Key? key, required this.connection})
    : super(key: key);

  @override
  State<StartNullMeasurementView> createState() =>
      _StartNullMeasurementViewState();
}

class _StartNullMeasurementViewState extends State<StartNullMeasurementView> {
  late NullMeasurementController _controller;
  late TextEditingController _delayController;

  @override
  void initState() {
    super.initState();
    _controller = NullMeasurementController(
      connection: widget.connection,
      onNullMeasurementComplete:
          () => {
            if (mounted)
              {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SensorMeasurementView(
                          connection: _controller.connection,
                        ),
                  ),
                ),
              },
          },
    );
    _controller.addListener(_onControllerUpdate);

    _delayController = TextEditingController();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nullmessung'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openDurationSettings,
            tooltip: 'Messzeit einstellen',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  _controller.isStartButtonPressedActive()
                      ? null
                      : () => {_controller.userStartButtonPressed()},
              child: Text(_controller.getTextOfUserButton()),
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  child: CircularProgressIndicator(
                    value: _controller.progress,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),

                Text(
                  '${_controller.measurementState.remainingSeconds}',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDurationSettings() {
    int selectedDuration =
        _controller.measurementState.measurementDuration ?? 10;
    String localDelayText = _controller.delayText;
    bool localActiveDelay = _controller.isDelayEnabled;
    int localSelectedTimeUnit = _controller.selectedTimeUnit;

    _delayController.text = localDelayText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Messzeit einstellen'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dauer der Nullmessung in Sekunden:'),
                  Slider(
                    value: selectedDuration.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 25,
                    label: selectedDuration.toString(),
                    onChanged: (double value) {
                      setState(() {
                        selectedDuration = value.round();
                      });
                    },
                  ),
                  Text('$selectedDuration Sekunden'),

                  SizedBox(height: 10),

                  Divider(),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Text("Selbstauslöser"),
                      Spacer(),
                      Switch(
                        value: localActiveDelay,
                        activeColor: Colors.blue,
                        onChanged: (bool value) {
                          setState(() {
                            localActiveDelay = value;
                          });
                        },
                      ),
                    ],
                  ),

                  if (localActiveDelay)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _delayController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: false,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value:
                                  TimeUnitChoice.fromValue(
                                    localSelectedTimeUnit,
                                  ).asString(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  localSelectedTimeUnit =
                                      TimeUnitChoice.values
                                          .firstWhere(
                                            (e) => e.asString() == newValue,
                                          )
                                          .value;
                                });
                              },
                              items:
                                  TimeUnitChoice.values
                                      .map((e) => e.asString())
                                      .toList()
                                      .map(
                                        (value) => DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () {
                _controller.updateMeasurementDuration(selectedDuration);
                _controller.setActiveDelay(localActiveDelay);
                _controller.setDelayText(_delayController.text);
                _controller.setSelectedTimeUnit(localSelectedTimeUnit);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }
}
