import 'package:twake/models/application.dart';
import 'package:twake/services/service_bundle.dart';

class ApplicationRepository {
  static Map<String?, Application> items = {};
  static ApplicationRepository? _repository;

  factory ApplicationRepository([List<String?>? companies]) {
    if (_repository == null || companies != null) {
      _repository = ApplicationRepository._()..load(companies!);
    }
    return _repository!;
  }

  ApplicationRepository._();

  final _api = Api();
  final _storage = Storage();
  final logger = Logger();

  Future<void> load(List<String?> companies) async {
    for (var c in companies) {
      await fetchForCompany(c);
    }
  }

  Future<void> fetchForCompany(String? companyId) async {
    final List<dynamic> applications = await (this._api.get(
      Endpoint.applications,
      params: {
        'company_id': companyId,
      },
    ) as FutureOr<List<dynamic>>);
    items.addEntries(
      applications.map(
        (a) => MapEntry(
          a['id'],
          Application.fromJson(a),
        ),
      ),
    );
    await this.save();
  }

  Future<void> save() async {
    await _storage.batchStore(
      type: StorageType.Application,
      items: items.values.map((v) => v.toJson()),
    );
  }
}
