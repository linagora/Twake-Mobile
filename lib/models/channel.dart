import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_channel.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends BaseChannel {
  @JsonKey(name: 'workspace_id')
  String workspaceId;
  @JsonKey(name: 'visibility', defaultValue: 'public')
  String visibility;

  Channel({
    this.workspaceId,
    this.visibility,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    if (json['permissions'] is String) {
      json['permissions'] = jsonDecode(json['permissions']);
    }
    if (json['last_message'] is String) {
      json['last_message'] = jsonDecode(json['last_message']);
    }
    return _$ChannelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    var map = _$ChannelToJson(this);
    map['last_message'] = jsonEncode(map['last_message']);
    map['permissions'] = jsonEncode(map['permissions']);
    return map;
  }
}
