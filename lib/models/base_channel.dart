import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

// part 'base_channel.g.dart';

abstract class BaseChannel extends CollectionItem {
  @JsonKey(required: true, nullable: false)
  String id;

  @JsonKey(required: true)
  String name;

  @JsonKey(defaultValue: ':+1:')
  String icon;

  String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(name: 'last_activity', defaultValue: 0)
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total', defaultValue: 0)
  int messagesTotal;

  @JsonKey(required: true, name: 'messages_unread', defaultValue: 0)
  int messagesUnread;

  @JsonKey(name: 'is_selected', defaultValue: 0)
  int isSelected;

  BaseChannel({
    this.id,
  }) : super(id);
}
