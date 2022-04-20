import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/workspace/workspace_hive.dart';
import 'package:twake/services/storage_service.dart';

class WorkspaceHiveClient extends BaseHiveClient<WorkspaceHive> {

  @override
  String get tableName => Table.workspace.name;

  @override
  Future<Box<WorkspaceHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<WorkspaceHive>(tableName);
      } else {
        return await Hive.openBox<WorkspaceHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(WorkspaceHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(WorkspaceHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<WorkspaceHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, WorkspaceHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<WorkspaceHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<WorkspaceHive> filterWorkspaces = box.values.toList();
      if (ids != null) {
        filterWorkspaces = box.values.where((workspace) {
          return ids.contains(workspace.id);
        }).toList();
      }

      return filterWorkspaces;
    });
  }

  @override
  Future<void> updateById({
    required WorkspaceHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<WorkspaceHive> filterWorkspaces = box.values.toList();
      if (ids != null) {
        filterWorkspaces = box.values.where((workspace) {
          return ids.contains(workspace.id);
        }).toList();
      }
      filterWorkspaces.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<WorkspaceHive> filterWorkspaces = box.values.toList();
      if (ids != null) {
        filterWorkspaces = box.values.where((workspace) {
          return ids.contains(workspace.id);
        }).toList();
      }
      filterWorkspaces.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

  Future<List<WorkspaceHive>> selectByCompanyIds({
    String? companyId,
    String? orderBy,
    String? sortOrder,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<WorkspaceHive> filterWorkspaces = box.values.toList();
      if(companyId != null) {
        filterWorkspaces = box.values.where((workspace) {
          return companyId == workspace.companyId;
        }).toList();
      }

      return filterWorkspaces;
    });
  }

}