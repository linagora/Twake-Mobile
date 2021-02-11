// import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'workspace.g.dart';

@JsonSerializable()
class Workspace extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  String name;

  @JsonKey(required: true, name: 'company_id')
  final String companyId;

  final String color;

  String logo;

  @JsonKey(name: 'user_last_access')
  int userLastAccess;

  @JsonKey(name: 'total_members')
  int totalMembers;

  @JsonKey(name: 'is_selected', defaultValue: 0)
  int isSelected;

  // @JsonKey(name: 'notification_rooms')
  // List<String> notificationRooms;

  Workspace({
    this.id,
    this.companyId,
    this.color,
    this.userLastAccess,
  }) : super(id);

  /// Convenience methods to avoid serializing this class to/from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Workspace.fromJson(Map<String, dynamic> json) {
    // json = Map.from(json);
    // if (json['notification_rooms'] is String) {
    // json['notification_rooms'] = jsonDecode(json['notification_rooms']);
    // }
    return _$WorkspaceFromJson(json);
  }

  Map<String, dynamic> toJson() {
    var map = _$WorkspaceToJson(this);
    // map['notification_rooms'] = jsonEncode(map['notification_rooms']);
    return map;
  }
}
