import 'package:twake/models/company/company.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class CompaniesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  CompaniesRepository();

  Stream<List<Company>> fetch() async* {
    final companies = await fetchLocal();

    yield companies;

    if (!Globals.instance.isNetworkConnected) return;

    final rcompanies = await fetchRemote();

    if (rcompanies.length != companies.length) {
      await _storage.truncate(table: Table.company);
      _storage.multiInsert(table: Table.company, data: companies);
    }

    yield rcompanies;
  }

  Future<List<Company>> fetchLocal() async {
    final localResult = await this._storage.select(table: Table.company);
    var companies =
        localResult.map((entry) => Company.fromJson(json: entry)).toList();

    return companies;
  }

  Future<List<Company>> fetchRemote() async {
    final List<dynamic> remoteResult =
        await this._api.get(endpoint: Endpoint.companies);

    final companies = remoteResult
        .map((entry) => Company.fromJson(json: entry, jsonify: false))
        .toList();

    _storage.multiInsert(table: Table.company, data: companies);

    return companies;
  }

  Future<void> saveOne({required Company company}) async {
    await _storage.insert(table: Table.company, data: company);
  }
}
