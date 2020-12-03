// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'sender', 'creation_date', 'content']);
  return Message(
    id: json['id'] as String,
    responsesCount: json['responses_count'] as int,
    sender: json['sender'] == null
        ? null
        : Sender.fromJson(json['sender'] as Map<String, dynamic>),
    creationDate: json['creation_date'] as int,
    content: json['content'] == null
        ? null
        : MessageTwacode.fromJson(json['content'] as Map<String, dynamic>),
    reactions: json['reactions'] as Map<String, dynamic>,
    responses: (json['responses'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    parentMessageId: json['parent_message_id'] as String,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'parent_message_id': instance.parentMessageId,
      'responses_count': instance.responsesCount,
      'sender': instance.sender?.toJson(),
      'creation_date': instance.creationDate,
      'content': instance.content?.toJson(),
      'reactions': instance.reactions,
      'responses': instance.responses?.map((e) => e?.toJson())?.toList(),
    };

MessageTwacode _$MessageTwacodeFromJson(Map<String, dynamic> json) {
  return MessageTwacode(
    originalStr: json['original_str'] as String,
    prepared: json['prepared'] as List,
  );
}

Map<String, dynamic> _$MessageTwacodeToJson(MessageTwacode instance) =>
    <String, dynamic>{
      'original_str': instance.originalStr,
      'prepared': instance.prepared,
    };

Sender _$SenderFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['username', 'userId']);
  return Sender(
    username: json['username'] as String,
    thumbnail: json['thumbnail'] as String,
    userId: json['userId'] as String,
    firstName: json['firstname'] as String,
    lastName: json['lastname'] as String,
  );
}

Map<String, dynamic> _$SenderToJson(Sender instance) => <String, dynamic>{
      'username': instance.username,
      'thumbnail': instance.thumbnail,
      'userId': instance.userId,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
    };
