import 'package:json_annotation/json_annotation.dart';

part 'workspace.g.dart';

@JsonSerializable()
class Workspace extends JsonSerializable {
  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final String name;
  final String logo;

  @JsonKey(ignore: true)
  bool isSelected = false;

  Workspace({
    this.id,
    this.name,
    this.logo,
  });

  /// Convenience methods to avoid serializing this class to/from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json)..isSelected = json['isSelected'] ?? false;

  Map<String, dynamic> toJson() {
    var map = _$WorkspaceToJson(this);
    map['isSelected'] = isSelected;
    return map;
  }
}
