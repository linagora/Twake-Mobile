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

    final rcompanies = await fetchRemote(localCopy: companies);

    if (rcompanies.length != companies.length) {
      await _storage.truncate(table: Table.company);
      _storage.multiInsert(table: Table.company, data: companies);
    }

    yield rcompanies;
  }

  Future<List<Company>> fetchLocal() async {
    final localResult = await _storage.select(table: Table.company);
    var companies =
        localResult.map((entry) => Company.fromJson(json: entry)).toList();

    return companies;
  }

  Future<List<Company>> fetchRemote({List<Company>? localCopy}) async {
    final List<dynamic> remoteResult = await this._api.get(
          endpoint: sprintf(Endpoint.companies, [Globals.instance.userId]),
        );

    if (localCopy == null) {
      final res = await _storage.select(table: Table.company);
      localCopy = res.map((entry) => Company.fromJson(json: entry)).toList();
    }

    final companies = remoteResult
        .map((entry) => Company.fromJson(json: entry, tranform: true))
        .toList();

    // Here we can resave local attributes before writing to storage

    for (final c in localCopy) {
      if (companies.any((co) => co.id == c.id)) {
        final company = companies.firstWhere((co) => co.id == c.id);
        company.selectedWorkspace = c.selectedWorkspace;
      }
    }

    _storage.multiInsert(table: Table.company, data: companies);

    return companies;
  }

  Future<void> saveOne({required Company company}) async {
    await _storage.insert(table: Table.company, data: company);
  }
}
