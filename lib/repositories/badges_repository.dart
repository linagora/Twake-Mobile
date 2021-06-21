import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/badge/badge.dart';

class BadgesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  BadgesRepository();

  Stream<List<Badge>> fetch() async* {
    var badges = await fetchLocal();
    if (badges.isNotEmpty) {
      yield badges;
    }

    if (!Globals.instance.isNetworkConnected) return;

    badges = await fetchRemote();

    yield badges;
  }

  Future<List<Badge>> fetchLocal() async {
    // grab everything we have
    final localResult = await _storage.select(table: Table.badge);
    final badges = localResult.map((e) => Badge.fromJson(json: e)).toList();

    return badges;
  }

  Future<List<Badge>> fetchRemote() async {
    final queryParameters = {
      'company_id': Globals.instance.companyId,
      'all_companies': 'true',
    };

    final List remoteResult = await _api.get(
      endpoint: Endpoint.badges,
      queryParameters: queryParameters,
    );

    final badges = remoteResult.map((e) => Badge.fromJson(json: e)).toList();

    await _storage.truncate(table: Table.badge);

    _storage.multiInsert(table: Table.badge, data: badges);

    return badges;
  }

  Future<void> saveOne({required Badge badge}) async {
    await _storage.insert(table: Table.badge, data: badge);
  }
}
