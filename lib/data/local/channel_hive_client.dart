import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/channel/channel_hive.dart';
import 'package:twake/services/storage_service.dart';

class ChannelHiveClient extends BaseHiveClient<ChannelHive> {

  @override
  String get tableName => Table.channel.name;

  @override
  Future<Box<ChannelHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<ChannelHive>(tableName);
      } else {
        return await Hive.openBox<ChannelHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(ChannelHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(ChannelHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<ChannelHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, ChannelHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<ChannelHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<ChannelHive> filterChannels = box.values.toList();
      if (ids != null) {
        filterChannels = box.values.where((channel) {
          return ids.contains(channel.id);
        }).toList();
      }

      return filterChannels;
    });
  }

  @override
  Future<void> updateById({
    required ChannelHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<ChannelHive> filterChannels = box.values.toList();
      if (ids != null) {
        filterChannels = box.values.where((channel) {
          return ids.contains(channel.id);
        }).toList();
      }
      filterChannels.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<ChannelHive> filterChannels = box.values.toList();
      if (ids != null) {
        filterChannels = box.values.where((channel) {
          return ids.contains(channel.id);
        }).toList();
      }
      filterChannels.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

  Future<List<ChannelHive>> selectByCompanyWorkspaceIds({
    String? companyId,
    String? workspaceId,
    String? orderBy,
    String? sortOrder,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<ChannelHive> filterChannels = box.values.toList();
      if (companyId != null && workspaceId != null) {
        filterChannels = box.values.where((channel) {
          return companyId == channel.companyId && workspaceId == channel.workspaceId;
        }).toList();
      }

      return filterChannels;
    });
  }
}