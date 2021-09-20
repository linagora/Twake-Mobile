import 'package:sqflite/sqflite.dart';

import 'v6.dart';

const CURRENT_MIGRATION = DDL_V6;
const DBVER = 7;

Future<void> dbUpgrade({required Database db, required int version}) async {
  // if (version == 5) for (final ddl in DDL_V6) db.execute(ddl);
}
