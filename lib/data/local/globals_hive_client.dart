import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/globals/globals_hive.dart';
import 'package:twake/services/storage_service.dart';

class GlobalsHiveClient extends BaseHiveClient<GlobalsHive> {

  @override
  String get tableName => Table.globals.name;

  @override
  Future<Box<GlobalsHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<GlobalsHive>(tableName);
      } else {
        return await Hive.openBox<GlobalsHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(GlobalsHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.token, newObject);
    });
  }

  @override
  Future<void> cleanInsert(GlobalsHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.token, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<GlobalsHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, GlobalsHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<GlobalsHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<GlobalsHive> filterGlobals = box.values.toList();
      if (ids != null) {
        filterGlobals = box.values.where((globals) {
          return ids.contains(globals.token);
        }).toList();
      }

      return filterGlobals;
    });
  }

  @override
  Future<void> updateById({
    required GlobalsHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<GlobalsHive> filterGlobals = box.values.toList();
      if (ids != null) {
        filterGlobals = box.values.where((globals) {
          return ids.contains(globals.token);
        }).toList();
      }
      filterGlobals.forEach((element) async {
        await box.put(element.token, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<GlobalsHive> filterGlobals = box.values.toList();
      if (ids != null) {
        filterGlobals = box.values.where((globals) {
          return ids.contains(globals.token);
        }).toList();
      }
      filterGlobals.forEach((element) async {
        await box.delete(element.token);
      });
    });
  }

}