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
    sender: json['sender'] == null
        ? null
        : Sender.fromJson(json['sender'] as Map<String, dynamic>),
    creationDate: json['creation_date'] as int,
    content: json['content'] == null
        ? null
        : MessageTwacode.fromJson(json['content'] as Map<String, dynamic>),
  )
    ..isSelected = json['isSelected'] as bool
    ..threadId = json['thread_id'] as String
    ..responsesCount = json['responses_count'] as int
    ..reactions = json['reactions'] as Map<String, dynamic>;
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'isSelected': instance.isSelected,
      'id': instance.id,
      'thread_id': instance.threadId,
      'responses_count': instance.responsesCount,
      'sender': instance.sender?.toJson(),
      'creation_date': instance.creationDate,
      'content': instance.content?.toJson(),
      'reactions': instance.reactions,
    };
