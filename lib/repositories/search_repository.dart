import 'package:sprintf/sprintf.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/api_service.dart';
import 'package:twake/services/storage_service.dart';

import '../services/endpoints.dart';

enum SearchFilter {
  all,
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
}
