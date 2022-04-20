import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/receive_sharing/shared_location_hive.dart';
import 'package:twake/services/storage_service.dart';

class SharedLocationHiveClient extends BaseHiveClient<SharedLocationHive> {

  @override
  String get tableName => Table.sharedLocation.name;

  @override
  Future<Box<SharedLocationHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<SharedLocationHive>(tableName);
      } else {
        return await Hive.openBox<SharedLocationHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(SharedLocationHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(SharedLocationHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<SharedLocationHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, SharedLocationHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<SharedLocationHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<SharedLocationHive> filterSharedLocations = box.values.toList();
      if (ids != null) {
        filterSharedLocations = box.values.where((sharedlocation) {
          return ids.contains(sharedlocation.id);
        }).toList();
      }

      if(orderBy != null) {
        final orderArr = orderBy.split(' ');
        if(orderArr.length == 2 && orderArr.isNotEmpty) {
          filterSharedLocations.sort((a1, a2) {
            if(a1.id != null && a2.id != null) {
              if (orderArr[1].toLowerCase() == 'desc') {
                return a2.id!.compareTo(a1.id!);
              }
              return a1.id!.compareTo(a2.id!);
            }
            return 0;
          });
        }
      }

      if(limit != null && limit > 0) {
        filterSharedLocations = filterSharedLocations.getRange(0, limit - 1).toList();
      }

      return filterSharedLocations;
    });
  }

  @override
  Future<void> updateById({
    required SharedLocationHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<SharedLocationHive> filterSharedLocations = box.values.toList();
      if (ids != null) {
        filterSharedLocations = box.values.where((sharedlocation) {
          return ids.contains(sharedlocation.id);
        }).toList();
      }
      filterSharedLocations.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<SharedLocationHive> filterSharedLocations = box.values.toList();
      if (ids != null) {
        filterSharedLocations = box.values.where((sharedlocation) {
          return ids.contains(sharedlocation.id);
        }).toList();
      }
      filterSharedLocations.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

}