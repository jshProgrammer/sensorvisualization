import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorvisualization/data/settingsModels/ConnectionDisplayState.dart';
import 'package:sensorvisualization/data/services/providers/ConnectionProvider.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';

class ConnectedDevicesDialog extends StatefulWidget {
  const ConnectedDevicesDialog({super.key});

  @override
  State<ConnectedDevicesDialog> createState() => _ConnectedDevicesDialogState();
}

class _ConnectedDevicesDialogState extends State<ConnectedDevicesDialog> {
  Timer? _dialogTimer;

  @override
  void initState() {
    super.initState();

    _dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _dialogTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (context, provider, _) {
        return StatefulBuilder(
          builder: (context, setState) {
            final connectedDevices = provider.connectedDevices;

            return AlertDialog(
              title: Text("Verbundene Geräte"),
              content:
                  connectedDevices.isEmpty
                      ? Text("Keine Geräte verbunden")
                      : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              connectedDevices.entries
                                  .map(
                                    (entry) =>
                                        _buildDeviceListTile(provider, entry),
                                  )
                                  .toList(),
                        ),
                      ),
              actions: [
                TextButton(
                  child: Text('Schließen'),
                  onPressed: () {
                    _dialogTimer?.cancel();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeviceListTile(
    ConnectionProvider provider,
    MapEntry<String, String> device,
  ) {
    final state = provider.getCurrentConnectionState(device.key);
    int? remainingSeconds = provider.getRemainingConnectionDurationInSec(
      device.key,
    );

    return ListTile(
      title: Text(
        device.value,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDeviceInfo(
            state,
            device.key,
            remainingSeconds,
            provider.batteryLevels[device.key],
          ),
          _buildPopupMenu(provider, device.key, state),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(
    ConnectionDisplayState state,
    String deviceKey,
    int? remainingSeconds,
    int? batteryLevel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: state.iconColor, size: 12),
            SizedBox(width: 10),
            Text(state.displayName),
            if (state == ConnectionDisplayState.paused)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.pause_circle_outline,
                  size: 16,
                  color: Colors.purple,
                ),
              ),
            if (state == ConnectionDisplayState.nullMeasurement ||
                state == ConnectionDisplayState.delayedMeasurement)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  remainingSeconds != null && remainingSeconds! >= 0
                      ? "Noch $remainingSeconds s"
                      : "",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
        SizedBox(height: 3),
        Text(deviceKey),
        SizedBox(height: 3),
        Row(
          children: [
            _buildBatteryIcon(batteryLevel),
            SizedBox(width: 10),
            Text(batteryLevel == null ? "unbekannt" : "$batteryLevel%"),
          ],
        ),
      ],
    );
  }

  Icon _buildBatteryIcon(int? batteryLevel) {
    if (batteryLevel == null) return Icon(Icons.battery_unknown);
    final rounded = (batteryLevel! / 10).floor();

    IconData icon;
    Color color;

    switch (rounded) {
      case 10:
      case 9:
        icon = Icons.battery_full;
        color = Colors.green;
        break;
      case 8:
      case 7:
        icon = Icons.battery_6_bar;
        color = Colors.green;
        break;
      case 6:
        icon = Icons.battery_5_bar;
        color = Colors.lightGreen;
        break;
      case 5:
      case 4:
        icon = Icons.battery_4_bar;
        color = Colors.amber;
        break;
      case 3:
        icon = Icons.battery_3_bar;
        color = Colors.orange;
        break;
      case 2:
        icon = Icons.battery_2_bar;
        color = Colors.deepOrange;
        break;
      case 1:
        icon = Icons.battery_1_bar;
        color = Colors.red;
        break;
      default:
        icon = Icons.battery_0_bar;
        color = Colors.red;
        break;
    }

    return Icon(icon, color: color);
  }

  Widget _buildPopupMenu(
    ConnectionProvider provider,
    String deviceKey,
    ConnectionDisplayState state,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected:
          (value) => _handleMenuAction(provider, deviceKey, state, value),
      itemBuilder: (_) => _buildMenuItems(state),
    );
  }

  void _handleMenuAction(
    ConnectionProvider provider,
    String deviceKey,
    ConnectionDisplayState state,
    String action,
  ) {
    switch (action) {
      case 'nullMeasurement':
        _showDurationInputDialog(
          context,
          'Nullmessung Dauer',
          'Geben Sie die Dauer in Sekunden ein:',
          (seconds) =>
              provider.sendStartNullMeasurementToClient(deviceKey, seconds),
        );
        break;
      case 'delayedMeasurement':
        _showDurationInputDialog(
          context,
          'Selbstauslöser Dauer',
          'Geben Sie die Verzögerung in Sekunden ein:',
          (seconds) =>
              provider.sendStartDelayedMeasurementToClient(deviceKey, seconds),
        );
        break;

      case 'pauseResumeMeasurement':
        state == ConnectionDisplayState.paused
            ? provider.sendResumeMeasurementToClient(deviceKey)
            : provider.sendPauseMeasurementToClient(deviceKey);
        break;

      case 'stopMeasurement':
        _showStopConfirmationDialog(provider, deviceKey);
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(ConnectionDisplayState state) {
    return [
      _buildMenuItem(
        value: 'nullMeasurement',
        icon: Icons.play_arrow,
        text: 'Nullmessung starten',
        enabled: state == ConnectionDisplayState.connected,
      ),
      _buildMenuItem(
        value: 'delayedMeasurement',
        icon: Icons.timer,
        text: 'Selbstauslöser starten',
        enabled: state == ConnectionDisplayState.connected,
      ),

      _buildPauseResumeMenuItem(state),

      _buildMenuItem(
        value: 'stopMeasurement',
        icon: Icons.stop,
        text: 'Messung stoppen',
        enabled: _canStopOrPause(state),
      ),
    ];
  }

  PopupMenuItem<String> _buildPauseResumeMenuItem(
    ConnectionDisplayState state,
  ) {
    final isPaused = state == ConnectionDisplayState.paused;
    final canPauseResume = _canStopOrPause(state);

    return PopupMenuItem<String>(
      value: 'pauseResumeMeasurement',
      enabled: canPauseResume,
      child: Row(
        children: [
          Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: _getItemColor(canPauseResume),
          ),
          const SizedBox(width: 8),
          Text(
            isPaused ? "Messung fortsetzen" : "Messung pausieren",
            style: TextStyle(color: _getItemColor(canPauseResume)),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required bool enabled,
  }) {
    return PopupMenuItem<String>(
      value: value,
      enabled: enabled,
      child: Row(
        children: [
          Icon(icon, color: _getItemColor(enabled)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: _getItemColor(enabled))),
        ],
      ),
    );
  }

  Color _getItemColor(bool enabled) {
    return enabled ? Colors.black : Colors.grey;
  }

  bool _canStopOrPause(ConnectionDisplayState state) {
    return state == ConnectionDisplayState.sending ||
        state == ConnectionDisplayState.paused;
  }

  Future<void> _showStopConfirmationDialog(
    ConnectionProvider provider,
    String deviceKey,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Messung stoppen'),
          content: const Text(
            'Sind Sie sicher, dass Sie die Messung stoppen möchten? '
            'Die Netzwerkverbindung wird unwiderruflich getrennt. Alle bisher empfangenen Daten sind gespeichert.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Stoppen'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      provider.sendStopMeasurementToClient(deviceKey);
    }
  }

  Future<void> _showDurationInputDialog(
    BuildContext context,
    String title,
    String label,
    Function(int) onConfirm,
  ) async {
    final TextEditingController controller = TextEditingController(text: '10');
    int selectedTimeUnit = TimeUnitChoice.seconds.value;

    final int? seconds = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value:
                              TimeUnitChoice.fromValue(
                                selectedTimeUnit,
                              ).asString(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
                              selectedTimeUnit =
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
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  int value = int.tryParse(controller.text) ?? 10;
                  if (selectedTimeUnit == TimeUnitChoice.minutes.value) {
                    value *= 60;
                  } else if (selectedTimeUnit == TimeUnitChoice.hours.value) {
                    value *= 3600;
                  }

                  Navigator.pop(context, value);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );

    if (seconds != null) {
      onConfirm(seconds);
    }

    controller.dispose();
  }
}
