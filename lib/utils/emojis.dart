import 'dart:convert';

import 'package:twake/services/api.dart';
import 'package:twake/services/service_bundle.dart';

const _EMOJIS_STORE_KEY = 'emojis';

class Emojis {
  static var _emojimap = {};
  static var _reverseEmojimap = {};

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
    _reverseEmojimap = _emojimap.map((k, v) => MapEntry(v, k));
  }

  static String getByName(String name) {
    name = name.replaceAll(':', '');
    List<int> codePoints = [];
    String codePoint = _emojimap[name];
    if (codePoint == null) {
      if (reverseLookup(name) != null)
        return name;
      else {
        codePoint = _emojimap['question'];
      }
    }
    for (String cp in codePoint.split('-')) {
      codePoints.add(int.parse(cp, radix: 16));
    }
    return String.fromCharCodes(codePoints);
  }

  static String reverseLookup(String value) {
    print('EMOJI CODE: $value');
    String hexcode =
        value.runes.map((r) => r.toRadixString(16).toUpperCase()).join('-');
    return _reverseEmojimap[hexcode];
  }
}
