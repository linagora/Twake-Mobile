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

  @JsonKey(
    defaultValue: false,
    name: 'is_selected',
    fromJson: intToBool,
    toJson: boolToInt,
  )
  bool isSelected;

  Workspace({
    this.id,
    this.companyId,
    this.color,
    this.userLastAccess,
  });

  /// Convenience methods to avoid serializing this class to/from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);

  Map<String, dynamic> toJson() {
    return _$WorkspaceToJson(this);
  }
}
