import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/controller/measurement/AlarmController.dart';
import 'package:sensorvisualization/data/services/client/SensorClient.dart';

class AlarmView extends StatelessWidget {
  final SensorClient connection;
  final Function? onAlarmStopReceived;

  const AlarmView({
    Key? key,
    required this.connection,
    this.onAlarmStopReceived,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => AlarmController(
            connection: connection,
            onAlarmStopReceived:
                () => {
                  if (Navigator.canPop(context)) {Navigator.pop(context)},
                },
          ),
      child: Consumer<AlarmController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.red,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 100, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'ALARM!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.stopAlarmNotification();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      'Alarm abbrechen',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
