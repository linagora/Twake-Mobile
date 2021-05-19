import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/sql/migrations.dart';

const String _DATABASE_FILE = 'twakesql.db';

class Storage {
  static late Database _db;
  final _logger = Logger();

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _DATABASE_FILE);

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      _logger.wtf('Failed to create databases directory!\nError: $e');
      throw e;
    }

    void onConfigure(Database db) async {
      // enable support for foreign key constraints
      await db.execute("PRAGMA foreign_keys = ON");
      // enable support for LIKE searches case sensitively
      await db.execute("PRAGMA case_sensitive_like = ON");
    }

    void onCreate(Database db, int version) async {
      for (var ddl in DDL_V4) {
        await db.execute(ddl);
      }
    }

    void onOpen(Database db) async {
      final v = await db.getVersion();
      _logger.d('Opened twake db v.$v');
    }

    void onUpgrade(db, oldVersion, newVersion) async {
      _logger.d('Migration to twake db v.$newVersion from v.$oldVersion');
      await dbUpgrade(db: db, version: oldVersion, dbPath: path);
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
  static Future<void> insert({
    required Table table,
    required JsonSerializable data,
  }) async {
    await _db.insert(
      table.name,
      data.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // This function can be used both for inserts and updates
  static Future<void> multiInsert({
    required Table table,
    required List<JsonSerializable> data,
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

  static Future<List<Map<String, Object?>>> select({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (where != null && whereArgs != null) {
      final expected = where.split('?').length;
      final actual = whereArgs.length;
      assert(expected == actual);
    }
    final result = await _db.query(table.name,
        columns: columns, where: where, whereArgs: whereArgs);
    return result;
  }
}

enum Table {
  userAccount,
  company,
  workspace,
  channel,
  message,
  globals,
}

extension TableExtension on Table {
  String get name {
    switch (this) {
      case Table.userAccount:
        return 'user_account';
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
    }
  }
}
