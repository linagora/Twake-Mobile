import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';

part 'profile_repository.g.dart';

// Index of profile record in store
// because it's a global object,
// it always has only one record in store
// per running app
const PROFILE_STORE_INDEX = 0;

// API Endpoint for loading profile data
const PROFILE_LOAD_METHOD = '/user';

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
  final logger = Logger();
  @JsonKey(ignore: true)
  final api = Api();
  @JsonKey(ignore: true)
  final storage = Storage;

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory ProfileRepository.fromJson(Map<String, dynamic> json) =>
      _$ProfileRepositoryFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$ProfileRepositoryToJson(this);
}
