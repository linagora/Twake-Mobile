import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

import 'package:twake/services/service_bundle.dart';
import 'package:twake/services/storage/storage.dart';
import 'package:twake/sql/migrations.dart';

const String _DATABASE_FILE = 'twakesql.db';
const int _CURRENT_MIGRATION = 4;

class SQLite with Storage {
  static late Database _db;

  @override
  final dynamic settingsField = 'value';

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

    _db = await openDatabase(
      path,
      version: _CURRENT_MIGRATION,
      onConfigure: (Database db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (Database db, int version) async {
        for (var ddl in DDL_V4) {
          await db.execute(ddl);
        }
      },
      onOpen: (Database db) async {
        final v = await db.getVersion();
        logger.d('Opened twake db v.$v');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var ddl = List<String>.from(DDL_V4);
        logger.d('SQFlite onUpdate called with new version: $newVersion');
        logger.d('Migration to twake db v.$newVersion from v.$oldVersion');
        if (oldVersion == 1) {
          ddl.removeWhere((el) => DDL_V1.contains(el));
          for (var migrationDdl in ddl) {
            await db.execute(migrationDdl);
          }
        } else if (oldVersion == 2) {
          ddl.removeWhere((el) => DDL_V2.contains(el));
          for (var migrationDdl in ddl) {
            await db.execute(migrationDdl);
          }
        } else if (oldVersion == 3) {
          ddl.removeWhere((el) => DDL_V3.contains(el));
          for (var migrationDdl in ddl) {
            await db.execute(migrationDdl);
          }
        }
      },
    );
  }

  @override
  Future<dynamic> customQuery(
    String sqlQuery, {
    filters,
    likeFilters: const [],
    orderings,
    limit: 100000,
    offset: 0,
  }) async {
    final orderBy = orderingsBuild(orderings);
    final where = filtersBuild(filters);
    final like = likeFiltersBuild(likeFilters);
    var whereArgs = [];
    sqlQuery += ' WHERE ${where.item1} ';
    whereArgs += where.item2!;
    if (like.item1 != null) {
      sqlQuery += 'AND (${like.item1})';
      whereArgs += like.item2!;
    }
    sqlQuery += ' ORDER BY $orderBy LIMIT $limit OFFSET $offset;';
    final result = await _db.rawQuery(sqlQuery, whereArgs);
    return result;
  }

  @override
  Future<dynamic> customUpdate({
    String? sql,
    List? args,
  }) async {
    final result = await _db.rawUpdate(sql!, args);
    return result;
  }

  @override
  Future<void> store({
    Map<String?, dynamic>? item,
    StorageType? type,
    key,
  }) async {
    final table = mapTypeToStore(type);
    await _db.insert(table, item as Map<String, Object?>, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Map<String, dynamic>?> load({
    StorageType? type,
    dynamic key,
    List<String?>? fields,
  }) async {
    final table = mapTypeToStore(type);
    final items = await _db.query(
      table,
      columns: fields as List<String>?,
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
    Iterable<Map<String, dynamic>>? items,
    StorageType? type,
  }) async {
    final table = mapTypeToStore(type);
    await _db.transaction((txn) async {
      for (Map i in items!) {
        await txn.insert(
          table,
          i as Map<String, Object?>,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> batchLoad({
    StorageType? type,
    List<List>? filters,
    Map<String, bool>? orderings,
    int? limit,
    int? offset,
  }) async {
    final table = mapTypeToStore(type);
    final filter = filtersBuild(filters);
    final items = await _db.query(
      table,
      where: filter.item1,
      whereArgs: filter.item2,
      orderBy: orderingsBuild(orderings),
      limit: limit,
      offset: offset,
    );
    return items;
  }

  @override
  String mapTypeToStore(StorageType? type) {
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
    else if (type == StorageType.Application)
      table = 'application';
    else if (type == StorageType.Emojis)
      table = 'setting';
    else if (type == StorageType.Drafts)
      table = 'draft';
    else if (type == StorageType.Member)
      table = 'member';
    else if (type == StorageType.Configuration)
      table = 'configuration';
    else if (type == StorageType.Account)
      table = 'configuration';
    else if (type == StorageType.User2Workspace)
      table = 'user2workspace';
    else
      throw 'Storage type does not exist';
    return table;
  }

  @override
  Future<void> delete({StorageType? type, key}) async {
    final table = mapTypeToStore(type);
    await _db.delete(table, where: 'id = ?', whereArgs: [key]);
  }

  @override
  Future<void> batchDelete({
    StorageType? type,
    List<List>? filters,
  }) async {
    logger.e('REQUESTING BATCH DELETE\nTYPE: $type\nFILTERS: $filters');
    final table = mapTypeToStore(type);
    final filter = filtersBuild(filters);
    await _db.delete(table, where: filter.item1, whereArgs: filter.item2);
  }

  @override
  Future<void> truncate(StorageType? type) async {
    final table = mapTypeToStore(type);
    await _db.delete(table);
  }

  @override
  Future<void> truncateAll({List<StorageType>? except}) async {
    List<String> storagesToKeep = [];
    if (except != null && except.length > 0) {
      storagesToKeep = except.map((e) => mapTypeToStore(e)).toList();
    }
    await _db.transaction((txn) async {
      for (String s in getAllStorages() as Iterable<String>) {
        if (!storagesToKeep.contains(s)) {
          print('Storage to delete: $s');
          await txn.delete(s);
        }
      }
    });
  }

  @override
  Tuple2<String?, List<dynamic>?> filtersBuild(List<List>? expressions) {
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
      if (rhs == null && op == '=')
        where += '$lhs IS NULL AND ';
      else if (rhs == 'null' && op == '!=')
        where += '$lhs IS NOT NULL AND ';
      else {
        where += '$lhs $op ? AND ';
        whereArgs.add(rhs);
      }
    }
    where = where.substring(0, where.length - 4);
    return Tuple2(where, whereArgs);
  }

  @override
  Tuple2<String?, List<dynamic>?> likeFiltersBuild(List<List> expressions) {
    if (expressions == null || expressions.isEmpty) {
      return Tuple2(null, null);
    }
    String where = '';
    List<dynamic> whereArgs = [];

    for (List e in expressions) {
      assert(e.length == 2);
      final lhs = e[0];
      final rhs = e[1];
      where += '$lhs LIKE ? OR ';
      whereArgs.add('%$rhs%');
    }
    where = where.substring(0, where.length - 3);
    return Tuple2(where, whereArgs);
  }

  @override
  String? orderingsBuild(Map<String, bool>? orderings) {
    if (orderings == null) return null;

    String orderBy = '';
    for (var e in orderings.entries) {
      orderBy += '${e.key} ${e.value ? "ASC" : "DESC"},';
    }
    orderBy = orderBy.substring(0, orderBy.length - 1);
    return orderBy;
  }
}
