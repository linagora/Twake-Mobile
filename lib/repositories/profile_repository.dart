import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';

part 'profile_repository.g.dart';

// Index of profile record in store
// because it's a global object,
// it always has only one record in store
// per running app
const _PROFILE_STORE_INDEX = 0;

@JsonSerializable(explicitToJson: true)
class ProfileRepository extends JsonSerializable {
  @JsonKey(required: true)
  final String userId;
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
    this.userId,
    this.username,
  });

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  static final _storage = Storage();

  // Pseudo constructor for loading profile from storage or api
  static Future<ProfileRepository> load() async {
    _logger.d('Loading profile from storage');
    var profileMap = await _storage.load(
        type: StorageType.Profile, key: _PROFILE_STORE_INDEX);
    if (profileMap == null) {
      _logger.d('No profile in storage, requesting from api...');
      profileMap = await _api.get(Endpoint.profile);
    }
    // Get repository instance
    final profile = ProfileRepository.fromJson(profileMap);
    // Save/resave it to store
    profile.save();
    // return it
    return profile;
  }

  Future<void> save() async {
    await _storage.store(
      item: this,
      type: StorageType.Profile,
      key: _PROFILE_STORE_INDEX,
    );
  }

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory ProfileRepository.fromJson(Map<String, dynamic> json) =>
      _$ProfileRepositoryFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$ProfileRepositoryToJson(this);
}
