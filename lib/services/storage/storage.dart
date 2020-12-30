import 'dart:io' show Platform;

// import 'package:twake/services/storage/sembast.dart';
import 'package:twake/services/storage/sqlite.dart';

abstract class Storage {
  final settingsField = null;
  static Storage _storage;
  factory Storage() {
    if (_storage == null) {
      if (Platform.isIOS || Platform.isAndroid) {
        _storage = SQLite();
      } else {
        throw '${Platform.operatingSystem} is not supported';
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
  });

  Future<void> delete({StorageType type, dynamic key});

  Future<void> truncate(StorageType type);

  Future<void> truncateAll();

  dynamic mapTypeToStore(StorageType type);

  dynamic filtersBuild(List<List> expressions);

  dynamic orderingsBuild(Map<String, bool> orderings);

  Iterable<dynamic> getAllStorages() {
    return StorageType.values.map((st) => mapTypeToStore(st));
  }
}

enum StorageType {
  Auth,
  Profile,
  Company,
  Workspace,
  Channel,
  Direct,
  Message,
  User,
}
