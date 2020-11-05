import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final String name;
  final String logo;
  @JsonKey(ignore: true)
  int workspaceCount;

  Company({
    @required this.id,
    @required this.name,
    this.logo,
  });

  /// Convenience methods to avoid serializing this class to/from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Company.fromJson(Map<String, dynamic> json) {
    return _$CompanyFromJson(json)
      ..workspaceCount =
          (json['workspaces'] as List<Map<String, dynamic>>).length;
  }
  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
