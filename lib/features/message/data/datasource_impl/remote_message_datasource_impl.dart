import 'package:sprintf/sprintf.dart';
import 'package:twake/features/message/data/datasource/message_datasource.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/api_service.dart';
import 'package:twake/services/endpoints.dart';

class RemoteMessageDataSourceImpl extends MessageDataSource {
  final _api = ApiService.instance;

  @override
  Future<List<Message>> fetch(
      {String? companyId,
      String? workspaceId,
      required String channelId,
      String? threadId,
      String? afterMessageId,
      bool? withExistedFiles = false}) async {
    List<dynamic> remoteResult;
    final queryParameters = <String, dynamic>{
      'include_users': 1,
      'emoji': false,
      'direction': 'history',
      'limit': 25,
    };

    if (afterMessageId != null) {
      queryParameters['page_token'] = afterMessageId;
      queryParameters['direction'] = 'future';
    }
    if (withExistedFiles == true) {
      queryParameters['filter'] = 'files';
    }
    if (threadId == null) {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadsChannel, [
          companyId ?? Globals.instance.companyId,
          workspaceId ?? Globals.instance.workspaceId,
          channelId
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      );
    } else {
      final queryParameters = <String, dynamic>{
        'include_users': 1,
        'emoji': false,
        'direction': 'history',
      };

      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadMessages, [
          companyId ?? Globals.instance.companyId,
          threadId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      );
    }

    return remoteResult
        .where((rm) =>
            rm['type'] == 'message' &&
            rm['subtype'] != 'system' &&
            rm['subtype'] !=
                'application') // TODO remove the last condition once the support for applications has been implemented
        .map((entry) => Message.fromJson(
              entry,
              channelId: channelId,
              jsonify: true,
              transform: true,
            ))
        .toList();
  }

  @override
  Future<void> multiInsert({required Iterable<BaseModel> data}) {
    // TODO: implement multiInsert
    throw UnimplementedError();
  }
}
