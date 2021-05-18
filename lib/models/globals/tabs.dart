import 'package:json_annotation/json_annotation.dart';

enum Tabs {
  @JsonValue('channels')
  Channels,
  @JsonValue('profile')
  Profile,
}
