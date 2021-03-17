import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_channel.dart';

part 'direct.g.dart';

@JsonSerializable(explicitToJson: true)
class Direct extends BaseChannel {
  @JsonKey(required: true, name: 'company_id')
  final String companyId;

  @JsonKey(required: true)
  List<String> members;

  Direct({this.companyId, this.members});

  factory Direct.fromJson(Map<String, dynamic> json) {
    if (json['permissions'] is String) {
      json['permissions'] = jsonDecode(json['permissions']);
    }
    if (json['members'] is String) {
      json['members'] = jsonDecode(json['members']);
    }
    if (json['last_message'] is String) {
      json['last_message'] = jsonDecode(json['last_message']);
    }
    return _$DirectFromJson(json);
  }

  Map<String, dynamic> toJson() {
    var map = _$DirectToJson(this);
    map['members'] = jsonEncode(map['members']);
    map['last_message'] = jsonEncode(map['last_message']);
    map['permissions'] = jsonEncode(map['permissions']);
    return map;
  }
}
