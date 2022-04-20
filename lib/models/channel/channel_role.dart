import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'channel_role.g.dart';

@HiveType(typeId: TypeConstant.CHANNEL_ROLE)
enum ChannelRole {
  @HiveField(0)
  @JsonValue('owner')
  owner,

  @HiveField(1)
  @JsonValue('member')
  member,

  @HiveField(2)
  @JsonValue('guest')
  guest,

  @HiveField(3)
  @JsonValue('bot')
  bot,
}
