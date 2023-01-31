import 'package:twake/core/domain/repository/repository.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';

abstract class MessageRepository extends Repository {
  Stream<List<Message>> fetch({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    bool? withExistedFiles = false,
  });
}
