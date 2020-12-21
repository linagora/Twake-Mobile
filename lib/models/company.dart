import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

// Model class for a company entity
@JsonSerializable(explicitToJson: true)
class Company extends JsonSerializable {
  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final String name;
  final String logo;
  @JsonKey(required: true)
  @JsonKey(defaultValue: false)
  bool isSelected;

  Company({
    this.id,
    this.name,
    this.logo,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Company.fromJson(Map<String, dynamic> json) {
    return _$CompanyFromJson(json)..isSelected = json['isSelected'] ?? false;
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$CompanyToJson(this);
    map['isSelected'] = isSelected;
    return map;
  }
}
