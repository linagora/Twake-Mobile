import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'channels_type.g.dart';

@HiveType(typeId: TypeConstant.CHANNEL_TYPE)
enum ChannelsType {
  @HiveField(0)
  @JsonValue('directs')
  directs,

  @HiveField(1)
  @JsonValue('commons')
  commons,
}
