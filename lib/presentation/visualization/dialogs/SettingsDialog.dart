import 'package:flutter/material.dart';
import 'package:sensorvisualization/controller/visualization/VisualizationHomeController.dart';
import 'package:sensorvisualization/data/services/providers/SettingsProvider.dart';

class SettingsDialog extends StatefulWidget {
  final VisualizationHomeController controller;

  const SettingsDialog({super.key, required this.controller});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String _originalSecondsValue;
  late int _originalTimeUnit;
  late int _originalTimeChoice;
  late int _originalAbsRelData;
  late bool _originalFirebaseSyncStatus;
  late int _originalSyncInterval;


  @override
  void initState() {
    super.initState();
    // Ursprüngliche Werte sichern
    _backupOriginalValues();
  }

  void _backupOriginalValues() {
    _originalSecondsValue = widget.controller.secondsController.text;
    _originalTimeUnit = widget.controller.selectedTimeUnit;
    _originalTimeChoice = widget.controller.selectedTimeChoice;
    _originalAbsRelData = widget.controller.selectedAbsRelData;
    _originalFirebaseSyncStatus = widget.controller.firebaseSync.isSyncing;
    _originalSyncInterval = widget.controller.firebaseSync.syncInterval;
  }

  void _restoreOriginalValues() {
    widget.controller.secondsController.text = _originalSecondsValue;
    widget.controller.updateTimeUnit(_originalTimeUnit);
    widget.controller.updateTimeChoice(_originalTimeChoice);
    widget.controller.updateAbsRelData(_originalAbsRelData);
    widget.controller.updateFirebaseSyncStatus(_originalFirebaseSyncStatus);
    widget.controller.updateSyncInterval(_originalSyncInterval);
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Einstellungen"),
      content: _buildSettingsContent(),
      actions: [
        TextButton(
          child: const Text('Schließen'),
          onPressed: () {
            _restoreOriginalValues();
            Navigator.of(context).pop();},
        ),
        TextButton(
          child: const Text('Speichern'),
          onPressed: () {
            widget.controller.saveSettings();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateDialog) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildScrollingSecondsSection(setStateDialog),
              const Divider(color: Colors.grey, thickness: 1, height: 20),
              _buildTimeSettingsSection(setStateDialog),
              const Divider(color: Colors.grey, thickness: 1, height: 20),
              _buildSensorDataSection(setStateDialog),
              const Divider(color: Colors.grey, thickness: 1, height: 20),
              _buildDatabaseSyncSection(setStateDialog),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollingSecondsSection(StateSetter setStateDialog) {
    return Column(
      children: [
        const Text("Mitlaufende Sekunden:"),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller.secondsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                decoration: InputDecoration(
                  labelText:
                  'default: ${SettingsProvider.DEFAULT_SCROLLING_SECONDS} s',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value:
              TimeUnitChoice.fromValue(
                widget.controller.selectedTimeUnit,
              ).asString(),
              onChanged: (String? newValue) {
                setStateDialog(() {
                  final unit = TimeUnitChoice.values.firstWhere(
                        (e) => e.asString() == newValue,
                  );
                  widget.controller.updateTimeUnit(unit.value);
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
  }

  Widget _buildTimeSettingsSection(StateSetter setStateDialog) {
    return Column(
      children: [
        const Text("Zeiteinstellung:"),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(
              value: TimeChoice.timestamp.value,
              label: Text('Systemzeit'),
            ),
            ButtonSegment<int>(
              value: TimeChoice.relativeToStart.value,
              label: Text('Zeit ab Start'),
            ),
            ButtonSegment<int>(
              value: TimeChoice.natoFormat.value,
              label: Text('NATO Format'),
            ),
          ],
          selected: {widget.controller.selectedTimeChoice},
          onSelectionChanged: (Set<int> newSelection) {
            setStateDialog(() {
              widget.controller.updateTimeChoice(newSelection.first);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSensorDataSection(StateSetter setStateDialog) {
    return Column(
      children: [
        const Text("Sensordaten:"),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(
              value: AbsRelDataChoice.relative.value,
              label: Text('Relative Werte'),
            ),
            ButtonSegment<int>(
              value: AbsRelDataChoice.absolute.value,
              label: Text('Absolute Werte'),
            ),
          ],
          selected: {widget.controller.selectedAbsRelData},
          onSelectionChanged: (Set<int> newSelection) {
            setStateDialog(() {
              widget.controller.updateAbsRelData(newSelection.first);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatabaseSyncSection(StateSetter setStateDialog) {
    return Column(
      children: [
        const Text("Datenbank Synchronisation:"),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: true, label: Text('Synchronisieren')),
            ButtonSegment<bool>(
              value: false,
              label: Text('Nicht synchronisieren'),
            ),
          ],
          selected: {widget.controller.firebaseSync.isSyncing},
          onSelectionChanged: (Set<bool> newSelection) {
            setStateDialog(() {
              widget.controller.updateFirebaseSyncStatus(newSelection.first);
            });
          },
        ),
        if (widget.controller.firebaseSync.isSyncing) ...[
          const SizedBox(height: 8),
          const Text("Synchronisationfrequenz (in Minuten):"),
          Slider(
            value: widget.controller.firebaseSync.syncInterval.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            label: '${widget.controller.firebaseSync.syncInterval} Minuten',
            onChanged: (double value) {
              setStateDialog(() {
                widget.controller.updateSyncInterval(value.round());
              });
            },
          ),
        ],
      ],
    );
  }
}
