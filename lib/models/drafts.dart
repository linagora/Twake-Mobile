import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:twake/services/service_bundle.dart';

const _DRAFTS_STORE_KEY = 'drafts';

enum DraftType {
  channel,
  direct,
}

class Drafts {
  static var _draftsMap = {};
  static var _reverseDraftsMap = {};

  static final _storage = Storage();

  static Future<void> load() async {
    var map = await _storage.load(
      type: StorageType.Drafts,
      key: _DRAFTS_STORE_KEY,
      fields: _storage.settingsField != null ? [_storage.settingsField] : null,
    );

    // if (map == null) {
    //   map = await _api.get(Endpoint.emojis);
    //   await _storage.store(
    //     item: {
    //       'id': _EMOJIS_STORE_KEY,
    //       _storage.settingsField: jsonEncode(map)
    //     },
    //     type: StorageType.Emojis,
    //   );
    //   _emojimap = map;
    // } else {
    _draftsMap= jsonDecode(map[_storage.settingsField]);
    // }
    _reverseDraftsMap = _draftsMap.map((k, v) => MapEntry(v, k));
  }

  static String getById(String id, {@required DraftType forType}) {
    var key = '$id-$forType';
    return _draftsMap[key] ?? '';
  }
}
