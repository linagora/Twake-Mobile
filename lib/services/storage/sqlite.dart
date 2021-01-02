import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

import 'package:twake/services/service_bundle.dart';
import 'package:twake/services/storage/storage.dart';
import 'package:twake/sql/v1.dart';

const String _DATABASE_FILE = 'twakesql.db';
const int _CURRENT_MIGRATION = 1;

class SQLite with Storage {
  static Database _db;

  @override
  final settingsField = 'value';

  SQLite();

  final logger = Logger();

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _DATABASE_FILE);

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      logger.wtf('Failed to create databases directory!');
      throw e;
    }

    _db = await openDatabase(path, version: _CURRENT_MIGRATION,
        onConfigure: (Database db) async {
      await db.execute("PRAGMA foreign_keys = ON");
    }, onCreate: (Database db, int version) async {
      for (var ddl in DDL_V1) {
        await db.execute(ddl);
      }
    }, onOpen: (Database db) async {
      final v = await db.getVersion();
      logger.d('Opened twake db v.$v');
    });
  }

  @override
  Future<void> store({
    Map<String, dynamic> item,
    StorageType type,
    key,
  }) async {
    final table = mapTypeToStore(type);
    await _db.insert(table, item, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Map<String, dynamic>> load({
    StorageType type,
    dynamic key,
    List<String> fields,
  }) async {
    final table = mapTypeToStore(type);
    final items = await _db.query(
      table,
      columns: fields,
      where: 'id = ?',
      whereArgs: [key],
    );
    if (items.isNotEmpty) {
      return items.first;
    }
    return null;
  }

  @override
  Future<void> batchStore({
    Iterable<Map<String, dynamic>> items,
    StorageType type,
  }) async {
    final table = mapTypeToStore(type);
    await _db.transaction((txn) async {
      for (Map i in items) {
        await txn.insert(
          table,
          i,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> batchLoad({
    StorageType type,
    List<List> filters,
    Map<String, bool> orderings,
  }) async {
    final table = mapTypeToStore(type);
    final filter = filtersBuild(filters);
    final items = await _db.query(
      table,
      where: filter.item1,
      whereArgs: filter.item2,
      orderBy: orderingsBuild(orderings),
    );
    return items;
  }

  @override
  String mapTypeToStore(StorageType type) {
    String table;
    if (type == StorageType.Auth)
      table = 'setting';
    else if (type == StorageType.Profile)
      table = 'setting';
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

  @override
  Future<void> delete({StorageType type, key}) async {
    final table = mapTypeToStore(type);
    await _db.delete(table, where: 'id = ?', whereArgs: [key]);
  }

  @override
  Future<void> truncate(StorageType type) async {
    final table = mapTypeToStore(type);
    await _db.delete(table);
  }

  @override
  Future<void> truncateAll() async {
    await _db.transaction((txn) async {
      for (String s in getAllStorages()) {
        await txn.delete(s);
      }
    });
  }

  @override
  Tuple2<String, List<dynamic>> filtersBuild(List<List> expressions) {
    if (expressions == null || expressions.isEmpty) {
      return Tuple2(null, null);
    }
    String where = '';
    List<dynamic> whereArgs = [];

    for (List e in expressions) {
      assert(e.length == 3);
      final lhs = e[0];
      final op = e[1];
      final rhs = e[2];
      where += '$lhs $op ?,';
      whereArgs.add(rhs);
    }
    where = where.substring(0, where.length - 1);
    return Tuple2(where, whereArgs);
  }

  @override
  String orderingsBuild(Map<String, bool> orderings) {
    if (orderings == null) return null;

    String orderBy = '';
    for (var e in orderings.entries) {
      orderBy += '${e.key} ${e.value ? "ASC" : "DESC"},';
    }
    orderBy = orderBy.substring(0, orderBy.length - 1);
    return orderBy;
  }
}
