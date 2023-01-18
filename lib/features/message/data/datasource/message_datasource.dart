import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/models/base_model/base_model.dart';

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
    required Iterable<BaseModel> data,
  });
}
