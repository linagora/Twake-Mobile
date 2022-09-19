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

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SocketIOWritingEvent {
  final String name;
  final WritingData data;

  const SocketIOWritingEvent({
    required this.name,
    required this.data,
  });

  // name:
  // previous::channels/2982dc0a-65aa-47ae-a13c-082b2e3cc2a9/messages/updates
  String get channelId => name.split('/').skip(1).first;

  factory SocketIOWritingEvent.fromJson({required Map<String, dynamic> json}) {
    return _$SocketIOWritingEventFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SocketIOWritingEventToJson(this);
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

@JsonSerializable(fieldRename: FieldRename.snake)
class WritingData {
  final String type;
  final WritingEvent event;

  const WritingData({
    required this.type,
    required this.event,
  });

  factory WritingData.fromJson(Map<String, dynamic> json) {
    return _$WritingDataFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$WritingDataToJson(this);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WritingEvent {
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'channel_id')
  String channelId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  @JsonKey(name: 'is_writing')
  bool isWriting;

  WritingEvent(
      {required this.threadId,
      required this.channelId,
      required this.name,
      required this.userId,
      required this.isWriting});
  factory WritingEvent.fromJson(Map<String, dynamic> json) {
    return _$WritingEventFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$WritingEventToJson(this);
  }
}

enum IOEventAction {
  @JsonValue('remove')
  remove,
  @JsonValue('update')
  update,
}
