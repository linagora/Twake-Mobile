import 'package:twake/models/company/company.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class CompanyRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  Stream<List<Company>> fetch() async* {
    final localResult = await this._storage.select(table: Table.company);
    var companies = localResult.map((entry) => Company.fromJson(json: entry)).toList();
    yield companies;

    if (!Globals.instance.isNetworkConnected) return;

    final remoteResult = await this._api.get(endpoint: Endpoint.companies);
    companies = remoteResult.map((entry) => Company.fromJson(json: entry, jsonify: false)).toList();

    _storage.multiInsert(table: Table.company, data: companies);

    yield companies;
  }
}
