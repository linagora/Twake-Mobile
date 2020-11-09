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
    sender: json['sender'] as String,
    creationDate: json['creation_date'] as int,
    content: json['content'] == null
        ? null
        : MessageTwacode.fromJson(json['content'] as Map<String, dynamic>),
    reactions: json['reactions'],
    responses: (json['responses'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'responses_count': instance.responsesCount,
      'sender': instance.sender,
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
