import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/services/service_bundle.dart';

part 'badge.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Badge extends BaseModel {
  final BadgeType type;
  final String id;
  int count;

  Badge({
    required this.type,
    required this.id,
    this.count: 0,
  });

  factory Badge.fromJson({required Map<String, dynamic> json}) {
    return _$BadgeFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({bool stringify: false}) {
    return _$BadgeToJson(this);
  }

  bool matches({required BadgeType type, required String id}) {
    return this.type == type && this.id == id && this.count > 0;
  }

  int get hash => type.hashCode + id.hashCode + count;
}

enum BadgeType {
  @JsonValue('company')
  company,
  @JsonValue('workspace')
  workspace,
  @JsonValue('channel')
  channel,
  @JsonValue('none')
  none
}
