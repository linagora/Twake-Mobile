import 'dart:convert';

import 'package:twake/services/api.dart';
import 'package:twake/services/service_bundle.dart';

const _EMOJIS_STORE_KEY = 'emojis';

class Emojis {
  static var _emojimap = {};

  static final _api = Api();
  static final _storage = Storage();

  static Future<void> load() async {
    var map = await _storage.load(
      type: StorageType.Emojis,
      key: _EMOJIS_STORE_KEY,
      fields: _storage.settingsField != null ? [_storage.settingsField] : null,
    );
    if (map == null) {
      map = await _api.get(Endpoint.emojis);
      await _storage.store(
        item: {
          'id': _EMOJIS_STORE_KEY,
          _storage.settingsField: jsonEncode(map)
        },
        type: StorageType.Emojis,
      );
      _emojimap = map;
    } else {
      _emojimap = jsonDecode(map[_storage.settingsField]);
    }
  }

  static String getByName(String name) {
    name = name.replaceAll(':', '');
    return _emojimap[name];
  }
}
