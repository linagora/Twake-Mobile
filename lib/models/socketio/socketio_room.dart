import 'package:json_annotation/json_annotation.dart';

part 'socketio_room.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SocketIORoom {
  final String key;
  final RoomType type;
  final String id;

  @JsonKey(ignore: true)
  bool subscribed = false;

  SocketIORoom({
    required this.key,
    required this.type,
    required this.id,
  });

  factory SocketIORoom.fromJson({required Map<String, dynamic> json}) {
    return _$SocketIORoomFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SocketIORoomToJson(this);
  }
}

enum RoomType {
  @JsonValue('channel')
  channel,
  @JsonValue('direct')
  direct,
  @JsonValue('channels_list')
  channelsList,
  @JsonValue('directs_list')
  directsList,
  @JsonValue('notifications')
  notifications,
}
