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
    return _$ChannelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ChannelToJson(this);
  }
}
