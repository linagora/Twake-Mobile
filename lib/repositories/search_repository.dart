import 'package:sprintf/sprintf.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/api_service.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/services/storage_service.dart';

enum SearchFilter {
  all,
}

class SearchRepositoryRequest<T> {
  final T result;
  final bool hasError;

  SearchRepositoryRequest({required this.result, required this.hasError});
}

class SearchRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  fetchAll({String searchTerm = ''}) {}

  Future<List<Message>> _fetch({
    required String searchTerm,
    required SearchFilter filter,
  }) async {
    List<dynamic> queryResult;

    final queryParameters = <String, dynamic>{
      'q': searchTerm,
      'emoji': false,
      'direction': 'history',
    };

    queryResult = await _api.get(
      endpoint: sprintf(Endpoint.search, [
        Globals.instance.companyId,
      ]),
      queryParameters: queryParameters,
      key: 'search',
    );

    return queryResult
        .where((rm) =>
            rm['type'] == 'message' &&
            rm['subtype'] != 'system' &&
            rm['subtype'] != 'application')
        .map((entry) => Message.fromJson(
              entry,
              channelId: '', // TODO: check this
              jsonify: true,
              transform: true,
            ))
        .toList();
  }

  Future<SearchRepositoryRequest<List<Account>>> fetchUsers({
    required String searchTerm,
  }) async {
    final queryParameters = <String, dynamic>{
      'search': searchTerm,
      'include_companies': 1,
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

  Future<SearchRepositoryRequest<List<Channel>>> fetchRecentChats() async {
    final queryParameters = <String, dynamic>{
      'limit': 14,
    };

    try {
      final queryResult = await _api.get(
        endpoint: sprintf(Endpoint.searchRecent, [
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
}
