import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:twake/services/service_bundle.dart';

const _DRAFTS_STORE_KEY = 'drafts';

enum DraftType {
  channel,
  direct,
}

class Drafts {
  static var _draftsMap = {};
  static final _storage = Storage();

  static Future<void> load() async {
    final map = await _storage.load(
      type: StorageType.Drafts,
      key: _DRAFTS_STORE_KEY,
      fields: _storage.settingsField != null ? [_storage.settingsField] : null,
    );
    _draftsMap = jsonDecode(map[_storage.settingsField]);
  }

  static Future<void> save({
    @required String id,
    @required DraftType type,
    @required String draft,
  }) async {
    final key = '$id-${describeEnum(type)}';
    _draftsMap[key] = draft;
    _store();
  }

  static Future<void> _store() async {
    await _storage.store(
      item: {
        'id': _DRAFTS_STORE_KEY,
        _storage.settingsField: jsonEncode(_draftsMap),
      },
      type: StorageType.Drafts,
    );
  }

  static Future<void> remove(
      {@required String byId, @required DraftType type}) async {
    final key = '$byId-${describeEnum(type)}';
    _draftsMap.remove(key);
    _store();
  }

  static String getById(String id, {@required DraftType forType}) {
    var key = '$id-${describeEnum(forType)}';
    return _draftsMap[key] ?? '';
  }
}
