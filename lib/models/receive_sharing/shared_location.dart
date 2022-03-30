import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
part 'shared_location.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SharedLocation extends BaseModel {
  final int? id;
  final String companyId;
  final String workspaceId;
  final String channelId;

  SharedLocation({
    this.id,
    required this.companyId,
    required this.workspaceId,
    required this.channelId,
  });

  factory SharedLocation.fromJson({required Map<String, dynamic> json}) {
    return _$SharedLocationFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({bool stringify = true}) {
    return _$SharedLocationToJson(this);
  }

}


