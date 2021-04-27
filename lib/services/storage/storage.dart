import 'package:flutter/foundation.dart';

// import 'package:twake/services/storage/sembast.dart';
import 'package:twake/services/storage/sqlite.dart';

abstract class Storage {
  final settingsField = null;
  static Storage _storage;
  factory Storage() {
    if (_storage == null) {
      if ((defaultTargetPlatform == TargetPlatform.iOS) ||
          (defaultTargetPlatform == TargetPlatform.android)) {
        _storage = SQLite();
      } else if ((defaultTargetPlatform == TargetPlatform.linux) ||
          (defaultTargetPlatform == TargetPlatform.macOS) ||
          (defaultTargetPlatform == TargetPlatform.windows)) {
        throw 'Desktop is not supported yet';
      } else {
        throw 'Web is not supported yet';
      }
    }
    return _storage;
  }

  Future<void> initDb();

  Future<Map<String, dynamic>> load({
    StorageType type,
    dynamic key,
    List<String> fields,
  });

  Future<dynamic> customUpdate({
    String sql,
    List args,
  });

  Future<dynamic> customQuery(
    String query, {
    List<List> filters,
    List<List> likeFilters: const [],
    Map<String, bool> orderings,
    int limit,
    int offset,
  });

  Future<void> store({
    Map<String, dynamic> item,
    StorageType type,
    dynamic key,
  });

  Future<void> batchStore({
    Iterable<Map<String, dynamic>> items,
    StorageType type,
  });

  Future<List<Map<String, dynamic>>> batchLoad({
    StorageType type,
    List<List> filters,
    Map<String, bool> orderings,
    int limit,
    int offset,
  });

  Future<void> batchDelete({
    StorageType type,
    List<List> filters,
  });

  Future<void> delete({StorageType type, dynamic key});

  Future<void> truncate(StorageType type);

  Future<void> truncateAll({List<StorageType> except});

  dynamic mapTypeToStore(StorageType type);

  dynamic filtersBuild(List<List> expressions);

  dynamic likeFiltersBuild(List<List> expressions);

  dynamic orderingsBuild(Map<String, bool> orderings);

  Iterable<dynamic> getAllStorages() {
    return StorageType.values.map((st) => mapTypeToStore(st));
  }
}

enum StorageType {
  Auth,
  Profile,
  Message,
  Channel,
  Direct,
  Workspace,
  Company,
  User,
  Application,
  Emojis,
  Drafts,
  Member,
  Configuration,
  Account,
  User2Workspace,
}
