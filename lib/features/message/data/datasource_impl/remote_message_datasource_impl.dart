import 'package:sprintf/sprintf.dart';
import 'package:twake/core/network/model/query/query_parameter.dart';
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

    final queryParameters = <QueryParameter?>[
      IntQueryParameter('include_users', 1),
      BooleanQueryParameter('emoji', false),
      StringQueryParameter('direction', 'history'),
      IntQueryParameter('limit', 25),
    ];

    if (afterMessageId != null) {
      queryParameters.addAll([
        StringQueryParameter('page_token', afterMessageId),
        StringQueryParameter('direction', 'future'),
      ]);
    }
    if (withExistedFiles == true) {
      queryParameters.add(
        StringQueryParameter('filter', 'files'),
       );
    }
    if (threadId == null) {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadsChannel, [
          companyId ?? Globals.instance.companyId,
          workspaceId ?? Globals.instance.workspaceId,
          channelId
        ]),
        queryParameters: queryParameters.toMap(),
        key: 'resources',
      );
    } else {
      final queryParameters = <QueryParameter?>[
        IntQueryParameter('include_users', 1),
        BooleanQueryParameter('emoji', false),
        StringQueryParameter('direction', 'history'),
      ];

      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadMessages, [
          companyId ?? Globals.instance.companyId,
          threadId,
        ]),
        queryParameters: queryParameters.toMap(),
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
