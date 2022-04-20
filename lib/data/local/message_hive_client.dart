import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/message/message_hive.dart';
import 'package:twake/services/storage_service.dart';

class MessageHiveClient extends BaseHiveClient<MessageHive> {

  @override
  String get tableName => Table.message.name;

  @override
  Future<Box<MessageHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<MessageHive>(tableName);
      } else {
        return await Hive.openBox<MessageHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(MessageHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(MessageHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<MessageHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, MessageHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<MessageHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<MessageHive> filterMessages = box.values.toList();
      if (ids != null) {
        filterMessages = box.values.where((message) {
          return ids.contains(message.id);
        }).toList();
      }

      return filterMessages;
    });
  }

  @override
  Future<void> updateById({
    required MessageHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<MessageHive> filterMessages = box.values.toList();
      if (ids != null) {
        filterMessages = box.values.where((message) {
          return ids.contains(message.id);
        }).toList();
      }
      filterMessages.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<MessageHive> filterMessages = box.values.toList();
      if (ids != null) {
        filterMessages = box.values.where((message) {
          return ids.contains(message.id);
        }).toList();
      }
      filterMessages.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

  Future<List<MessageHive>> selectByMultipleId({
    required String channelId,
    String? threadId,
    String? files,
    String? orderBy,
    String? sortOrder,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<MessageHive> filterMessages = box.values.toList();
      filterMessages = box.values.where((message) {
        if (threadId != null) {
          if (files != null && files == '[]') {
            return message.channelId == channelId &&
                message.threadId == threadId &&
                (message.files != null && message.files!.isNotEmpty);
          } else {
            return message.channelId == channelId
                && message.threadId == threadId;
          }
        } else {
          return message.channelId == channelId
              && message.threadId == 'id';
        }
      }).toList();

      return filterMessages;
    });
  }
}