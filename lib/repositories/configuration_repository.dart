import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';

part 'configuration_repository.g.dart';

// Index of server ip record in store
// because it's a global object,
// it always has only one record in store
const CONFIG_KEY = 'configuration';

@JsonSerializable()
class ConfigurationRepository extends JsonSerializable {
  @JsonKey(required: true, name: 'host')
  String host;

  @JsonKey(ignore: true)
  static final _storage = Storage();

  @JsonKey(ignore: true)
  ConfigurationRepository({String host});

  factory ConfigurationRepository.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationRepositoryFromJson(json);

  static Future<ConfigurationRepository> load() async {
    var configurationMap = await _storage.load(
      type: StorageType.Configuration,
      fields: _storage.settingsField != null ? [_storage.settingsField] : null,
      key: CONFIG_KEY,
    );

    Logger().d('Configuration map: $configurationMap');

    if (configurationMap != null) {
      final configurationRepository =
          ConfigurationRepository.fromJson(configurationMap);
      return configurationRepository;
    }
    return ConfigurationRepository();
  }

  Future<void> remove() async {
    await _storage.delete(
      type: StorageType.Configuration,
      key: CONFIG_KEY,
    );
  }

  Future<void> save() async {
    var jsonToSave = jsonEncode(this.toJson());
    Logger().d('Configuration json to save: $jsonToSave');

    await _storage.store(
      item: {
        'id': CONFIG_KEY,
        _storage.settingsField: jsonToSave,
      },
      type: StorageType.Configuration,
    );
  }
}
