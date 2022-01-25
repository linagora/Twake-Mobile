import 'package:sqflite/sqflite.dart';
import 'package:twake/sql/v8.dart';

import 'v6.dart';

const CURRENT_MIGRATION = DDL_V6;
const DBVER = DB_V8;

Future<void> dbUpgrade({required Database db, required int oldVersion, required int newVersion}) async {
  if (newVersion > oldVersion) {
    if(oldVersion < DB_V8) {
      final batch = db.batch();
      MIGRATION_8.forEach((element) {
        batch.execute(element);
      });
      await batch.commit();
    }
  }
}
