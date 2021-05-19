import 'package:json_annotation/json_annotation.dart';

enum ChannelVisibility {
  @JsonValue('public')
  Public,

  @JsonValue('private')
  Private,

  @JsonValue('direct')
  Direct,
}
