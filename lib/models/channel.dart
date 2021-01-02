import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/collection_item.dart';
import 'package:twake/services/service_bundle.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends BaseChannel {
  @JsonKey(name: 'workspace_id')
  String workspaceId;

  Channel({
    this.workspaceId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    Logger().d('CONVERTING CHANNEL: $json');
    return _$ChannelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    Logger().d('CONVERTING CHANNEL TO JSON: $id');
    return _$ChannelToJson(this);
  }
}
