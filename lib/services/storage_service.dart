import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/sql/migrations.dart';

const String _DATABASE_FILE = 'twakesql.db';

class StorageService {
  static late final StorageService _service;
  late Database _db;

  factory StorageService({required reset}) {
    if (reset) {
      _service = StorageService._();
    }
    return _service;
  }

  static StorageService get instance {
    return _service;
  }

  StorageService._();

  // Must be called before accessing instance!
  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _DATABASE_FILE);

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      Logger().wtf('Failed to create databases directory!\nError: $e');
      throw e;
    }
    if (await databaseExists(path)) {
      final oldDBVersion = await openReadOnlyDatabase(path).then((db) async {
        final version = await db.getVersion();
        db.close();
        return version;
      });

      if (oldDBVersion < 5) {
        await deleteDatabase(path);
      }
    }

    void onConfigure(Database db) async {
      // enable support for foreign key constraints
      await db.execute("PRAGMA foreign_keys = ON");
      // enable support for LIKE searches case sensitively
      await db.execute("PRAGMA case_sensitive_like = ON");
    }

    void onCreate(Database db, int version) async {
      for (var ddl in CURRENT_MIGRATION) {
        await db.execute(ddl);
      }
    }

    void onOpen(Database db) async {
      final v = await db.getVersion();
      Logger().d('Opened twake db v.$v');
    }

    void onUpgrade(db, oldVersion, newVersion) async {
      Logger().d('Migration to twake db v.$newVersion from v.$oldVersion');
      await dbUpgrade(db: db, version: oldVersion);
    }

    _db = await openDatabase(
      path,
      version: DBVER,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onOpen: onOpen,
      onUpgrade: onUpgrade,
    );
  }

  // This function can be used both for inserts and updates
  Future<void> insert({
    required Table table,
    required BaseModel data,
  }) async {
    await _db.insert(
      table.name,
      data.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // This function is used when we need a clean table to insert the data
  Future<void> cleanInsert({
    required Table table,
    required BaseModel data,
  }) async {
    final batch = _db.batch();
    batch.delete(table.name);
    batch.insert(table.name, data.toJson());

    await batch.commit(noResult: true);
  }

  // This function can be used both for inserts and updates
  Future<void> multiInsert({
    required Table table,
    required Iterable<BaseModel> data,
  }) async {
    final batch = _db.batch();
    for (final item in data) {
      batch.insert(
        table.name,
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> select({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    int? limit,
  }) async {
    if (where != null && whereArgs != null) {
      final expected = where.split('?').length;
      final actual = whereArgs.length;
      assert(expected == actual);
    }
    final result = await _db.query(
      table.name,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
    return result;
  }

  Future<Map<String, Object?>> first({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final result = await select(
      table: table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
    );
    return result.length > 0 ? result[0] : const {};
  }

  Future<void> update({
    required Table table,
    required Map<String, dynamic> values,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await _db.update(
      table.name,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete({
    required Table table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await _db.delete(table.name, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> rawSelect({
    required String sql,
    List<dynamic>? args,
  }) async {
    final result = await _db.rawQuery(sql, args);
    return result;
  }

  Future<void> truncate({required Table table}) async {
    await _db.delete(table.name);
  }

  Future<void> truncateAll() async {
    final batch = _db.batch();
    for (final table in Table.values) {
      batch.delete(table.name);
    }
    await batch.commit(noResult: true);
  }
}

enum Table {
  authentication,
  account,
  account2workspace,
  company,
  workspace,
  channel,
  message,
  globals,
  badge,
}

extension TableExtension on Table {
  String get name {
    switch (this) {
      case Table.authentication:
        return 'authentication';
      case Table.account:
        return 'account';
      case Table.account2workspace:
        return 'account2workspace';
      case Table.company:
        return 'company';
      case Table.workspace:
        return 'workspace';
      case Table.channel:
        return 'channel';
      case Table.message:
        return 'message';
      case Table.globals:
        return 'globals';
      case Table.badge:
        return 'badge';
    }
  }
}
