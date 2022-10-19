import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';

class SearchRepositoryRequest<T> {
  final T result;
  final bool hasError;

  SearchRepositoryRequest({required this.result, required this.hasError});
}

class SearchMessage {
  final Message message;
  final Channel channel;

  SearchMessage(this.message, this.channel);
}

class SearchRepository {
  final _api = ApiService.instance;

  Future<SearchRepositoryRequest<List<Channel>>> fetchChats({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': 100,
      'q': searchTerm,
      'company_id': Globals.instance.companyId,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchChannels, [
          Globals.instance.companyId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final result = queryResult
          .map((e) => Channel.fromJson(
                json: e,
                jsonify: false,
                transform: true,
              ))
          .toList();

      return SearchRepositoryRequest(result: result, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching chats:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }

  Future<SearchRepositoryRequest<List<Channel>>> fetchRecentChats() async {
    final queryParameters = <String, dynamic>{
      'limit': 14,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchRecentChannels, [
          Globals.instance.companyId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final result = queryResult
          .map((e) => Channel.fromJson(
                json: e,
                jsonify: false,
                transform: true,
              ))
          .toList();

      return SearchRepositoryRequest(result: result, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching recent chats:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }

  Future<SearchRepositoryRequest<List<Account>>> fetchUsers({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'search': searchTerm,
      //'include_companies': 1,
      'search_company_id': Globals.instance.companyId,
    };

    try {
      final queryResult = await _api.get(
        endpoint: Endpoint.searchUsers,
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final users = queryResult
          .map((e) => Account.fromJson(json: e, transform: true))
          .toList();

      return SearchRepositoryRequest(result: users, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching users:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }

  Future<SearchRepositoryRequest<List<SearchMessage>>> fetchMessages({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': 50,
      'q': searchTerm,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchMessages, [
          Globals.instance.companyId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final result = queryResult
          .where((rm) =>
              rm['type'] == 'message' &&
              rm['subtype'] != 'system' &&
              rm['subtype'] != 'application')
          .map((entry) => SearchMessage(
              Message.fromJson(
                entry,
                jsonify: true,
                transform: true,
                channelId: '',
              ),
              Channel.fromJson(json: entry['channel'], transform: true)))
          .toList();

      return SearchRepositoryRequest(result: result, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching messages:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }

  Future<SearchRepositoryRequest<List<MessageFile>>> fetchMedia({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': 25,
      'is_media': true,
      'q': searchTerm,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchFiles, [
          Globals.instance.companyId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final List<MessageFile> messageFiles =
          queryResult.map((e) => MessageFile.fromJson(e)).toList();

      return SearchRepositoryRequest(result: messageFiles, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching files:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }

  Future<SearchRepositoryRequest<List<MessageFile>>> fetchFiles({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': 25,
      'is_file': true,
      'q': searchTerm,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchFiles, [
          Globals.instance.companyId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final List<MessageFile> messageFiles =
          queryResult.map((e) => MessageFile.fromJson(e)).toList();

      return SearchRepositoryRequest(result: messageFiles, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching files:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }
}
