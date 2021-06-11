import 'package:json_annotation/json_annotation.dart';

enum ChannelsType {
  @JsonValue('directs')
  directs,
  @JsonValue('commons')
  commons,
}
