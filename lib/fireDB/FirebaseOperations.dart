import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: Noch einstellungen in ChartHomeScreen ab Zeile 90 ca.

class Firebasesync {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Databaseoperations _databaseOperations;

  final List<String> _tablesToSync = ['Note', 'Sensor', 'Identification'];

  Timer? _syncTimer;
  int syncInterval = 10;
  bool isSyncing = false;

  Future<void> initializeApp(AppDatabase localDB) async {
    _databaseOperations = Databaseoperations(localDB);
    try {
      await loadSyncSettings();

      await deleteOldTablesInFirestore();

      await syncDatabaseWithCloud(localDB);

      _startSyncTimer(localDB);
    } catch (e) {
      print("Fehler bei der App-Initialisierung: $e");
    }
  }

  void _startSyncTimer(AppDatabase localDB) {
    _syncTimer?.cancel();

    _syncTimer = Timer.periodic(Duration(minutes: syncInterval), (timer) async {
      print("Periodische Synchronisierung wird ausgeführt...");
      await syncDatabaseWithCloud(localDB);
    });
  }

  void stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> updateSyncSettings(
    int newInterval,
    bool enableSync,
    AppDatabase localDB,
  ) async {
    syncInterval = newInterval;
    isSyncing = enableSync;

    if (isSyncing) {
      _startSyncTimer(localDB);
    } else {
      stopSyncTimer();
    }
  }

  Future<void> saveSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sync_interval', syncInterval);
    await prefs.setBool('is_syncing', isSyncing);
  }

  Future<void> loadSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    syncInterval = prefs.getInt('sync_interval') ?? 10; // Standard: 10 Minuten
    isSyncing = prefs.getBool('is_syncing') ?? true; // Standard: aktiviert
  }

  Future<void> syncDatabaseWithCloud(AppDatabase localDB) async {
    if (!await isInternetAvailable()) {
      print("Keine Internetverbindung. Synchronisation übersprungen.");
      return;
    }

    for (var tableName in _tablesToSync) {
      try {
        final localData = await _databaseOperations.readTableData(tableName);

        if (localData.isNotEmpty) {
          final batch = _firestore.batch();

          final syncId =
              '${tableName}_${DateTime.now().millisecondsSinceEpoch}';
          final metadataRef = _firestore.collection('local_data').doc(syncId);

          batch.set(metadataRef, {
            'name': tableName,
            'count': localData.length,
            'last_updated': DateTime.now().toIso8601String(),
          });

          for (var i = 0; i < localData.length; i++) {
            final docRef = metadataRef.collection('entries').doc('entry_$i');

            batch.set(docRef, {
              'data': localData[i],
              'created_at': DateTime.now().toIso8601String(),
            });
          }

          await batch.commit();

          await _databaseOperations.updateMetadata(tableName, DateTime.now());

          print(
            "Tabelle $tableName synchronisiert mit ${localData.length} Einträgen.",
          );
        } else {
          print(
            "Keine Daten in Tabelle $tableName. Synchronisation übersprungen.",
          );
        }
      } catch (e) {
        print("Fehler bei der Synchronisation von Tabelle $tableName: $e");
      }
    }
  }

  //Noch bei start der App aufrufen TODO
  Future<void> deleteOldTablesInFirestore() async {
    if (!await isInternetAvailable()) {
      print("Keine Internetverbindung. Löschung alter Tabellen übersprungen.");
      return;
    }

    final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));

    try {
      final cloudData = await _firestore.collection('local_data').get();

      for (var table in cloudData.docs) {
        final data = table.data();

        if (data.containsKey('last_updated')) {
          final lastUpdated = DateTime.parse(data['last_updated']);

          if (lastUpdated.isBefore(twoWeeksAgo)) {
            try {
              final entriesSnapshot =
                  await table.reference.collection('entries').get();
              final batch = _firestore.batch();

              for (var doc in entriesSnapshot.docs) {
                batch.delete(doc.reference);
              }

              await batch.commit();

              await table.reference.delete();

              final tableName = table.id.split('_').first;
              _databaseOperations.deleteMetadataEntry(tableName, lastUpdated);
              print(
                "Alte Tabelle in Firebase gelöscht: $tableName (ID: ${table.id})",
              );
            } catch (e) {
              print("Fehler beim Löschen der Tabelle ${data['name']}: $e");
            }
          }
        }
      }
    } catch (e) {
      print("Fehler beim Löschen alter Tabellen: $e");
    }
  }

  Future<bool> isInternetAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      return true;
    } catch (e) {
      print("Fehler bei der Internetverbindungsprüfung: $e");
      return false;
    }
  }

  Future<void> exportTableAsCSV(String tableName) async {
    if (!await isInternetAvailable()) {
      print("Keine Internetverbindung. Export übersprungen.");
      return;
    }

    try {
      final metadataDoc =
          await _firestore.collection('local_data').doc(tableName).get();

      if (!metadataDoc.exists) {
        print("Tabelle $tableName existiert nicht in Firebase.");
        return;
      }

      final entriesSnapshot =
          await metadataDoc.reference.collection('entries').get();

      if (entriesSnapshot.docs.isEmpty) {
        print("Keine Daten in Tabelle $tableName gefunden.");
        return;
      }

      final List<List<dynamic>> dataRows = [];

      final firstEntryData = entriesSnapshot.docs.first.data()['data'];
      if (firstEntryData is Map) {
        dataRows.add(firstEntryData.keys.toList());
      }

      for (var doc in entriesSnapshot.docs) {
        final entryData = doc.data()['data'];

        if (entryData is Map) {
          dataRows.add(entryData.values.toList());
        } else if (entryData is List) {
          dataRows.add(entryData);
        }
      }

      final csvData = const ListToCsvConverter().convert(dataRows);

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/$tableName-${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      print("Tabelle $tableName als CSV exportiert: $path");
    } catch (e) {
      print("Fehler beim Exportieren der Tabelle $tableName: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableTables() async {
    if (!await isInternetAvailable()) {
      print(
        "Keine Internetverbindung. Tabellen können nicht abgerufen werden.",
      );
      return [];
    }

    try {
      final metadata = await _firestore.collection('local_data').get();
      return metadata.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? doc.id,
          'last_updated': data['last_updated'] ?? '',
          'count': data['count'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print("Fehler beim Abrufen der verfügbaren Tabellen: $e");
      return [];
    }
  }

  Future<void> exportTableByNameAndDate(String tableName, DateTime date) async {
    if (!await isInternetAvailable()) {
      print("Keine Internetverbindung. Export übersprungen.");
      return;
    }

    final formattedDate = date.toIso8601String();

    try {
      final querySnapshot =
          await _firestore
              .collection('local_data')
              .where('name', isEqualTo: tableName)
              .where('last_updated', isEqualTo: formattedDate)
              .get();

      if (querySnapshot.docs.isEmpty) {
        print(
          "Keine Tabelle mit dem Namen $tableName und Datum $formattedDate gefunden.",
        );
        return;
      }

      for (var metadataDoc in querySnapshot.docs) {
        final entriesSnapshot =
            await metadataDoc.reference.collection('entries').get();

        if (entriesSnapshot.docs.isEmpty) {
          print("Keine Daten in Tabelle ${metadataDoc.id} gefunden.");
          continue;
        }

        final List<List<dynamic>> dataRows = [];

        final firstEntryData = entriesSnapshot.docs.first.data()['data'];
        if (firstEntryData is Map) {
          dataRows.add(firstEntryData.keys.toList());
        }

        for (var doc in entriesSnapshot.docs) {
          final entryData = doc.data()['data'];

          if (entryData is Map) {
            dataRows.add(entryData.values.toList());
          } else if (entryData is List) {
            dataRows.add(entryData);
          }
        }

        final csvData = const ListToCsvConverter().convert(dataRows);

        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${metadataDoc.id}-${date.millisecondsSinceEpoch}.csv';
        final file = File(path);
        await file.writeAsString(csvData);

        print("Tabelle ${metadataDoc.id} als CSV exportiert: $path");
      }
    } catch (e) {
      print("Fehler beim Exportieren der Tabelle $tableName: $e");
    }
  }
}
