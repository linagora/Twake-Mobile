import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake_mobile/models/company.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile {
  @JsonKey(required: true)
  final String userId;
  @JsonKey(required: true)
  final String username;
  @JsonKey(name: 'firstname')
  final String firstName;
  @JsonKey(name: 'lastname')
  final String lastName;
  // Avatar of user
  final String thumbnail;
  @JsonKey(required: true)
  final List<Company> companies;
  Profile({
    @required this.userId,
    @required this.username,
    @required this.companies,
    this.firstName,
    this.lastName,
    this.thumbnail,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  /// Convenience method to deserialize from String data stored in database
  /// For now it's a pretty straightforward and dumb implementation,
  /// should consider to make it more ergonimic and error proof
  factory Profile.fromJsonText(String jsonText) {
    final map = jsonDecode(jsonText);
    return _$ProfileFromJson(map);
  }

  /// Convenience method to deserialize from String data stored in database
  /// For now it's a pretty straightforward and dumb implementation,
  /// should consider to make it more ergonimic and error proof
  String toJsonText() {
    final map = _$ProfileToJson(this);
    return jsonEncode(map);
  }

  /// Method called before inserting profile into database
  /// sqflite accepts only maps
  Map<String, String> toMap() {
    return {
      'profileJSON': toJsonText(),
    };
  }
}
