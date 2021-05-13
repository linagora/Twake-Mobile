import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/services/service_bundle.dart';

part 'profile_repository.g.dart';

const _PROFILE_STORE_KEY = 'profile';

@JsonSerializable(explicitToJson: true)
class ProfileRepository extends JsonSerializable {
  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final String username;
  @JsonKey(name: 'firstname')
  String firstName;
  @JsonKey(name: 'lastname')
  String lastName;
  @JsonKey(name: 'console_id')
  final String consoleId;

  // Avatar of user
  String thumbnail;
  String email;

  // @JsonKey(name: 'notification_rooms')
  // List<String> notificationRooms;

  @JsonKey(required: true)
  ProfileRepository({
    this.id,
    this.username,
    this.consoleId,
  });

  @JsonKey(ignore: true)
  static final logger = Logger();
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
  static Future<ProfileRepository> load() async {
    // logger.w("Loading profile");
    bool loadedFromNetwork = false;
    var profileMap = await _storage.load(
      type: StorageType.Profile,
      key: _PROFILE_STORE_KEY,
    );
    if (profileMap == null) {
      logger.d('No profile in storage, requesting from api...');
      profileMap = await _api.get(Endpoint.profile);
      logger.d('RECEIVED PROFILE: $profileMap');
      loadedFromNetwork = true;
    } else {
      profileMap = jsonDecode(profileMap[_storage.settingsField]);
      logger.d('RETRIEVED FROM STORAGE PROFILE: $profileMap');
    }
    // Get repository instance
    final profile = ProfileRepository.fromJson(profileMap);
    // Save it to store
    if (loadedFromNetwork) profile.save();
    // return it

    // TODO uncomment when ready
    // fetchInfo();

    return profile;
  }

  Future<void> reload() async {
    final profileMap = await _api.get(Endpoint.profile);
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
      type: StorageType.Profile,
      key: _PROFILE_STORE_KEY,
    );
  }

  Future<void> save() async {
    await _storage.store(
      item: {
        'id': _PROFILE_STORE_KEY,
        _storage.settingsField: jsonEncode(this.toJson())
      },
      type: StorageType.Profile,
    );
  }

  void _update(Map<String, dynamic> json) {
    firstName = json['firstname'] as String;
    lastName = json['lastname'] as String;
    thumbnail = json['thumbnail'] as String;
    email = json['email'] as String;
  }

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory ProfileRepository.fromJson(Map<String, dynamic> json) {
    // json = Map.from(json);
    // if (json['notification_rooms'] is String) {
    // json['notification_rooms'] = jsonDecode(json['notification_rooms']);
    // }
    return _$ProfileRepositoryFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$ProfileRepositoryToJson(this);
    // map['notification_rooms'] = jsonEncode(map['notification_rooms']);
    return map;
  }
}
