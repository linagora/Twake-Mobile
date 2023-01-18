import 'package:twake/features/message/data/datasource_impl/local_message_datasource_impl.dart';
import 'package:twake/features/message/data/datasource_impl/remote_message_datasource_impl.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/features/message/domain/repository/message_repository.dart';
import 'package:twake/models/globals/globals.dart';

class MessageRepositoryImpl extends MessageRepository {
  final LocalMessageDataSourceImpl _localMessageDataSourceImpl;
  final RemoteMessageDataSourceImpl _remoteMessageDataSourceImpl;

  MessageRepositoryImpl(this._localMessageDataSourceImpl, this._remoteMessageDataSourceImpl);

  @override
  Stream<List<Message>> fetch(
      {String? companyId,
      String? workspaceId,
      required String channelId,
      String? threadId,
      bool? withExistedFiles = false}) async* {
    if (!Globals.instance.isNetworkConnected) {
      var messages = await _localMessageDataSourceImpl.fetch(
        channelId: channelId,
        threadId: threadId,
        withExistedFiles: withExistedFiles,
      );
      yield messages;
      return;
    }

    final remoteMessages = await _remoteMessageDataSourceImpl.fetch(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
      withExistedFiles: withExistedFiles,
    );

    await _localMessageDataSourceImpl.multiInsert(data: remoteMessages);
    final data = await _localMessageDataSourceImpl.fetch(
      channelId: channelId,
      threadId: threadId,
      withExistedFiles: withExistedFiles,
    );

    yield data;
  }
}
