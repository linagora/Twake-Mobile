import 'package:sqflite/sqflite.dart';
import 'package:twake/sql/v8.dart';
import 'package:twake/sql/v9.dart';

import 'v6.dart';

const CURRENT_MIGRATION = DDL_V6;
const DBVER = DB_V9;

Future<void> dbUpgrade(
    {required Database db,
    required int oldVersion,
    required int newVersion}) async {
  if (newVersion > oldVersion) {
    final batch = db.batch();
    if (oldVersion < DB_V8) {
      MIGRATION_8.forEach((element) {
        batch.execute(element);
      });
    } else if (oldVersion < DB_V9) {
      MIGRATION_9.forEach((element) {
        batch.execute(element);
      });
    }
    await batch.commit();
  }
}
