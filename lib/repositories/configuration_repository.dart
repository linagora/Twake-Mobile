import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/init.dart';
import 'package:twake/services/service_bundle.dart';

part 'configuration_repository.g.dart';

// Index of configuration record in store
// because it's a global object,
// it always has only one record in store
const CONFIG_KEY = 'configuration';
const DEFAULT_HOST = 'https://mobile.api.twake.app';

@JsonSerializable()
class ConfigurationRepository extends JsonSerializable {
  @JsonKey(required: true, name: 'host')
  String host;

  @JsonKey(ignore: true)
  static final _storage = Storage();

  @JsonKey(ignore: true)
  ConfigurationRepository({this.host});

  factory ConfigurationRepository.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigurationRepositoryToJson(this);

  static Future<ConfigurationRepository> load() async {
    var configurationMap = await _storage.load(
      type: StorageType.Configuration,
      fields: _storage.settingsField != null ? [_storage.settingsField] : null,
      key: CONFIG_KEY,
    );

    Logger().d('Configuration map: $configurationMap');

    if (configurationMap != null) {
      final configurationRepository = ConfigurationRepository.fromJson(
          jsonDecode(configurationMap[_storage.settingsField]));
      return configurationRepository;
    }
    return ConfigurationRepository(host: DEFAULT_HOST);
  }

  Future<void> clean() async {
    host = '';
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
