import 'package:sqflite/sqflite.dart';

export 'v1.dart' show DDL_V1;
export 'v2.dart' show DDL_V2;
export 'v3.dart' show DDL_V3;
export 'v4.dart' show DDL_V4;

import 'v5.dart';

const CURRENT_MIGRATION = DDL_V5;
const DBVER = 5;

Future<void> dbUpgrade({
  required Database db,
  required int version,
  required String dbPath,
}) async {
  if (version < 5) {
    await deleteDatabase(dbPath);
  }
}
