import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/sql/migrations.dart';
import 'package:twake/utils/platform_detection.dart';
import 'package:twake/services/hive_storage.dart' deferred as hiveStorage;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'sqlite_storage_service.dart';
part 'hive_storage_service.dart';

abstract class StorageService {
  static late final StorageService _service;

  factory StorageService({required reset}) {
    if (reset) {
      Get.find<PlatformDetection>().dbLayerByPlatform(
        webImpl: () {
          _service = HiveStorageService._();
        },
        linuxImpl: () {
          _service = SqliteStorageService._(useSqlFFI: true);
        },
        windowsImpl: () {
          _service = SqliteStorageService._(useSqlFFI: true);
        },
        androidImpl: () {
          _service = SqliteStorageService._();
        },
        iOSImpl: () {
          _service = SqliteStorageService._();
        },
      );
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
  });

  // This function is used when we need a clean table to insert the data
  Future<void> cleanInsert({
    required Table table,
    required BaseModel data,
  });

  // This function can be used both for inserts and updates
  Future<void> multiInsert({
    required Table table,
    required Iterable<BaseModel> data,
  });

  Future<List<Map<String, Object?>>> select({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  });

  Future<Map<String, Object?>> first({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  });

  Future<void> update({
    required Table table,
    required Map<String, dynamic> values,
    String? where,
    List<dynamic>? whereArgs,
  });

  Future<void> delete({
    required Table table,
    String? where,
    List<dynamic>? whereArgs,
  });

  Future<List<Map<String, Object?>>> rawSelect({
    required String sql,
    List<dynamic>? args,
  });

  Future<void> truncate({required Table table});

  Future<void> truncateAll();
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
