import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/account/account_hive.dart';
import 'package:twake/services/storage_service.dart';

class AccountHiveClient extends BaseHiveClient<AccountHive> {

  @override
  String get tableName => Table.account.name;

  @override
  Future<Box<AccountHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<AccountHive>(tableName);
      } else {
        return await Hive.openBox<AccountHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(AccountHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(AccountHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<AccountHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, AccountHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<AccountHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<AccountHive> filterAccounts = box.values.toList();
      if (ids != null) {
        filterAccounts = box.values.where((account) {
          return ids.contains(account.id);
        }).toList();
      }

      return filterAccounts;
    });
  }

  @override
  Future<void> updateById({
    required AccountHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<AccountHive> filterAccounts = box.values.toList();
      if (ids != null) {
        filterAccounts = box.values.where((account) {
          return ids.contains(account.id);
        }).toList();
      }
      filterAccounts.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<AccountHive> filterAccounts = box.values.toList();
      if (ids != null) {
        filterAccounts = box.values.where((account) {
          return ids.contains(account.id);
        }).toList();
      }
      filterAccounts.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

  Future<List<AccountHive>> selectByUsernames({List<String>? usernames}) {
    return Future.sync(() async {
      final box = await openBox();

      List<AccountHive> filterAccounts = box.values.toList();
      if (usernames != null) {
        filterAccounts = box.values.where((account) {
          return usernames.contains(account.username);
        }).toList();
      }

      return filterAccounts;
    });
  }

}