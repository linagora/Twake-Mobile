import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'direct.g.dart';

@JsonSerializable(explicitToJson: true)
class Direct extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  String name;

  @JsonKey(required: true, name: 'company_id')
  final String companyId;

  @JsonKey(required: true)
  List<String> members;

  String icon;

  String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(required: true, name: 'last_activity')
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  int messageTotal;

  @JsonKey(required: true, name: 'messages_unread')
  int messageUnread;

  @JsonKey(
    defaultValue: false,
    name: 'is_selected',
    fromJson: intToBool,
    toJson: boolToInt,
  )
  bool isSelected;

  Direct({
    this.id,
    this.companyId,
  });

  factory Direct.fromJson(Map<String, dynamic> json) {
    if (json['members'] is String) {
      json['members'] = jsonDecode(json['members']);
    }
    return _$DirectFromJson(json);
  }

  Map<String, dynamic> toJson() {
    var map = _$DirectToJson(this);
    map['members'] = jsonEncode(map['members']);
    return map;
  }
}
