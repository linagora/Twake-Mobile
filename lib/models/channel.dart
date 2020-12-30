import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/collection_item.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends BaseChannel {
  @JsonKey(name: 'workspace_id')
  String workspaceId;

  Channel({
    this.workspaceId,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    return _$ChannelToJson(this);
  }
}
