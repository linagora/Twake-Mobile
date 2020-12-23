import 'package:json_annotation/json_annotation.dart';

part 'sender.g.dart';

@JsonSerializable()
class Sender {
  @JsonKey(defaultValue: 'BOT')
  final String username;

  final String thumbnail;

  @JsonKey(required: true)
  final String userId;

  @JsonKey(name: 'firstname')
  final String firstName;

  @JsonKey(name: 'lastname')
  final String lastName;

  Sender({
    this.username,
    this.thumbnail,
    this.userId,
    this.firstName,
    this.lastName,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$SenderToJson(this);
}
