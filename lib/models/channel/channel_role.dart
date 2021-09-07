import 'package:json_annotation/json_annotation.dart';

enum ChannelRole {
  @JsonValue('owner')
  owner,

  @JsonValue('member')
  member,

  @JsonValue('guest')
  guest,

  @JsonValue('bot')
  bot,
}
