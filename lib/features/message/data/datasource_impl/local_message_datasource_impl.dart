import 'package:twake/features/message/data/datasource/message_datasource.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/services/storage_service.dart';

class LocalMessageDataSourceImpl extends MessageDataSource {
  final _storage = StorageService.instance;

  @override
  Future<List<Message>> fetch(
      {String? companyId,
      String? workspaceId,
      required String channelId,
      String? threadId,
      String? afterMessageId,
      bool? withExistedFiles = false}) async {
    var where = 'channel_id = ?';
    if (threadId == null) {
      where += ' AND thread_id = id';
    } else {
      where += ' AND thread_id = ?';
    }
    if (withExistedFiles == true) {
      where += ' AND files <> ?';
    }

    final localResult = await _storage.select(
      table: Table.message,
      where: where,
      limit: threadId == null ? 25 : 9999,
      orderBy: 'created_at DESC',
      whereArgs: [
        channelId,
        if (threadId != null) threadId,
        if (withExistedFiles == true) '[]'
      ],
    );
    final messages =
        localResult.map((entry) => Message.fromJson(entry)).toList();

    return messages;
  }

  @override
  Future<void> multiInsert({required Iterable<Message> data}) async {
    await _storage.multiInsert(table: Table.message, data: data);
  }
}
