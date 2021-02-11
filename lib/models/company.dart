// import 'dart:convert' show jsonEncode, jsonDecode;
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

  @JsonKey(name: 'total_members', defaultValue: 0)
  final int totalMembers;

  @JsonKey(name: 'is_selected', defaultValue: 0)
  int isSelected;

  // @JsonKey(name: 'notification_rooms')
  // List<String> notificationRooms;

  Company({
    this.id,
    this.name,
    this.logo,
    this.totalMembers,
  }) : super(id);

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Company.fromJson(Map<String, dynamic> json) {
    // json = Map.from(json);
    // if (json['notification_rooms'] is String) {
    //   json['notification_rooms'] = jsonDecode(json['notification_rooms']);
    // }
    return _$CompanyFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$CompanyToJson(this);
    // map['notification_rooms'] = jsonEncode(map['notification_rooms']);
    return map;
  }
}
