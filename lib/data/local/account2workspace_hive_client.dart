import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/account/account2workspace_hive.dart';
import 'package:twake/services/storage_service.dart';

class Account2WorkspaceHiveClient extends BaseHiveClient<Account2WorkspaceHive> {

  @override
  String get tableName => Table.account2workspace.name;

  @override
  Future<Box<Account2WorkspaceHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<Account2WorkspaceHive>(tableName);
      } else {
        return await Hive.openBox<Account2WorkspaceHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(Account2WorkspaceHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.userId, newObject);
    });
  }

  @override
  Future<void> cleanInsert(Account2WorkspaceHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.userId, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<Account2WorkspaceHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, Account2WorkspaceHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<Account2WorkspaceHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<Account2WorkspaceHive> filterAccount2Workspaces = box.values.toList();
      if (ids != null) {
        filterAccount2Workspaces = box.values.where((element) {
          return ids.contains(element.userId);
        }).toList();
      }

      return filterAccount2Workspaces;
    });
  }

  @override
  Future<void> updateById({
    required Account2WorkspaceHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<Account2WorkspaceHive> filterAccount2Workspaces = box.values.toList();
      if (ids != null) {
        filterAccount2Workspaces = box.values.where((element) {
          return ids.contains(element.userId);
        }).toList();
      }
      filterAccount2Workspaces.forEach((element) async {
        await box.put(element.userId, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<Account2WorkspaceHive> filterAccount2Workspaces = box.values.toList();
      if (ids != null) {
        filterAccount2Workspaces = box.values.where((element) {
          return ids.contains(element.userId);
        }).toList();
      }
      filterAccount2Workspaces.forEach((element) async {
        await box.delete(element.userId);
      });
    });
  }

}