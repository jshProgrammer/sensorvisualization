import 'package:drift/drift.dart';

class Identification extends Table {
  TextColumn get ip => text()();
  TextColumn get name => text()();

  Set<Column> get primaryKey => {ip};
}
