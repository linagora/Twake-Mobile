import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/sql/migrations.dart';

part 'storage_service_mobile.dart';
part 'storage_service_desktop_app.dart';

const String _DATABASE_FILE = 'twakesql.db';

abstract class StorageService {
  static late final StorageService _service;
  late Database _db;

  factory StorageService({required reset}) {
    if (reset) {
      if(Platform.isMacOS || Platform.isWindows || Platform.isLinux){
        _service = StorageServiceDesktop._();
      }else if(Platform.isIOS || Platform.isAndroid){
        _service = StorageServiceMobile._();
      }else{

      }
    }
    return _service;
  }

  static StorageService get instance {
    return _service;
  }

  StorageService._();

  // Must be called before accessing instance!
  Future<void> init();

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

  // This function can be used for rawInserts
  Future<void> rawInsert(
      {required Table table,
      required List<String> fields,
      required List<dynamic> values}) async {
    final length = fields.length > 1 ? ',?' * (fields.length - 1) : '';
    await _db.rawInsert(
        "INSERT into $table (${fields.toString()})"
        " VALUES (?$length)",
        [values]);
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
    String? orderBy,
    int? limit,
  }) async {
    final result = await _db.query(
      table.name,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
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
    //TODO Remove when API for editing user profile is ready,integrate it into LanguageRepository
    for (final table in Table.values) {
      if (table.name != 'account') {
        batch.delete(table.name);
      }
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
  sharedLocation,
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
      case Table.sharedLocation:
        return 'sharedlocation';
    }
  }
}
