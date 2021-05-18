import 'package:json_annotation/json_annotation.dart';

enum ChannelsType {
  @JsonValue('directs')
  Directs,
  @JsonValue('commons')
  Commons,
}
