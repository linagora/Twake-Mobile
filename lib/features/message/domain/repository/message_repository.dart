import 'package:twake/features/message/data/model/message/response/message.dart';

abstract class MessageRepository {
  Stream<List<Message>> fetch({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    bool? withExistedFiles = false,
  });
}
