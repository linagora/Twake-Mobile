import 'package:sqflite/sqflite.dart';

import 'v7.dart';

const CURRENT_MIGRATION = DDL_V7;
const DBVER = 8;

Future<void> dbUpgrade({required Database db, required int version}) async {
  // if (version == 5) for (final ddl in DDL_V6) db.execute(ddl);
}
