import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:twake/services/service_bundle.dart';

enum DraftType {
  none,
  channel,
  direct,
  thread,
}

class DraftRepository {
  final _storage = Storage();

  DraftRepository();

  Future<String?> load({
    required String? id,
    required DraftType type,
  }) async {
    final key = '$id-${describeEnum(type)}';

    final map = await _storage.load(
      type: StorageType.Drafts,
      key: key,
    );
    final draft = map != null ? map['value'] : '';
    return draft;
  }

  Future<void> save({
    required String? id,
    required DraftType type,
    required String? draft,
  }) async {
    final key = '$id-${describeEnum(type)}';
    await _storage.store(
      item: {'id': key, 'value': draft},
      type: StorageType.Drafts,
      key: key,
    );
  }

  Future<void> remove({required String? id, required DraftType type}) async {
    final key = '$id-${describeEnum(type)}';
    await _storage.delete(
      type: StorageType.Drafts,
      key: key,
    );
  }
}
