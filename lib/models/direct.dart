import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'direct.g.dart';

@JsonSerializable(explicitToJson: true)
class Direct extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  String name;

  @JsonKey(required: true, name: 'company_id')
  final String companyId;

  @JsonKey(required: true)
  List<String> members;

  String icon;

  String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(required: true, name: 'private')
  bool isPrivate;

  @JsonKey(required: true, name: 'last_activity')
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  int messageTotal;

  @JsonKey(required: true, name: 'messages_unread')
  int messageUnread;

  @JsonKey(defaultValue: false)
  bool isSelected;

  Direct({
    this.id,
    this.companyId,
  });

  factory Direct.fromJson(Map<String, dynamic> json) => _$DirectFromJson(json);

  Map<String, dynamic> toJson() => _$DirectToJson(this);
}
