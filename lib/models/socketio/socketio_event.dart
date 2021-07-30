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

  // name:
  // previous::channels/2982dc0a-65aa-47ae-a13c-082b2e3cc2a9/messages/updates
  String get channelId => name.split('/').skip(1).first;

  factory SocketIOEvent.fromJson({required Map<String, dynamic> json}) {
    return _$SocketIOEventFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SocketIOEventToJson(this);
  }
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

  String get threadIdNotEmpty => threadId.isEmpty ? messageId : threadId;

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return _$MessageDataFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MessageDataToJson(this);
  }
}

enum IOEventAction {
  @JsonValue('remove')
  remove,
  @JsonValue('update')
  update
}
