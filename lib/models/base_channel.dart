import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'base_channel.g.dart';

@JsonSerializable()
class BaseChannel extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  String name;

  String icon;

  String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(required: true, name: 'last_activity')
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  int messagesTotal;

  @JsonKey(required: true, name: 'messages_unread')
  int messagesUnread;

  @JsonKey(
    name: 'is_selected',
    fromJson: intToBool,
    toJson: boolToInt,
  )
  bool isSelected = false;

  BaseChannel({
    this.id,
  });

  factory BaseChannel.fromJson(Map<String, dynamic> json) =>
      _$BaseChannelFromJson(json);

  Map<String, dynamic> toJson() {
    return _$BaseChannelToJson(this);
  }
}
