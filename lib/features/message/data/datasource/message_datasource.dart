import 'package:twake/features/message/data/model/message/response/message.dart';

abstract class MessageDataSource {
  Future<List<Message>> fetch({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    String? afterMessageId,
    bool? withExistedFiles = false,
  });

  Future<void> multiInsert({
    required Iterable<Message> data,
  });
}
