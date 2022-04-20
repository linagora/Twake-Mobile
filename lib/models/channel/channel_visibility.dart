import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'channel_visibility.g.dart';

@HiveType(typeId: TypeConstant.CHANNEL_VISIBILITY)
enum ChannelVisibility {
  @HiveField(0)
  @JsonValue('public')
  public,

  @HiveField(1)
  @JsonValue('private')
  private,

  @HiveField(2)
  @JsonValue('direct')
  direct,
}
