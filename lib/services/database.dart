import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:twake/services/service_bundle.dart';
import 'package:twake/sql/v1.dart';

const String _DATABASE_FILE = 'twakesql.db';
const int _CURRENT_MIGRATION = 1;

class DB {
  static Database _db;
  static DB _singleton;

  factory DB() {
    if (_singleton == null) {
      _singleton = DB._();
    }
    return _singleton;
  }

  DB._();

  final logger = Logger();

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _DATABASE_FILE);

    try {
      await Directory(path).create(recursive: true);
    } catch (e) {
      logger.wtf('Failed to create databases directory!');
      throw e;
    }

    _db = await openDatabase(
      path,
      version: _CURRENT_MIGRATION,
      onConfigure: (Database db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (Database db, int version) async {
        for (var ddl in DDL_V1) {
          await db.execute(ddl);
        }
      },
      onOpen: (Database db) => logger.d('Opened twake db v.${db.getVersion}'),
    );
  }

  Future<Map<String, dynamic>> load({
    StorageType type,
    dynamic key,
    bool copyMap: false,
  }) async {
    final table = mapTypeToStore(type);
    final items = await _db.query(table, where: 'id = ?', whereArgs: [key]);
    if (items.isNotEmpty) {
      if (copyMap)
        return Map.from(items.first);
      else
        return items.first;
    }
    return null;
  }

  String mapTypeToStore(StorageType type) {
    String table;
    if (type == StorageType.Auth)
      table = 'settings';
    else if (type == StorageType.Profile)
      table = 'settings';
    else if (type == StorageType.Company)
      table = 'company';
    else if (type == StorageType.Workspace)
      table = 'workspace';
    else if (type == StorageType.Channel)
      table = 'channel';
    else if (type == StorageType.Direct)
      table = 'direct';
    else if (type == StorageType.Message)
      table = 'message';
    else if (type == StorageType.User)
      table = 'user';
    else
      throw 'Storage type does not exist';
    return table;
  }
}
