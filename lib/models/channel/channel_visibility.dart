import 'package:json_annotation/json_annotation.dart';

enum ChannelVisibility {
  @JsonValue('public')
  public,

  @JsonValue('private')
  private,

  @JsonValue('direct')
  direct,
}
