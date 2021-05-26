import 'package:json_annotation/json_annotation.dart';

part 'socketio_event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SocketIOEvent {
  final String name;
  final MessageData data;

  const SocketIOEvent({
    required this.name,
    required this.data,
  });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageData {
  final IOEventAction action;
  final String messageId;
  final String threadId;

  const MessageData({
    required this.action,
    required this.messageId,
    required this.threadId,
  });
}

enum IOEventAction {
  @JsonValue('remove')
  remove,
  @JsonValue('update')
  update
}
