import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/authentication/authentication_hive.dart';
import 'package:twake/services/storage_service.dart';

class AuthenticationHiveClient extends BaseHiveClient<AuthenticationHive> {

  @override
  String get tableName => Table.authentication.name;

  @override
  Future<Box<AuthenticationHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<AuthenticationHive>(tableName);
      } else {
        return await Hive.openBox<AuthenticationHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(AuthenticationHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.idToken, newObject);
    });
  }

  @override
  Future<void> cleanInsert(AuthenticationHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.idToken, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<AuthenticationHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, AuthenticationHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<AuthenticationHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<AuthenticationHive> filterAuthentications = box.values.toList();
      if (ids != null) {
        filterAuthentications = box.values.where((authentication) {
          return ids.contains(authentication.idToken);
        }).toList();
      }

      return filterAuthentications;
    });
  }

  @override
  Future<void> updateById({
    required AuthenticationHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<AuthenticationHive> filterAuthentications = box.values.toList();
      if (ids != null) {
        filterAuthentications = box.values.where((authentication) {
          return ids.contains(authentication.idToken);
        }).toList();
      }
      filterAuthentications.forEach((element) async {
        await box.put(element.idToken, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<AuthenticationHive> filterAuthentications = box.values.toList();
      if (ids != null) {
        filterAuthentications = box.values.where((authentication) {
          return ids.contains(authentication.idToken);
        }).toList();
      }
      filterAuthentications.forEach((element) async {
        await box.delete(element.idToken);
      });
    });
  }

}