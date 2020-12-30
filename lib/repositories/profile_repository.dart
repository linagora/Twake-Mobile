import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';

part 'profile_repository.g.dart';

const _PROFILE_STORE_INDEX = 'profile';

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
  // Avatar of user
  String thumbnail;
  @JsonKey(required: true)
  ProfileRepository({
    this.id,
    this.username,
  });

  @JsonKey(ignore: true)
  static final logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  static final _storage = Storage();

  // Pseudo constructor for loading profile from storage or api
  static Future<ProfileRepository> load() async {
    bool loadedFromNetwork = false;
    var profileMap = await _storage.load(
      type: StorageType.Profile,
      key: _PROFILE_STORE_INDEX,
    );
    if (profileMap == null) {
      logger.d('No profile in storage, requesting from api...');
      profileMap = await _api.get(Endpoint.profile);
      loadedFromNetwork = true;
    } else {
      profileMap = jsonDecode(profileMap[_storage.settingsField]);
    }
    // Get repository instance
    final profile = ProfileRepository.fromJson(profileMap);
    // Save it to store
    if (loadedFromNetwork) profile.save();
    // return it
    return profile;
  }

  Future<void> reload() async {
    final profileMap = await _api.get(Endpoint.profile);
    _update(profileMap);
  }

  Future<void> clean() async {
    await _storage.delete(
      type: StorageType.Profile,
      key: _PROFILE_STORE_INDEX,
    );
  }

  Future<void> save() async {
    await _storage.store(
      item: {
        'id': _PROFILE_STORE_INDEX,
        _storage.settingsField: jsonEncode(this.toJson())
      },
      type: StorageType.Profile,
    );
  }

  void _update(Map<String, dynamic> json) {
    firstName = json['firstname'] as String;
    lastName = json['lastname'] as String;
    thumbnail = json['thumbnail'] as String;
  }

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory ProfileRepository.fromJson(Map<String, dynamic> json) {
    return _$ProfileRepositoryFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$ProfileRepositoryToJson(this);
}
