import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/models/account_field.dart';
import 'package:twake/models/language_field.dart';
import 'package:twake/models/language_option.dart';

part 'account_repository.g.dart';

const _ACCOUNT_STORE_KEY = 'account';

@JsonSerializable(explicitToJson: true)
class AccountRepository extends JsonSerializable {
  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final String username;
  @JsonKey(name: 'firstname')
  String firstName;
  @JsonKey(name: 'lastname')
  String lastName;

  // Avatar of user
  String thumbnail;

  // @JsonKey(name: 'notification_rooms')
  // List<String> notificationRooms;

  @JsonKey(required: true)
  AccountRepository({
    this.id,
    this.username,
  });

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  static final _storage = Storage();

  @JsonKey(name: 'selected_company_id')
  String selectedCompanyId;
  @JsonKey(name: 'selected_workspace_id')
  String selectedWorkspaceId;
  @JsonKey(ignore: true)
  String selectedChannelId;
  @JsonKey(ignore: true)
  String selectedThreadId;
  @JsonKey(ignore: true)
  Company selectedCompany;
  @JsonKey(ignore: true)
  Workspace selectedWorkspace;
  @JsonKey(ignore: true)
  BaseChannel selectedChannel;
  @JsonKey(ignore: true)
  Map<String, dynamic> badges = {};

  // Pseudo constructor for loading profile from storage or api
  static Future<AccountRepository> load() async {
    _logger.w("Loading account:");
    bool loadedFromNetwork = false;
    var accountMap = await _storage.load(
      type: StorageType.Account,
      key: _ACCOUNT_STORE_KEY,
    );
    if (accountMap == null) {
      _logger.d('No account in storage, requesting from api...');
      accountMap = await _api.get(Endpoint.account);
      _logger.d('RECEIVED ACCOUNT: $accountMap');
      loadedFromNetwork = true;
    } else {
      accountMap = jsonDecode(accountMap[_storage.settingsField]);
      // _logger.d('RETRIEVED ACCOUNT: $accountMap');
    }
    // Get repository instance
    final account = AccountRepository.fromJson(accountMap);
    // Save it to store
    if (loadedFromNetwork) account.save();
    // return it

    return account;
  }

  Future<void> reload() async {
    final profileMap = await _api.get(Endpoint.account);
    _update(profileMap);
  }

  Future<void> syncBadges() async {
    this.badges = await _api.get(
      Endpoint.badges,
      params: {'company_id': this.selectedCompanyId, 'all_companies': 'true'},
    );
  }

  Future<void> clean() async {
    await _storage.delete(
      type: StorageType.Account,
      key: _ACCOUNT_STORE_KEY,
    );
  }

  Future<void> save() async {
    await _storage.store(
      item: {
        'id': _ACCOUNT_STORE_KEY,
        _storage.settingsField: jsonEncode(this.toJson())
      },
      type: StorageType.Account,
    );
  }

  void _update(Map<String, dynamic> json) {
    firstName = json['firstname'] as String;
    lastName = json['lastname'] as String;
    thumbnail = json['thumbnail'] as String;
  }

  Future<AccountRepository> patch({
    String newFirstName,
    String newLastName,
    String newLanguage,
    String oldPassword,
    String newPassword,
  }) async {
    final Map<String, dynamic> accountMap = <String, dynamic>{};
    if (newFirstName != null) {
      firstName = newFirstName;
      accountMap['firstname'] = newFirstName;
    }
    if (newLastName != null) {
      lastName = newLastName;
      accountMap['lastname'] = newLastName;
    }
    final result = await _api.patch(Endpoint.account, body: toJson());
    if (result != null) {
      print('Account updated: $accountMap');
      save();
    }
    return this;
  }

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory AccountRepository.fromJson(Map<String, dynamic> json) {
    // json = Map.from(json);
    // if (json['notification_rooms'] is String) {
    // json['notification_rooms'] = jsonDecode(json['notification_rooms']);
    // }
    return _$AccountRepositoryFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$AccountRepositoryToJson(this);
    // map['notification_rooms'] = jsonEncode(map['notification_rooms']);
    return map;
  }
}
