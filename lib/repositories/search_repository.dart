import 'package:sprintf/sprintf.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/api_service.dart';
import 'package:twake/services/endpoints.dart';
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

class SearchFile {
  final Message message;
  final Account user;
  final File file;

  SearchFile(this.message, this.user, this.file);
}

class SearchMedia {
  final Message message;
  final Account user;
  final File file;

  SearchMedia(this.message, this.user, this.file);
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
      'limit': 100,
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

  Future<SearchRepositoryRequest<List<SearchFile>>> fetchFiles({
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

      final result = queryResult
          .where((entry) => entry['metadata']['name'] != null)
          .map((entry) => SearchFile(
              Message.fromJson(
                entry['message'],
                jsonify: true,
                transform: true,
                channelId: '',
              ),
              Account.fromJson(json: entry['user'], transform: true),
              File.fromJson({
                ...entry,
                'user_id': entry['user']['id'],
                'company_id': entry['cache']['company_id'],
                'thumbnails': entry['metadata']['thumbnails'],
                'upload_data': {
                  'size': entry['metadata']['size'],
                  'chunks': 1,
                },
                'updated_at': entry['created_at']
              })))
          .toList();

      return SearchRepositoryRequest(result: result, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching files:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }

  Future<SearchRepositoryRequest<List<SearchMedia>>> fetchMedia({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': 25,
      'is_file': true,
      'q': searchTerm,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchMedia, [
          Globals.instance.companyId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      ) as List<dynamic>;

      final result = queryResult
          .where((entry) => entry['metadata']['name'] != null)
          .map((entry) => SearchMedia(
              Message.fromJson(
                entry['message'],
                jsonify: true,
                transform: true,
                channelId: '',
              ),
              Account.fromJson(json: entry['user'], transform: true),
              File.fromJson({
                ...entry,
                'user_id': entry['user']['id'],
                'company_id': entry['cache']['company_id'],
                'thumbnails': entry['metadata']['thumbnails'],
                'upload_data': {
                  'size': entry['metadata']['size'],
                  'chunks': 1,
                },
                'updated_at': entry['created_at']
              })))
          .toList();

      return SearchRepositoryRequest(result: result, hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching media:\n$e');

      return SearchRepositoryRequest(result: [], hasError: true);
    }
  }
}
