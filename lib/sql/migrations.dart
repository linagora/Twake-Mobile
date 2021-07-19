import 'package:sqflite/sqflite.dart';

import 'v5.dart';
import 'v6.dart';

const CURRENT_MIGRATION = [
  ...DDL_V5,
  ...DDL_V6,
];
const DBVER = 6;

Future<void> dbUpgrade({required Database db, required int version}) async {
  if (version == 5) for (final ddl in DDL_V6) db.execute(ddl);
}
