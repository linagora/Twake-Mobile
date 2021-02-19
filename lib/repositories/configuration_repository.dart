import 'package:meta/meta.dart';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';

part 'configuration_repository.g.dart';

// Index of server ip record in store
// because it's a global object,
// it always has only one record in store
const HOST_KEY = 'host';

@JsonSerializable()
class ConfigurationRepository extends JsonSerializable {
  @JsonKey(required: true, name: 'host')
  String host;

  @JsonKey(ignore: true)
  static final _storage = Storage();
  @JsonKey(ignore: true)
  final _logger = Logger();

  ConfigurationRepository() {

  }

  factory ConfigurationRepository.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationRepositoryFromJson(json);

  static Future<ConfigurationRepository> load() async {
    var configurationMap = await _storage.load(
      type: StorageType.Configuration,
      fields: _storage.settingsField != null ? [_storage.settingsField] : null,
      key: HOST_KEY,
    );

    if (configurationMap != null) {
      final configurationRepository = ConfigurationRepository.fromJson(configurationMap);
      return configurationRepository;
    }
    return ConfigurationRepository();
  }

  Future<void> removeHost() async {
    await _storage.delete(
      type: StorageType.Configuration,
      key: HOST_KEY,
    );
  }


  Future<void> saveHost() async {
    await _storage.store(
      item: {
        'id': HOST_KEY,
        _storage.settingsField: jsonEncode(this.toJson())
      },
      type: StorageType.Configuration,
    );
  }
}