import 'package:sqflite/sqflite.dart';
import 'package:twake/sql/v11.dart';
import 'package:twake/sql/v10.dart';
import 'package:twake/sql/v6.dart';
import 'package:twake/sql/v8.dart';
import 'package:twake/sql/v9.dart';
import 'package:twake/sql/v12.dart';

// Base curent migration
const CURRENT_MIGRATION = DDL_V6;
// The latest versions
const DBVER = DB_V12;
// Add latest needed changes
const List<int> DB_VERSIONS = [DB_V8, DB_V9, DB_V10, DB_V11, DB_V12];
const List<List<String>> MIGRATIONS = [
  MIGRATION_8,
  MIGRATION_9,
  MIGRATION_10,
  MIGRATION_11,
  MIGRATION_12,
];

Future<void> dbUpgrade(
    {required Database db,
    required int oldVersion,
    required int newVersion}) async {
  if (newVersion > oldVersion) {
    final batch = db.batch();
    for (int i = 0; i < DB_VERSIONS.length; i++) {
      if (oldVersion < DB_VERSIONS[i]) {
        MIGRATIONS[i].forEach((element) {
          batch.execute(element);
        });
      }
    }
    await batch.commit();
  }
}
