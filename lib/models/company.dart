import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'company.g.dart';

// Model class for a company entity
@JsonSerializable(explicitToJson: true)
class Company extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final String name;

  final String logo;

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
    return _$CompanyFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$CompanyToJson(this);
    return map;
  }
}
