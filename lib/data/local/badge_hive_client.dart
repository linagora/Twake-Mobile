import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/badge/badge_hive.dart';
import 'package:twake/services/storage_service.dart';

class BadgeHiveClient extends BaseHiveClient<BadgeHive> {

  @override
  String get tableName => Table.badge.name;

  @override
  Future<Box<BadgeHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<BadgeHive>(tableName);
      } else {
        return await Hive.openBox<BadgeHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(BadgeHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(BadgeHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<BadgeHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, BadgeHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<BadgeHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<BadgeHive> filterBadges = box.values.toList();
      if (ids != null) {
        filterBadges = box.values.where((badge) {
          return ids.contains(badge.id);
        }).toList();
      }

      return filterBadges;
    });
  }

  @override
  Future<void> updateById({
    required BadgeHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<BadgeHive> filterBadges = box.values.toList();
      if (ids != null) {
        filterBadges = box.values.where((badge) {
          return ids.contains(badge.id);
        }).toList();
      }
      filterBadges.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<BadgeHive> filterBadges = box.values.toList();
      if (ids != null) {
        filterBadges = box.values.where((badge) {
          return ids.contains(badge.id);
        }).toList();
      }
      filterBadges.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

}