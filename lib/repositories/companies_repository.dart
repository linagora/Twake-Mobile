import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/models/company.dart';

part 'companies_repository.g.dart';

const _COMPANIES_LOAD_METHOD = '/companies';

@JsonSerializable(explicitToJson: true)
class CompaniesRepository {
  List<Company> companies;

  CompaniesRepository(this.companies);

  int get companiesCount => (companies ?? []).length;

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  static final _storage = Storage();

  // Sort of a constructor method
  // to load and build instance of class from either
  // storage or api request
  static Future<CompaniesRepository> load() async {
    _logger.d('Loading companies from storage');
    var companiesList = await _storage.loadList(type: StorageType.Company);
    if (companiesList == null) {
      _logger.d('No companies in storage, requesting from api...');
      companiesList = await _api.get(_COMPANIES_LOAD_METHOD);
    }
    // In order to use auto deserialization we need to stick
    // list of companies into a map
    final companiesMap = {'companies': companiesList};
    return CompaniesRepository.fromJson(companiesMap);
  }

  Future<void> reloadCompanies() async {
    _logger.d('Reloading companies from api...');
    final companiesList = await _api.get(_COMPANIES_LOAD_METHOD);
    _updateCompanies(companiesList);
  }

  void _updateCompanies(List<Map<String, dynamic>> companiesList) {
    final companies = companiesList.map((c) => Company.fromJson(c)).toList();
    this.companies = companies;
  }

  Future<void> save() async {
    await _storage.storeList(
      items: this.companies,
      type: StorageType.Company,
    );
  }

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory CompaniesRepository.fromJson(Map<String, dynamic> json) {
    return _$CompaniesRepositoryFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    return _$CompaniesRepositoryToJson(this);
  }
}
