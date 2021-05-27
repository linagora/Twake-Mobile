import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SocketIORoom {
  final String key;
  final String type;
  final String id;

  const SocketIORoom({
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
