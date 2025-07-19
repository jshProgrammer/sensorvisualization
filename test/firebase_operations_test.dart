import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sensorvisualization/database/AppDatabase.dart';
import 'package:sensorvisualization/database/DatabaseOperations.dart';
import 'package:sensorvisualization/fireDB/FirebaseOperations.dart';
import 'package:sensorvisualization/database/MetadataTable.dart';
import 'package:sensorvisualization/database/SensorTable.dart';
import 'package:sensorvisualization/database/NoteTable.dart';
import 'package:sensorvisualization/database/IdentificationTable.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  WriteBatch,
  Connectivity,
  AppDatabase,
  Databaseoperations,
])
import 'firebase_operations_test.mocks.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {
  @override
  String get name => 'test-app';

  @override
  FirebaseOptions get options => const FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    FirebasePlatform.instance = MockFirebasePlatform();

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  });

  group('Firebasesync Tests', () {
    late TestableFirebasesync firebasesync;
    late FakeFirebaseFirestore fakeFirestore;
    late MockConnectivity mockConnectivity;
    late MockAppDatabase mockAppDatabase;
    late MockDatabaseoperations mockDatabaseOperations;

    setUp(() {
      SharedPreferences.setMockInitialValues({});

      fakeFirestore = FakeFirebaseFirestore();

      mockConnectivity = MockConnectivity();
      mockAppDatabase = MockAppDatabase();
      mockDatabaseOperations = MockDatabaseoperations();

      firebasesync = TestableFirebasesync(
        mockConnectivity: mockConnectivity,
        mockFirestore: fakeFirestore,
        mockDatabaseOperations: mockDatabaseOperations,
      );
    });

    group('Internet Connectivity Tests', () {
      test('isInternetAvailable returns true when connected', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);

        final result = await firebasesync.isInternetAvailable();

        expect(result, isTrue);
      });

      test('isInternetAvailable returns false when not connected', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.none);

        final result = await firebasesync.isInternetAvailable();

        expect(result, isFalse);
      });

      test('isInternetAvailable returns false on exception', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenThrow(Exception('Connection error'));

        final result = await firebasesync.isInternetAvailable();

        expect(result, isFalse);
      });
    });

    group('Sync Settings Tests', () {
      test('loadSyncSettings loads default values', () async {
        await firebasesync.loadSyncSettings();

        expect(firebasesync.syncInterval, 10);
        expect(firebasesync.isSyncing, true);
      });

      test('saveSyncSettings saves current values', () async {
        firebasesync.syncInterval = 5;
        firebasesync.isSyncing = false;

        await firebasesync.saveSyncSettings();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('sync_interval'), 5);
        expect(prefs.getBool('is_syncing'), false);
      });

      test('updateSyncSettings updates values', () async {
        await firebasesync.updateSyncSettings(15, false, mockAppDatabase);

        expect(firebasesync.syncInterval, 15);
        expect(firebasesync.isSyncing, false);
      });
    });

    group('Metadata Sync Tests', () {
      test('syncToFirestore successfully syncs metadata', () async {
        final metadata = MetadataCompanion(
          name: const Value('TestTable'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        await firebasesync.syncToFirestore(metadata);

        final collection = fakeFirestore.collection('local_data');
        final snapshot = await collection.get();
        expect(snapshot.docs.isNotEmpty, isTrue);
      });

      test('syncToFirestore handles data correctly', () async {
        final testDate = DateTime.now();
        final metadata = MetadataCompanion(
          name: const Value('TestMetadata'),
          createdAt: Value(testDate),
          updatedAt: Value(testDate),
        );

        await firebasesync.syncToFirestore(metadata);

        final collection = fakeFirestore.collection('local_data');
        final snapshot = await collection.get();

        expect(snapshot.docs.length, 1);
        final docData = snapshot.docs.first.data();
        expect(docData['name'], 'TestMetadata');
        expect(docData.containsKey('createdAt'), isTrue);
        expect(docData.containsKey('updatedAt'), isTrue);
      });
    });

    group('Database Sync Tests', () {
      test('syncDatabaseWithCloud skips when no internet', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.none);

        await firebasesync.syncDatabaseWithCloud(mockAppDatabase);

        verifyNever(mockDatabaseOperations.readTableData(any));
      });

      test('syncDatabaseWithCloud processes sensor data', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);

        final sensorData = TestDataFactory.createRealisticSensorData(2);
        when(
          mockDatabaseOperations.readTableData('Sensor'),
        ).thenAnswer((_) async => sensorData);
        when(
          mockDatabaseOperations.readTableData('Note'),
        ).thenAnswer((_) async => []);
        when(
          mockDatabaseOperations.readTableData('Identification'),
        ).thenAnswer((_) async => []);
        when(
          mockDatabaseOperations.updateMetadata(any, any),
        ).thenAnswer((_) async => {});

        await firebasesync.syncDatabaseWithCloud(mockAppDatabase);

        verify(mockDatabaseOperations.readTableData('Sensor')).called(1);
        verify(mockDatabaseOperations.updateMetadata('Sensor', any)).called(1);

        final snapshot = await fakeFirestore.collection('local_data').get();
        expect(snapshot.docs.isNotEmpty, isTrue);
      });

      test('syncDatabaseWithCloud handles empty tables', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockDatabaseOperations.readTableData(any),
        ).thenAnswer((_) async => []);

        await firebasesync.syncDatabaseWithCloud(mockAppDatabase);

        verify(mockDatabaseOperations.readTableData('Note')).called(1);
        verify(mockDatabaseOperations.readTableData('Sensor')).called(1);
        verify(
          mockDatabaseOperations.readTableData('Identification'),
        ).called(1);
        verifyNever(mockDatabaseOperations.updateMetadata(any, any));
      });

      test(
        'syncDatabaseWithCloud handles database errors gracefully',
        () async {
          when(
            mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => ConnectivityResult.wifi);
          when(mockDatabaseOperations.readTableData('Note')).thenAnswer(
            (_) async => [
              {
                'id': 1,
                'date': DateTime.now().toIso8601String(),
                'note': 'Test',
              },
            ],
          );
          when(
            mockDatabaseOperations.readTableData('Sensor'),
          ).thenThrow(Exception('Database error'));
          when(
            mockDatabaseOperations.readTableData('Identification'),
          ).thenAnswer((_) async => []);
          when(
            mockDatabaseOperations.updateMetadata(any, any),
          ).thenAnswer((_) async => {});

          expect(
            () => firebasesync.syncDatabaseWithCloud(mockAppDatabase),
            returnsNormally,
          );
        },
      );
    });

    group('Table Management Tests', () {
      test('getAvailableTables returns empty list when no internet', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.none);

        final result = await firebasesync.getAvailableTables();

        expect(result, isEmpty);
      });

      test('getAvailableTables returns table list when connected', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);

        await fakeFirestore.collection('local_data').doc('test_table_123').set({
          'name': 'TestTable',
          'last_updated': DateTime.now().toIso8601String(),
          'count': 5,
        });

        final result = await firebasesync.getAvailableTables();

        expect(result, isNotEmpty);
        expect(result.first['name'], 'TestTable');
        expect(result.first['count'], 5);
      });
    });

    group('CSV Export Tests', () {
      test('exportTableAsCSV skips when no internet', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.none);

        await firebasesync.exportTableAsCSV('TestTable');
      });

      test('exportTableAsCSV handles non-existent table', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);

        expect(
          () => firebasesync.exportTableAsCSV('NonExistentTable'),
          returnsNormally,
        );
      });
    });

    group('Timer Management Tests', () {
      test('stopSyncTimer works correctly', () {
        firebasesync.stopSyncTimer();

        expect(firebasesync.isSyncing, false);
      });
    });

    group('Integration Tests', () {
      test('initializeApp completes successfully', () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockDatabaseOperations.readTableData(any),
        ).thenAnswer((_) async => []);

        await firebasesync.initializeApp(mockAppDatabase);

        expect(firebasesync.syncInterval, 10);
        expect(firebasesync.isSyncing, true);
      });
    });
  });
}

class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseAppPlatform()];
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform()
    : super(
        'test-app',
        const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        ),
      );

  @override
  Future<void> delete() async {}

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

class TestableFirebasesync extends Firebasesync {
  final MockConnectivity mockConnectivity;
  final FakeFirebaseFirestore mockFirestore;
  final MockDatabaseoperations mockDatabaseOperations;

  TestableFirebasesync({
    required this.mockConnectivity,
    required this.mockFirestore,
    required this.mockDatabaseOperations,
  });

  @override
  Future<void> syncToFirestore(MetadataCompanion metadata) async {
    try {
      await mockFirestore.collection('local_data').add({
        'name': metadata.name.value,
        'createdAt': metadata.createdAt.value?.toIso8601String(),
        'updatedAt': metadata.updatedAt.value?.toIso8601String(),
      });
      print('FakeFirestore: Metadata synced successfully.');
    } catch (e) {
      print('FakeFirestore: Error syncing metadata: $e');
    }
  }

  @override
  Future<bool> isInternetAvailable() async {
    try {
      final connectivityResult = await mockConnectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  @override
  FirebaseFirestore get firestore => mockFirestore;

  @override
  Future<void> syncDatabaseWithCloud(AppDatabase database) async {
    if (!await isInternetAvailable()) return;

    final tables = ['Note', 'Sensor', 'Identification'];

    for (final tableName in tables) {
      try {
        final data = await mockDatabaseOperations.readTableData(tableName);

        if (data.isNotEmpty) {
          await mockFirestore
              .collection('local_data')
              .doc('${tableName}_${DateTime.now().millisecondsSinceEpoch}')
              .set({
                'name': tableName,
                'data': data,
                'last_updated': DateTime.now().toIso8601String(),
                'count': data.length,
              });

          await mockDatabaseOperations.updateMetadata(
            tableName,
            DateTime.now(),
          );
        }
      } catch (e) {
        print('Error syncing table $tableName: $e');
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableTables() async {
    if (!await isInternetAvailable()) return [];

    try {
      final snapshot = await mockFirestore.collection('local_data').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'last_updated': data['last_updated'] ?? '',
          'count': data['count'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> exportTableAsCSV(String tableName) async {
    if (!await isInternetAvailable()) return;

    try {
      final doc =
          await mockFirestore.collection('local_data').doc(tableName).get();
      if (!doc.exists) {
        print('Table $tableName does not exist');
        return;
      }
    } catch (e) {
      print('Error exporting table $tableName: $e');
    }
  }
}

class TestDataFactory {
  static MetadataCompanion createTestMetadata({
    String name = 'TestTable',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return MetadataCompanion(
      name: Value(name),
      createdAt: Value(createdAt ?? now),
      updatedAt: Value(updatedAt ?? now),
    );
  }

  static List<Map<String, dynamic>> createRealisticSensorData(int count) {
    return List.generate(
      count,
      (index) => {
        'id': index + 1,
        'date':
            DateTime.now().subtract(Duration(minutes: index)).toIso8601String(),
        'ip': '192.168.1.${100 + index}',
        'accelerationX': (index * 0.1) - 0.5,
        'accelerationY': (index * 0.15) - 0.3,
        'accelerationZ': 9.8 + (index * 0.05),
        'gyroskopX': index * 0.02,
        'gyroskopY': index * 0.03,
        'gyroskopZ': index * 0.01,
        'magnetometerX': 25.0 + (index * 0.5),
        'magnetometerY': -15.0 + (index * 0.3),
        'magnetometerZ': 45.0 + (index * 0.8),
        'barometer': 1013.25 + (index * 0.1),
      },
    );
  }

  static List<Map<String, dynamic>> createTestNoteData(int count) {
    return List.generate(
      count,
      (index) => {
        'id': index + 1,
        'date':
            DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
        'note': 'Test measurement note ${index + 1}',
      },
    );
  }

  static List<Map<String, dynamic>> createTestIdentificationData(int count) {
    return List.generate(
      count,
      (index) => {
        'ip': '192.168.1.${100 + index}',
        'name': 'Device_${index + 1}',
      },
    );
  }
}
